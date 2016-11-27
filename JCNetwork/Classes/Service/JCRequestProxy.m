//
//  JCRequestProxy.m
//  JCNetwork
//
//  Created by Jam on 16/1/5.
//  Copyright © 2016年 Jam. All rights reserved.

#import "JCRequestProxy.h"
#import "JCRequester.h"
#import "JCCacheResponedDispatcher.h"

@interface JCRequestProxy () {
    JCRequester *_requester;
}

@end

@implementation JCRequestProxy

+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static JCRequestProxy *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[JCRequestProxy alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _requester = [JCRequester sharedInstance];
    }
    
    return self;
}

#pragma mark request
- (JCRequestID)httpGetWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withCompleteBlock:(JCNetworkResponseBlock)responedBlock {
    if (!requestObj || ![requestObj hostName]) {
        return JC_ERROR_REQUESTID;
    }
    
    return [_requester httpGetWithRequest:requestObj entityClass:entityName withCompleteBlock:responedBlock];
}

- (JCRequestID)httpPostWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withCompleteBlock:(JCNetworkResponseBlock)responedBlock {
    if (!requestObj || ![requestObj hostName]) {
        return JC_ERROR_REQUESTID;
    }
    
    return [_requester httpPostWithRequest:requestObj entityClass:entityName withCompleteBlock:responedBlock];
}

- (JCRequestID)upLoadFileWithRequest:(JCRequestObj *)requestObj files:(NSDictionary *)files entityClass:(NSString *)entityName withUpLoadBlock:(JCNetworkResponseBlock)upLoadBlock {
    if (!requestObj || ![requestObj hostName]) {
        return JC_ERROR_REQUESTID;
    }
    return [_requester upLoadFileWithRequest:requestObj files:files entityClass:entityName withUpLoadBlock:upLoadBlock];
}

- (JCRequestID)downLoadFileFrom:(NSURL *)remoteURL toFile:(NSString*)filePath withDownLoadBlock:(JCNetworkResponseBlock)responedBlock {
    if (!remoteURL) {
        return JC_ERROR_REQUESTID;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    return [_requester downLoadFileFrom:remoteURL toFile:filePath withDownLoadBlock:responedBlock];
}

#pragma mark CacheResponed

- (__kindof JCResponedObj *)getCacheResponedObj:(JCRequestObj *)requestObj entityClass:(NSString *)entityName {
    
    JCRequest *request = [[JCRequest alloc] initWithRequestObj:requestObj];
    JCCacheResponed *cacheResponed = [[JCCacheResponedDispatcher sharedInstance] getCacheResponedWithKey:request.cacheKey];
    
    if (!cacheResponed) {
        return nil;
    }
    
    NSDictionary *returnValue = cacheResponed.responedDic;
    
    if (entityName) {
        Class cls = NSClassFromString(entityName);
        NSObject *responsed = [cls yy_modelWithDictionary:returnValue];
        return responsed;
    }
    
    return cacheResponed.responedDic;
}

#pragma mark ImageRequest
- (void)autoLoadImageWithURL:(NSURL *)imageURL placeHolderImage:(UIImage*)image toImageView:(UIImageView *)imageView {
    if (!imageURL) {
        return ;
    }
    
    return [_requester autoLoadImageWithURL:imageURL placeHolderImage:image toImageView:imageView];
}

- (void)loadImageWithURL:(NSURL *)imageURL completionHandler:(JCNetworkImageFetch)imageFetchBlock {
    if (!imageURL) {
        return;
    }
    return [_requester loadImageWithURL:imageURL completionHandler:imageFetchBlock];
}

- (UIImage *)getImageIfExisted:(NSURL *)imageURL {
    if (!imageURL) {
        return nil;
    }
    
    return [_requester getImageIfExisted:imageURL];
}

#pragma mark cancelRequest

- (void)cancelRequestID:(JCRequestID)requestID {
    [_requester cancelRequest:requestID];
}

- (void)cancelAllRequest {
    [_requester cancelAllRequest];
}

- (void)clearSave {
    [[JCCacheResponedDispatcher sharedInstance] clearn];
}

@end
