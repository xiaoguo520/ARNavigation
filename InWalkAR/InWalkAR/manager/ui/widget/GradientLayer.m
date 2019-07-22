//
//  GradientLayer.m
//  InWalkAR
//  用于渐变径向动画
//  https://stackoverflow.com/questions/26907352/how-to-draw-radial-gradients-in-a-calayer
//
//  Created by limu on 2019/5/25.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import "GradientLayer.h"

@implementation GradientLayer

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setNeedsDisplay];
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx {    
    size_t gradLocationsNum = 2;
    CGFloat gradLocations[2] = {0.0f, 1.0f};
    CGFloat gradColors[8] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.5f};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint gradCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat gradRadius = MIN(self.bounds.size.width, self.bounds.size.height);
    
    CGContextDrawRadialGradient(ctx, gradient, gradCenter, 0, gradCenter, gradRadius, kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(gradient);
}

@end
