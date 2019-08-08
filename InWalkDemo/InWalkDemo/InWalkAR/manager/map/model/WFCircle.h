//
//  WFCircle.h
//  InWalkAR
//
//  Created by wangfan on 2018/7/19.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WFShape.h"
NS_ASSUME_NONNULL_BEGIN

@interface WFCircle : WFShape
@property(nonatomic) CGPoint center;
@property(nonatomic) float radius;
-(instancetype) initWithCenter:(CGPoint) center radius:(float) radius;
@end

NS_ASSUME_NONNULL_END
