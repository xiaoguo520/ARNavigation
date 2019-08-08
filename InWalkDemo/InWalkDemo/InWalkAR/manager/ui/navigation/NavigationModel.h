//
//  NavigationModel.h
//  ARKitDemoUI
//
//  Created by limu on 2019/1/4.
//  Copyright © 2019年 example. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, NavigationTip) {
    NavigationTipStart     = 0,
    NavigationTipStraight  = 1,
    NavigationTipTurnLeft  = 2,
    NavigationTipTurnRight = 3,
    NavigationTipEnd       = 4,
};

@interface NavigationModel : NSObject
@property NSString *distanceToTurnDesc;
@property NSString *distanceToEndDesc;
@property NavigationTip tip;
@property float distanceToTurn;
@property float distanceToEnd;

- (instancetype)initWithDistanceToTurn:(NSString *)length tip:(NavigationTip)tip;
@end

NS_ASSUME_NONNULL_END
