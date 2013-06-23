//
//  JCOperationResponse.h
//  JCNetworkNew
//
//  Created by Jam on 13-6-23.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCOperationResponse : NSObject

@property (nonatomic, strong) MKNetworkOperation *operation;
@property (nonatomic, assign) JCRequestID requestID;

@end
