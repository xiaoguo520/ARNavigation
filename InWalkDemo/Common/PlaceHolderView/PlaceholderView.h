//
//  PlaceholderView.h
//  InWalkDemo
//
//  Created by xky_ios on 2019/8/6.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    JKPlaceholderTypeCom,
    JKPlaceholderTypeNoNet,
    JKPlaceholderTypeServeError,
    JKPlaceholderTypeUnkown,
} PlaceholderType;

typedef void(^PlaceholderViewBlcok)(void);

@interface PlaceholderView : UIView

@property (nonatomic,weak) UIImageView * holderView;
@property (nonatomic,weak) UILabel * holderTitle;
@property (nonatomic,weak) UIButton * holderBtn;

/**
 是否显示按钮
 */
@property (nonatomic,assign) BOOL isShowBtn;

/**
 是否点击空白页刷新，默认不点击
 */
@property (nonatomic,assign) BOOL isClickBlank;

/**
 点击按钮回调
 */
@property (nonatomic,copy) PlaceholderViewBlcok btnClickBlock;
/**
 点击空白页回调
 */
@property (nonatomic,copy) PlaceholderViewBlcok blankBlcok;


-(instancetype)initWithImageName:(NSString *)imageName withMsg:(NSString *)msg BtnTitle:(NSString *)title superView:(UIView *)view;


-(void)setPlaceholderWithSuperView:(UIView *)view placeholderType:(PlaceholderType)type;


@end

NS_ASSUME_NONNULL_END
