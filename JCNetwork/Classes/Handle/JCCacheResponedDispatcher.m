//
//  JCCacheResponedDispatcher.m
//  JCNetwork
//
//  Created by seris-Jam on 16/8/27.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "JCCacheResponedDispatcher.h"

@implementation JCCacheResponed

- (instancetype)init {
    self = [super init];
    
    if (self) {
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithDouble:_timeInterval] forKey:@"timeInterval"];
    [aCoder encodeObject:_responedDic forKey:@"responedDic"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.timeInterval = [[aDecoder decodeObjectForKey:@"timeInterval"] doubleValue];
        self.responedDic = [aDecoder decodeObjectForKey:@"responedDic"];
    }
    return self;
}

@end


@interface JCCacheResponedDispatcher ()

@property (nonatomic, strong) YYCache *cache;

@end

@implementation JCCacheResponedDispatcher

+ (id)sharedInstance {
    static dispatch_once_t pred;
    static JCCacheResponedDispatcher *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[JCCacheResponedDispatcher alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        self.cache = [[YYCache alloc] initWithName:@"JCNetworkCache"];
        self.cache.memoryCache.shouldRemoveAllObjectsOnMemoryWarning = YES;
        self.cache.memoryCache.shouldRemoveAllObjectsWhenEnteringBackground = YES;

    }
    return self;
}

- (void)saveCacheResponed:(NSDictionary *)responedDic forKey:(NSString *)cacheKey {
    JCCacheResponed *cacheResponed = [[JCCacheResponed alloc] init];
    cacheResponed.timeInterval = [[NSDate date] timeIntervalSince1970];
    cacheResponed.responedDic = responedDic;
    
    [self.cache setObject:cacheResponed forKey:cacheKey];
}

- (JCCacheResponed *)getCacheResponedWithKey:(NSString *)cacheKey {
    return [self.cache objectForKey:cacheKey];
}

- (void)clearn {
    [self.cache removeAllObjects];
}

@end
