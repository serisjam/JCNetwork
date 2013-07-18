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
#pragma mark request Get
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

#pragma mark request Post
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

#pragma mark autoloadimage
- (void)autoLoadImageWithURL:(NSURL *)imageURL placeHolderImage:(UIImage *)image toImageView:(UIImageView *)imageView
{
    [_requester autoLoadImageWithURL:imageURL placeHolderImage:image toImageView:imageView];
}

- (void)emptyImageCache
{
    
}

#pragma mark upload
- (JCRequestID)uploadFileWithServiceID:(JCServiceType)serviceID methodName:(NSString *)methodName params:(NSDictionary *)params files:(NSDictionary *)files target:(id)target action:(SEL)action
{
    if (params && ![params isKindOfClass:[NSDictionary class]]) {
        return JC_ERROR_REQUESTID;
    }
    
    id service = [_serviceDict objectForKey:[NSNumber numberWithInt:serviceID]];
    
    if ([[service getAllMethods] indexOfObject:methodName] == NSNotFound) {
        return JC_ERROR_REQUESTID;
    }
    
    return [_requester httpPost:[service buildPathWithMethod:methodName] params:params files:files serivce:serviceID target:target action:action];
}

- (void)onUploadProgressChanged:(JCRequestID)requestID target:(id)target action:(SEL)action
{
    [_requester onUploadProgressChanged:requestID target:target action:action];
}

#pragma mark download
- (JCRequestID)downloadFileFrom:(NSString *)remoteURL toFile:(NSString *)filePath target:(id)target action:(SEL)action
{
    return [_requester httpGet:remoteURL toFile:filePath target:target action:action];
}

- (void)onDownloadProgressChanged:(JCRequestID)requestID target:(id)target action:(SEL)action
{
    [_requester onDownloadProgressChanged:requestID target:target action:action];
}

- (void)cancelRequestID:(JCRequestID)requestID
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
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN)
        return @"2G3G";
    else if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWiFi)
        return @"WiFi";
    else
        return @"";
}

- (NSString *)reachabilityWithHostname:(NSString*)hostname
{
    NetworkStatus netStatus = [[Reachability reachabilityWithHostname:hostname] currentReachabilityStatus];
    
    if (netStatus == ReachableViaWiFi) {
        return @"WiFi";
    } else if (netStatus == ReachableViaWWAN) {
        return @"2G3G";
    } else {
        return @"";
    }
}

- (BOOL)isInternetAvailiable {
    return [[Reachability reachabilityForInternetConnection] isReachable];
}

- (BOOL)isWiFiAvailiable {
    return [[Reachability reachabilityForInternetConnection] isReachableViaWiFi];
}

@end
