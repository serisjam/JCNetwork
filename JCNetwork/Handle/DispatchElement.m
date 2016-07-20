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
@synthesize responseBlock = _responseBlock;
@synthesize entityClassName = _entityClassName;
@synthesize request = _request;


- (id)init {
    self = [super init];
    
    if (self) {
    }
    
    return self;
}

@end
