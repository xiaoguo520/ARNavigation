//
//  InWalkManager.h
//
//  Created by InWalk on 2019/5/8.
//  Copyright © 2019年 InWalk Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define InWalkErrorDomain @"InWalkError"

typedef NS_ENUM(NSUInteger, InWalkErrorCode) {
    InWalkErrorCodeInit // 初始化失败错误码
};
@class InWalkManager;


@protocol InWalkManagerDelegate
@optional

/**
 结束导航
 */
- (void)didEndNavigation;

/**
 错误回调
 @param error 错误描述
 */
- (void)manager:(InWalkManager *)manager didOccurError:(NSError *)error;
@end


@interface InWalkManager : NSObject
@property(nonatomic, weak) id<InWalkManagerDelegate> delegate;

/**
 初始化
 @param container 渲染容器
 @param productId 项目ID
 */
- (instancetype)initWithContainer:(nonnull UIView *)container productId:(nonnull NSString *)productId;

- (instancetype)initWithContainer:(nonnull UIView *)container data:(nonnull NSArray<NSData *> *)data;

/**
 释放持有的资源
 */
- (void)releaseResource;

@end
