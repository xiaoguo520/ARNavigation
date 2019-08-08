//
//  PlateNumberUI.h
//  ARKitDemoUI
//
//  Created by limu on 2018/12/28.
//  Copyright © 2018年 example. All rights reserved.
//
//  function: 用于手动输入车辆所在【泊位号】，即目标点泊位号（支持模糊查询）
//    -- 达实智能项目中此文件未用到（改用StartPositionUI中同时录入起点、终点的泊位号）

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

NS_ASSUME_NONNULL_BEGIN
@protocol PlateNumberDelegate
@required // list of required methods
@optional // list of optional methods
- (void)onConfirm:(NSString *)plateNumber;
@end

@interface PlateNumberUI : NSObject

@property (nonatomic, retain) id<PlateNumberDelegate> delegate;

- (void)setSuperView:(UIView *)view;
- (void)show;
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
