//
//  PhonePoseUI.m
//  InWalkAR
//
//  Created by limu on 2019/4/27.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width

#import "PhonePoseUI.h"

@interface PhonePoseUI(){
    UIView *_superView;
    UIView *popView;
    InWalkPhonePose currentFlag;
    UILabel *titleView;
    UILabel *countdownView;
    UIImageView *wrongPoseimg;
    UIImageView *countdownImg;
    UILabel *tipsView;
}
@end

@implementation PhonePoseUI

- (void)setSuperView:(UIView *)view {
    _superView = view;
    currentFlag = InWalkPhonePoseFree;
}

- (void)setPhonePose:(InWalkPhonePose)flag {
    if (currentFlag == flag) return;
    
    // 375 * 667
    
    // 1 -- 1-5-1 -- 1 >> 9*60=540(h)
    // 1 - 5 - 1 >> 7*5=350(w)
    
    if (!popView) {
        //NSLog(@"  %f    %f", kScreenWidth, kScreenHeight);
        CGFloat paddingTop, paddingLeft, w, h;
        w = 300;
        h = 500;
        paddingTop = (kScreenHeight - h) / 2;
        paddingLeft = (kScreenWidth - w) / 2;
        CGRect rect = CGRectMake(paddingLeft, paddingTop, w, h);
        popView = [[UIView alloc] initWithFrame:rect];
        popView.backgroundColor = [UIColor whiteColor];
        popView.layer.cornerRadius = 10; // 圆角
        
        // add title
        CGRect rt1 = CGRectMake(20, 40, w - 20 * 2, 60);
        titleView = [[UILabel alloc] initWithFrame: rt1];
        //[titleView setText: @"Pose is right ...."];
        [titleView setTextAlignment:NSTextAlignmentCenter];
        [titleView setFont:[UIFont systemFontOfSize:24 weight:UIFontWeightMedium]];
        [popView addSubview:titleView];
        
        // add image
        CGRect rt2 = CGRectMake(10, 120, 280, 280);
        wrongPoseimg = [[UIImageView alloc] initWithFrame:rt2];
        [wrongPoseimg setImage:[UIImage imageNamed:@"pose_wrong.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
        wrongPoseimg.backgroundColor = [UIColor redColor];
        wrongPoseimg.contentMode = UIViewContentModeScaleAspectFill;
        [popView addSubview:wrongPoseimg];
        
        // add image2
        CGRect rt21 = CGRectMake((w - 120) / 2, 180, 120, 120);
        countdownImg = [[UIImageView alloc] initWithFrame:rt21];
        [countdownImg setImage:[UIImage imageNamed:@"pose_right.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
        countdownImg.contentMode = UIViewContentModeCenter;
        [popView addSubview:countdownImg];
        //countdownImg.backgroundColor = [UIColor greenColor];
        // add text(countdown)
        CGRect rt3 = CGRectMake(20, 300, w - 20 * 2, 60);
        countdownView = [[UILabel alloc] initWithFrame:rt3];
        //[countdownView setText:@"3"];
        [countdownView setTextAlignment:NSTextAlignmentCenter];
        [countdownView setFont:[UIFont systemFontOfSize:24 weight:UIFontWeightMedium]];
        [popView addSubview:countdownView];
        
        // add tips
        CGRect rt4 = CGRectMake(20, 400, w - 20 * 2, 60);
        tipsView = [[UILabel alloc] initWithFrame:rt4];
        //[tipsView setText:@"tips ..........."];
        [tipsView setTextAlignment:NSTextAlignmentCenter];
        [tipsView setFont:[UIFont systemFontOfSize:16]]; // weight:UIFontWeightMedium
        tipsView.numberOfLines = 5;
        [popView addSubview:tipsView];
        
        [_superView addSubview:popView];
    }
    
    currentFlag = flag;
    switch (currentFlag) {
        case InWalkPhonePoseKeep3:
            // 姿势正确：保持3秒
            ////NSLog(@" >> setPhonePose .. 3");
            [self showRightPose:@"3"];
            
            // 震动手机进行提示
            break;
        case InWalkPhonePoseKeep2:
            // 姿势正确：保持2秒
            ////NSLog(@" >> setPhonePose .. 2");
            [self showRightPose:@"2"];
            break;
        case InWalkPhonePoseKeep1:
            // 姿势正确：保持1秒
            ////NSLog(@" >> setPhonePose .. 1");
            [self showRightPose:@"1"];
            break;
        case InWalkPhonePoseFree:
            // 开始导航
            ////NSLog(@" >> setPhonePose .. 0");
            if (popView) {
                [popView removeFromSuperview];
            }
            break;
        case InWalkPhonePoseWrong:
        default:
            // 姿势错误：保持竖直
            ////NSLog(@" >> setPhonePose .. xxx");
            [self showWrongPose];
            break;
    }
}

- (void)showRightPose:(NSString *)countdown {
    [titleView setText:@"姿势正确"];
    [wrongPoseimg setHidden:YES];
    [countdownView setHidden:NO];
    [countdownView setText:countdown];
    [countdownImg setHidden:NO];
    [tipsView setText:@"请保持这个动作维持3秒，这有利于我们充分理解您的周围环境"];
}

- (void)showWrongPose {
    [titleView setText:@"手持手机并保持垂直"];
    [wrongPoseimg setHidden:NO];
    [countdownView setHidden:YES];
    [countdownImg setHidden:YES];
    [tipsView setText:@"请使用时处于站立状态，手持手机并保持与地面垂直"];
}

@end
