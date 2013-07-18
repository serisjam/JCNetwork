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
        _path = @"AppDataAccess/";
#else
            _hostName = @"dcs.zhaofangtong.com";
            _path = @"AppDataAccess/";
#endif
            NSArray *apiList = [NSArray arrayWithObjects:
                                //手机动态获取所有频道的分类
                                @"AppNewsCategory.aspx",
                                //通过手机串号，获取该用户已经订阅的频道
                                @"AppGetSubscriberNewsCategory.aspx",
                                //将自己订阅的频道保存在服务器端
                                @"AppSaveSubscriberNewsCategory.aspx",
                                //推荐
                                @"AppRecommend.aspx",
                                //根据不同的条件获取相关新闻
                                @"iosAppNews.aspx",
                                //每条新闻的相关评论
                                @"AppRemark.aspx",
                                //添加好评
                                @"AppGoodRemark.aspx",
                                //保存评论
                                @"AppRemarkAdd.aspx",
                                //反馈信息
                                @"AppFeedback.aspx",
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
