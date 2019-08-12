//
//  UIViewController+Extend.m
//  BigReading
//
//  Created by 新开元 iOS on 2017/4/12.
//  Copyright © 2017年 新开元 iOS. All rights reserved.
//

#import "UIViewController+Extend.h"
#import <objc/runtime.h>



@implementation UIViewController (Extend)

- (UIView *)snapshot
{
    UIView *view = objc_getAssociatedObject(self, @"JKAnimationTransitioningSnapshot");
    if (!view)
    {
        view = [self.navigationController.view snapshotViewAfterScreenUpdates:NO];
        [self setSnapshot:view];
    }
    return view;
}

- (void)setSnapshot:(UIView *)snapshot
{
    objc_setAssociatedObject(self, @"JKAnimationTransitioningSnapshot", snapshot, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (UIView *)topSnapshot
{
    UIView *view = objc_getAssociatedObject(self, @"JKAnimationTransitioningTopSnapshot");
    if(!view)
    {
        view = [self.navigationController.view resizableSnapshotViewFromRect:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), 64) afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
        [self setTopSnapshot:view];
    }
    return view;
}
- (void)setTopSnapshot:(UIView *)topSnapshot
{
    objc_setAssociatedObject(self, @"JKAnimationTransitioningTopSnapshot", topSnapshot, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)viewSnapshot
{
    UIView *view = objc_getAssociatedObject(self, @"JKAnimationTransitioningViewSnapshot");
    if (!view)
    {
        view = [self.navigationController.view resizableSnapshotViewFromRect:CGRectMake(0, 64, CGRectGetWidth([[UIScreen mainScreen] bounds]), CGRectGetHeight([[UIScreen mainScreen] bounds]) - 64) afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
        [self setViewSnapshot:view];
    }
    return view;
}

- (void)setViewSnapshot:(UIView *)viewSnapshot
{
    objc_setAssociatedObject(self, @"JKAnimationTransitioningViewSnapshot", viewSnapshot, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


-(void)setBackgroundImageWithImageName:(NSString *)imageName{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:imageName];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:imageView];
}

//定义常量 必须是C语言字符串
static char *CloudoxKey = "CloudoxKey";

- (void)setNavBarBgAlpha:(NSString *)navBarBgAlpha {
    /*
     OBJC_ASSOCIATION_ASSIGN;            //assign策略
     OBJC_ASSOCIATION_COPY_NONATOMIC;    //copy策略
     OBJC_ASSOCIATION_RETAIN_NONATOMIC;  // retain策略
     
     OBJC_ASSOCIATION_RETAIN;
     OBJC_ASSOCIATION_COPY;
     */
    /*
     * id object 给哪个对象的属性赋值
     const void *key 属性对应的key
     id value  设置属性值为value
     objc_AssociationPolicy policy  使用的策略，是一个枚举值，和copy，retain，assign是一样的，手机开发一般都选择NONATOMIC
     objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy);
     */

    objc_setAssociatedObject(self, CloudoxKey, navBarBgAlpha, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    // 设置导航栏透明度（利用Category自己添加的方法）
    [self.navigationController setNeedsNavigationBackground:[navBarBgAlpha floatValue]];
}

- (NSString *)navBarBgAlpha {
    return objc_getAssociatedObject(self, CloudoxKey) ? : @"1.0";
}

#pragma mark - 导航按钮相关
- (void)addLeftBackBtn
{
//    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
//                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                       target:nil action:nil];
//    negativeSpacer.width = -15;
//    UIButton *button =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)] ;
//    button.backgroundColor = [UIColor clearColor];
//    [button setImage:[UIImage imageNamed:JKbackImageName] forState:UIControlStateNormal];
//    [button setImage:[UIImage imageNamed:JKbackHImageName] forState:UIControlStateHighlighted];
//    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//    if (JK_IOS11) {
//        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0,0,0)];
//    }
//    UIBarButtonItem *backNavigationItem = [[UIBarButtonItem alloc] initWithCustomView:button];
//    self.navigationItem.leftBarButtonItems = @[negativeSpacer, backNavigationItem];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:[UIImage imageNamed:JKbackImageName]];
    
}

- (void)addBackBtnToHomePage
{
    UIButton *button =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)] ;
    button.backgroundColor = [UIColor clearColor];
    [button setImage:[UIImage imageNamed:JKbackImageName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:JKbackHImageName] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(backToHomepage) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button] ;
}

- (UIButton *)addRightTextButtonWithText:(NSString *)buttonText action:(SEL)action
{
    UIButton *textButton =[[UIButton alloc] initWithFrame:CGRectZero];
    textButton.backgroundColor = [UIColor clearColor];
    [textButton setTitle:buttonText forState:UIControlStateNormal];
    [textButton setTitleColor:COLOR_APPBlueColor forState:UIControlStateNormal];
    textButton.titleLabel.font = [UIFont systemFontOfSize:SizeNavigationButtonFontSize];
    [textButton sizeToFit];
    if (buttonText.length == 4) {
        if (IPHONE_IOS7) {
            textButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -15);
        }
    }else {
        if (IPHONE_IOS7) {
            textButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -48);
        }
    }
    [textButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:textButton];
    return textButton;
}

- (UIButton *)addRightImageButtonWithImageName:(NSString *)imageName action:(SEL)action
{
    UIButton *imageButton;
    if (IPHONE_iPhone_6_Plus) {
        imageButton =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    }
    else{
        imageButton =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    }
    imageButton.backgroundColor = [UIColor clearColor];
    [imageButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [imageButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
    imageButton.titleLabel.font = [UIFont systemFontOfSize:SizeNavigationButtonFontSize];
    [imageButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    NSMutableArray * tempArray;
    if (self.navigationItem.rightBarButtonItems.count > 0) {
        tempArray = [self.navigationItem.rightBarButtonItems mutableCopy];
        UIBarButtonItem *tempItem = [[UIBarButtonItem alloc] initWithCustomView:imageButton];
        [tempArray insertObject:tempItem atIndex:self.navigationItem.leftBarButtonItems.count];
        self.navigationItem.rightBarButtonItems = nil;
        self.navigationItem.rightBarButtonItems = tempArray;
    }else{
        self.navigationItem.rightBarButtonItems = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:imageButton];
    }
    return imageButton;
}


- (UIButton *)addLeftTextButtonWithText:(NSString *)buttonText action:(SEL)action
{
    UIButton *textButton =[[UIButton alloc] initWithFrame:CGRectZero];
    textButton.backgroundColor = [UIColor clearColor];
    [textButton setTitle:buttonText forState:UIControlStateNormal];
    textButton.titleLabel.font = [UIFont systemFontOfSize:SizeNavigationButtonFontSize];
    [textButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [textButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [textButton sizeToFit];
    if (buttonText.length == 4) {
        if (IPHONE_IOS7) {
            textButton.titleEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
        }
    }else {
        if (IPHONE_IOS7) {
            textButton.titleEdgeInsets = UIEdgeInsetsMake(0, -48, 0, 0);
        }
    }
    [textButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    NSMutableArray * tempArray;
    if (self.navigationItem.leftBarButtonItems.count > 0) {
        tempArray = [self.navigationItem.leftBarButtonItems mutableCopy];
        UIBarButtonItem *tempItem = [[UIBarButtonItem alloc] initWithCustomView:textButton];
        [tempArray insertObject:tempItem atIndex:self.navigationItem.leftBarButtonItems.count];
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.leftBarButtonItems = tempArray;
    }else{
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:textButton];
    }
    
    return textButton;
}

#pragma mark - Action

//返回上一级页面
- (void)back{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backToHomepage{
    [self.view endEditing:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
