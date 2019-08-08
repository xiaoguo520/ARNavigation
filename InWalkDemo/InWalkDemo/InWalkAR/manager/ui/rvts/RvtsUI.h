//
//  RvtsUI.h
//  InWalkAR
//
//  Created by limu on 2019/4/10.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RvtsUIDelegate
@required // list of required methods
@optional // list of optional methods
- (void)onClickRvts:(NSString *)carNum; // 根据车牌号找反向寻车系统要车辆所在的泊位号
- (void)onCloseRvts; // 点击关闭按钮
@end

@interface RvtsUI : NSObject
@property (nonatomic, retain) id<RvtsUIDelegate> delegate;

- (void)setSuperView:(UIView *)view;
- (void)setTitle:(NSString *)title;
- (void)show;
- (void)dismiss;
- (void)hideView;
- (void)restoreView;

@end

NS_ASSUME_NONNULL_END
