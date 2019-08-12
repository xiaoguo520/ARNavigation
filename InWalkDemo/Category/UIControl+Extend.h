//
//  UIControl+Extend.h
//  patient
//
//  Created by 新开元 iOS on 16/10/19.
//  Copyright © 2016年 com.xky.app. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (Extend)
- (void)addControlEvent:(UIControlEvents)event withBlock:(void(^)(id sender))block;
- (void)removeControlEvent:(UIControlEvents)event;
@end
