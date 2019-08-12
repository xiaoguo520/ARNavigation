//
//  UIButton+Extend.m
//  New_Patient
//
//  Created by 新开元 iOS on 2018/6/20.
//  Copyright © 2018年 新开元 iOS. All rights reserved.
//

#import "UIButton+Extend.h"

@implementation UIButton (Extend)


-(dispatch_source_t)startWithTime:(NSInteger)timeLine title:(NSString *)title countDownTitle:(NSString *)subTitle mainColor:(UIColor *)mColor countColor:(UIColor *)color conuntBlcok:(JKButtonConuntBlcok)conuntBlcok finishBlock:(JKButtonConuntFinshBlcok)finishblock{
    self.selected = YES;
    //倒计时时间
    __block NSInteger timeOut = timeLine;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //每秒执行一次
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        //倒计时结束，关闭
        if (timeOut <= 0) {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.backgroundColor = mColor;
                [self setTitle:title forState:UIControlStateNormal];
                self.userInteractionEnabled = YES;
                if (finishblock) {
                    finishblock();
                }
            });
        } else {
            int allTime = (int)timeLine + 1;
            int seconds = timeOut % allTime;
            NSString *timeStr = [NSString stringWithFormat:@"%0.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.backgroundColor = color;
                [self setTitle:[NSString stringWithFormat:@"%@%@",subTitle,[timeStr formatDataStr]] forState:UIControlStateNormal];
                self.userInteractionEnabled = NO;
            });
            timeOut--;
            if (conuntBlcok) {
                conuntBlcok();
            }
        }
    });
    dispatch_resume(_timer);
    return _timer;
}


-(dispatch_source_t)startGetCodeWithTime:(NSInteger)timeLine title:(NSString *)title countDownTitle:(NSString *)subTitle mainColor:(UIColor *)mColor countColor:(UIColor *)color conuntBlcok:(JKButtonConuntBlcok)conuntBlcok finishBlock:(JKButtonConuntFinshBlcok)finishblock{
    __block NSInteger timeOut = timeLine;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //每秒执行一次
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        //倒计时结束，关闭
        if (timeOut <= 0) {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.backgroundColor = mColor;
                [self setTitle:title forState:UIControlStateNormal];
                self.userInteractionEnabled = YES;
                if (finishblock) {
                    finishblock();
                }
            });
        } else {
            int allTime = (int)timeLine + 1;
            int seconds = timeOut % allTime;
            NSString *timeStr = [NSString stringWithFormat:@"%0.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.backgroundColor = color;
                [self setTitle:[NSString stringWithFormat:@"%@(%@)",subTitle,timeStr] forState:UIControlStateNormal];
                self.userInteractionEnabled = NO;
            });
            timeOut--;
            if (conuntBlcok) {
                conuntBlcok();
            }
        }
    });
    dispatch_resume(_timer);
    return _timer;
}

//更换文字跟图片位置
-(void)ExchangingPositionLabelAndImage{
    
    CGFloat spacing = 3.0;
    [self sizeToFit];
    // 图片右移
    CGSize imageSize = self.imageView.frame.size;
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width * 2 - spacing, 0.0, 0.0);
    
    // 文字左移
    CGSize titleSize = self.titleLabel.frame.size;
    
    self.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, - titleSize.width * 2 - spacing);
}


@end
