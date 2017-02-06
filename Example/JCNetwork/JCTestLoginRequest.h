//
//  JCTestLoginRequest.h
//  JCNetwork
//
//  Created by 贾淼 on 17/2/6.
//  Copyright © 2017年 贾淼. All rights reserved.
//

#import <JCNetwork/JCNetwork.h>

@interface JCTestLoginRequest : JCRequestObj

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@end
