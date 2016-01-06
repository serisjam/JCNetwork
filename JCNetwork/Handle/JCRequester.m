//
//  JCRequester.m
//  JCNetworkNew
//
//  Created by Jam on 13-6-20.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCRequester.h"
#import "DispatchElement.h"
#import "MKNetworkRequest+JCNetwork.h"
#import "UIImageView+MKNKAdditions.h"

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
        _requestEngines = [[NSMutableDictionary alloc] init];
        _dispatcher = [JCDispatcher sharedInstance];
        _lastRequestID = JC_MIN_REQUESTID;
    }
    
    return self;
}

#pragma mark request block

- (JCRequestID)httpGetWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withCompleteBlock:(JCNetworkResponseBlock)responedBlock {
    if (++_lastRequestID >= JC_MAX_REQUESTID) {
        _lastRequestID = JC_MIN_REQUESTID;
    }
    
    MKNetworkHost *hostEngine = [self getNetworkHostEngineWithRequest:requestObj];
    MKNetworkRequest *hostRequest = [self createRequesWithRequest:requestObj andHostEngine:hostEngine httpMethod:@"GET"];
    
    [self addDispatchElementWithCompleteBlock:responedBlock withHostRequest:hostRequest entityClass:entityName withHostName:requestObj.hostName];
    
    [hostEngine startRequest:hostRequest];
    
    return _lastRequestID;
}

- (JCRequestID)httpPostWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withCompleteBlock:(JCNetworkResponseBlock)responedBlock {
    if (++_lastRequestID >= JC_MAX_REQUESTID) {
        _lastRequestID = JC_MIN_REQUESTID;
    }
    
    MKNetworkHost *hostEngine = [self getNetworkHostEngineWithRequest:requestObj];
    MKNetworkRequest *hostRequest = [self createRequesWithRequest:requestObj andHostEngine:hostEngine httpMethod:@"POST"];
    
    [self addDispatchElementWithCompleteBlock:responedBlock withHostRequest:hostRequest entityClass:entityName withHostName:requestObj.hostName];
    
    [hostEngine startRequest:hostRequest];
    
    return _lastRequestID;
}

#pragma mark upload request
- (JCRequestID)httpPostFile:(JCRequestObj *)requestObj files:(NSDictionary *)files entityClass:(NSString *)entityName withUpLoadBlock:(JCNetworkResponseBlock)upLoadBlock {
    if (++_lastRequestID >= JC_MAX_REQUESTID) {
        _lastRequestID = JC_MIN_REQUESTID;
    }
    
    MKNetworkHost *hostEngine = [self getNetworkHostEngineWithRequest:requestObj];
    MKNetworkRequest *hostRequest = [self createRequesWithRequest:requestObj andHostEngine:hostEngine httpMethod:@"POST"];
    NSArray *keys = [files allKeys];
    for (NSString *item in keys) {
        [hostRequest attachFile:[files objectForKey:item] forKey:item mimeType:@"application/octet-stream"];
    }
    
    [hostRequest setRequestID:_lastRequestID];
    DispatchElement *element = [[DispatchElement alloc] init];
    element.requestID = _lastRequestID;
    element.responseBlock = upLoadBlock;
    element.hostName = requestObj.hostName;
    element.entityClassName = entityName;
    element.request = hostRequest;
    [_dispatcher addDispatchUploadItem:element];
    
    [hostEngine startUploadRequest:hostRequest];
    
    return _lastRequestID;
}

#pragma mark download request
- (JCRequestID)downloadFileFrom:(NSURL *)remoteURL toFile:(NSString*)filePath withDownLoadBlock:(JCNetworkResponseBlock)responedBlock {
    if (++_lastRequestID >= JC_MAX_REQUESTID) {
        _lastRequestID = JC_MIN_REQUESTID;
    }
    
    MKNetworkHost *hostEngine = [self getNetworkHostEngineWithRequestURL:remoteURL];
    MKNetworkRequest *hostRequest = [hostEngine requestWithURLString:[remoteURL absoluteString]];
    
    [hostRequest setRequestID:_lastRequestID];
    [hostRequest setDownloadPath:filePath];
    
    DispatchElement *element = [[DispatchElement alloc] init];
    element.requestID = _lastRequestID;
    element.responseBlock = responedBlock;
    element.hostName = remoteURL.host;
    element.entityClassName = nil;
    element.request = hostRequest;
    [_dispatcher addDispatchDownloadItem:element];
    
    [hostEngine startDownloadRequest:hostRequest];
    
    return _lastRequestID;
}

//image request
- (void)autoLoadImageWithURL:(NSURL *)imageURL placeHolderImage:(UIImage*)image toImageView:(UIImageView *)imageView {
    
    if ([[_requestEngines allKeys] indexOfObject:@"image"] == NSNotFound) {
        [_requestEngines setObject:[[MKNetworkHost alloc] init] forKey:@"image"];
    }
    
    MKNetworkHost *hostEngine = [_requestEngines objectForKey:@"image"];
    [UIImageView changeImageHostEngine:hostEngine];
    
    if (image) {
        imageView.image = image;
        
        [imageView loadImageFromURLString:imageURL.absoluteString placeHolderImage:image animated:YES];
        return ;
    }
    
    [imageView loadImageFromURLString:imageURL.absoluteString];
}

