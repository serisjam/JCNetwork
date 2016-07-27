//
//  JCRequester.m
//  JCNetworkNew
//
//  Created by Jam on 13-6-20.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCRequester.h"
#import "DispatchElement.h"

#import "AFNetworking.h"
#import "AFImageDownloader.h"
#import "UIImageView+AFNetworking.h"

@implementation JCRequester

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static JCRequester *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[JCRequester alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _requestEngines = [[NSMutableDictionary alloc] init];
        _dispatcher = [JCDispatcher sharedInstance];
        
        _lastRequestID = JC_MIN_REQUESTID;
    }
    
    return self;
}

#pragma mark request block

- (JCRequestID)httpGetWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withCompleteBlock:(JCNetworkResponseBlock)responedBlock {
    if (++_lastRequestID >= JC_MAX_REQUESTID) {
        _lastRequestID = JC_MIN_REQUESTID;
    }
    
    return _lastRequestID;
}

- (JCRequestID)httpPostWithRequest:(JCRequestObj *)requestObj entityClass:(NSString *)entityName withCompleteBlock:(JCNetworkResponseBlock)responedBlock {
    if (++_lastRequestID >= JC_MAX_REQUESTID) {
        _lastRequestID = JC_MIN_REQUESTID;
    }
    
    JCRequest *request = [[JCRequest alloc] initWithRequestObj:requestObj];
    DispatchElement *element = [self getDispatchElementWithCompleteBlock:responedBlock WithRequest:request entityClass:entityName];
    [_dispatcher addPostDispatchItem:element];
    
    return _lastRequestID;
}

#pragma mark upload request
- (JCRequestID)upLoadFileWithRequest:(JCRequestObj *)requestObj files:(NSDictionary *)files entityClass:(NSString *)entityName withUpLoadBlock:(JCNetworkResponseBlock)upLoadBlock {
    if (++_lastRequestID >= JC_MAX_REQUESTID) {
        _lastRequestID = JC_MIN_REQUESTID;
    }
    
    return _lastRequestID;
}

#pragma mark download request
- (JCRequestID)downLoadFileFrom:(NSURL *)remoteURL toFile:(NSString*)filePath withDownLoadBlock:(JCNetworkResponseBlock)responedBlock {
    if (++_lastRequestID >= JC_MAX_REQUESTID) {
        _lastRequestID = JC_MIN_REQUESTID;
    }
    
    return _lastRequestID;
}

//image request
- (void)autoLoadImageWithURL:(NSURL *)imageURL placeHolderImage:(UIImage*)image toImageView:(UIImageView *)imageView {
    [imageView setImageWithURL:imageURL placeholderImage:image];
}

- (void)loadImageWithURL:(NSURL *)imageURL completionHandler:(JCNetworkImageFetch)imageFetchBlock {
    UIImage *cachedImage = [self getImageIfExisted:imageURL];
    
    if (cachedImage) {
        imageFetchBlock(cachedImage, YES);
        return ;
    }
    AFImageDownloader *downloader = [AFImageDownloader defaultInstance];
    NSMutableURLRequest *imageURLRequest = [NSMutableURLRequest requestWithURL:imageURL];
    [imageURLRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [downloader downloadImageForURLRequest:imageURLRequest success:^(NSURLRequest * request, NSHTTPURLResponse * responed, UIImage * image){
        imageFetchBlock(image, NO);
    } failure:^(NSURLRequest * request, NSHTTPURLResponse * responed, NSError * error){
        imageFetchBlock(nil, NO);
    }];
}

- (UIImage *)getImageIfExisted:(NSURL *)imageURL {
    
    AFImageDownloader *downloader = [AFImageDownloader defaultInstance];
    id <AFImageRequestCache> imageCache = downloader.imageCache;
    NSMutableURLRequest *imageURLRequest = [NSMutableURLRequest requestWithURL:imageURL];
    [imageURLRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    UIImage *cachedImage = [imageCache imageforRequest:imageURLRequest withAdditionalIdentifier:nil];
    
    if (cachedImage) {
        return cachedImage;
    }
    
    return nil;
}

#pragma cancelRequest

- (void)cancelRequest:(JCRequestID)requestID {
    [_dispatcher cancelRequest:requestID];
}

#pragma mark bulid DispatchElement

- (DispatchElement *)getDispatchElementWithCompleteBlock:(JCNetworkResponseBlock)responedBlock WithRequest:(JCRequest *)request entityClass:(NSString *)entityName {
    
    DispatchElement *element = [[DispatchElement alloc] init];
    element.requestID = _lastRequestID;
    element.responseBlock = responedBlock;
    element.entityClassName = entityName;
    element.request = request;
    
    return element;
}

@end
