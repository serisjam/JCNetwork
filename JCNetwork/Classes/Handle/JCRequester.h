//
//  JCRequester.h
//  JCNetworkNew
//
//  Created by Jam on 13-6-20.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCNetworkResponse.h"
#import "JCDispatcher.h"

#define JC_MIN_REQUESTID 1
#define JC_MAX_REQUESTID UINT_MAX


@interface JCRequester : NSObject {
    @package
    NSMutableDictionary *_requestEngines;
    JCRequestID _lastRequestID;
    JCDispatcher *_dispatcher;
}

+ (id)sharedInstance;
- (id)init;

- (JCRequestID)httpGetWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withCompleteBlock:(void (^)(JCNetworkResponse *response))responedBlock;
- (JCRequestID)httpPostWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withCompleteBlock:(void (^)(JCNetworkResponse *response))responedBlock;

//upload request
- (JCRequestID)upLoadFileWithRequest:(JCRequestObj *)requestObj files:(NSDictionary *)files entityClass:(NSString *)entityName withUpLoadBlock:(void (^)(JCNetworkResponse *response))upLoadBlock;

//download request
- (JCRequestID)downLoadFileFrom:(NSURL *)remoteURL toFile:(NSString*)filePath withDownLoadBlock:(void (^)(JCNetworkResponse *response))responedBlock;

//image request
- (void)autoLoadImageWithURL:(NSURL *)imageURL placeHolderImage:(UIImage*)image toImageView:(UIImageView *)imageView;
- (void)loadImageWithURL:(NSURL *)imageURL completionHandler:(void (^)(UIImage *fetchImage, BOOL isCache))imageFetchBlock;
- (UIImage *)getImageIfExisted:(NSURL *)imageURL;

//cancelRequest with RequestID
- (void)cancelRequest:(JCRequestID)requestID;
- (void)cancelAllRequest;

@end
