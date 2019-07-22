//
//  InWalkPath.h
//  InWalkAR
//
//  Created by limu on 2018/11/28.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 路径：path和node需要避免出现闭环（即两个node之间含有两条直接连接的path）
@interface InWalkPath : NSObject

@property(nonatomic) NSString *pathID;
@property(nonatomic) NSString *pathName;
@property(nonatomic) NSString *headNodeID;
@property(nonatomic) NSString *tailNodeID;
@property(nonatomic) NSNumber *headAngle;
@property(nonatomic) NSNumber *tailAngle;
@property(nonatomic) NSArray<NSNumber *> *data;
@property(nonatomic) NSNumber *weight;
@property(nonatomic) NSNumber *length; // 暂未用到
@property(nonatomic) NSNumber *floor;

-(NSArray<NSNumber *> *) positionAtIndex:(int) index;

@end

NS_ASSUME_NONNULL_END
