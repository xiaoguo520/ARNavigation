//
//  InWalkIbeaconManager.h
//  InWalkAR
//
//  Created by guodeng 郭 on 2019/6/25.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//  Ibeacon管理类

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "BRTBeaconSDK.h"

NS_ASSUME_NONNULL_BEGIN


typedef enum : NSUInteger {
    //未开启定位
    NoOpenLocation,
    //不支持测距
    NoRangingAvailable,
    //未知位置
    Unkown,
} IbeaconErrorType;


typedef void(^iBeaconsCompletionBlock)(NSArray* beacons, CLBeaconRegion* region, NSError* error);
typedef void (^IbeaconErrorTypeBlock)(IbeaconErrorType type);
typedef void (^iBeaconResultBlcok)(BRTBeacon * beacon);


@interface InWalkIbeaconManager : NSObject


/**
 单例
 
 @return return value description
 */
+ (instancetype)manager;


/**
 初始化Ibeacon

 @param key 智石appKey
 */
+ (void)registerIbeaconWitnAppKey:(NSString *)key;



/**
 开始定位

 @param UUIDS 设备编号，用于处理监听区域
 @param completion completion description
 @param error error description
 */
+ (void)startRangingBeaconsInUUIDS:(NSArray<NSString *> *)UUIDS Completion:(iBeaconsCompletionBlock) completion Error:(IbeaconErrorTypeBlock)error;



/**
 开始定位

 @param UUIDS UUIDS description
 @param blcok blcok description
 */
- (void)startSearchIbeaconWithUUIDS:(NSArray *)UUIDS iBeaconResultBlcok:(iBeaconResultBlcok)blcok;


/**
 关闭扫描定位
 */
- (void)stopRangingBeacons;

@end

NS_ASSUME_NONNULL_END
