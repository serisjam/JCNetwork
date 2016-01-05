//
//  MKNetworkRequest+JCNetwork.m
//  JCNetwork
//
//  Created by Jam on 16/1/5.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "MKNetworkRequest+JCNetwork.h"
#import <objc/runtime.h>

static const char *kJCNetworkRequestID;

@implementation MKNetworkRequest (JCNetwork)

- (void)setRequestID:(JCRequestID)requestID {
    objc_setAssociatedObject(self, kJCNetworkRequestID, [NSNumber numberWithInt:requestID], OBJC_ASSOCIATION_ASSIGN);
}

- (JCRequestID)getRequestID {
    NSNumber *requestNumber = objc_getAssociatedObject(self, kJCNetworkRequestID);
    JCRequestID requestId = [requestNumber intValue];
    return requestId;
}

@end
