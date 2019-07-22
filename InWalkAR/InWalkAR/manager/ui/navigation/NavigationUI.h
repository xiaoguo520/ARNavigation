//
//  NavigationUI.h
//  ARKitDemoUI
//
//  Created by limu on 2019/1/4.
//  Copyright © 2019年 example. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NavigationDelegate
@required // list of required methods
@optional // list of optional methods
//- (void)startNavigationFrom:(NSString *)from to:(NSString *)to;
- (void)onClickMapBtn:(BOOL)shouldOpenMap;
- (void)onClickFinishBtn;
- (void)makeMapCenter;
@end

@interface NavigationUI : NSObject
@property (nonatomic, retain) id<NavigationDelegate> delegate;

- (void)setSuperView:(UIView *)view;
- (void)setItems:(NSArray<NavigationModel *> *)items dest:(NSString *)destParkingNo;
//- (void)setTip:(NavigationModel *)tip remainTime:(NSString *)timeStr distance:(NSString *)distance arriveTime:(NSString *)arriveTime;
- (void)showTip:(NavigationModel *)tip remainTime:(NSString *)timeStr distance:(NSString *)distance arriveTime:(NSString *)arriveTime;
- (void)refreshMapBtn:(BOOL)isMapOpen;
- (void)setTipsVisible:(BOOL)visible;

@end

NS_ASSUME_NONNULL_END
