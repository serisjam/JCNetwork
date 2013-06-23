//
//  DispatchElement.m
//  JCNetworkNew
//
//  Created by Jam on 13-6-23.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "DispatchElement.h"

@implementation DispatchElement

@synthesize requestID = _requestID;
@synthesize target = _target;
@synthesize callback = _callback;
@synthesize serviceID = _serviceID;
@synthesize operation = _operation;
@synthesize startTime = _startTime;

- (id)init
{
    self = [super init];
    
    if (self) {
        self.startTime = [NSDate date];
    }
    
    return self;
}

@end
