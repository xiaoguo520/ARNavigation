//
//  NavigationModel.m
//  ARKitDemoUI
//
//  Created by limu on 2019/1/4.
//  Copyright © 2019年 example. All rights reserved.
//

#import "NavigationModel.h"

@implementation NavigationModel

- (instancetype)initWithDistanceToTurn:(NSString *)distance tip:(NavigationTip)tip{
    self = [self init];
    if (self) {
        self.distanceToTurnDesc = distance;
        self.tip = tip;
    }
    return self;
}

@end
