//
//  JCDispatcher.h
//  JCNetworkNew
//
//  Created by Jam on 13-6-21.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DispatchElement.h"

@interface JCDispatcher : NSObject {
    @package
    NSMutableDictionary *_serviceDict;
    NSMutableDictionary *_dispatchTable;
}

@property (nonatomic, readonly) NSMutableDictionary *serviceDict;

+ (id)sharedInstance;
- (id)init;

- (void)addDispatchItem:(DispatchElement *)item;
- (void)addDispatchUploadItem:(DispatchElement *)item;
- (void)addDispatchDownloadItem:(DispatchElement *)item;

- (void)cancelRequest:(JCRequestID)requestID;

//根据requestID获取分发Item
- (DispatchElement *)getDispatchElement:(JCRequestID)requestID;

- (void)dispatchResponse:(JCNetworkResponse *)response forElement:(DispatchElement *)element;

//factory method
- (MKNetworkHost *)createHostEngineWithRequestHostName:(NSString *)hostName;

@end