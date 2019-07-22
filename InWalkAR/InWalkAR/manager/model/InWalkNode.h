//
//  ZXSPlayerNode.h
//  InRealApp
//
//  Created by 王凡 on 16/12/16.
//  Copyright © 2016年 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

// 节点
@interface InWalkNode : NSObject

@property (strong, nonatomic, nonnull) NSString *nodeID;
@property (strong, nonatomic, nonnull) NSString *name;
@property (nonatomic, nullable) NSNumber *floor;
@property (nonatomic) NSArray<NSNumber *> *position; // [x,y]

@property (strong, nonatomic, nonnull) NSArray<NSNumber *> *directions; // 用到了但是没有数据
@property (strong, nonatomic, nonnull) NSArray<NSString *> *pathIDs; // 手动添加的字段
@property (strong, nonatomic, nonnull) NSMutableArray<NSString *> *nodeIDs; // 手动添加的字段

@end
