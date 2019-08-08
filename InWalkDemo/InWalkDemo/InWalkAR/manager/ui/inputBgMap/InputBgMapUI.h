//
//  InputBgMapUI.h
//  InWalkAR
//
//  Created by limu on 2019/4/27.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "InWalkMap.h"

NS_ASSUME_NONNULL_BEGIN

@interface InputBgMapUI : NSObject

- (void)setSuperView:(UIView *)view;
- (void)setFloor:(InWalkMap *)floor;
- (void)hide;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
