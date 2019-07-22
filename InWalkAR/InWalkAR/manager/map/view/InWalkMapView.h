//
//  InWalkMapView.h
//  InWalkAR
//
//  Created by wangfan on 2018/7/13.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFShape.h"
NS_ASSUME_NONNULL_BEGIN

@interface InWalkMapView : UIView<UIScrollViewDelegate>

@property(nullable,nonatomic,weak) InWalkMapView *syncView;

-(void) addShape:(id<WFDrawble>) shape;
-(void) removeShape:(id<WFDrawble>) shape;
-(void) clear;
- (BOOL)isZoomingOrDragging;
@end

NS_ASSUME_NONNULL_END
