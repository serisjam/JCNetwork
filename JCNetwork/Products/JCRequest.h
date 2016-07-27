//
//  JCRequest.h
//  JCNetwork
//
//  Created by 贾淼 on 16/7/20.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import <Foundation/Foundation.h>

//内部请求类，主要用来保存内部请求参数等

@interface JCRequest : NSObject

@property (nonatomic, readonly, strong) NSString *URLString;
@property (nonatomic, readonly, strong) NSDictionary *paramsDic;
@property (nonatomic, readonly, strong) AFHTTPRequestSerializer<AFURLRequestSerialization> *requestSerializer;

- (instancetype)initWithRequestObj:(JCRequestObj *)requestObj;

@end
