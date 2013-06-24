//
//  JCNetworkDefine.h
//  JCNetwork
//
//  Created by Jam on 13-6-23.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#ifndef JCNetwork_JCNetworkDefine_h
#define JCNetwork_JCNetworkDefine_h

//定义JCRequestID类型用于记录每次请求的ID
typedef unsigned int JCRequestID;

//错误的请求ID 对应的serviceID不存在后者是请求的methodName不存在
#define JC_ERROR_REQUESTID 0        

//每个新增产品线需增加新的Product类并在这里添加新的说明
#define SERVICES [NSArray arrayWithObjects:@"JCZhaofangtongService", @"JCHouseService", nil]

//请求响应的状态
typedef enum _JCNetworkResponseStatus {
    JCNetworkResponseStatusSuccess,
    JCNetworkResponseStatusFailed
} JCNetworkResponseStatus;

//定义不同产品的ServiceID
typedef enum _JCServiceType
{
    JCZhaofangtongServiceID = 10,
    JCHouseServiceID = 20,
} JCServiceType;

#endif
