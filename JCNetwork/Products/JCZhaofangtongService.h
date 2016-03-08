//
//  JCZhaofangtongService.h
//  JCNetwork
//
//  Created by Jam on 13-6-23.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCBaseService.h"

@interface JCZhaofangtongService : JCBaseService

@property (assign, nonatomic) JCServiceType serviceID;

- (id)init;

- (NSString *)buildPathWithMethod:(NSString *)methodName;

@end
