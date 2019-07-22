//
//  WFLine.h
//  InWalkAR
//
//  Created by wangfan on 2018/7/19.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WFShape.h"
NS_ASSUME_NONNULL_BEGIN

@interface WFLine : WFShape
@property(nonatomic,strong,nonnull) NSArray *pointArray;
@property(nonatomic) UIColor *lineEdgeColor;

@end

NS_ASSUME_NONNULL_END
