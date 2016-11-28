//
//  DispatchElement.h
//  JCNetworkNew
//
//  Created by Jam on 13-6-23.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCRequest.h"
#import "JCNetworkResponse.h"

@interface DispatchElement : NSObject

@property (nonatomic, assign) JCRequestID requestID;
@property (nonatomic, copy) void (^responseBlock)(JCNetworkResponse *response);
@property (nonatomic, strong) JCRequest *request;
@property (nonatomic, strong) NSString *entityClassName;


- (id)init;

@end
