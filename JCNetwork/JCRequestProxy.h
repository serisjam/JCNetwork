//
//  JCRequestProxy.h
//  JCNetwork
//
//  Created by Jam on 13-6-23.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCNetworkDefine.h"
#import "JCNetworkResponse.h"

@class JCRequester;     // 前向声明

@interface JCRequestProxy : NSObject
{
    JCRequester *_requester;
    NSMutableDictionary *_serviceDict;
}

+ (id)sharedInstance;
- (id)init;

//根据不同产品的serviceID和请求接口请求数据
//GET请求
- (JCRequestID)httpGetWithServiceID:(JCServiceType)serviceID methodName:(NSString *)methodName params:(NSDictionary *)params target:(id)target action:(SEL)action;
//POST请求
- (JCRequestID)httpPostWithServiceID:(JCServiceType)serviceID methodName:(NSString *)methodName params:(NSDictionary *)params target:(id)target action:(SEL)action;
//Image请求
- (void)autoLoadImageWithURL:(NSURL *)imageURL placeHolderImage:(UIImage*)image toImageView:(UIImageView *)imageView;
//upload 请求
- (JCRequestID)uploadFileWithServiceID:(JCServiceType)serviceID methodName:(NSString *)methodName params:(NSDictionary *)params files:(NSDictionary *)files target:(id)target action:(SEL)action;
//upload上传进度根据上传返回的requestID
- (void)onUploadProgressChanged:(JCRequestID)requestID target:(id)target action:(SEL)action;
//download 请求
- (JCRequestID)downloadFileFrom:(NSString*)remoteURL toFile:(NSString*)filePath target:(id)target action:(SEL)action;
- (void)onDownloadProgressChanged:(JCRequestID)requestID target:(id)target action:(SEL)action;

// 根据请求ID取消一个请求
- (void)cancelRequest:(JCRequestID)requestID;

//根据不同产品serviceID设置其接口的名字和版本
- (void)setApiName:(NSString *)apiName forService:(JCServiceType)serviceID;
- (void)setApiVersion:(NSString *)apiVersion forService:(JCServiceType)serviceID;

//获取网络类型 wifi 或是 2g/3g
- (NSString *)getNetworkStatus;

@end
