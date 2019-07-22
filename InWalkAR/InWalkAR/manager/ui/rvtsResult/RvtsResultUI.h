//
//  RvtsResultUI.h
//  InWalkAR
//
//  Created by limu on 2019/4/25.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "InWalkReverse4CarModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RvtsResultDelegate
@required // list of required methods
@optional // list of optional methods
- (void)onConfirmRvtsResult:(NSString *)plateNo;
- (void)onCloseRvtsResult;
@end

@interface RvtsResultUI : NSObject
@property (nonatomic, retain) id<RvtsResultDelegate> delegate;

- (void)setSuperView:(UIView *)view;
- (void)showRvtsResultItems:(NSArray<InWalkReverse4CarModel *> *)items;
- (void)dismiss;
- (void)restoreView;

@end

NS_ASSUME_NONNULL_END
