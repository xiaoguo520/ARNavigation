//
//  UIViewController+Extend.h
//  BigReading
//
//  Created by 新开元 iOS on 2017/4/12.
//  Copyright © 2017年 新开元 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Extend)
/**
 *屏幕快照
 */
@property (nonatomic, strong) UIView *snapshot;

@property(nonatomic,strong)UIView *topSnapshot;

@property(nonatomic,strong)UIView *viewSnapshot;

@property (copy, nonatomic) NSString *navBarBgAlpha;

-(void)setBackgroundImageWithImageName:(NSString *)imageName;


/**
 设置返回按钮
 */
- (void)addLeftBackBtn;

/**
 设置返回根按钮
 */
- (void)addBackBtnToHomePage;

/**
 设置右边文字按钮
 */
- (UIButton *)addRightTextButtonWithText:(NSString *)buttonText action:(SEL)action;

/**
 设置右边图片按钮
 */
- (UIButton *)addRightImageButtonWithImageName:(NSString *)imageName action:(SEL)action;

/**
 设置左边文字按钮 注意不能与 addBackBtnToHomePage | addLeftBackBtn 同时使用
 */

- (UIButton *)addLeftTextButtonWithText:(NSString *)buttonText action:(SEL)action;



#pragma mark - action
//返回上一级页面
- (void)back;

//返回根页面
- (void)backToHomepage;



@end
