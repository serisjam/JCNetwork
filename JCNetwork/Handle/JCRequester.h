//
//  JCRequester.h
//  JCNetworkNew
//
//  Created by Jam on 13-6-20.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCDispatcher.h"
#import "JCNetworkDefine.h"

#define JC_MIN_REQUESTID 1
#define JC_MAX_REQUESTID UINT_MAX

@interface JCRequester : NSObject
{
    JCDispatcher *_dispatcher;
    NSMutableDictionary *_serviceDict;
    NSMutableDictionary *_servicesRequestEngine;
    
    JCRequestID _lastRequestID;
}

+ (id)sharedInstance;
- (id)init;

- (void)autoLoadImageWithURL:(NSURL *)imageURL placeHolderImage:(UIImage*)image toImageView:(UIImageView *)imageView;
- (JCRequestID)httpGetRquest:(NSString *)path service:(JCServiceType)serviceID params:(NSDictionary *)params target:(id)target action:(SEL)action;
- (JCRequestID)httpPostRquest:(NSString *)path service:(JCServiceType)serviceID params:(NSDictionary *)params target:(id)target action:(SEL)action;
//upload
- (JCRequestID)httpPost:(NSString *)path params:(NSDictionary *)params files:(NSDictionary *)files serivce:(JCServiceType)serviceID target:(id)target action:(SEL)action;
- (void)onUploadProgressChanged:(JCRequestID)requestID target:(id)target action:(SEL)action;

- (void)cancelRequest:(JCRequestID)requestID;

- (NSString *)getNetworkStatus;

@end
