//
//  NavigationViewController.m
//  InWalkDemo
//
//  Created by limu on 2019/4/18.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import "ARNavigationViewController.h"
#import <InWalkAR/InWalkAR.h>
#import "Global.h"

@interface ARNavigationViewController ()<InWalkManagerDelegate>
@property(nonatomic) InWalkManager * inWalkManager;
@end

@implementation ARNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
//    //从本地加载数据
//    NSString *file = [NSBundle.mainBundle pathForResource:@"songriparking3.json" ofType:nil]; // 最新版本
//    NSData *data = [NSData dataWithContentsOfFile:file];
//    //    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//
////    self.inWalkManager = [[InWalkManager alloc]initWithContainer:self.view data:data];
//    self.inWalkManager = [[InWalkManager alloc]initWithContainer:self.view productId: [Global sharedInstance].val];
////    self.inWalkManager = [[InWalkManager alloc]initWithContainer:self.view productId: @"5cbffd2664c2af7b7e53ea6d"];
//    self.inWalkManager.delegate = self;
    
    
    //从本地加载数据
    NSArray<NSData *> *data;
    
    
    if ([[Global sharedInstance].val isEqualToString:@"id_xxxxx"]) {
        NSString *strF1 = [NSBundle.mainBundle pathForResource:@"gz_mall.json" ofType:nil];
        NSData *dataF1 = [NSData dataWithContentsOfFile:strF1];
        NSString *strF2 = [NSBundle.mainBundle pathForResource:@"gz_parking.json" ofType:nil];
        NSData *dataF2 = [NSData dataWithContentsOfFile:strF2];
        data = @[dataF1, dataF2];
    } else if ([[Global sharedInstance].val isEqualToString:@"id_xxxxx22"]) {
        NSString *strF1 = [NSBundle.mainBundle pathForResource:@"sz_zhuoyue_b2.json" ofType:nil];
        NSData *dataF1 = [NSData dataWithContentsOfFile:strF1];
        data = @[dataF1];
    }

    self.inWalkManager = [[InWalkManager alloc]initWithContainer:self.view data:data];
    self.inWalkManager.delegate = self;
    
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
    NSLog(@"error: %@", errorInfo);
}

-(void) didEndNavigation{
    NSLog(@" did end nav ...");
    NSLog(@"  555 >>> didEndNavigationToPoint .. dismiss");
    [self dismissViewControllerAnimated:NO completion:nil];
    
    // todo release related resources.
    
    
    if (self.inWalkManager) {
        [self.inWalkManager releaseResource];
    }
    
    
}

@end
