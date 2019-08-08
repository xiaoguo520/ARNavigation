//
//  InWalkARManager.h
//
//  Created by InWalk on 2019/5/8.
//  Copyright © 2019年 InWalk Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "InWalkModel.h"
#import "InWalkItem.h"
#import "InWalkLocationModel.h"
#import "InWalkNavigationPathPoint.h"
#import "NavigationModel.h"
#import "BRTBeaconSDK.h"
NS_ASSUME_NONNULL_BEGIN
@class InWalkARManager;

@protocol InWalkARManagerDelegate <NSObject>
- (void)updateNavigationDetails:(NSArray<NavigationModel *> *)details;
- (void)updateNavigationTip:(NavigationModel *)tip;
- (void)onMapOpend:(BOOL)isOpenNow;
- (void)onAngleRectified; // 10米纠偏完成
@end

@interface InWalkARManager : NSObject

@property(nonatomic,weak) id<InWalkARManagerDelegate> delegate;
@property(nonatomic) CGPoint currentPoistion; // 用户当前所处位置(在后台数据对应的坐标系中的坐标)
@property(nonatomic) simd_float3 forwardPosition; // 用户手机朝向(确切的说，是摄像头所指的方向，在后台数据对应的坐标系中的坐标)

/**
 InWalkARManager的初始化方法

 @param container 容纳ARKit的容器View
 @param productId 项目ID，暂时未实际用到
 @param paths 项目数据中的路径点数据
 @param nodes 项目数据中的结点数据
 @param points 项目数据中的导航点数据
 @param maps 项目数据中的地图(楼层)数据
  @param uuids beacon设备uuid
 @return 实例
 */
-(instancetype)initWithCountainer:(UIView *)container
                        productId:(NSString *) productId
                            paths:(NSDictionary<NSString *, InWalkPath *> *) paths
                            nodes:(NSDictionary<NSString *, InWalkNode *> *) nodes
                           points:(NSDictionary<NSString *, InWalkInnerPoint *> *) points
                            UUIDS:(NSArray *)uuids
                             maps:(NSArray<InWalkMap *> *)maps;


/**
 更新用户当前所处位置

 @param pointId 当前所处位置对应的导航点的ID
 */
- (void)updateCurrentPoint:(NSString *) pointId;

/**
 开始导航

 @param pointId 目标导航点的ID
 */
- (void)startNavigationTo:(NSString*) pointId;

/**
 刷新导航路径对于的AR贴图
 */
- (void)updateNavigationGuide;


/**
 根据当前定位的beacon纠偏

 @param beacon beacon设备信息
 */
- (void)rectifyAtBeaconsWithBeacon:(BRTBeacon *)beacon;

/**
 小地图：使用户当前所处位置展示在小地图(屏幕)中心
 */
- (void)makeMapCenter;

/**
 释放InWalkARManager持有的资源
 */
- (void)releaseArResouce;


/**
 隐藏调试信息，目前已废弃
 
 @param isHidden 是否隐藏，隐藏为YES，不隐藏为NO
 */
- (void)hideDebugInfo:(BOOL) isHidden;

/**
 测试方法，目前已废弃
 */
- (void)testUpdatePlus;

@end

NS_ASSUME_NONNULL_END
