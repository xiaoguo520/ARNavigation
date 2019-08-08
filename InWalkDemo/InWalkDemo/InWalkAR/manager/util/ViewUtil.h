//
//  ViewUtl.h
//  InWalkAR
//
//  Created by limu on 2018/12/6.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewUtil : NSObject
+(void)makeToast:(NSString *)message view:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
