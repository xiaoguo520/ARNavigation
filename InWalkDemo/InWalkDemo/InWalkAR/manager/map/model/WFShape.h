//
//  WFShape.h
//  InWalkAR
//
//  Created by wangfan on 2018/7/19.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol WFDrawble <NSObject>

-(void) drawSelf;

@end
@interface WFShape : NSObject <WFDrawble>
@property(nonatomic) UIColor *lineColor;
@property(nonatomic) float lineWidth;
@property(nonatomic) UIColor *fillColor;
@property(nonatomic) CGFloat alpha;
-(void) drawSelf;
@end

NS_ASSUME_NONNULL_END