- (void)loadImageWithURL:(NSURL *)imageURL size:(CGSize)size completionHandler:(JCNetworkImageFetch)imageFetchBlock {
    if ([[_requestEngines allKeys] indexOfObject:@"image"] == NSNotFound) {
        MKNetworkHost *engineNetwork = [[MKNetworkHost alloc] init];
        [engineNetwork enableCache];
        [_requestEngines setObject:engineNetwork forKey:@"image"];
    }
    
    MKNetworkHost *hostEngine = [_requestEngines objectForKey:@"image"];
    MKNetworkRequest *hostRequest = [hostEngine requestWithURLString:imageURL.absoluteString];
    hostRequest.alwaysCache = YES;
    
    [hostRequest addCompletionHandler:^(MKNetworkRequest* completedRequest){
        if(completedRequest.responseAvailable) {
            UIImage *decompressedImage;
            if (CGSizeEqualToSize(size, CGSizeZero)) {
                decompressedImage = [completedRequest responseAsImage];
            } else {
               decompressedImage = [completedRequest decompressedResponseImageOfSize:size];
            }
            imageFetchBlock(decompressedImage, completedRequest.isCachedResponse);
            return ;
        }
        
        if (completedRequest.state == MKNKRequestStateError) {
            imageFetchBlock(nil, NO);
        }
    }];
    [hostEngine startRequest:hostRequest];
}

- (UIImage *)getImageIfExisted:(NSURL *)imageURL {
    if ([[_requestEngines allKeys] indexOfObject:@"image"] == NSNotFound) {
        MKNetworkHost *engineNetwork = [[MKNetworkHost alloc] init];
        [engineNetwork enableCache];
        [_requestEngines setObject:engineNetwork forKey:@"image"];
    }
    
    MKNetworkHost *hostEngine = [_requestEngines objectForKey:@"image"];
    MKNetworkRequest *hostRequest = [hostEngine requestWithURLString:imageURL.absoluteString];
    
    NSData *cacheData = [hostEngine getCacheDataWithRequest:hostRequest];
    
    if (cacheData) {
        static CGFloat scale = 2.0f;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            scale = [UIScreen mainScreen].scale;
        });
        return [UIImage imageWithData:cacheData scale:scale];
    }
    
    return nil;
}

#pragma cancelRequest

- (void)cancelRequest:(JCRequestID)requestID {
    [_dispatcher cancelRequest:requestID];
}

#pragma mark createRequestWithEngine

- (MKNetworkRequest *)createRequesWithRequest:(JCRequestObj *)requestObj andHostEngine:(MKNetworkHost *)hostEngine httpMethod:(NSString *)method {
    
    MKNetworkRequest *request = [hostEngine requestWithPath:requestObj.path params:[self bulidRequestParamsWithRequest:requestObj] httpMethod:method];
    
    [request addHeaders:requestObj.headerDictionary];
    request.alwaysCache = requestObj.alwaysCache;
    request.alwaysLoad = requestObj.alwaysLoad;
    request.ignoreCache = requestObj.ignoreCache;
    request.doNotCache = requestObj.doNotCache;
    
    switch (requestObj.parameterType) {
        case JCNetworkParameterTypeURL:
            request.parameterEncoding = 0;
            break;
        case JCNetworkParameterTypeJSON:
            request.parameterEncoding = 1;
            break;
        case JCNetworkParameterTypelist:
            request.parameterEncoding = 2;
            break;
        default:
            break;
    }
    
    return request;
}

#pragma mark AddElement to Dispatch

- (void)addDispatchElementWithCompleteBlock:(JCNetworkResponseBlock)responedBlock withHostRequest:(MKNetworkRequest *)hostRequest entityClass:(NSString *)entityName withHostName:(NSString *)hostName {
    
    [hostRequest setRequestID:_lastRequestID];
    DispatchElement *element = [[DispatchElement alloc] init];
    element.requestID = _lastRequestID;
    element.responseBlock = responedBlock;
    element.hostName = hostName;
    element.entityClassName = entityName;
    element.request = hostRequest;
    [_dispatcher addDispatchItem:element];
    
}

#pragma mark get MKNetworkEngine queue

- (MKNetworkHost *)getNetworkHostEngineWithRequest:(JCRequestObj *)requestObj {
    //get different products MKNetworkEngine queue
    if ([[_requestEngines allKeys] indexOfObject:[requestObj hostName]] == NSNotFound) {
        [_requestEngines setObject:[_dispatcher createHostEngineWithRequestHostName:requestObj.hostName] forKey:[requestObj hostName]];
    }
    
    return [_requestEngines objectForKey:[requestObj hostName]];
}

- (MKNetworkHost *)getNetworkHostEngineWithRequestURL:(NSURL *)remoteURL {

    if ([[_requestEngines allKeys] indexOfObject:remoteURL.host] == NSNotFound) {
        [_requestEngines setObject:[_dispatcher createHostEngineWithRequestHostName:remoteURL.host] forKey:remoteURL.host];
    }
    
    return [_requestEngines objectForKey:remoteURL.host];
    
    return nil;
}

#pragma mark bulid RequestParams

- (NSDictionary *)bulidRequestParamsWithRequest:(JCRequestObj *)requestObj {
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionaryWithDictionary:[requestObj yy_modelToJSONObject]];
    //删除不必要的属性
    [paramsDict removeObjectForKey:@"hostName"];
    [paramsDict removeObjectForKey:@"path"];
    [paramsDict removeObjectForKey:@"parameterType"];
    [paramsDict removeObjectForKey:@"headerDictionary"];
    [paramsDict removeObjectForKey:@"doNotCache"];
    [paramsDict removeObjectForKey:@"alwaysCache"];
    [paramsDict removeObjectForKey:@"ignoreCache"];
    [paramsDict removeObjectForKey:@"alwaysLoad"];
    
    return paramsDict;
}

@end
