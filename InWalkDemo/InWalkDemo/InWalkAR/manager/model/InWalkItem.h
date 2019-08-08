//
//  InWalkItem.h
//  InWalkAR
//
//  Created by wangfan on 2018/5/25.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "InWalkNode.h"
#import "InWalkPath.h"
#import "InWalkMap.h"
#import "InWalkInnerPoint.h"

// 单个楼层的数据
@interface InWalkItem : NSObject

// 楼层的基本信息
@property (nonatomic, nullable) InWalkMap *drawer;
// 所有节点
@property (nonatomic, nullable) NSArray<InWalkNode *> *nodes;
// 所有路径
@property (nonatomic, nullable) NSArray<InWalkPath *> *pathes;
// 所有导航点
@property (nonatomic, nullable) NSArray<InWalkInnerPoint *> *navs;
// id
@property (nonatomic, strong) NSString *_id;
// name
@property (nonatomic, strong) NSString *name;

@end
