//
//  InWalkARAnchor.h
//  InWalkAR
//
//  Created by wangfan on 2018/8/24.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import <ARKit/ARKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InWalkARAnchor:ARAnchor
@property(nonatomic,strong,nullable) NSString *title;
@property(nonatomic) int flag;
@property(nonatomic,strong,nullable) NSString *des;
@property(nonatomic,strong,nullable) NSArray<SCNConstraint *> *constraints;
@property(nonatomic) int turnFlag;
@property(nonatomic,strong,nullable) NSString *hid;
@property(nonatomic) int tag;
@end

NS_ASSUME_NONNULL_END
