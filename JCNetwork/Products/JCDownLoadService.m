//
//  JCDownLoadService.m
//  JCNetwork
//
//  Created by Jam on 13-6-27.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCDownLoadService.h"

@implementation JCDownLoadService
- (id)init
{
    self = [super init];
    
    if (self) {
        _serviceID = JCDownLoadServiceID;
    }
    
    return self;
}

@end