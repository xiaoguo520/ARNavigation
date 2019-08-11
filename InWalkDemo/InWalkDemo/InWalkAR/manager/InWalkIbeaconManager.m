//
//  InWalkIbeaconManager.m
//  InWalkAR
//
//  Created by guodeng 郭 on 2019/6/25.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InWalkIbeaconManager.h"



@interface InWalkIbeaconManager ()

@property(nonatomic,strong) NSMutableDictionary * beaconDic;
@property (nonatomic,copy) iBeaconResultBlcok block;
@property(nonatomic,strong) dispatch_source_t timer;

@end

@implementation InWalkIbeaconManager

//单例宏.m
+ (InWalkIbeaconManager *)manager{
    static dispatch_once_t once = 0;
    static InWalkIbeaconManager *sharedObject;
    dispatch_once(&once, ^{
        sharedObject = [[InWalkIbeaconManager alloc] init];
    });
    return sharedObject;
}


-(NSMutableDictionary *)beaconDic{
    if (!_beaconDic) {
        _beaconDic = [NSMutableDictionary dictionary];
    }
    return _beaconDic;
}
/**
 初始化Ibeacon
 
 @param key 智石appKey
 */
+ (void)registerIbeaconWitnAppKey:(NSString *)key{
    
#if TARGET_OS_SIMULATOR
#else
    [BRTBeaconSDK registerApp:key onCompletion:^(BOOL complete, NSError *error) {
        if (complete) {
            //注册成功
            NSLog(@"Ibeacon注册成功");
        }else{
            NSLog(@"%@",error);
        }
    }];
#endif

    
}

+ (void)startRangingBeaconsInUUIDS:(NSArray<NSString *> *)UUIDS Completion:(iBeaconsCompletionBlock)completion Error:(IbeaconErrorTypeBlock)error{
    
#if TARGET_OS_SIMULATOR
#else
    //IOS8.0以后，需在plist配置获得定位权限描述<key>NSLocationAlwaysUsageDescription</key><string>定位用途提示</string>
    if ([CLLocationManager authorizationStatus] <= kCLAuthorizationStatusDenied) {
        error(NoOpenLocation);
    }
    NSMutableArray * regions = [NSMutableArray array];
    NSInteger i = 0;
    for (NSString * uuidString in UUIDS) {
        //转大写
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString.uppercaseString];
        BRTBeaconRegion *region = [[BRTBeaconRegion alloc] initWithProximityUUID:uuid identifier:[NSString stringWithFormat:@"Beacon%ld",i]];
        [regions addObject:region];
        i++;
    }
//    NSString * uuidStr1 = @"0bfc92e0-877b-11e9-b3de-e783454c0316";
//    NSUUID * uuid1 = [[NSUUID alloc] initWithUUIDString:uuidStr1.uppercaseString];
//    BRTBeaconRegion * region1 = [[BRTBeaconRegion alloc] initWithProximityUUID:uuid1 identifier:@"1"];
//    [regions addObject:region1];
//    NSString * uuidStr2 = @"1f5fa5c0-877b-11e9-b3de-e783454c0316";
//    NSUUID * uuid2 = [[NSUUID alloc] initWithUUIDString:uuidStr2.uppercaseString];
//    BRTBeaconRegion * region2 = [[BRTBeaconRegion alloc] initWithProximityUUID:uuid2 identifier:@"2"];
//    [regions addObject:region2];
//    [regions addObject:region3];

    //测试UUID
    //判断设备是否支持测距
    if ([CLLocationManager isRangingAvailable]) {
        //开始扫描Beacon设备
        [BRTBeaconSDK startRangingBeaconsInRegions:regions onCompletion:^(NSArray * _Nonnull beacons, CLBeaconRegion * _Nonnull region, NSError * _Nonnull error) {
            //回到主线程通知
            completion(beacons,region,error);
        }];
    }else{
        error(NoRangingAvailable);
    }
#endif
    
}


