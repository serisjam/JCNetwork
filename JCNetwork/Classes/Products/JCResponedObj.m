//
//  JCResponedObject.m
//  JCNetwork
//
//  Created by Jam on 16/1/5.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "JCResponedObj.h"

@implementation JCResponedObj

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    return [self yy_modelWithDictionary:dictionary];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return nil;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return nil;
}

- (id)modelToJSONObject {
    return [self yy_modelToJSONObject];
}

@end
