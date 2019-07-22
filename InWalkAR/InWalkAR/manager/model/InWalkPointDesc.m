//
//  InWalkPointDesc.m
//  InWalkAR
//
//  Created by limu on 2019/6/4.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import "InWalkPointDesc.h"

@implementation InWalkPointDesc

-(instancetype) initWithSlogan:(NSString*)sloganImg type:(NSString*)typeImg ad:(NSString*)adImg desc:(NSString*)desc{
    if (self = [self init]) {
        self.imgSlogan = sloganImg;
        self.imgType = typeImg;
        self.imgAd = adImg;
        self.imgDesc = desc;
    }
    return self;
}

- (instancetype)initWithShopName:(NSString*)shopName smallImage:(NSString*)smallImg scale:(float)scale1 expandImage:(NSString*)expandImg scale:(float)scale2 {
    if (self = [self init]) {
        self.name = shopName;
        self.imgSmall = smallImg;
        self.imgExpand = expandImg;
        self.scaleSmall = scale1;
        self.scaleExpand = scale2;
    }
    return self;
}

@end
