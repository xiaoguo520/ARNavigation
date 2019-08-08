//
//  WFShape.m
//  InWalkAR
//
//  Created by wangfan on 2018/7/19.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import "WFShape.h"

@implementation WFShape

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.alpha = 1;
    }
    return self;
}

-(void) drawSelf{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, _lineWidth);
    [_lineColor setStroke];
    [_fillColor setFill];
}
@end
