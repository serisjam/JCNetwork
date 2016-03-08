//
//  JCEstateBookService.m
//  JCNetwork
//
//  Created by Jam on 13-6-25.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCEstateBookService.h"

@implementation JCEstateBookService

- (id)init
{
    self = [super init];
    
    if (self) {
            _serviceID = JCEstateBookServiceID;
            _apiName = @"i-estatebook";
            _apiVersion = @"1.0";
            
#ifdef DEBUG
        _hostName = @"dcs.zhaofangtong.com";
        _path = @"Interface/";
#else
            _hostName = @"dcs.zhaofangtong.com";
            _path = @"Interface/";
#endif
            NSArray *apiList = [NSArray arrayWithObjects:
                                //手机动态获取所有频道的分类
                                @"AppNewsCategory.ashx",
                                //通过手机串号，获取该用户已经订阅的频道
                                @"AppGetSubscriberNewsCategory.ashx",
                                //将自己订阅的频道保存在服务器端
                                @"AppSaveSubscriberNewsCategory.ashx",
                                //推荐
                                @"AppRecommend.ashx",
                                //根据不同的条件获取相关新闻
                                @"AppNews.ashx",
                                //每条新闻的相关评论
                                @"AppRemark.ashx",
                                //添加好评
                                @"AppGoodRemark.ashx",
                                //保存评论
                                @"AppRemarkAdd.ashx",
                                //反馈信息
                                @"AppFeedback.ashx",
                                //升级信息
                                @"AppUpdate.ashx",
                                //测试URL下载
                                @"Apps.ashx",
                                
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
