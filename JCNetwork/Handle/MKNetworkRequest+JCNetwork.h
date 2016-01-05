//
//  MKNetworkRequest+JCNetwork.h
//  JCNetwork
//
//  Created by Jam on 16/1/5.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "MKNetworkRequest.h"

@interface MKNetworkRequest (JCNetwork)

- (void)setRequestID:(JCRequestID)requestID;
- (JCRequestID)getRequestID;

@end
