//
//  InWalkMapManager.h
//  InWalkAR
//
//  Created by wangfan on 2018/7/19.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <simd/simd.h>
#import "InWalkModel.h"
#import "InWalkItem.h"

NS_ASSUME_NONNULL_BEGIN
// 协议
@protocol InWalkMapDelegate
@required // list of required methods
@optional // list of optional methods
- (void)onClickMap:(BOOL)isMapOpenNow;
- (void)makeDirectionTipVisible:(BOOL)visible;
@end


@interface InWalkMapManager : NSObject
@property (nonatomic, retain) id<InWalkMapDelegate> delegate;
@property(nonatomic,strong,readonly) UIView *mapView;

-(instancetype) initWithPaths:(NSDictionary<NSString *, InWalkPath *> *) paths;

-(void) updateCurrentPosition:(CGPoint) point;
-(void) updateCurrentForwardPosition:(CGPoint) forwardPoint;
-(void) updateNavigationPath:(NSArray *) path;
-(void) updateMap:(InWalkMap *) map;
-(void) showMap:(BOOL)showBigMap;
- (void)setTouchEnabled:(BOOL)enabled;
- (void)makeMapCenter;
- (void)releaseMap;
//删除当前导航路径
- (void)removeNavigationPath;
@end

NS_ASSUME_NONNULL_END
