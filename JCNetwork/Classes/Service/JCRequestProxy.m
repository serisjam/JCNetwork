//
//  JCRequestProxy.m
//  JCNetwork
//
//  Created by Jam on 16/1/5.
//  Copyright © 2016年 Jam. All rights reserved.

#import "JCRequestProxy.h"
#import "JCRequester.h"
#import "JCCacheResponedDispatcher.h"

#import <objc/runtime.h>

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

- (JCRequestID)httpGetWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withControlObj:(NSObject *)controlObj withCompleteBlock:(JCNetworkResponseBlock)responedBlock {
    
    JCRequestID requestID = [self httpGetWithRequest:requestObj entityClass:entityName withCompleteBlock:responedBlock];
    
    if (controlObj) {
        [self handleControlObj:controlObj withRequestID:requestID];
    }
	return requestID;
}

- (JCRequestID)httpGetWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withControlObj:(NSObject *)controlObj withSucessBlock:(void (^)(id content))sucessBlock andFailedBlock:(void (^)(NSError *error))failedBlock {
    
    JCRequestID requestID = [self httpGetWithRequest:requestObj entityClass:entityName withCompleteBlock:^(JCNetworkResponse *response) {
        if (response.status == JCNetworkResponseStatusSuccess) {
            sucessBlock(response.content);
            return ;
        }
        failedBlock(response.error);
    }];
    
    if (controlObj) {
        [self handleControlObj:controlObj withRequestID:requestID];
    }
	return requestID;
}

- (JCRequestID)httpPostWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withCompleteBlock:(JCNetworkResponseBlock)responedBlock {
    if (!requestObj || ![requestObj hostName]) {
        return JC_ERROR_REQUESTID;
    }
    
    return [_requester httpPostWithRequest:requestObj entityClass:entityName withCompleteBlock:responedBlock];
}

- (JCRequestID)httpPostWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withControlObj:(NSObject *)controlObj withCompleteBlock:(JCNetworkResponseBlock)responedBlock {
    
    JCRequestID requestID = [self httpPostWithRequest:requestObj entityClass:entityName withCompleteBlock:responedBlock];
    
    if (controlObj) {
        [self handleControlObj:controlObj withRequestID:requestID];
    }
	return requestID;
}

- (JCRequestID)httpPostWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withControlObj:(NSObject *)controlObj withSucessBlock:(void (^)(id content))sucessBlock andFailedBlock:(void (^)(NSError *error))failedBlock {
    
    JCRequestID requestID = [self httpPostWithRequest:requestObj entityClass:entityName withCompleteBlock:^(JCNetworkResponse *response) {
        if (response.status == JCNetworkResponseStatusSuccess) {
            sucessBlock(response.content);
            return ;
        }
        failedBlock(response.error);
    }];
    
    if (controlObj) {
        [self handleControlObj:controlObj withRequestID:requestID];
    }
    return requestID;
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

#pragma mark ControlObj

- (void)handleControlObj:(NSObject *)controlObj withRequestID:(JCRequestID)requestID {
    NSMutableArray *requstIdArrary = [self getAllRequestID:controlObj];
    
    if (!requstIdArrary) {
        [self setAllRequestID:controlObj];
        requstIdArrary = [self getAllRequestID:controlObj];
        
        SEL aSelector = NSSelectorFromString(@"dealloc");
        __weak typeof(self) weakSelf = self;
        [controlObj aspect_hookSelector:aSelector withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo){
            NSMutableArray *requestArrary = [weakSelf getAllRequestID:aspectInfo.instance];
            [requstIdArrary enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [weakSelf cancelRequestID:[obj integerValue]];
            }];
        } error:nil];
    }
    
    [requstIdArrary addObject:[NSNumber numberWithInt:requestID]];
}

- (NSMutableArray *)getAllRequestID:(NSObject *)controlObj {
    NSMutableArray *requstIdArrary = objc_getAssociatedObject(controlObj, 'allRequestID');
    return requstIdArrary;
}

- (void)setAllRequestID:(NSObject *)controlObj {
    NSMutableArray *requestArrary = [[NSMutableArray alloc] init];
    objc_setAssociatedObject(controlObj, 'allRequestID', requestArrary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
