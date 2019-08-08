//
//  RvtsUI.m
//  InWalkAR
//
//  Created by limu on 2019/4/10.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import "RvtsUI.h"
#import "RZCarPlateNoTextField.h"
#import "PopView.h"
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width

@interface RvtsUI(){
    PopView *_popView;
    UIView *_superView;
    NSString *_title;
    RZCarPlateNoTextField *search;
    UIPanGestureRecognizer *pan;
}
@end

@implementation RvtsUI

- (void)setSuperView:(UIView *)view {
    _superView = view;
}

- (void)setTitle:(NSString *)title {
    _title = title;
}

- (void)show {
    float viewWidth = kScreenWidth;
    float viewHeight = 186;
    
    CGRect rect = CGRectMake(0, kScreenHeight - viewHeight, viewWidth, viewHeight);
    _popView = [[PopView alloc] initWithFrame:rect];
    [_popView setBackgroundColor:[UIColor whiteColor]];
    // 阴影效果
    _popView.layer.shadowOpacity = 0.5;
    _popView.layer.shadowRadius = 5;
    _popView.layer.shadowColor = [UIColor grayColor].CGColor;
    _popView.layer.shadowOffset = CGSizeMake(0, -1);
    //
    [_superView addSubview:_popView];
    // add header view.
    {
        float w = 32;
        float h = 4;
        CGRect headerFrame = CGRectMake((viewWidth - w) / 2, (24 - h) / 2, w, h);
        UIView *header = [[UIView alloc] initWithFrame:headerFrame];
        [header setBackgroundColor:[UIColor lightGrayColor]];
        [header.layer setCornerRadius:2];
        [_popView addSubview:header];
    }
    // add close button(height:32+12=44).
    {
        float padding = 6;
        float w = 32;
        CGRect closeFrame = CGRectMake(viewWidth - w - padding, padding, w, w);
        UIImageView *img = [[UIImageView alloc] initWithFrame:closeFrame];
        [img setImage:[UIImage imageNamed:@"close_48.png"
                                 inBundle:[NSBundle bundleForClass:[self class]]
            compatibleWithTraitCollection:nil]];
        // add tap event.
        UITapGestureRecognizer *tapGesturePop = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
        img.userInteractionEnabled = YES;
        [img addGestureRecognizer:tapGesturePop];
        [_popView addSubview:img];
    }
    // add title(height:36).
    {
        float y = 32;
        CGRect titleFrame = CGRectMake(16, y, viewWidth - 32, 36);
        UILabel *title = [[UILabel alloc] initWithFrame:titleFrame];
        [title setText:@"输入您的车牌号码"];
        [title setTextAlignment:NSTextAlignmentLeft];
        [title setFont:[UIFont systemFontOfSize:18]];
        [_popView addSubview:title];
    }
    // add input text(height:36).
    {
//        RZCarPlateNoTextField *textfield = [[RZCarPlateNoTextField alloc] initWithFrame:CGRectMake(10, 100, 300, 50)];
        float y = 76; //32 + 36 + 8;
        CGRect searchFrame = CGRectMake(16, y, viewWidth - 32, 36);
        search = [[RZCarPlateNoTextField alloc] initWithFrame:searchFrame];
        search.leftViewMode = UITextFieldViewModeAlways;
//        //[search setShowsCancelButton:YES];
        //[search setBackgroundColor:[UIColor redColor]]; // 外边框背景色
        [search setPlaceholder:@"输入车牌号码"]; // 搜索泊位号
        search.layer.cornerRadius = 4;
//        [search setBackgroundImage:[UIImage new]]; // 去掉外边框的灰色部分
//        // 输入部分背景色
//        UITextField *txfSearchField = [search valueForKey:@"_searchField"];
        search.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1]; // #f6f6f6
        // 弹出键盘时，视图上移
        [_popView addSubview:search];
        // 注册观察键盘的变化
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transformView:) name:UIKeyboardWillChangeFrameNotification object:nil];
//        // 输入时的事件
//        search.delegate = self;
//        // 展示键盘DONE键
//        search.returnKeyType = UIReturnKeyDone;
    }
    // add confirm button(height:40).
    {
        float y = 126; // 76 + 36 + 14
        CGRect btnFrame = CGRectMake(16, y, viewWidth - 32, 46);
        UIButton *btn = [[UIButton alloc] initWithFrame:btnFrame];
        [btn setTitle:@"确定" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor blueColor]];
        // #0x2789fc
        [btn setBackgroundColor:[UIColor colorWithRed:39.0/255 green:137.0/255 blue:252.0/255 alpha:1.0]];
        [btn.layer setCornerRadius:4];
        // 点击事件
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_popView addSubview:btn];
    }
    
    // add tap event.
    UITapGestureRecognizer *tapGesturePop = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popTouchUpInside:)];
    _popView.userInteractionEnabled = YES;
    [_popView addGestureRecognizer:tapGesturePop];
    
    [self addPanGesture];
}


