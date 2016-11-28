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

- (void)addGetDispatchItem:(DispatchElement *)item;
- (void)addPostDispatchItem:(DispatchElement *)item;
- (void)addDispatchUploadItem:(DispatchElement *)item withFiles:(NSDictionary *)files;
- (void)addDispatchDownloadItem:(DispatchElement *)item;

- (void)cancelRequest:(JCRequestID)requestID;
- (void)cancelAllRequest;

- (void)dispatchResponse:(JCNetworkResponse *)response forElement:(DispatchElement *)element;

@end
