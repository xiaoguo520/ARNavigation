//
//  ARTestViewController.m
//  InWalkDemo
//
//  Created by limu on 2018/11/28.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import "ARTestViewController.h"
#import <InWalkAR/InWalkAR.h>

@interface ARTestViewController ()<InWalkManagerDelegate>

@property(nonatomic) InWalkManager * inwalkManager;

@end

@implementation ARTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //从本地加载数据
    //NSString *file = [NSBundle.mainBundle pathForResource:@"songriparking.json" ofType:nil]; // 6个node
    //NSString *file = [NSBundle.mainBundle pathForResource:@"songriparking2.json" ofType:nil]; // 5个node
    NSString *file = [NSBundle.mainBundle pathForResource:@"songriparking3.json" ofType:nil]; // 最新版本
    NSData *data = [NSData dataWithContentsOfFile:file];
    //    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
//    self.inwalkManager = [[InWalkManager alloc]initWithContainer:self.view data:data];
//    self.inwalkManager.delegate = self;
    
}

-(void) didPreparedWithManager:(InWalkManager *)manager{
    //self.prepared = YES;
    //[self removeActivityIndicator];
    // [manager setRenderMode:InWalkRenderMode360Double];
}

-(void) manager:(InWalkManager *)manager didOccurError:(NSError *)error{
    NSString *errorInfo = @"";
    switch (error.code) {
        case InWalkErrorCodeInit:
            errorInfo = @"初始化失败";
            break;
        default:
            break;
    }
    errorInfo = [NSString stringWithFormat:@"%@:%@",errorInfo,error.userInfo[@"message"]];
    //[self.view makeToast:errorInfo];
    
}

-(void) didEndNavigation {
    NSLog(@" did end nav ...");
    [self dismissViewControllerAnimated:NO completion:nil];
    
    // todo release related resources.
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
