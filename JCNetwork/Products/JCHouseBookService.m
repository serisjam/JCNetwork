//
//  JCHouseBookService.m
//  JCNetwork
//
//  Created by Jam on 13-6-25.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCHouseBookService.h"

@implementation JCHouseBookService

- (id)init
{
    self = [super init];
    
    if (self) {
        _serviceID = JCHouseBookServiceID;
        _apiName = @"i-housebook";
        _apiVersion = @"1.0";
        
#ifdef DEBUG
        _hostName = @"ls.zhaofangtong.com";
        _path = @"api/";
#else
        _hostName = @"ls.zhaofangtong.com";
        _path = @"api/";
#endif
        NSArray *apiList = [NSArray arrayWithObjects:
                            @"api.php",
                            nil];
        
        _methodDict = [[NSMutableDictionary alloc] initWithCapacity:[apiList count]];
        for (id method in apiList) {
            NSString *methodStr = (NSString *)method;
            [_methodDict setValue:[NSString stringWithFormat:@"/%@", method] forKey:methodStr];
        }
    }
    
    return self;
}

- (NSString *)buildPathWithMethod:(NSString *)methodName
{
    return [_path stringByAppendingFormat:@"%@", methodName];
}

@end
