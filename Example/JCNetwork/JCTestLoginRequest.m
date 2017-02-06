//
//  JCTestLoginRequest.m
//  JCNetwork
//
//  Created by 贾淼 on 17/2/6.
//  Copyright © 2017年 贾淼. All rights reserved.
//

#import "JCTestLoginRequest.h"

@implementation JCTestLoginRequest

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.hostName = @"http://10.154.40.41:9000/api/app";
        self.path = @"/security/login";
        self.parameterType = JCNetworkParameterTypeJSON;
    }
    
    return self;
}

@end
