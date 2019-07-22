//
//  WFImage.h
//  InWalkAR
//
//  Created by wangfan on 2018/7/20.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/Uikit.h>
#import "WFShape.h"
NS_ASSUME_NONNULL_BEGIN

@interface WFImage : WFShape
@property(nonatomic,strong,nonnull) UIImage *image;
@property(nonatomic) CGSize scale;
@property(nonatomic) CGPoint position;
@property(nonatomic) float rotateAngle;
@end

NS_ASSUME_NONNULL_END
