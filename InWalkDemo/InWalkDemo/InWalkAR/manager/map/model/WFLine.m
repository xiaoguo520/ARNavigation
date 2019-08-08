//
//  WFLine.m
//  InWalkAR
//
//  Created by wangfan on 2018/7/19.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import "WFLine.h"

@implementation WFLine
-(instancetype) init{
    if(self = [super init]){
        self.lineColor = UIColor.blackColor;
        self.lineWidth = 2;
    }
    return self;
}

-(void) drawSelf{
    NSAssert(_pointArray.count>=2,@"数组长度必须大于等于2");
    NSAssert([[_pointArray[0] class] isSubclassOfClass:[NSValue class]], @"数组成员必须是CGPoint组成的NSValue");
    [super drawSelf];
    
    CGContextRef     context = UIGraphicsGetCurrentContext();
    CGFloat padding = 4; // 外层边框的宽度
    
    CGContextSetAlpha(context, self.alpha);
    
    if (_pointArray.count == 2) {
        // 只绘制终点
        
        // 2. 外层圆
        CGPoint point = [_pointArray[_pointArray.count - 1] CGPointValue]; // 终点
        [self.lineColor setFill];
        // 终点圆（外层边框填充）
        CGContextAddArc(context, point.x, point.y, self.lineWidth / 2, 0, M_PI *2, 0); //添加一个圆
        CGContextDrawPath(context, kCGPathFill);
        
        // 4. 里层圆
        [self.fillColor setFill];
        // 终点圆（里层填充）
        CGContextAddArc(context, point.x, point.y, self.lineWidth / 2 - padding, 0, M_PI *2, 0); //添加一个圆
        CGContextDrawPath(context, kCGPathFill);
        
        return;
    }
    
    // 起点
    NSValue *startPointValue = _pointArray[0];
    CGPoint  startPoint      = [startPointValue CGPointValue];
    
//    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
//
//    for(int i = 1;i<_pointArray.count;i++)
//    {
//        NSAssert([[_pointArray[i] class] isSubclassOfClass:[NSValue class]], @"数组成员必须是CGPoint组成的NSValue");
//        NSValue *pointValue = _pointArray[i];
//        CGPoint  point      = [pointValue CGPointValue];
//        CGContextAddLineToPoint(context, point.x,point.y);
//    }
//
//    CGContextStrokePath(context);
    
    // 使用贝塞尔曲线平滑处理路线锐角处
    // 参考 https://ekulelu.github.io/2017/10/30/画图wiki/iOS%20画图轨迹圆滑处理/
    UIBezierPath *innerPath = [UIBezierPath bezierPath];
    UIBezierPath *outterPath = [UIBezierPath bezierPath];
    [innerPath moveToPoint:CGPointMake(startPoint.x, startPoint.y)];
    [outterPath moveToPoint:CGPointMake(startPoint.x, startPoint.y)];
    CGPoint midPt/*P0*/, nextMidPt/*P2*/, currentPt/*P1*/, nextPt;
    // 起点到第一个midPt
    if (_pointArray.count > 2) {
        currentPt = [_pointArray[1] CGPointValue];
        midPt = CGPointMake((startPoint.x + currentPt.x) / 2, (startPoint.y + currentPt.y) / 2);
        [innerPath addLineToPoint: midPt];
        [outterPath addLineToPoint: midPt];
    }
    // 第一个midPt到最后一个midPt
    for (int i = 1; i < _pointArray.count - 1; i++) {
        currentPt = [_pointArray[i] CGPointValue];
        nextPt = [_pointArray[i + 1] CGPointValue];
        nextMidPt = CGPointMake((currentPt.x + nextPt.x) / 2, (currentPt.y + nextPt.y) / 2);
        [innerPath addQuadCurveToPoint:nextMidPt controlPoint:currentPt];
        [outterPath addQuadCurveToPoint:nextMidPt controlPoint:currentPt];
    }
    // 最后一个midPt到终点
    if (_pointArray.count > 2) {
        [innerPath addLineToPoint: [_pointArray[_pointArray.count - 1] CGPointValue]];
        [outterPath addLineToPoint: [_pointArray[_pointArray.count - 1] CGPointValue]];
    }
    
    // 1. 线的外层边框(宽度较大)
    CGContextAddPath(context, innerPath.CGPath);
    CGContextDrawPath(context, kCGPathStroke);
    
    // 2. 外层圆
    CGPoint point = [_pointArray[_pointArray.count - 1] CGPointValue]; // 终点
    [self.lineColor setFill];
    // 起点圆（外层边框填充）
    CGContextAddArc(context, startPoint.x, startPoint.y, self.lineWidth / 2, 0, M_PI *2, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathFill);
    // 终点圆（外层边框填充）
    CGContextAddArc(context, point.x, point.y, self.lineWidth / 2, 0, M_PI *2, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathFill);
    
    // 3. 线的里层填充(宽度较小)
    [self.fillColor setStroke];
    CGContextSetLineWidth(context, self.lineWidth - padding * 2);
    CGContextAddPath(context, outterPath.CGPath);
    CGContextDrawPath(context, kCGPathStroke);
    
    // 4. 里层圆
    [self.fillColor setFill];
    // 起点圆（里层填充）
    CGContextAddArc(context, startPoint.x, startPoint.y, self.lineWidth / 2 - padding, 0, M_PI *2, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathFill);
    // 终点圆（里层填充）
    CGContextAddArc(context, point.x, point.y, self.lineWidth / 2 - padding, 0, M_PI *2, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathFill);
}
@end
