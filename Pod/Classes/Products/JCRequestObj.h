//
//  JCRequestObj.h
//  JCNetwork
//
//  Created by Jam on 14-7-14.
//  Copyright (c) 2014年 Jam. All rights reserved.
//

#import "JCNetworkDefine.h"

@interface JCRequestObj : NSObject

@property (assign, nonatomic) JCNetworkParameterType parameterType;
@property (strong, nonatomic) NSString *hostName;
@property (strong, nonatomic) NSString *path;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

//headerfield
@property (nonatomic, strong) NSDictionary *headerFieldDic;
//直接采用NSDictionary作为请求参数
@property (nonatomic, strong) NSDictionary *paramsDic;

//缓存key,默认为绝对URL地址，可以自己修改
@property (nonatomic, strong) NSString *cacheKey;

@property (nonatomic, assign) JCRequestCachePolicy cachePolicy;
//在JCNetWorkReturnCacheDataReLoad 模式下，缓存多长时间要刷新，其他模式都没用, 默认缓存一天, 单位为秒
@property (nonatomic, assign) NSTimeInterval cacheRefreshTimeInterval;

//处理请求参数,默认不处理,子类可对改参数做额外修改
- (NSDictionary *)handlerParamsDic:(NSDictionary *)orginParamsDic;

@end
