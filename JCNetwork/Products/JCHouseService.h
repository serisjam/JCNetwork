//
//  JCHouseService.h
//  JCNetwork
//
//  Created by Jam on 13-6-24.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCBaseService.h"

@interface JCHouseService : JCBaseService

@property (assign, nonatomic) JCServiceType serviceID;

- (id)init;

- (NSString *)buildPathWithMethod:(NSString *)methodName;

@end
