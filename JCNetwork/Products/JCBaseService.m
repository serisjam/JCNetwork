//
//  JCBaseService.m
//  JCNetwork
//
//  Created by Jam on 13-6-23.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCBaseService.h"

@implementation JCBaseService

@synthesize serviceID = _serviceID;

@synthesize hostName = _hostName;
@synthesize path = _path;

@synthesize apiVersion = _apiVersion;
@synthesize apiName = _apiName;

- (NSArray *)getAllMethods
{
    return [_methodDict allKeys];
}

@end
