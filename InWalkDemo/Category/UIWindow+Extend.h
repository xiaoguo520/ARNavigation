//
//  UIWindow+Extend.h
//  New_Patient
//
//  Created by 新开元 iOS on 2018/5/16.
//  Copyright © 2018年 新开元 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (Extend)


/**
 当前控制器
 @return UIViewController
 */
- (UIViewController*)currentController;

/**
 当前状态条

 @return UIView
 */
- (UIView*)statusBar;

/**
 当前状态条高度

 @return CGFloat
 */
- (CGFloat)statusBarHeight;

@end
