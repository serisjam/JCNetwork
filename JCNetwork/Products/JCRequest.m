//
//  JCRequest.m
//  JCNetwork
//
//  Created by 贾淼 on 16/7/20.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "JCRequest.h"

@implementation JCRequest

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (instancetype)initWithRequestObj:(JCRequestObj *)requestObj {
    self = [super init];
    
    if (self) {
        _paramsDic = [self bulidRequestParamsWithRequest:requestObj];
        _URLString = [self getURLStringWithRequest:requestObj];
        _requestSerializer = [self getRequestSerializeWithRequest:requestObj];
        _timeoutInterval = requestObj.timeoutInterval;
    }
    
    return self;
}

#pragma mark private method

- (NSDictionary *)bulidRequestParamsWithRequest:(JCRequestObj *)requestObj {
    
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionaryWithDictionary:[requestObj yy_modelToJSONObject]];
    //删除不必要的属性
    [paramsDict removeObjectForKey:@"hostName"];
    [paramsDict removeObjectForKey:@"path"];
    [paramsDict removeObjectForKey:@"parameterType"];
    [paramsDict removeObjectForKey:@"timeoutInterval"];
    paramsDict = [NSMutableDictionary dictionaryWithDictionary:[requestObj handlerParamsDic:paramsDict]];
    
    return paramsDict;
}

- (NSString *)getURLStringWithRequest:(JCRequestObj *)requestObj {
    
    NSMutableString *urlString = [NSMutableString stringWithString:requestObj.hostName];
    
    if(requestObj.path) {
        if(requestObj.path.length > 0 && [requestObj.path characterAtIndex:0] == '/')
            [urlString appendFormat:@"%@", requestObj.path];
        else if (requestObj.path != nil)
            [urlString appendFormat:@"/%@", requestObj.path];
    }
    return urlString;
}

- (AFHTTPRequestSerializer<AFURLRequestSerialization> *)getRequestSerializeWithRequest:(JCRequestObj *)requestObj {
    switch (requestObj.parameterType) {
        case JCNetworkParameterTypeURL:
            return [AFHTTPRequestSerializer serializer];
        case JCNetworkParameterTypeJSON:
            return [AFJSONRequestSerializer serializer];
        case JCNetworkParameterTypeList:
            return [AFPropertyListRequestSerializer serializer];
        default:
            break;
    }
}

@end
