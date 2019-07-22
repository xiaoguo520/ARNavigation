//
//  InWalkPath.m
//  InWalkAR
//
//  Created by limu on 2018/11/28.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import "InWalkPath.h"

@implementation InWalkPath

-(NSArray<NSNumber *> *) positionAtIndex:(int) index{
    if (index < _data.count - 1 && index >= 0) {
        NSMutableArray<NSNumber *> * position = [NSMutableArray arrayWithCapacity:3] ;
        position[0] = _data[index];
        position[1] = _data[index + 1];
        position[2] = [NSNumber numberWithInt:0];
        return position;
    }
    return nil;
}

@end
