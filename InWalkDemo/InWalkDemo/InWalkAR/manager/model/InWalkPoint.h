//
//  InWalkPoint.h
//  InWalkAR
//
//  Created by wangfan on 2018/6/15.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InWalkPoint : NSObject

/**
 场景Id，当hid为nil时，说明不在已知场景点上
 */
@property (nonatomic, nullable,strong) NSString *hid;

/**
 场景点默认经度
 */
@property (nonatomic,nullable, strong) NSNumber *angle;

@property(nonatomic) int floor;

@end
