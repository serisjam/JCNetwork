//
//  JCDispatcher.m
//  JCNetworkNew
//
//  Created by Jam on 13-6-21.
//  Copyright (c) 2013年 Jam. All rights reserved.
//

#import "JCDispatcher.h"
#import "JCOperationResponse.h"
#import "MKNetworkRequest+JCNetwork.h"

@implementation JCDispatcher

@synthesize serviceDict = _serviceDict;

+ (id)sharedInstance {
    static dispatch_once_t pred;
    static JCDispatcher *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[JCDispatcher alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#pragma mark - Handle dispatch

- (void)addDispatchItem:(DispatchElement *)item {
    JCRequestID requestID = item.requestID;
    MKNetworkRequest *request = item.request;
    [self cancelRequest:requestID];
    [_dispatchTable setObject:item forKey:[NSNumber numberWithInt:requestID]];
    
    __weak typeof(self) weakSelf = self;
    [request addCompletionHandler:^(MKNetworkRequest* completedRequest){
        switch (completedRequest.state) {
            case MKNKRequestStateStaleResponseAvailableFromCache:
            case MKNKRequestStateResponseAvailableFromCache: {
                JCOperationResponse *operationResponse = [[JCOperationResponse alloc] init];
                operationResponse.request = completedRequest;
                operationResponse.requestID = completedRequest.getRequestID;
                [weakSelf requestFinished:operationResponse];
            }
                break;
            case MKNKRequestStateCompleted: {
                JCOperationResponse *operationResponse = [[JCOperationResponse alloc] init];
                operationResponse.request = completedRequest;
                operationResponse.requestID = completedRequest.getRequestID;
                [weakSelf requestFinished:operationResponse];
            }
                break;
            case MKNKRequestStateError: {
                JCOperationResponse *operationResponse = [[JCOperationResponse alloc] init];
                operationResponse.request = completedRequest;
                operationResponse.requestID = completedRequest.getRequestID;
                [weakSelf requestFailed:operationResponse withError:completedRequest.error];
            }
                break;
            default: {
                [weakSelf cancelRequest:completedRequest.getRequestID];
            }
                break;
        }
    }];
}

- (void)addDispatchUploadItem:(DispatchElement *)item {
    JCRequestID requestID = item.requestID;
    MKNetworkRequest *request = item.request;
    [self cancelRequest:requestID];
    [_dispatchTable setObject:item forKey:[NSNumber numberWithInt:requestID]];
    
    __weak typeof(self) weakSelf = self;
    [request addUploadProgressChangedHandler:^(MKNetworkRequest* completedRequest){
        switch (completedRequest.state) {
            case MKNKRequestStateCompleted: {
                JCOperationResponse *operationResponse = [[JCOperationResponse alloc] init];
                operationResponse.request = completedRequest;
                operationResponse.requestID = completedRequest.getRequestID;
                [weakSelf requestFinished:operationResponse];
            }
                break;
            case MKNKRequestStateError: {
                JCOperationResponse *operationResponse = [[JCOperationResponse alloc] init];
                operationResponse.request = completedRequest;
                operationResponse.requestID = completedRequest.getRequestID;
                [weakSelf requestFailed:operationResponse withError:completedRequest.error];
            }
                break;
            default: {
                [weakSelf cancelRequest:completedRequest.getRequestID];
            }
                break;
        }
    }];
}

- (void)addDispatchDownloadItem:(DispatchElement *)item {
    JCRequestID requestID = item.requestID;
    MKNetworkRequest *request = item.request;
    [self cancelRequest:requestID];
    [_dispatchTable setObject:item forKey:[NSNumber numberWithInt:requestID]];
    
    __weak typeof(self) weakSelf = self;
    [request addDownloadProgressChangedHandler:^(MKNetworkRequest* completedRequest){
        switch (completedRequest.state) {
            case MKNKRequestStateCompleted: {
                JCOperationResponse *operationResponse = [[JCOperationResponse alloc] init];
                operationResponse.request = completedRequest;
                operationResponse.requestID = completedRequest.getRequestID;
                [weakSelf requestFinished:operationResponse];
            }
                break;
            case MKNKRequestStateError: {
                JCOperationResponse *operationResponse = [[JCOperationResponse alloc] init];
                operationResponse.request = completedRequest;
                operationResponse.requestID = completedRequest.getRequestID;
                [weakSelf requestFailed:operationResponse withError:completedRequest.error];
            }
                break;
            default: {
                [weakSelf cancelRequest:completedRequest.getRequestID];
            }
                break;
        }
    }];
}

- (DispatchElement *)getDispatchElement:(JCRequestID)requestID {
    id dispatchOperation = [_dispatchTable objectForKey:[NSNumber numberWithInt:requestID]];
    
    if (dispatchOperation) {
        return dispatchOperation;
    }
    return nil;
}

- (void)cancelRequest:(JCRequestID)requestID {
    MKNetworkRequest *request = [_dispatchTable objectForKey:[NSNumber numberWithInt:requestID]];
    if (request) {
        [request cancel];
        [_dispatchTable removeObjectForKey:[NSNumber numberWithInt:requestID]];
    }
}

#pragma mark - Handle requests

- (void)dispatchResponse:(JCNetworkResponse *)response forElement:(DispatchElement *)element {
    JCRequestID requestID = [element requestID];
    
    if (element.responseBlock) {
        element.responseBlock(response);
    }
    // remove dispatch item from dispatch table
    [_dispatchTable removeObjectForKey:[NSNumber numberWithInt:requestID]];
}

#pragma mark - Handle responses

- (void)requestFinished:(JCOperationResponse *)operationResponse {
    DispatchElement *element = [_dispatchTable objectForKey:[NSNumber numberWithInt:[operationResponse requestID]]];
    if (!element) {
        return ;
    }
    
    NSDictionary *responseDict = [operationResponse.request responseAsJSON];
    JCNetworkResponse *response = [[JCNetworkResponse alloc] init];
    [response setRequestID:operationResponse.requestID];
    
    if ([element entityClassName] != nil) {
        Class cls = NSClassFromString(element.entityClassName);
        NSObject *responsed = [cls yy_modelWithDictionary:responseDict];
        [response setContent:responsed];
    } else {
        [response setContent:responseDict];
    }
    
    response.progress = operationResponse.request.progress;
    [response setStatus:JCNetworkResponseStatusSuccess];
    [self dispatchResponse:response forElement:element];
}

- (void)requestFailed:(JCOperationResponse *)operationResponse withError:(NSError *)error {
    id element = [_dispatchTable objectForKey:[NSNumber numberWithInt:[operationResponse requestID]]];
    if (!element)
        return;
    
    JCNetworkResponse *response = [[JCNetworkResponse alloc] init];
    [response setRequestID:operationResponse.requestID];
    [response setError:operationResponse.request.error];
    [response setContent:nil];
    [response setStatus:JCNetworkResponseStatusFailed];
    [response setError:error];
    
    [self dispatchResponse:response forElement:element];
}

//factory method returen different products request queue
- (MKNetworkHost *)createHostEngineWithRequestHostName:(NSString *)hostName {
    if (hostName) {
        MKNetworkHost *hostEngine = [[MKNetworkHost alloc] initWithHostName:hostName];
        return hostEngine;
    }
    return nil;
}

@end