//开始搜索Ibeacon硬件
- (void)startSearchIbeaconWithUUIDS:(NSArray *)UUIDS iBeaconResultBlcok:(iBeaconResultBlcok)blcok{
    
    
    _block = blcok;
    //    [InWalkIbeaconManager registerIbeaconWitnAppKey:DEFAULT_KEY];
    
    //获取设备
    [InWalkIbeaconManager startRangingBeaconsInUUIDS:UUIDS Completion:^(NSArray * _Nonnull beacons, CLBeaconRegion * _Nonnull region, NSError * _Nonnull error) {
//        [self.beaconDic removeAllObjects];
        
        if (beacons.count > 0) {
            //实时添加附件的设备
            [self.beaconDic setObject:beacons.copy forKey:region.proximityUUID.UUIDString];
        }else{
            [self.beaconDic removeObjectForKey:region.proximityUUID.UUIDString];
        }
        
    } Error:^(IbeaconErrorType type) {
        switch (type) {
            case NoOpenLocation:{
//                [self.container makeToast:@"暂未开启定位，无法定位当前位置"];
                
            }
                break;
            case NoRangingAvailable:{
//                [self.container makeToast:@"当前设备暂不支持测距，无法定位当前位置"];
            }
                
                break;
                
            default:
                break;
        }
    }];
    
    //1s刷新一次位置信息
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, (int64_t)0.2 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        [self updataUserLocationWithIbeacons];
    });
    dispatch_resume(_timer);// 启动任务
}

- (void)updataUserLocationWithIbeacons{
    NSMutableArray * beacons = [NSMutableArray array];
    //    if (self.beaconDic.allValues.count == 0) {
    //        //置空
    //        [self.uiManager upDataOriginFormPosition:nil];
    //        return;
    //    }
    //取出数据
    for (NSArray * array in self.beaconDic.allValues) {
        [beacons addObjectsFromArray:array];
    }
    
    //proximity 为immediate的设备
    NSMutableArray * immediates = [NSMutableArray array];
    //proximity 为near的设备
    NSMutableArray * nears = [NSMutableArray array];
    
    NSMutableArray * fars = [NSMutableArray array];
    
    if (beacons.count > 0) {
//        NSLog(@"搜索到设备为%@",beacons);
    }
    for (BRTBeacon * beacon in beacons) {
        //先判断immediate
        if (beacon.proximity == CLProximityImmediate) {
            [immediates addObject:beacon];
            continue;
        }
        if (beacon.proximity == CLProximityNear) {
            [nears addObject:beacon];
            continue;
        }
        if (beacon.proximity == CLProximityFar) {
            [fars addObject:beacon];
        }
    }
    
    //此处需增加一个搜寻循环次数,一定的次数时未搜寻到设备，再提示用户手动输入定位点
    if (immediates.count == 0 && nears.count == 0 && fars.count == 0) {
        //提示用户定位失败，需手动输入起点位置
        return;
    }
    
    if (immediates.count != 0) {
        //根据accuracy排序，升序
        [immediates sortUsingComparator:^NSComparisonResult(BRTBeacon * obj1, BRTBeacon * obj2) {
            CGFloat l1 = obj1.accuracy;
            CGFloat l2 = obj1.accuracy;
            if (l1 > l2) {
                return NSOrderedAscending;
            }
            return NSOrderedDescending;
        }];
        
        BRTBeacon * currentBeacon = [immediates firstObject];
        _block(currentBeacon);
        //取到当前定位点
        return;
    }
    if (nears.count != 0) {
        //根据accuracy排序，升叙
        [nears sortUsingComparator:^NSComparisonResult(BRTBeacon * obj1, BRTBeacon * obj2) {
            CGFloat l1 = obj1.accuracy;
            CGFloat l2 = obj1.accuracy;
            if (l1 > l2) {
                return NSOrderedAscending;
            }
            return NSOrderedDescending;
        }];
        
        BRTBeacon * currentBeacon = [nears firstObject];
        _block(currentBeacon);
        //取到当前定位点
        return;
    }
    if (fars.count != 0) {
        [fars sortUsingComparator:^NSComparisonResult(BRTBeacon * obj1, BRTBeacon * obj2) {
            CGFloat l1 = obj1.accuracy;
            CGFloat l2 = obj1.accuracy;
            if (l1 > l2) {
                return NSOrderedAscending;
            }
            return NSOrderedDescending;
        }];
        BRTBeacon * currentBeacon = [fars firstObject];
//        _block(currentBeacon);
        //取到当前定位点
        return;
    }
    
}

/**
 关闭扫描定位
 */
- (void)stopRangingBeacons{
    
    //清除所有蓝牙设备
    [self.beaconDic removeAllObjects];
#if TARGET_OS_SIMULATOR
#else
    [BRTBeaconSDK stopRangingBeacons];
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        _timer = nil;
    }
#endif
}

@end
