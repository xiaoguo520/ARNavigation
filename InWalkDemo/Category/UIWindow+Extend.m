//
//  UIWindow+Extend.m
//  New_Patient
//
//  Created by 新开元 iOS on 2018/5/16.
//  Copyright © 2018年 新开元 iOS. All rights reserved.
//

#import "UIWindow+Extend.h"

@implementation UIWindow (Extend)

- (UIViewController*)currentController{
    UIViewController *vc = nil;
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    if ([window.rootViewController isKindOfClass:[UINavigationController class]])
    {
        vc = [(UINavigationController *)window.rootViewController visibleViewController];
    }
    else if ([window.rootViewController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabVC = (UITabBarController*)window.rootViewController;
        if ([[tabVC selectedViewController] isKindOfClass:[UINavigationController class]]) {
            vc = [(UINavigationController *)[tabVC selectedViewController] visibleViewController];
        }else{
            vc = tabVC.selectedViewController;
        }
    }
    else
    {
        vc = window.rootViewController;
    }
    
    return vc;
}

- (UIView*)statusBar{
    UIView *statusBar = nil;
    NSData *data = [NSData dataWithBytes:(unsigned char []){0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72} length:9];
    NSString *key = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    id object = [UIApplication sharedApplication];
    if ([object respondsToSelector:NSSelectorFromString(key)]) statusBar = [object valueForKey:key];
    return statusBar;
}
- (CGFloat)statusBarHeight{
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

@end
