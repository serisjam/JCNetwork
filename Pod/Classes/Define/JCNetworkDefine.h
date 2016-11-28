//
//  JCNetworkDefine.h
//  JCNetwork
//
//  Created by Jam on 13-6-23.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#ifndef JCNetwork_JCNetworkDefine_h
#define JCNetwork_JCNetworkDefine_h

//定义JCRequestID类型用于记录每次请求的ID
typedef unsigned int JCRequestID;

//错误的请求ID 对应的serviceID不存在或者是请求的methodName不存在
#define JC_ERROR_REQUESTID 0

//请求响应的状态
typedef NS_ENUM (NSInteger, JCNetworkResponseStatus) {
    JCNetworkResponseStatusSuccess,
    JCNetworkResponseStatusDowning,
    JCNetworkResponseStatusUploading,
    JCNetworkResponseStatusFailed
};

//请求发送格式
typedef NS_ENUM (NSInteger, JCNetworkParameterType) {
    JCNetworkParameterTypeURL = 0,
    JCNetworkParameterTypeJSON = 1,
    JCNetworkParameterTypeList = 2
};

//缓存状态设定
typedef NS_ENUM(NSUInteger, JCRequestCachePolicy){
    JCNetWorkReloadIgnoringLocalCacheData,  ///忽略缓存，重新请求
    //一下二种情况，当网络请求失败时都会返回数据
    JCNetWorkReturnCacheDataElseLoad,       ///有缓存就用缓存，没有缓存就重新请求(用于数据不变时)
    JCNetWorkReturnCacheDataReLoad,         ///设置一个缓存时间，如果超过缓存存储时间就重新请求并缓存，如果在缓存时间内则返回缓存内容
};

#endif
