//
//  StartPositionModel.m
//  ARKitDemoUI
//
//  Created by limu on 2019/1/4.
//  Copyright © 2019年 example. All rights reserved.
//

#import "StartPositionModel.h"

@implementation StartPositionModel

- (instancetype)initWithName:(NSString *)name detail:(NSString *)detail imgName:(NSString *)imgName key:(NSString *)key{
    self = [self init];
    if (self) {
        self.name = name;
        self.detail = detail;
        self.imgName = imgName;
        self.keyId = key;
    }
    return self;
}

@end
