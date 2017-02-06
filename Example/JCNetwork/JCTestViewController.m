//
//  JCTestViewController.m
//  JCNetwork
//
//  Created by 贾淼 on 17/2/6.
//  Copyright © 2017年 贾淼. All rights reserved.
//

#import "JCTestViewController.h"

#import <JCNetwork/JCNetwork.h>
#import "JCTestLoginRequest.h"

@interface JCTestViewController ()

@end

@implementation JCTestViewController

- (void)dealloc {
    NSLog(@"dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    JCTestLoginRequest *loginRequest = [[JCTestLoginRequest alloc] init];
    loginRequest.username = @"15205286667";
    loginRequest.password = @"670B14728AD9902AECBA32E22FA4F6BD";
    
    [[JCRequestProxy sharedInstance] httpPostWithRequest:loginRequest entityClass:nil withControlObj:self withCompleteBlock:^(JCNetworkResponse *response) {
        if (response.status == JCNetworkResponseStatusSuccess) {
            NSLog(@"%@", response.content);
        } else {
            NSLog(@"cancel");
        }
    }];
    
    [[JCRequestProxy sharedInstance] httpPostWithRequest:loginRequest entityClass:nil withControlObj:self withCompleteBlock:^(JCNetworkResponse *response) {
        if (response.status == JCNetworkResponseStatusSuccess) {
            NSLog(@"%@", response.content);
        } else {
            NSLog(@"cancel");
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onClickDismiss:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
