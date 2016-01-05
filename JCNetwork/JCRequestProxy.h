//
//  JCRequestProxy.h
//  JCNetwork
//
//  Created by Jam on 16/1/5.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCRequestObj.h"

typedef void(^JCNetworkResponseBlock)(JCNetworkResponse *response);

@interface JCRequestProxy : NSObject

+ (id)sharedInstance;
- (id)init;

// Get Request
- (JCRequestID)httpGetWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withCompleteBlock:(JCNetworkResponseBlock)responedBlock;

//Post Request
- (JCRequestID)httpPostWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withCompleteBlock:(JCNetworkResponseBlock)responedBlock;

// 根据请求ID取消一个请求
- (void)cancelRequestID:(JCRequestID)requestID;

@end
