//
//  UIImage+ColorPick.h
//  InWalkAR
//
//  Created by limu on 2019/5/16.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (ColorPick)

- (UIColor *)colorAtPixel:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
