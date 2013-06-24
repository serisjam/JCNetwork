//
//  JCHouseService.m
//  JCNetwork
//
//  Created by Jam on 13-6-24.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCHouseService.h"

@implementation JCHouseService

- (id)init
{
    self = [super init];
    
    if (self) {
        _serviceID = JCHouseServiceID;
        _apiName = @"i-139house";
        _apiVersion = @"1.0";
        
#ifdef DEBUG
        _hostName = @"api.zhaofangtong.net";
        _path = @"house/interface/";
#else
        _hostName = @"api.zhaofangtong.net";
        _path = @"house/interface/";
#endif
        NSArray *apiList = [NSArray arrayWithObjects:
                            //cityInfo
                            @"cityinfo.ashx",
                            @"getcitys.ashx",
                            @"getCitysInfo.ashx",
                            
                            //advertise
                            @"advinfo.ashx",    //only in ipad
                            
                            //agent
                            @"agentdetail.ashx",
                            @"agenthouselist.ashx",
                            @"agentlist",
                            
                            //uploadToken
                            @"upload.ashx",
                            
                            //upgrade
                            @"updrade.ashx",
                            
                            //search
                            @"search.ashx",
                            
                            //projectlist
                            @"projectdetail.ashx",
                            
                            //notice
                            @"mynotices,ashx",
                            
                            //login
                            @"login.ashx",
                            
                            //favorite
                            @"favorite.ashx",
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
    return [_path stringByAppendingFormat:@"%@/%@/%@", _apiName, _apiVersion, methodName];
}

@end
