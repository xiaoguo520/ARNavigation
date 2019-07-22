//
//  InWalkNavigationPathPoint.h
//  InWalkAR
//
//  Created by wangfan on 2018/5/29.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import "InWalkInnerPoint.h"
#import <simd/simd.h>
@interface InWalkNavigationPathPoint : InWalkInnerPoint
@property(nonatomic) BOOL isCorner;
@property(nonatomic) float corner;
@property(nonatomic) BOOL isStair;
@property(nonatomic) simd_float3 pathPosition;
@property(nonatomic) float angleToNext; // 指向下一个点的角度
@property(nonatomic) int turnFlag; // 直行/起点为0，左拐为1，右拐为2，终点为3

@end
