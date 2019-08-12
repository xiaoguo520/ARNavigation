//
//  UINavigationController+Extend.m
//  BigReading
//
//  Created by 新开元 iOS on 2018/4/11.
//  Copyright © 2018年 新开元 iOS. All rights reserved.
//

#import "UINavigationController+Extend.h"
#import <objc/runtime.h>

@implementation UINavigationController (Extend)

@dynamic popDelegate;


-(void)setPopDelegate:(id)popDelegate{
    self.popDelegate = popDelegate;
}

//此方法必须实现
-(void)setExtendPopDelegate{
     self.interactivePopGestureRecognizer.delegate = self.popDelegate;
}

- (void)setNeedsNavigationBackground:(CGFloat)alpha {
    // 导航栏背景透明度设置
    UIView *barBackgroundView;
    if (self.navigationBar.subviews.count > 0) {
       barBackgroundView = [[self.navigationBar subviews] objectAtIndex:0];// _UIBarBackground
    }
    if (self.navigationBar.isTranslucent) {
        for (UIView * view in barBackgroundView.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                UIImageView *backgroundImageView = (UIImageView *)view;
                if (backgroundImageView != nil && backgroundImageView.image != nil) {
                    barBackgroundView.alpha = alpha;
                }
            }else{
                UIView *backgroundEffectView = view;// UIVisualEffectView
                if (backgroundEffectView != nil) {
                    backgroundEffectView.alpha = alpha;
                }
            }
        }
    } else {
        barBackgroundView.alpha = alpha;
    }
    self.navigationBar.clipsToBounds = alpha == 0.0;
}
+ (void)initialize {
    if (self == [UINavigationController self]) {
        // 交换方法
        SEL originalSelector = NSSelectorFromString(@"_updateInteractiveTransition:");
        SEL swizzledSelector = NSSelectorFromString(@"et__updateInteractiveTransition:");
        Method originalMethod = class_getInstanceMethod([self class], originalSelector);
        Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

// 交换的方法，监控滑动手势
- (void)et__updateInteractiveTransition:(CGFloat)percentComplete {
    [self et__updateInteractiveTransition:(percentComplete)];
    UIViewController *topVC = self.topViewController;
    if (topVC != nil && topVC.navBarBgAlpha) {
        id<UIViewControllerTransitionCoordinator> coor = topVC.transitionCoordinator;
        if (coor != nil) {
            // 随着滑动的过程设置导航栏透明度渐变
            CGFloat fromAlpha = [[coor viewControllerForKey:UITransitionContextFromViewControllerKey].navBarBgAlpha floatValue];
            CGFloat toAlpha = [[coor viewControllerForKey:UITransitionContextToViewControllerKey].navBarBgAlpha floatValue];
            CGFloat nowAlpha = fromAlpha + (toAlpha - fromAlpha) * percentComplete;
//            NSLog(@"from:%f, to:%f, now:%f",fromAlpha, toAlpha, nowAlpha);
            [self setNeedsNavigationBackground:nowAlpha];
        }
    }
}

#pragma mark - UINavigationController Delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if(viewController == self.viewControllers[0])
    {//显示根控制器
        self.interactivePopGestureRecognizer.delegate = self.popDelegate;
    }
    else
    {
        self.interactivePopGestureRecognizer.delegate = nil;
    }
    UIViewController *topVC = self.topViewController;
    if (topVC != nil) {
        id<UIViewControllerTransitionCoordinator> coor = topVC.transitionCoordinator;
        if (coor != nil) {
            //            [coor notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context){
            //                [self dealInteractionChanges:context];
            //            }];
            
            // notifyWhenInteractionChangesUsingBlock是10.0以后的api，换成notifyWhenInteractionEndsUsingBlock
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [coor notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context){
                [self dealInteractionChanges:context];
#pragma clang diagnostic pop
            }];
        }
    }
}

- (void)dealInteractionChanges:(id<UIViewControllerTransitionCoordinatorContext>)context {
    if ([context isCancelled]) {// 自动取消了返回手势
        NSTimeInterval cancelDuration = [context transitionDuration] * (double)[context percentComplete];
        [UIView animateWithDuration:cancelDuration animations:^{
            CGFloat nowAlpha = [[context viewControllerForKey:UITransitionContextFromViewControllerKey].navBarBgAlpha floatValue];
//            NSLog(@"自动取消返回到alpha：%f", nowAlpha);
            [self setNeedsNavigationBackground:nowAlpha];
        }];
    } else {// 自动完成了返回手势
        NSTimeInterval finishDuration = [context transitionDuration] * (double)(1 - [context percentComplete]);
        [UIView animateWithDuration:finishDuration animations:^{
            CGFloat nowAlpha = [[context viewControllerForKey:
                                 UITransitionContextToViewControllerKey].navBarBgAlpha floatValue];
//            NSLog(@"自动完成返回到alpha：%f", nowAlpha);
            [self setNeedsNavigationBackground:nowAlpha];
        }];
    }
}



#pragma mark - UINavigationBar Delegate
- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item {
    if (self.viewControllers.count >= navigationBar.items.count) {// 点击返回按钮
        UIViewController *popToVC = self.viewControllers[self.viewControllers.count - 1];
        [self setNeedsNavigationBackground:[popToVC.navBarBgAlpha floatValue]];
        //        [self popViewControllerAnimated:YES];
    }
}

- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item {
    // push到一个新界面
    [self setNeedsNavigationBackground:[self.topViewController.navBarBgAlpha floatValue]];
}


//定义常量 必须是C语言字符串
static char *CloudoxKey = "CloudoxKey";

-(void)setCloudox:(NSString *)cloudox{
    objc_setAssociatedObject(self, CloudoxKey, cloudox, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)cloudox{
    return objc_getAssociatedObject(self, CloudoxKey);
}

@end
