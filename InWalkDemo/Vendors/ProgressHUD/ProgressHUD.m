//
//  ProgressHUD.m
//  测试SVProgressHUD
//
//  Created by 新开元 iOS on 2018/7/19.
//  Copyright © 2018年 新开元 iOS. All rights reserved.
//

#import "ProgressHUD.h"
#import <SVProgressHUD/SVProgressHUD.h>

@implementation ProgressHUD


+(void)load{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
//    [SVProgressHUD setImageViewSize:CGSizeMake(28, 28)];
    [SVProgressHUD setFont:[UIFont systemFontOfSize:16]];
    [SVProgressHUD setMaximumDismissTimeInterval:5.0];
    [SVProgressHUD setMinimumDismissTimeInterval:2.0];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
//    [SVProgressHUD set]
    [SVProgressHUD setRingRadius:5];
    [SVProgressHUD setCornerRadius:5];
    [SVProgressHUD setRingThickness:2];// 转圈的宽度
    [SVProgressHUD setFadeInAnimationDuration:0.1];
    [SVProgressHUD setFadeOutAnimationDuration:0.1];
    [SVProgressHUD setSuccessImage:[UIImage imageNamed:@"success-white"]];
    [SVProgressHUD setErrorImage:[UIImage imageNamed:@"error-white"]];
    [SVProgressHUD setInfoImage:[UIImage imageNamed:@"trouble-white"]];
    //    [SVProgressHUD setMinimumSize:CGSizeMake(100, 100)];
    
}

+(void)dismiss{
    if ([ProgressHUD isShow]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([SVProgressHUD isProgress]) {
                //延时。0.5秒
                [SVProgressHUD dismiss];
            }
        });
    }
}


+(void)dismiss:(NSTimeInterval)delay{
    [SVProgressHUD dismissWithDelay:delay];
}

+(void)show:(NSString *)status{
    [SVProgressHUD setMinimumSize:CGSizeMake(100 * Size_FIT_WIDTH, 100 * Size_FIT_WIDTH)];
    [SVProgressHUD showWithStatus:status];
}

+(void)show:(NSString *)status image:(UIImage *)imgStr imageSize:(CGSize)size{
    [SVProgressHUD setImageViewSize:size];
    [SVProgressHUD showImage:imgStr status:status];
}

+(void)showNoImage:(NSString *)status{
    [ProgressHUD dismiss];
    [SVProgressHUD setMinimumSize:CGSizeMake(100 * Size_FIT_WIDTH, 0)];
    [SVProgressHUD showImage:[UIImage imageNamed:@""] status:status];
}

+(void)showSuccess:(NSString *)status{
    [SVProgressHUD setMinimumSize:CGSizeMake(100, 100)];
    [SVProgressHUD showSuccessWithStatus:status];
}

+(void)showError:(NSString *)status{
    [SVProgressHUD setMinimumSize:CGSizeMake(100, 100)];
    [SVProgressHUD showErrorWithStatus:status];
}

+(void)showTrouble:(NSString *)status{
    [SVProgressHUD setMinimumSize:CGSizeMake(100, 100)];
    [SVProgressHUD showInfoWithStatus:status];
}


+(void)showWarning:(NSString *)status{
    [SVProgressHUD showImage:[UIImage imageNamed:@"warning-white"] status:status];
}

+(BOOL)isShow{
    return [SVProgressHUD isVisible];
}


@end
