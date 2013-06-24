//
//  JCDispatcher.m
//  JCNetworkNew
//
//  Created by Jam on 13-6-21.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCDispatcher.h"

@implementation JCDispatcher

@synthesize servicesRequestEngine = _servicesRequestEngine;
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
        _servicesRequestEngine = [[NSMutableDictionary alloc] initWithCapacity:[SERVICES count]];
        
        for (id serviceName in SERVICES) {
            id service = [[NSClassFromString((NSString *)serviceName) alloc] init];
            if (!service)
                continue;
            [_serviceDict setObject:service forKey:[NSNumber numberWithInt:[service serviceID]]];
            //add products class and httprequest Queue
            [_servicesRequestEngine setObject:[self createRequestQueueWith:service] forKey:[NSNumber numberWithInt:[service serviceID]]];
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

    [operation addCompletionHandler:^(MKNetworkOperation* completedOperation){
        DLog(@"commplete finish");
        [_dispatchTable setObject:item forKey:[NSNumber numberWithInt:requestID]];
        JCOperationResponse *operationResponse = [[JCOperationResponse alloc] init];
        [operationResponse setOperation:completedOperation];
        [operationResponse setRequestID:requestID];
        [self requestFinished:operationResponse];
    } errorHandler:^(MKNetworkOperation* completedOperation, NSError* error){
        DLog(@"commplete failed");
        [_dispatchTable setObject:item forKey:[NSNumber numberWithInt:requestID]];
        JCOperationResponse *operationResponse = [[JCOperationResponse alloc] init];
        [operationResponse setOperation:completedOperation];
        [operationResponse setRequestID:requestID];
        [self requestFailed:operationResponse withError:error];
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
