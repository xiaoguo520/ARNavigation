//
//  InWalkMap.h
//  InWalkAR
//
//  Created by wangfan on 2018/7/25.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

// 楼层的基本信息
@interface InWalkMap : NSObject
@property(nonatomic,strong,nonnull) NSNumber *planeId;
@property(nonatomic,strong,nonnull) NSString *uri;
@property(nonatomic,strong,nullable) NSNumber *contentScale;
@property(nonatomic,strong,nullable) NSNumber *rotation;
@property(nonatomic,strong,nullable) NSNumber *scale;
@property(nonatomic,strong,nullable) NSNumber *xOffset;
@property(nonatomic,strong,nullable) NSNumber *yOffset;
@property(nonatomic,strong,nullable) NSNumber *northOffset;

// new add on 20190421
@property(nonatomic,strong,nullable) NSNumber *mapUri;
@property(nonatomic,strong,nullable) NSNumber *height;
@property(nonatomic,strong,nullable) NSNumber *mapRotate;
@property(nonatomic,strong,nullable) NSNumber *plotScale;
@property(nonatomic,strong,nullable) NSNumber *width;

@property(nonatomic) float contentWidth;  // 对应ScrollView的contentSize宽度（缩放后的宽度）
@property(nonatomic) float contentHeight; // 对应ScrollView的contentSize高度（缩放后的高度）

@property(nonatomic,strong) NSString *name;
@property(nonatomic) int tag;

@end

NS_ASSUME_NONNULL_END
