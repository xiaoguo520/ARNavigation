//
//  NavigationManager.h
//  InWalkAR
//
//  Created by wangfan on 2018/5/25.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InWalkNode.h"
#import "InWalkInnerPoint.h"
#import "InWalkNavigationPathPoint.h"
#import "InWalkPath.h"
#import "NavigationModel.h"

@interface InWalkNavigationManager : NSObject
@property(nonatomic,strong,readonly) NSArray<InWalkNavigationPathPoint *> *navigationPath;
@property(nonatomic,strong,readonly) NSMutableArray<InWalkNavigationPathPoint *> *completeNavigationPath; // 用于纠偏时估算实时位置对应的点，保存的是完整的路径点集合
@property(nonatomic,strong,readonly) NSMutableArray<InWalkNavigationPathPoint *> * beaconNavigationPath;
@property(nonatomic,readonly) float totalLength;

-(instancetype) initWithPaths:(NSDictionary<NSString *, InWalkPath *> *)paths
                        nodes:(NSDictionary<NSString *, InWalkNode *> *)nodes
                       points:(NSDictionary<NSString *, InWalkInnerPoint *> *)points;
-(void) navigateFrom:(InWalkInnerPoint *) startPoint to:(InWalkInnerPoint *) endPoint;
- (NSArray<NavigationModel *> *)getNavDetails;//navDetailsByPath:(NSArray<InWalkNavigationPathPoint *> *)path;
- (NavigationModel *)calcRealtimeDistanceAtIndex:(int)index;// onPath:(NSArray<InWalkNavigationPathPoint *> *)path;
- (void)releaseNavigation;
/**
 生成两个场景点之间的导航路径
 
 @param startPoint 起始场景点
 @param endPoint 结束场景点
 @return 导航路径
 */
-(NSArray<InWalkNavigationPathPoint *> *)generateNavigationPathFrom:(InWalkInnerPoint *)startPoint to:(InWalkInnerPoint *)endPoint;
@end
