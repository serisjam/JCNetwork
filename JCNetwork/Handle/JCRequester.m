//
//  JCRequester.m
//  JCNetworkNew
//
//  Created by Jam on 13-6-20.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCRequester.h"
#import "DispatchElement.h"
#import "MKNetworkRequest+JCNetwork.h"

@implementation JCRequester

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static JCRequester *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[JCRequester alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _requestEngines = [[NSMutableDictionary alloc] init];
        _dispatcher = [JCDispatcher sharedInstance];
        _lastRequestID = JC_MIN_REQUESTID;
    }
    
    return self;
}

#pragma mark request block

- (JCRequestID)httpGetWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withCompleteBlock:(JCNetworkResponseBlock)responedBlock {
    return [self httpSendRequesWithRequest:requestObj entityClass:entityName withCompleteBlock:responedBlock httpMethod:@"GET"];
}

- (JCRequestID)httpPostWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withCompleteBlock:(JCNetworkResponseBlock)responedBlock {
    return [self httpSendRequesWithRequest:requestObj entityClass:entityName withCompleteBlock:responedBlock httpMethod:@"POST"];
}

- (JCRequestID)httpSendRequesWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withCompleteBlock:(JCNetworkResponseBlock)responedBlock httpMethod:(NSString *)method {
    if (++_lastRequestID >= JC_MAX_REQUESTID) {
        _lastRequestID = JC_MIN_REQUESTID;
    }
    
    //get different products MKNetworkEngine queue
    if ([[_requestEngines allKeys] indexOfObject:[requestObj hostName]] == NSNotFound) {
        [_requestEngines setObject:[_dispatcher createHostEngineWithRequestObj:requestObj] forKey:[requestObj hostName]];
    }
    
    MKNetworkHost *hostEngine = [_requestEngines objectForKey:[requestObj hostName]];
    MKNetworkRequest *request = [hostEngine requestWithPath:requestObj.path params:[self bulidRequestParamsWithRequest:requestObj] httpMethod:method];
    
    request.alwaysCache = requestObj.alwaysCache;
    request.alwaysLoad = requestObj.alwaysLoad;
    request.ignoreCache = requestObj.ignoreCache;
    request.doNotCache = requestObj.doNotCache;
    [request setRequestID:_lastRequestID];
    
    switch (requestObj.parameterType) {
        case JCNetworkParameterTypeURL:
            request.parameterEncoding = 0;
            break;
        case JCNetworkParameterTypeJSON:
            request.parameterEncoding = 1;
            break;
        case JCNetworkParameterTypelist:
            request.parameterEncoding = 2;
            break;
        default:
            break;
    }
    
    DispatchElement *element = [[DispatchElement alloc] init];
    element.requestID = _lastRequestID;
    element.responseBlock = responedBlock;
    element.hostName = requestObj.hostName;
    element.entityClassName = entityName;
    element.request = request;
    [_dispatcher addDispatchItem:element];
    
    [hostEngine startRequest:request];
    
    return _lastRequestID;
}

#pragma cancelRequest

- (void)cancelRequest:(JCRequestID)requestID {
    [_dispatcher cancelRequest:requestID];
}

#pragma mark bulid RequestParams

- (NSDictionary *)bulidRequestParamsWithRequest:(JCRequestObj *)requestObj {
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionaryWithDictionary:[requestObj yy_modelToJSONObject]];
    //删除不必要的属性
    [paramsDict removeObjectForKey:@"hostName"];
    [paramsDict removeObjectForKey:@"path"];
    [paramsDict removeObjectForKey:@"parameterType"];
    [paramsDict removeObjectForKey:@"doNotCache"];
    [paramsDict removeObjectForKey:@"alwaysCache"];
    [paramsDict removeObjectForKey:@"ignoreCache"];
    [paramsDict removeObjectForKey:@"alwaysLoad"];
    
    NSLog(@"%@", paramsDict);
    
    return paramsDict;
}

@end
