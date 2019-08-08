//
//  InWalkUIManager.h
//  InWalkAR
//
//  Created by limu on 2019/1/6.
//  Copyright © 2019年 InWalk Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NavigationModel.h"
#import "StartPositionModel.h"
#import "InWalkReverse4CarModel.h"
#import "InWalkMap.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, InWalkPhonePose) {
    InWalkPhonePoseKeep3,
    InWalkPhonePoseKeep2,
    InWalkPhonePoseKeep1,
    InWalkPhonePoseWrong,
    InWalkPhonePoseFree
};

// 协议
@protocol InWalkUIDelegate
@required // list of required methods
@optional // list of optional methods
- (void)onConfirmPlateNumber:(NSString *)plateNumber;
- (void)onConfirmRvts:(NSString *)plateNumber;
- (void)onConfirmLocateResult;
- (void)startNavigationFrom:(NSString *)from to:(NSString *)to;
- (void)finishNavigation;
- (void)showMap:(BOOL)shouldOpenMap;
- (void)onConfirmDestParkingNo:(NSString *)destParkingNo;
- (void)makeMapCenter;
- (void)onClickFloor:(int)tag;
@end

@interface InWalkUIManager : NSObject
@property (nonatomic, retain) id<InWalkUIDelegate> delegate;
@property(nonatomic,strong,readonly) UIView *superView;

- (instancetype)initWithSuperView:(UIView*)view;
- (void)showTipButtons;
- (void)showFloors:(NSDictionary<NSString *, InWalkMap *> *)mapList;
- (void)showFloorBgView:(InWalkMap *)floor;
- (void)hideFloorBgView;
- (void)showPhonePose:(InWalkPhonePose)flag;
- (void)showPlateNumberView;
- (void)showPlateNumberView2;
- (void)showLocationResultDesc:(NSString *)desc tip:(NSString *)tip imgs:(NSArray<NSString *> *)imgs parkingNum:(NSString *)num;
- (void)showStartPositionViewWithItems:(NSArray<StartPositionModel *> *)items;
- (void)setNavPath:(NSArray<NavigationModel *> *)path;
- (void)showTip:(NavigationModel *)tip remainTime:(NSString *)t1 distance:(NSString *)distance arriveTime:(NSString *)t2;
- (void)refreshMapBtn:(BOOL)isMapOpen;
- (void)showRvtsResult:(NSArray<InWalkReverse4CarModel *> *)list;
- (void)dismissInputViews;
- (void)releaseUIResource; // 释放UIManager持有的资源6/27


//2019/06/27新增
//根据定位更新起点
- (void)upDataOriginFormPosition:(StartPositionModel *)model;

@end

NS_ASSUME_NONNULL_END
