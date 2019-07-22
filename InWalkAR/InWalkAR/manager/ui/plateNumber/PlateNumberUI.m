//
//  PlateNumberUI.m
//  ARKitDemoUI
//
//  Created by limu on 2018/12/28.
//  Copyright © 2018年 example. All rights reserved.
//

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width

#import "PlateNumberUI.h"

@interface PlateNumberUI()<UISearchBarDelegate>{
    UIView *_popView;
    UIView *_superView;
    UISearchBar *search;
    UIPanGestureRecognizer *pan;
}
@end

// 输入车牌号码
@implementation PlateNumberUI

- (void)setSuperView:(UIView *)view{
    _superView = view;
}

- (void)show{
    float viewWidth = kScreenWidth;
    float viewHeight = 186;
    
    CGRect rect = CGRectMake(0, kScreenHeight - viewHeight, viewWidth, viewHeight);
    _popView = [[UIView alloc] initWithFrame:rect];
    [_popView setBackgroundColor:[UIColor whiteColor]];
    // 圆角（上边框）
    float radius = 4;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_superView.bounds
                                                   byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                         cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = _superView.bounds;
    maskLayer.path = maskPath.CGPath;
    _popView.layer.mask = maskLayer;
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
        UITapGestureRecognizer *tapGesturePop = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
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
        float y = 76; //32 + 36 + 8;
        CGRect searchFrame = CGRectMake(10, y, viewWidth - 20, 36);
        search = [[UISearchBar alloc] initWithFrame:searchFrame];
        //[search setShowsCancelButton:YES];
        //[search setBackgroundColor:[UIColor redColor]]; // 外边框背景色
        [search setPlaceholder:@"输入车牌号码"]; // 搜索泊位号
        [search setBackgroundImage:[UIImage new]]; // 去掉外边框的灰色部分
        // 输入部分背景色
        UITextField *txfSearchField = [search valueForKey:@"_searchField"];
        txfSearchField.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1]; // #f6f6f6
        // 弹出键盘时，视图上移
        [_popView addSubview:search];
        // 注册观察键盘的变化
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transformView:) name:UIKeyboardWillChangeFrameNotification object:nil];
        // 输入时的事件
        search.delegate = self;
        // 展示键盘DONE键
        search.returnKeyType = UIReturnKeyDone;
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
    //NSLog(@"pan ... %f", tp.y);
    if (tp.y > 50) {
        [self removePanGesture];
        
        // 收起键盘
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        
        [self addPanGesture];
    }
}


// 键盘的DONE键点击事件
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    // 收起键盘
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
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
    
    //在0.25s内完成self.view的Frame的变化，等于是给self.view添加一个向上移动deltaY的动画
    [UIView animateWithDuration:0.25f animations:^{
        [_superView setFrame:CGRectMake(_superView.frame.origin.x,
                                        _superView.frame.origin.y + deltaY,
                                        _superView.frame.size.width,
                                        _superView.frame.size.height)];
    }];
}

- (void)btnClick:(UITapGestureRecognizer *)recognizer{
    //NSLog(@"onclick(plate num)");
    if (_delegate) {
        [_delegate onConfirm:search.text];
        //NSLog(@"onclick(plate num):%@",search.text);
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
- (void)dismiss:(UITapGestureRecognizer *)recognizer{
    //NSLog(@"dismiss(close) ...");
    //[self dismiss];
}

// 点击popWindow
-(void) popTouchUpInside:(UITapGestureRecognizer *)recognizer{
    //NSLog(@"clicked pop...");
}

@end
