//
//  JCRequestObj.h
//  JCNetwork
//
//  Created by Jam on 14-7-14.
//  Copyright (c) 2014年 Jam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCRequestObj : NSObject

@property (assign, nonatomic) JCNetworkParameterType parameterType;
@property (strong, nonatomic) NSString *hostName;
@property (strong, nonatomic) NSString *path;

@property (strong, nonatomic) NSDictionary *headerDictionary;
@property (strong, nonatomic) NSDictionary *paramsDic;

@property (assign, nonatomic) BOOL doNotCache;
@property (assign, nonatomic) BOOL alwaysCache;

@property (assign, nonatomic) BOOL ignoreCache;
@property (assign, nonatomic) BOOL alwaysLoad;


//处理请求参数,默认不处理,子类可对改参数做额外修改
- (NSDictionary *)handlerParamsDic:(NSDictionary *)orginParamsDic;

@end
