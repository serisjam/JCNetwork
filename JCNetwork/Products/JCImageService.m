//
//  JCImageService.m
//  JCNetwork
//
//  Created by Jam on 13-6-25.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCImageService.h"

@implementation JCImageService

- (id)init
{
    self = [super init];
    
    if (self) {
        _serviceID = JCImageServiceID;
    }
    
    return self;
}

@end
