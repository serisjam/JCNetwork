//
//  JCRequestProxy.h
//  JCNetwork
//
//  Created by Jam on 16/1/5.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "JCNetworkResponse.h"
#import "JCRequestObj.h"
#import "JCResponedObj.h"

typedef void(^JCNetworkResponseBlock)(JCNetworkResponse *response);
typedef void(^JCNetworkImageFetch)(UIImage *fetchImage, BOOL isCache);

@interface JCRequestProxy : NSObject

+ (instancetype)sharedInstance;

- (instancetype)init;

// Get Request
- (JCRequestID)httpGetWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withCompleteBlock:(JCNetworkResponseBlock)responedBlock;

// Get Request with Control
- (JCRequestID)httpGetWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withControlObj:(NSObject *)controlObj withCompleteBlock:(JCNetworkResponseBlock)responedBlock;

- (JCRequestID)httpGetWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withControlObj:(NSObject *)controlObj withSucessBlock:(void (^)(id content))sucessBlock andFailedBlock:(void (^)(NSError *error))failedBlock;

//Post Request
- (JCRequestID)httpPostWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withCompleteBlock:(JCNetworkResponseBlock)responedBlock;

//Post Request with Control
- (JCRequestID)httpPostWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withControlObj:(NSObject *)controlObj withCompleteBlock:(JCNetworkResponseBlock)responedBlock;

- (JCRequestID)httpPostWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withControlObj:(NSObject *)controlObj withSucessBlock:(void (^)(id content))sucessBlock andFailedBlock:(void (^)(NSError *error))failedBlock;

//upload
- (JCRequestID)upLoadFileWithRequest:(JCRequestObj *)requestObj files:(NSDictionary *)files entityClass:(NSString *)entityName withUpLoadBlock:(JCNetworkResponseBlock)responedBlock;

//download
- (JCRequestID)downLoadFileFrom:(NSURL *)remoteURL toFile:(NSString*)filePath withDownLoadBlock:(JCNetworkResponseBlock)responedBlock;

- (__kindof JCResponedObj *)getCacheResponedObj:(JCRequestObj *)requestObj entityClass:(NSString *)entityName;

//Image请求
- (void)autoLoadImageWithURL:(NSURL *)imageURL placeHolderImage:(UIImage*)image toImageView:(UIImageView *)imageView;
- (void)loadImageWithURL:(NSURL *)imageURL completionHandler:(JCNetworkImageFetch)imageFetchBlock;
- (UIImage *)getImageIfExisted:(NSURL *)imageURL;

// 根据请求ID取消一个请求
- (void)cancelRequestID:(JCRequestID)requestID;
- (void)cancelAllRequest;

//清除缓存
- (void)clearSave;
@end
