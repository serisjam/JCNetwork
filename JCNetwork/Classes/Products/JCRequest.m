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
        _headerFieldDic = requestObj.headerFieldDic;
        _URLString = [self getURLStringWithRequest:requestObj];
        _requestSerializer = [self getRequestSerializeWithRequest:requestObj];
        _timeoutInterval = requestObj.timeoutInterval;
        
        if (requestObj.cacheKey) {
            _cacheKey = requestObj.cacheKey;
        } else {
            _cacheKey = [self getAbsoluteURLStringWithPath:_URLString withParameters:_paramsDic];
        }
        
        _cachePolicy = requestObj.cachePolicy;
        _cacheRefreshTimeInterval = requestObj.cacheRefreshTimeInterval;
    }
    
    return self;
}

#pragma mark private method

- (NSDictionary *)bulidRequestParamsWithRequest:(JCRequestObj *)requestObj {
    
    if (requestObj.paramsDic) {
        return requestObj.paramsDic;
    }
    
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionaryWithDictionary:[requestObj yy_modelToJSONObject]];
    //删除不必要的属性
    [paramsDict removeObjectForKey:@"hostName"];
    [paramsDict removeObjectForKey:@"path"];
    [paramsDict removeObjectForKey:@"parameterType"];
    [paramsDict removeObjectForKey:@"timeoutInterval"];
    [paramsDict removeObjectForKey:@"cachePolicy"];
    [paramsDict removeObjectForKey:@"cacheRefreshTimeInterval"];
    [paramsDict removeObjectForKey:@"cacheKey"];
    [paramsDict removeObjectForKey:@"headerFieldDic"];
    [paramsDict removeObjectForKey:@"paramsDic"];
    paramsDict = [NSMutableDictionary dictionaryWithDictionary:[requestObj handlerParamsDic:paramsDict]];
    
    return paramsDict;
}

- (NSString *)getURLStringWithRequest:(JCRequestObj *)requestObj {
    
    NSMutableString *urlString = [NSMutableString stringWithString:requestObj.hostName];
    
    if ([urlString characterAtIndex:[urlString length]-1] == '/') {
        urlString = [NSMutableString stringWithString:[urlString substringToIndex:[urlString length]-1]];
    }
    
    if(requestObj.path) {
        if(requestObj.path.length > 0 && [requestObj.path characterAtIndex:0] == '/')
            [urlString appendFormat:@"%@", requestObj.path];
        else if (requestObj.path != nil)
            [urlString appendFormat:@"/%@", requestObj.path];
    }
    return urlString;
}

- (NSString *)getAbsoluteURLStringWithPath:(NSString *)urlString withParameters:(NSDictionary *)parameters {
    
    if (parameters) {
        if (![NSJSONSerialization isValidJSONObject:parameters]) return nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
        NSString *paramStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return [urlString stringByAppendingString:paramStr];
    }
    
    return urlString;
}

- (AFHTTPRequestSerializer<AFURLRequestSerialization> *)getRequestSerializeWithRequest:(JCRequestObj *)requestObj {
    AFHTTPRequestSerializer *requestSerializer;
    switch (requestObj.parameterType) {
        case JCNetworkParameterTypeURL:
            requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        case JCNetworkParameterTypeJSON:
            requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        case JCNetworkParameterTypeList:
            requestSerializer = [AFPropertyListRequestSerializer serializer];
            break;
        default:
            break;
    }
    
    for (NSString *key in [_headerFieldDic allKeys]) {
        [requestSerializer setValue:[_headerFieldDic objectForKey:key] forHTTPHeaderField:key];
    }
    return requestSerializer;
}

@end
