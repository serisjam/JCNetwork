//
//  JCRequester.m
//  JCNetworkNew
//
//  Created by Jam on 13-6-20.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCRequester.h"
#import "DispatchElement.h"

#import "AFNetworking.h"

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
    
    return _lastRequestID;
}

- (JCRequestID)httpPostWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withCompleteBlock:(JCNetworkResponseBlock)responedBlock {
    if (++_lastRequestID >= JC_MAX_REQUESTID) {
        _lastRequestID = JC_MIN_REQUESTID;
    }
    
    JCRequest *request = [[JCRequest alloc] initWithRequestObj:requestObj];
    DispatchElement *element = [self getDispatchElementWithCompleteBlock:responedBlock WithRequest:request entityClass:entityName];
    [_dispatcher addPostDispatchItem:element];
    
    return _lastRequestID;
}

#pragma mark upload request
- (JCRequestID)upLoadFileWithRequest:(JCRequestObj *)requestObj files:(NSDictionary *)files entityClass:(NSString *)entityName withUpLoadBlock:(JCNetworkResponseBlock)upLoadBlock {
    if (++_lastRequestID >= JC_MAX_REQUESTID) {
        _lastRequestID = JC_MIN_REQUESTID;
    }
    
    return _lastRequestID;
}

#pragma mark download request
- (JCRequestID)downLoadFileFrom:(NSURL *)remoteURL toFile:(NSString*)filePath withDownLoadBlock:(JCNetworkResponseBlock)responedBlock {
    if (++_lastRequestID >= JC_MAX_REQUESTID) {
        _lastRequestID = JC_MIN_REQUESTID;
    }
    
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

#pragma mark bulid DispatchElement

- (DispatchElement *)getDispatchElementWithCompleteBlock:(JCNetworkResponseBlock)responedBlock WithRequest:(JCRequest *)request entityClass:(NSString *)entityName {
    
    DispatchElement *element = [[DispatchElement alloc] init];
    element.requestID = _lastRequestID;
    element.responseBlock = responedBlock;
    element.entityClassName = entityName;
    element.request = request;
    
    return element;
}

@end
