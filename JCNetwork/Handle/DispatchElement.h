//
//  DispatchElement.h
//  JCNetworkNew
//
//  Created by Jam on 13-6-23.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DispatchElement : NSObject

@property (nonatomic, assign) JCRequestID requestID;
@property (nonatomic, assign) id    target;
@property (nonatomic, assign) SEL   callback;
@property (nonatomic, assign) JCServiceType serviceID;
@property (nonatomic, retain) MKNetworkOperation *operation;
@property (nonatomic, retain) NSDate *startTime;

- (id)init;

@end
