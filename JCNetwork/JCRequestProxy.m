//
//  JCRequestProxy.m
//  JCNetwork
//
//  Created by Jam on 16/1/5.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "JCRequestProxy.h"
#import "JCRequester.h"

@interface JCRequestProxy () {
    JCRequester *_requester;
}

@end

@implementation JCRequestProxy

+ (id)sharedInstance {
    static dispatch_once_t pred;
    static JCRequestProxy *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[JCRequestProxy alloc] init];
    });
    return sharedInstance;
}

- (id)init {
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

- (JCRequestID)httpPostWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withCompleteBlock:(JCNetworkResponseBlock)responedBlock {
    if (!requestObj || ![requestObj hostName]) {
        return JC_ERROR_REQUESTID;
    }
    
    return [_requester httpPostWithRequest:requestObj entityClass:entityName withCompleteBlock:responedBlock];
}

#pragma mark cancelRequest

- (void)cancelRequestID:(JCRequestID)requestID {
    [_requester cancelRequest:requestID];
}
@end
