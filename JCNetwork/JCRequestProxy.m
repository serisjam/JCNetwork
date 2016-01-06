//
//  JCRequestProxy.m
//  JCNetwork
//
//  Created by Jam on 16/1/5.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "JCRequestProxy.h"
#import "JCRequester.h"

@interface JCRequestProxy () {
    JCRequester *_requester;
}

@end

@implementation JCRequestProxy

+ (id)sharedInstance {
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

- (JCRequestID)httpPostFile:(JCRequestObj *)requestObj files:(NSDictionary *)files entityClass:(NSString *)entityName withUpLoadBlock:(JCNetworkResponseBlock)upLoadBlock {
    if (!requestObj || ![requestObj hostName]) {
        return JC_ERROR_REQUESTID;
    }
    
    return [_requester httpPostFile:requestObj files:files entityClass:entityName withUpLoadBlock:upLoadBlock];
}

- (JCRequestID)downloadFileFrom:(NSURL *)remoteURL toFile:(NSString*)filePath withDownLoadBlock:(JCNetworkResponseBlock)responedBlock {
    if (!remoteURL) {
        return JC_ERROR_REQUESTID;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    return [_requester downloadFileFrom:remoteURL toFile:filePath withDownLoadBlock:responedBlock];
}

#pragma mark ImageRequest
- (void)autoLoadImageWithURL:(NSURL *)imageURL placeHolderImage:(UIImage*)image toImageView:(UIImageView *)imageView {
    if (!imageURL) {
        return ;
    }
    
    return [_requester autoLoadImageWithURL:imageURL placeHolderImage:image toImageView:imageView];
}

- (void)loadImageWithURL:(NSURL *)imageURL size:(CGSize)size completionHandler:(JCNetworkImageFetch)imageFetchBlock {
    if (!imageURL) {
        return;
    }
    return [_requester loadImageWithURL:imageURL size:size completionHandler:imageFetchBlock];
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
@end
