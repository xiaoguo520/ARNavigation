//
//  WalkModel.h
//  InWalkApp
//
//  Created by wujq on 2017/5/6.
//  Copyright © 2017年 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InWalkItem.h"
#import "InWalkInnerPoint.h"
#import "InWalkMap.h"

// 一个项目（商场/停车场）的所有楼层数据
@interface InWalkModel : NSObject

// 所有楼层的数据
@property(nonatomic, strong) NSArray<InWalkItem *> *meta;

// 是否支持反向寻车
@property(nonatomic) BOOL supportRvts; // reverse vehicle tracking system

@end
