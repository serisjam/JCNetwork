//
//  JCRequester.m
//  JCNetworkNew
//
//  Created by Jam on 13-6-20.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCRequester.h"
#import "DispatchElement.h"

@implementation JCRequester

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static JCRequester *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[JCRequester alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _dispatcher = [JCDispatcher sharedInstance];
        _serviceDict = [[JCDispatcher sharedInstance] serviceDict];
        _servicesRequestEngine = [[NSMutableDictionary alloc] initWithCapacity:[SERVICES count]];
        
        _lastRequestID = JC_MIN_REQUESTID;
    }
    
    return self;
}

- (void)autoLoadImageWithURL:(NSURL *)imageURL placeHolderImage:(UIImage *)image toImageView:(UIImageView *)imageView
{
    if ([[_servicesRequestEngine allKeys] indexOfObject:[NSNumber numberWithInt:JCImageServiceID]] == NSNotFound) {
        [_servicesRequestEngine setObject:[_dispatcher createRequestQueueWith:[_serviceDict objectForKey:[NSNumber numberWithInt:JCImageServiceID]]] forKey:[NSNumber numberWithInt:JCImageServiceID]];
    }
    MKNetworkEngine *engine = [_servicesRequestEngine objectForKey:[NSNumber numberWithInt:JCImageServiceID]];
    
    [UIImageView setDefaultEngine:engine];
    [imageView setImageFromURL:imageURL placeHolderImage:image];
}

- (JCRequestID)httpGetRquest:(NSString *)path service:(JCServiceType)serviceID params:(NSDictionary *)params target:(id)target action:(SEL)action
{
    if (++_lastRequestID >= JC_MAX_REQUESTID) {
        _lastRequestID = JC_MIN_REQUESTID;
    }
    
    //get different products MKNetworkEngine queue
    if ([[_servicesRequestEngine allKeys] indexOfObject:[NSNumber numberWithInt:serviceID]] == NSNotFound) {
            [_servicesRequestEngine setObject:[_dispatcher createRequestQueueWith:[_serviceDict objectForKey:[NSNumber numberWithInt:serviceID]]] forKey:[NSNumber numberWithInt:serviceID]];
    }
    MKNetworkEngine *engine = [_servicesRequestEngine objectForKey:[NSNumber numberWithInt:serviceID]];
    MKNetworkOperation *op = [engine operationWithPath:path params:params httpMethod:@"GET"];
    
    DispatchElement *element = [[DispatchElement alloc] init];
    [element setRequestID:_lastRequestID];
    [element setTarget:target];
    [element setCallback:action];
    [element setServiceID:serviceID];
    [element setOperation:op];
    
    [_dispatcher addDispatchItem:element];
    [engine enqueueOperation:op];
    DLog(@"%@", [op url]);
    return _lastRequestID;
}

- (JCRequestID)httpPostRquest:(NSString *)path service:(JCServiceType)serviceID params:(NSDictionary *)params target:(id)target action:(SEL)action
{
    if (++_lastRequestID >= JC_MAX_REQUESTID) {
        _lastRequestID = JC_MIN_REQUESTID;
    }
    
    //get different products MKNetworkEngine queue
    if ([[_servicesRequestEngine allKeys] indexOfObject:[NSNumber numberWithInt:serviceID]] == NSNotFound) {
        [_servicesRequestEngine setObject:[_dispatcher createRequestQueueWith:[_serviceDict objectForKey:[NSNumber numberWithInt:serviceID]]] forKey:[NSNumber numberWithInt:serviceID]];
    }
    MKNetworkEngine *engine = [_servicesRequestEngine objectForKey:[NSNumber numberWithInt:serviceID]];
    MKNetworkOperation *op = [engine operationWithPath:path params:params httpMethod:@"POST"];
    
    DispatchElement *element = [[DispatchElement alloc] init];
    [element setRequestID:_lastRequestID];
    [element setTarget:target];
    [element setCallback:action];
    [element setServiceID:serviceID];
    [element setOperation:op];
    [_dispatcher addDispatchItem:element];
    [engine enqueueOperation:op];
    DLog(@"%@", [op url]);
    return _lastRequestID;
}

- (JCRequestID)httpPost:(NSString *)path params:(NSDictionary *)params files:(NSDictionary *)files serivce:(JCServiceType)serviceID target:(id)target action:(SEL)action
{
    if (++_lastRequestID >= JC_MAX_REQUESTID) {
        _lastRequestID = JC_MIN_REQUESTID;
    }
    
    //get different products MKNetworkEngine queue
    if ([[_servicesRequestEngine allKeys] indexOfObject:[NSNumber numberWithInt:serviceID]] == NSNotFound) {
        [_servicesRequestEngine setObject:[_dispatcher createRequestQueueWith:[_serviceDict objectForKey:[NSNumber numberWithInt:serviceID]]] forKey:[NSNumber numberWithInt:serviceID]];
    }
    
    MKNetworkEngine *engine = [_servicesRequestEngine objectForKey:[NSNumber numberWithInt:serviceID]];
    MKNetworkOperation *op = [engine operationWithPath:path params:params httpMethod:@"POST"];
    
    NSArray *keys = [files allKeys];
    for (NSString *item in keys) {
        [op addFile:[files objectForKey:item] forKey:item];
    }
    
    DispatchElement *element = [[DispatchElement alloc] init];
    [element setRequestID:_lastRequestID];
    [element setTarget:target];
    [element setCallback:action];
    [element setServiceID:serviceID];
    [element setOperation:op];
    [_dispatcher addDispatchItem:element];
    [engine enqueueOperation:op];
    DLog(@"%@", [op url]);
    return _lastRequestID;
}

- (void)cancelRequest:(JCRequestID)requestID
{
    [_dispatcher cancelRequest:requestID];
}

- (BOOL)isInternetAvailiable {
    return [[Reachability reachabilityForInternetConnection] isReachable];
}

- (BOOL)isWiFiAvailiable {
    return [[Reachability reachabilityForInternetConnection] isReachableViaWiFi];
}

- (NSString *)getNetworkStatus {
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN)
        return @"2G3G";
    else if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWiFi)
        return @"WiFi";
    else
        return @"";
}

@end
