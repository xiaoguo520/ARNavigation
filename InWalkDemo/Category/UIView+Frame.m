//
//  UIView+Frame.m
//  NetWalking
//
//  Created by yz on 14/11/5.
//  Copyright (c) 2014年 iThinker. All rights reserved.
//

#import "UIView+Frame.h"
#import <UIKit/UIKit.h>

@implementation UIView (Frame)


-(CGSize)getLabelSizeWithFont:(CGFloat)font lableText:(NSString *)labelText{
    
    return [labelText sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:font],NSFontAttributeName, nil]];
}

- (CGFloat)jk_width
{
    return self.frame.size.width;
}


-(void)setJk_width:(CGFloat)jk_width{
    CGRect frame = self.frame;
    frame.size.width = jk_width;
    self.frame = frame;
}

-(CGFloat)jk_height{
    
    return self.frame.size.height;
}


-(void)setJk_height:(CGFloat)jk_height{
    CGRect frame = self.frame;
    frame.size.height = jk_height;
    self.frame = frame;
}


-(CGFloat)jk_x{
    return self.frame.origin.x;
}


-(void)setJk_x:(CGFloat)jk_x{
    CGRect frame = self.frame;
    frame.origin.x = jk_x;
    self.frame = frame;
}



-(CGFloat)jk_y{
    return self.frame.origin.y;
}

-(void)setJk_y:(CGFloat)jk_y{
    CGRect frame = self.frame;
    frame.origin.y = jk_y;
    self.frame = frame;
}

-(CGSize)jk_size{
    return self.frame.size;
}

-(void)setJk_size:(CGSize)jk_size{
    CGRect frame = self.frame;
    frame.size = jk_size;
    self.frame = frame;
}

//点击绑定block
- (void)click:(void(^)(UIView *view, UIGestureRecognizer *sender))block{
    if (!block) return;
    self.elementDic[@"block"] = block;
    
    [self addTapGestureRecognizerWithTarget:self action:@selector(onClick:)];
}
- (void)onClick:(UIGestureRecognizer*)sender{
    //CGPoint point = [sender locationInView:self]; //获取触点在视图中的坐标
    void(^block)(UIView *view, UIGestureRecognizer *sender) = sender.view.elementDic[@"block"];
    block(sender.view, sender);
}

//长按绑定block
- (void)longClick:(void(^)(UIView *view, UIGestureRecognizer *sender))block{
    if (!block) return;
    self.elementDic[@"block"] = block;
    [self addLongPressGestureRecognizerWithTarget:self action:@selector(onLongClick:)];
}


- (void)onLongClick:(UIGestureRecognizer*)sender{
    if (sender.state == UIGestureRecognizerStateBegan) {
        void(^block)(UIView *view, UIGestureRecognizer *sender) = sender.view.elementDic[@"block"];
        block(sender.view, sender);
    }
}

//点击
- (void)addTapGestureRecognizerWithTarget:(id)target action:(SEL)action{
    [self addTapGestureRecognizerWithTouches:1 target:target action:action];
}


- (void)addTapGestureRecognizerWithTouches:(NSInteger)touches target:(id)target action:(SEL)action{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    recognizer.delegate = target;
    recognizer.numberOfTouchesRequired = touches;
    
    [self addGestureRecognizer:recognizer];
}

//长按
- (void)addLongPressGestureRecognizerWithTarget:(id)target action:(SEL)action{
    [self addLongPressGestureRecognizerWithTouches:1 target:target action:action];
}

- (void)addLongPressGestureRecognizerWithTouches:(NSInteger)touches target:(id)target action:(SEL)action{
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:action];
    recognizer.delegate = target;
    recognizer.numberOfTouchesRequired = touches;
    [self addGestureRecognizer:recognizer];
}


+(UIView *)getLineView{
    UIView * lineView = [[UIView alloc] init];
    lineView.backgroundColor = COLOR_DefaultLineColor;
    return lineView;
}

+ (void)cashapeLine:(UIView *)view beginPont:(CGPoint)beginPont endPoint:(CGPoint)endPoint color:(UIColor *) color {
    
    //画一条虚线
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:view.bounds];
    [shapeLayer setPosition:view.center];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    
    //设置虚线颜色
    [shapeLayer setStrokeColor:color.CGColor];
    
    //虚线宽度
    [shapeLayer setLineWidth:1.0f];
    [shapeLayer setLineJoin:kCALineJoinRound];
    
    //3 线的宽度  1 每条线的间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],nil]];
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, beginPont.x, beginPont.y);
    CGPathAddLineToPoint(path, NULL, endPoint.x,endPoint.y);
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    [[view layer] addSublayer:shapeLayer];
}



@end
