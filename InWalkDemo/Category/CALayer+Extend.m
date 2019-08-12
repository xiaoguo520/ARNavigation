//
//  CALayer+Extend.m
//  New_Patient
//
//  Created by 新开元 iOS on 2019/3/5.
//  Copyright © 2019年 新开元 iOS. All rights reserved.
//

#import "CALayer+Extend.h"

@implementation CALayer (Extend)

+ (CALayer *)addSubLayerWithFrame:(CGRect)frame
                  backgroundColor:(UIColor *)color
                         backView:(UIView *)baseView
{
    CALayer * layer = [[CALayer alloc]init];
    layer.frame = frame;
    layer.backgroundColor = [color CGColor];
    [baseView.layer addSublayer:layer];
    return layer;
}

@end
