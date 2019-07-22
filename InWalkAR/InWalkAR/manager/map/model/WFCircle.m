//
//  WFCircle.m
//  InWalkAR
//
//  Created by wangfan on 2018/7/19.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import "WFCircle.h"

@implementation WFCircle
-(instancetype) init{
    self = [self initWithCenter:CGPointMake(0, 0) radius:1];
    return self;
}

-(instancetype) initWithCenter:(CGPoint) center radius:(float) radius{
    if(self = [super init]){
        _center = center;
        _radius = radius;
        self.lineWidth = 2;
        self.lineColor = UIColor.blackColor;

        self.fillColor = UIColor.blackColor;
    }
    return self;
}

-(void) drawSelf{
    [super drawSelf];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, &CGAffineTransformIdentity, _center.x, _center.y, _radius, 0, M_PI *2, NO);
    CGPathCloseSubpath(path);
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGPathRelease(path);
    
}

@end
