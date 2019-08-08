//
//  InWalkMapView.m
//  InWalkAR
//
//  Created by wangfan on 2018/7/13.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import "InWalkMapView.h"
@interface InWalkMapView()<UIGestureRecognizerDelegate>
@property(nonatomic) CGPoint currentPosition;
@property(nonatomic,strong) NSMutableArray<id<WFDrawble>> *mutableObjects;
@property(nonatomic) BOOL isZooming;
@property(nonatomic) BOOL isDragging;
@end
@implementation InWalkMapView
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextScaleCTM(context, 1, -1); // 原点在左下角，y轴向上（x轴向右）
    CGContextScaleCTM(context, 1, 1);    // 原点在左上角，y轴向下（x轴向右）
    [super drawRect:rect];
    for (id<WFDrawble>  object in _mutableObjects) {
        [object drawSelf];
    }
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self;
}

- (BOOL)isZoomingOrDragging {
    return self.isZooming || self.isDragging;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.isZooming = YES;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    self.isZooming = NO;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isDragging = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.isDragging = NO;
}

// 缩放后，小地图居中展示
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = 0;
    if (scrollView.bounds.size.width > scrollView.contentSize.width) {
        offsetX = (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5;
    }
    CGFloat offsetY = 0;
    if (scrollView.bounds.size.height > scrollView.contentSize.height) {
        offsetY = (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5;
    }
    self.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    
    if (_syncView) {
        _syncView.center = self.center;
        _syncView.bounds = self.bounds;
        _syncView.transform = self.transform;
    }
    
}

-(void) addShape:(id<WFDrawble>)shape{
    if(_mutableObjects == nil){
        _mutableObjects = [NSMutableArray new];
    }
    [_mutableObjects addObject:shape];
    [self setNeedsDisplay];
}
-(void) removeShape:(id<WFDrawble>) shape{
    if([_mutableObjects containsObject:shape]){
        [_mutableObjects removeObject:shape];
    }
    [self setNeedsDisplay];
}

-(void) clear{
    [_mutableObjects removeAllObjects];
    [self setNeedsDisplay];
}
@end
