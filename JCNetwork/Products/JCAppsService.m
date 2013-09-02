//
//  JCHouseBookService.m
//  JCNetwork
//
//  Created by Jam on 13-6-25.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCAppsService.h"

@implementation JCAppsService

- (id)init
{
    self = [super init];
    
    if (self) {
        _serviceID = JCAppsServiceID;
        _apiName = @"i-apps";
        _apiVersion = @"1.0";
        
#ifdef DEBUG
        _hostName = @"121.199.6.32:8070";
        _path = @"app/";
#else
        _hostName = @"121.199.6.32:8070";
        _path = @"app/";
#endif
        NSArray *apiList = [NSArray arrayWithObjects:
                            @"downclient.json",
                            @"addclient.json",
                            @"supplierAppList.json",
                            @"addwebclip.json",
                            @"clickwebclip.json",
                            @"app/addAppStartNotice.json",
                            @"addAppEndNotice.json",
                            @"addAppSetupNotice.json",
                            @"checkid.json",
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
