//
//  DispatchElement.h
//  JCNetworkNew
//
//  Created by Jam on 13-6-23.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCRequestProxy.h"

@interface DispatchElement : NSObject

@property (nonatomic, assign) JCRequestID requestID;
@property (nonatomic, copy) JCNetworkResponseBlock responseBlock;
@property (nonatomic, strong) NSString *hostName;
@property (nonatomic, strong) NSString *entityClassName;
@property (nonatomic, assign) MKNetworkRequest *request;

- (id)init;

@end
