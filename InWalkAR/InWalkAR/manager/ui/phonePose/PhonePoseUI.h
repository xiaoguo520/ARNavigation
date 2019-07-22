//
//  PhonePoseUI.h
//  InWalkAR
//
//  Created by limu on 2019/4/27.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "InWalkUIManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhonePoseUI : NSObject

- (void)setSuperView:(UIView *)view;
- (void)setPhonePose:(InWalkPhonePose)flag;

@end

NS_ASSUME_NONNULL_END