#pragma mark - popView展开时(键盘可见)，向下滑动popView将键盘隐藏，并将popView重置为收缩状态
- (void)addPanGesture {
    if (!pan) {
        pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    }
    [_popView addGestureRecognizer:pan];
}

- (void)removePanGesture {
    if (pan) {
        [_popView removeGestureRecognizer:pan];
    }
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    CGPoint tp = [pan translationInView:_popView];
    // 向上滑动时 tp.y 为负，向下滑动时 tp.y 为正
    if (tp.y > 50) {
        [self removePanGesture];
        
        // 收起键盘
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        
        [self addPanGesture];
    }
}


// 弹出键盘，视图上移
-(void)transformView:(NSNotification *)aNSNotification{
    // 键盘弹出前的Rect
    NSValue *keyBoardBeginRect = [[aNSNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect beginRect = [keyBoardBeginRect CGRectValue];
    
    // 键盘弹出后的Rect
    NSValue *keyBoardEndRect = [[aNSNotification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect endRect = [keyBoardEndRect CGRectValue];
    
    // 获取键盘位置变化前后纵坐标Y的变化值
    CGFloat deltaY = endRect.origin.y - beginRect.origin.y; // -216
    if (deltaY < 0) {
        deltaY += 60;
    } else {
        deltaY -= 60;
    }
    
    //在0.25s内完成self.view的Frame的变化，等于是给self.view添加一个向上移动deltaY的动画
    [UIView animateWithDuration:0.25f animations:^{
//        [_superView setFrame:CGRectMake(_superView.frame.origin.x,
//                                        _superView.frame.origin.y + deltaY,
//                                        _superView.frame.size.width,
//                                        _superView.frame.size.height)];
        
        [_popView setFrame:CGRectMake(_popView.frame.origin.x,
                                      _popView.frame.origin.y + deltaY,
                                      _popView.frame.size.width,
                                      _popView.frame.size.height)];
    }];
}

- (void)btnClick:(UITapGestureRecognizer *)recognizer{
    //NSLog(@" todo-反向寻车 onclick(plate num) %@", search.text);
    if (_delegate) {
        [_delegate onClickRvts:search.text];
        ////NSLog(@"onclick(plate num):%@",search.text);
    }
}

- (void)hideView {
    if (_popView) {        
        [_popView removeFromSuperview];
    }
}

- (void)restoreView {
    if (_popView) {
        [_superView addSubview:_popView];
    }
}

- (void)dismiss{
    if (_popView) {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
        [_popView removeFromSuperview];
        
        if (_popView.subviews) {
            for (UIView *v in _popView.subviews) {
                [v removeFromSuperview];
            }
        }
    }
}

// close.
- (void)close:(UITapGestureRecognizer *)recognizer{
    //NSLog(@"dismiss(close) ...");
    //[self dismiss];
    [self dismiss];
    if (_delegate) {
        [_delegate onCloseRvts];
    }
}

// 点击popWindow
-(void) popTouchUpInside:(UITapGestureRecognizer *)recognizer{
    ////NSLog(@"clicked pop...");
}

@end
