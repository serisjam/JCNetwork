//
//  JCHouseBookService.h
//  JCNetwork
//
//  Created by Jam on 13-6-25.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCBaseService.h"

@interface JCAppsService : JCBaseService

@property (assign, nonatomic) JCServiceType serviceID;

- (id)init;

- (NSString *)buildPathWithMethod:(NSString *)methodName;

@end
