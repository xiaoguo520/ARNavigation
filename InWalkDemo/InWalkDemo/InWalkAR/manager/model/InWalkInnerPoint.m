//
//  InWalkInnerPoint.m
//  InWalkAR
//
//  Created by wangfan on 2018/6/15.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InWalkInnerPoint.h"
#import "InWalkPoint.h"

@implementation InWalkInnerPoint
-(InWalkPoint *) parseToPoint;{
    InWalkPoint *point = [[InWalkPoint alloc] init];
    //point.angle = _angle;
    point.hid = _hid;
    //point.url = _url;
    point.floor = _floor;
    return point;
}
@end
