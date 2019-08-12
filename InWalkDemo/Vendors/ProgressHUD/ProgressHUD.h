//
//  ProgressHUD.h
//  测试SVProgressHUD
//
//  Created by 新开元 iOS on 2018/7/19.
//  Copyright © 2018年 新开元 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ProgressHUD : NSObject


+ (void)dismiss;
+ (void)dismiss:(NSTimeInterval)delay;
+ (void)show:(NSString*)status;
+ (void)show:(NSString*)status image:(UIImage *)imgStr imageSize:(CGSize)size;
+ (void)showSuccess:(NSString*)status;
+ (void)showError:(NSString*)status;
+ (void)showTrouble:(NSString*)status;
+ (void)showWarning:(NSString*)status;
+ (void)showNoImage:(NSString*)status;
+ (BOOL)isShow;

@end
