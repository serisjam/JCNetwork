//
//  JCRequestProxy.m
//  JCNetwork
//
//  Created by Jam on 13-6-23.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCRequestProxy.h"
#import "JCRequester.h"
#import "JCDispatcher.h"

@implementation JCRequestProxy
+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static JCRequestProxy *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[JCRequestProxy alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _requester = [JCRequester sharedInstance];
        _serviceDict = [[JCDispatcher sharedInstance] serviceDict];
    }
    
    return self;
}

#pragma mark - Requests
- (JCRequestID)httpGetWithServiceID:(JCServiceType)serviceID methodName:(NSString *)methodName params:(NSDictionary *)params target:(id)target action:(SEL)action
{
    
    if (params && ![params isKindOfClass:[NSDictionary class]]) {
        return JC_ERROR_REQUESTID;
    }
    
    id service = [_serviceDict objectForKey:[NSNumber numberWithInt:serviceID]];
    
    if ([[service getAllMethods] indexOfObject:methodName] == NSNotFound) {
        return JC_ERROR_REQUESTID;
    }
    
    return [_requester httpGetRquest:[service buildPathWithMethod:methodName] service:serviceID params:params target:target action:action];
}

- (JCRequestID)httpPostWithServiceID:(JCServiceType)serviceID methodName:(NSString *)methodName params:(NSDictionary *)params target:(id)target action:(SEL)action
{
    if (params && ![params isKindOfClass:[NSDictionary class]]) {
        return JC_ERROR_REQUESTID;
    }
    
    id service = [_serviceDict objectForKey:[NSNumber numberWithInt:serviceID]];
    
    if ([[service getAllMethods] indexOfObject:methodName] == NSNotFound) {
        return JC_ERROR_REQUESTID;
    }
    
    return [_requester httpPostRquest:[service buildPathWithMethod:methodName] service:serviceID params:params target:target action:action];
}

- (void)cancelRequest:(JCRequestID)requestID
{
    [_requester cancelRequest:requestID];
}

#pragma mark SetApi
- (void)setApiName:(NSString *)apiName forService:(JCServiceType)serviceID
{
    if (!apiName || [apiName length] == 0)
        return;
    
    [[_serviceDict objectForKey:[NSNumber numberWithInt:serviceID]] setApiName:apiName];
}

- (void)setApiVersion:(NSString *)apiVersion forService:(JCServiceType)serviceID
{
    if (!apiVersion || [apiVersion length] == 0) {
        return;
    }
    [[_serviceDict objectForKey:[NSNumber numberWithInt:serviceID]] setApiVersion:apiVersion];
}

#pragma mark getNeworkStatus
- (NSString *)getNetworkStatus
{
    return [_requester getNetworkStatus];
}

@end
