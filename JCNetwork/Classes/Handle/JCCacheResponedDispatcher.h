//
//  JCCacheResponedDispatcher.h
//  JCNetwork
//
//  Created by seris-Jam on 16/8/27.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCCacheResponed : NSObject <NSCoding>

//时间戳
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, strong) NSDictionary *responedDic;

@end

@interface JCCacheResponedDispatcher : NSObject

+ (id)sharedInstance;

- (void)saveCacheResponed:(NSDictionary *)responedDic forKey:(NSString *)cacheKey;
- (JCCacheResponed *)getCacheResponedWithKey:(NSString *)cacheKey;
- (void)clearn;

@end
