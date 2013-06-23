//
//  JCBaseService.h
//  JCNetwork
//
//  Created by Jam on 13-6-23.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCBaseService : NSObject
{
    JCServiceType _serviceID;
    NSDictionary *_methodDict;
    
    NSString *_hostName;
    NSString *_path;
    NSString *_apiVersion;
    NSString *_apiName;
}

@property (assign, nonatomic) JCServiceType serviceID;

@property (strong, nonatomic) NSString *hostName;
@property (strong, nonatomic) NSString *path;

@property (strong, nonatomic) NSString *apiVersion;
@property (strong, nonatomic) NSString *apiName;

- (NSArray *)getAllMethods;

@end
