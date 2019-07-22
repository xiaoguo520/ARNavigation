//
//  HotspotModel.h
//  InReal
//
//  Created by wangfan on 2017/5/10.
//  Copyright © 2017年 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@class InWalkPoint;

// 导航点
@interface InWalkInnerPoint:NSObject

/**
 场景Id
 */
@property (nonatomic, strong) NSString *hid;

@property (nonatomic, strong) NSString *name;

/**
 描述信息
 */
@property (nonatomic, strong) NSString *desc;

@property (nonatomic, strong) NSNumber *offset;

@property (nonatomic) NSNumber *position;
@property (nonatomic) NSNumber *x;
@property (nonatomic) NSNumber *y;

//@property (nonatomic) NSArray<NSNumber *> *realPosition;
@property (nonatomic) NSNumber *realX;
@property (nonatomic) NSNumber *realY;

@property(nonatomic) NSNumber *direction; // 前后左右

@property (nonatomic, strong) NSString *pathID; // old

@property(nonatomic) NSNumber *distanceToHead; //



// 手动添加的字段
@property (nonatomic, strong) NSNumber *angle;

// 手动添加的字段
@property(nonatomic) int floor;

// 手动添加的字段
@property(nonatomic) int pointIndex;



-(InWalkPoint *) parseToPoint;

@end
