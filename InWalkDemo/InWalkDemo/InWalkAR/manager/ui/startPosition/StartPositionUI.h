//
//  StartPositionUI.h
//  ARKitDemoUI
//
//  Created by limu on 2019/1/2.
//  Copyright © 2019年 example. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StartPositionModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol StartPositionDelegate
@required // list of required methods
@optional // list of optional methods
- (void)startNavigationFrom:(NSString *)from to:(NSString *)to;
- (void)onCloseStartPositionUI:(BOOL)isDestConfirmed;
@end

@interface StartPositionUI : NSObject
@property (nonatomic, retain) id<StartPositionDelegate> delegate;
//根据定位更新起点
- (void)upDataOriginFormPosition:(StartPositionModel *)model;

- (void)setSuperView:(UIView *)view;
//- (void)setItems:(NSArray<StartPositionModel *> *)items;
- (void)showDest:(NSString *)destNum items:(NSArray<StartPositionModel *> *)items;
- (void)dismiss;
- (void)refreshDest:(NSString *)destNum items:(NSArray<StartPositionModel *> *)items;

@end

NS_ASSUME_NONNULL_END
