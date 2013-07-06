//
//  JCDispatcher.m
//  JCNetworkNew
//
//  Created by Jam on 13-6-21.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCDispatcher.h"

@implementation JCDispatcher

@synthesize serviceDict = _serviceDict;

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static JCDispatcher *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[JCDispatcher alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
        _serviceDict = [[NSMutableDictionary alloc] initWithCapacity:[SERVICES count]];
        _timeoutDict = [[NSMutableDictionary alloc] init];
        
        for (id serviceName in SERVICES) {
            id service = [[NSClassFromString((NSString *)serviceName) alloc] init];
            if (!service)
                continue;
            [_serviceDict setObject:service forKey:[NSNumber numberWithInt:[service serviceID]]];
        }
    }
    
    return self;
}

#pragma mark - Handle requests
- (void)addDispatchItem:(DispatchElement *)item
{
    JCRequestID requestID = [item requestID];
    MKNetworkOperation *operation = [item operation];
    
    [self cancelRequest:requestID];
    //如果是POST开启计时器超时操作
    if ([operation.HTTPMethod isEqualToString:@"POST"]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:item forKey:@"item"];
        NSTimer *timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:kMKNetworkKitRequestTimeOutInSeconds * 1.2 target:self selector:@selector(HandleTimeOut:) userInfo:dic repeats:NO];
        [_timeoutDict setObject:timeOutTimer forKey:[NSNumber numberWithInt:requestID]];
    }
    
    [operation addCompletionHandler:^(MKNetworkOperation* completedOperation){
        DLog(@"commplete finish");
        NSTimer *timer = [_timeoutDict objectForKey:[NSNumber numberWithInt:requestID]];
        if (!timer) {
            return ;
        }
        [timer invalidate];

        JCOperationResponse *operationResponse = [[JCOperationResponse alloc] init];
        [operationResponse setOperation:completedOperation];
        [operationResponse setRequestID:requestID];
        [self requestFinished:operationResponse];
    } errorHandler:^(MKNetworkOperation* completedOperation, NSError* error){
        DLog(@"commplete failed");
        NSTimer *timer = [_timeoutDict objectForKey:[NSNumber numberWithInt:requestID]];
        if (!timer) {
            return ;
        }
        [timer invalidate];
        
        JCOperationResponse *operationResponse = [[JCOperationResponse alloc] init];
        [operationResponse setOperation:completedOperation];
        [operationResponse setRequestID:requestID];
        [self requestFailed:operationResponse withError:error];
    }];
    [_dispatchTable setObject:item forKey:[NSNumber numberWithInt:requestID]];
}

- (DispatchElement *)getDispatchElement:(JCRequestID)requestID
{
    id dispatchOperation = [_dispatchTable objectForKey:[NSNumber numberWithInt:requestID]];
    
    if (dispatchOperation) {
        return dispatchOperation;
    }
    return nil;
}

- (void)onUploadDispatchItem:(DispatchElement *)item
{
    id target = [item target];
    SEL callback = [item callback];
    [[item operation] onUploadProgressChanged:^(double progress){
        [target performSelector:callback withObject:[NSNumber numberWithFloat:progress]];
    }];
}

- (void)onDownloadDispatchItem:(DispatchElement *)item
{
    id target = [item target];
    SEL callback = [item callback];
    [[item operation] onDownloadProgressChanged:^(double progress){
        [target performSelector:callback withObject:[NSNumber numberWithFloat:progress]];
    }];
}

- (void)cancelRequest:(JCRequestID)requestID
{
    id dispatchOperation = [_dispatchTable objectForKey:[NSNumber numberWithInt:requestID]];
    
    if (dispatchOperation) {
        [MKNetworkEngine cancelOperationsMatchingBlock:^BOOL (MKNetworkOperation* op){
            return YES;
        }];
    }
}
#pragma mark - Handle TimeOut

- (void)HandleTimeOut:(NSTimer*)timer
{
    DispatchElement *item = [[timer userInfo] objectForKey:@"item"];
    JCRequestID requestID = [item requestID];
    MKNetworkOperation *operation = [item operation];
    
    JCOperationResponse *operationResponse = [[JCOperationResponse alloc] init];
    [operationResponse setOperation:operation];
    [operationResponse setRequestID:requestID];
    NSError *error = [NSError errorWithDomain:@"request time out" code:-1001 userInfo:nil];
    [self requestFailed:operationResponse withError:error];
    
    [timer invalidate];
    [_timeoutDict removeObjectForKey:[NSNumber numberWithInt:requestID]];
}

#pragma mark - Handle responses

- (void)requestFinished:(JCOperationResponse *)operationResponse
{
    id element = [_dispatchTable objectForKey:[NSNumber numberWithInt:[operationResponse requestID]]];
    if (!element)
        return;
    
    // Use when fetching text data
    NSDictionary *responseDict = [[operationResponse operation] responseJSON];
    //DLog(@"%@", [[operationResponse operation] responseJSON]);
    
    JCNetworkResponse *response = [[JCNetworkResponse alloc] init];
    [response setRequestID:[element requestID]];
    
    if ([element serviceID] == JCDownLoadServiceID) {
        responseDict = [NSDictionary dictionaryWithObjectsAndKeys:@"download file success", @"message", nil];
    }
    [response setContent:responseDict];
    [response setStatus:JCNetworkResponseStatusSuccess];
  
    [self dispatchResponse:response forElement:element];
}

- (void)requestFailed:(JCOperationResponse *)operationResponse withError:(NSError *)error
{
    
    id element = [_dispatchTable objectForKey:[NSNumber numberWithInt:[operationResponse requestID]]];
    if (!element)
        return;
    
    JCNetworkResponse *response = [[JCNetworkResponse alloc] init];
    [response setRequestID:[element requestID]];
    [response setContent:[NSDictionary dictionaryWithObjectsAndKeys:error, @"ERROR", nil]];
    [response setStatus:JCNetworkResponseStatusFailed];
    [response setError:error];
    
    [self dispatchResponse:response forElement:element];
}

- (void)dispatchResponse:(JCNetworkResponse *)response forElement:(DispatchElement *)element
{
    JCRequestID requestID = [element requestID];
    id target = [element target];
    SEL callback = [element callback];
    
    if (target && [target respondsToSelector:callback]) {
		[target performSelector:callback withObject:response];
	}
    
    // remove dispatch item from dispatch table
    [_dispatchTable removeObjectForKey:[NSNumber numberWithInt:requestID]];
}

//factory method returen different products request queue
- (MKNetworkEngine *)createRequestQueueWith:(JCBaseService *)service
{
    if (service) {
        MKNetworkEngine *JCengine = [[MKNetworkEngine alloc] initWithHostName:[service hostName]];
        // use Cache 
        [JCengine useCache];
        return JCengine;
    }
    
    return nil;
}

@end
