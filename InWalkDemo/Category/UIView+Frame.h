//
//  UIView+Frame.h
//  NetWalking
//
//  Created by yz on 14/11/5.
//  Copyright (c) 2014年 iThinker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

@property (nonatomic, assign) CGFloat jk_width;
@property (nonatomic, assign) CGFloat jk_height;
@property (nonatomic, assign) CGFloat jk_x;
@property (nonatomic, assign) CGFloat jk_y;

@property (nonatomic, assign) CGSize jk_size;


@property (nonatomic, assign) CGRect jk_frame;

-(CGSize)getLabelSizeWithFont:(CGFloat)font lableText:(NSString *)labelText;

- (void)click:(void(^)(UIView *view, UIGestureRecognizer *sender))block;
- (void)longClick:(void(^)(UIView *view, UIGestureRecognizer *sender))block;

+(UIView *)getLineView;

//绘制虚线
+ (void)cashapeLine:(UIView *)view beginPont:(CGPoint)beginPont endPoint:(CGPoint)endPoint color:(UIColor *) color;

@end
