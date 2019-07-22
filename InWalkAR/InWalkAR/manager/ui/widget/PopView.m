//
//  PopView.m
//  同时添加mask和shadow的解决方案（上边框圆角+阴影效果）
//  参考 https://www.jianshu.com/p/0754833349a1
//
//  Created by limu on 2019/5/23.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import "PopView.h"

@implementation PopView
+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        ((CAShapeLayer *)self.layer).fillColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:1.0].CGColor;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    // 上边框圆角
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                         cornerRadii:CGSizeMake(4, 4)];
    ((CAShapeLayer *)self.layer).path = maskPath.CGPath;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    ((CAShapeLayer *)self.layer).fillColor = backgroundColor.CGColor;
}
@end
