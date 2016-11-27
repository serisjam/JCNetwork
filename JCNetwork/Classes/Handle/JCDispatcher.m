//
//  JCDispatcher.m
//  JCNetworkNew
//
//  Created by Jam on 13-6-21.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCDispatcher.h"
#import "JCCacheResponedDispatcher.h"

@implementation JCDispatcher

@synthesize serviceDict = _serviceDict;

+ (id)sharedInstance {
    static dispatch_once_t pred;
    static JCDispatcher *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[JCDispatcher alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#pragma mark - Handle dispatch

- (void)addGetDispatchItem:(DispatchElement *)item {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [item.request requestSerializer];
    manager.requestSerializer.timeoutInterval = item.request.timeoutInterval;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [self cancelRequest:item.requestID];
    
    if ([self haveCacheResponedWithDispatchElement:item]) {
        return ;
    }
    
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [manager GET:item.request.URLString parameters:item.request.paramsDic progress:nil success:^(NSURLSessionDataTask *task, id responseObject){
        [weakSelf requestFinished:responseObject withDispatchElement:item];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf requestFailed:error withDispatchElement:item];
    }];
    
    [_dispatchTable setObject:task forKey:[NSNumber numberWithInt:item.requestID]];
}

- (void)addPostDispatchItem:(DispatchElement *)item {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [item.request requestSerializer];
    manager.requestSerializer.timeoutInterval = item.request.timeoutInterval;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [self cancelRequest:item.requestID];
    
    if ([self haveCacheResponedWithDispatchElement:item]) {
        return ;
    }
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [manager POST:item.request.URLString parameters:item.request.paramsDic progress:nil success:^(NSURLSessionDataTask *task, id responseObject){
        [weakSelf requestFinished:responseObject withDispatchElement:item];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf requestFailed:error withDispatchElement:item];
    }];
    
    [_dispatchTable setObject:task forKey:[NSNumber numberWithInt:item.requestID]];
}

- (void)addDispatchUploadItem:(DispatchElement *)item withFiles:(NSDictionary *)files {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [item.request requestSerializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [self cancelRequest:item.requestID];
    
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [manager POST:item.request.URLString parameters:item.request.paramsDic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSString *key in [files allKeys]) {
            [formData appendPartWithFileData:[files objectForKey:key] name:key fileName:key mimeType:@"application/octet-stream"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [weakSelf requestFinished:responseObject withDispatchElement:item];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf requestFailed:error withDispatchElement:item];
    }];
    [_dispatchTable setObject:task forKey:[NSNumber numberWithInt:item.requestID]];
}


- (void)cancelRequest:(JCRequestID)requestID {
    NSURLSessionDataTask *task = [_dispatchTable objectForKey:[NSNumber numberWithInt:requestID]];
    if (task) {
        // remove dispatch item from dispatch table
        [_dispatchTable removeObjectForKey:[NSNumber numberWithInt:requestID]];
        [task cancel];
    }
}

- (void)cancelAllRequest {
    for (NSNumber *requestNumber in [_dispatchTable allKeys]) {
        [self cancelRequest:[requestNumber intValue]];
    }
}

#pragma mark - Handle requests

- (void)dispatchResponse:(JCNetworkResponse *)response forElement:(DispatchElement *)element {
    
    JCRequestID requestID = [element requestID];
    
    if (element.responseBlock) {
        element.responseBlock(response);
    }
    
    // remove dispatch item from dispatch table
    [_dispatchTable removeObjectForKey:[NSNumber numberWithInt:requestID]];
}

#pragma mark - Handle CacheResponed

//缓存是否有效
- (BOOL)haveCacheResponedWithDispatchElement:(DispatchElement *)element {
    
    JCCacheResponed *cacheResponed = [[JCCacheResponedDispatcher sharedInstance] getCacheResponedWithKey:element.request.cacheKey];
    
    if (!cacheResponed) {
        return NO;
    }
    
    if (element.request.cachePolicy == JCNetWorkReturnCacheDataElseLoad) {
        [self handleRequestFinished:cacheResponed.responedDic withDispatchElement:element];
        return YES;
    }
    
    //JCNetWorkReturnCacheDataReLoad策略判断是否成功
    NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
    if (currentTimeInterval - cacheResponed.timeInterval >= element.request.cacheRefreshTimeInterval) {
        return NO;
    }
    [self handleRequestFinished:cacheResponed.responedDic withDispatchElement:element];
    return YES;
}

#pragma mark - Handle responses

- (void)requestFinished:(id)responseObject withDispatchElement:(DispatchElement *)element {
    
    JCNetworkResponse *response = [[JCNetworkResponse alloc] init];
    [response setRequestID:element.requestID];
    response.progress = 1.0;
    
    NSError *error = nil;
    
    id returnValue = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
    if(!returnValue) {
        [self requestFailed:error withDispatchElement:element];
        return ;
    }
    
    if (element.request.cachePolicy == JCNetWorkReturnCacheDataElseLoad || element.request.cachePolicy == JCNetWorkReturnCacheDataReLoad ) {
        [[JCCacheResponedDispatcher sharedInstance] saveCacheResponed:returnValue forKey:element.request.cacheKey];
    }
    
    if ([element entityClassName] != nil) {
        Class cls = NSClassFromString(element.entityClassName);
        NSObject *responsed = [cls yy_modelWithDictionary:returnValue];
        [response setContent:responsed];
    } else {
        [response setContent:returnValue];
    }
    
    [response setStatus:JCNetworkResponseStatusSuccess];
    [self dispatchResponse:response forElement:element];
}

- (void)handleRequestFinished:(NSDictionary *)responedDic withDispatchElement:(DispatchElement *)element {
    
    JCNetworkResponse *response = [[JCNetworkResponse alloc] init];
    [response setRequestID:element.requestID];
    response.progress = 1.0;
    
    if ([element entityClassName] != nil) {
        Class cls = NSClassFromString(element.entityClassName);
        NSObject *responsed = [cls yy_modelWithDictionary:responedDic];
        [response setContent:responsed];
    } else {
        [response setContent:responedDic];
    }
    
    [response setStatus:JCNetworkResponseStatusSuccess];
    [self dispatchResponse:response forElement:element];
}



- (void)requestFailed:(NSError *)error withDispatchElement:(DispatchElement *)element {
    
    JCNetworkResponse *response = [[JCNetworkResponse alloc] init];
    [response setRequestID:element.requestID];
    [response setError:error];
    [response setContent:nil];
    
    [response setStatus:JCNetworkResponseStatusFailed];
    [self dispatchResponse:response forElement:element];
}

@end
