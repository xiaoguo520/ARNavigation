//
//  InWalkLocationModel.h
//  InWalkAR
//
//  Created by wangfan on 2018/6/6.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InWalkLocationNavigation.h"
@interface InWalkLocationModel : NSObject
/**
 场景点id
 */
@property (nonatomic, strong) NSString *navigationId;
/**
 场景点水平方向默认角度
 */
@property (nonatomic, strong) NSNumber *angle;

/**
 场景点名称
 */
@property(nonatomic,strong) InWalkLocationNavigation *navigation;

@property(nonatomic) int floor;
@end
