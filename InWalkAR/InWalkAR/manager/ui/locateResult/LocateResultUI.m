//
//  LocateResultUI.m
//  ARKitDemoUI
//  支持反向寻车的停车场：根据输入的车牌号找到车辆所在泊位后，展示确认页面
//
//  Created by limu on 2019/1/2.
//  Copyright © 2019年 example. All rights reserved.
//

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width

#import "LocateResultUI.h"

@interface LocateResultUI(){
    UIView *_popView;
    UIView *_superView;
//    NSArray *_items;
//    NSString *_desc;
//    NSString *_tip;
}
@end

@implementation LocateResultUI

- (void)setSuperView:(UIView *)view{
    _superView = view;
}

//- (void)setItems:(NSArray<NSString *> *)items{
//- (void)setDesc:(NSString *)desc tip:(NSString *)tip items:(NSArray<NSString *> *)items{
//    _desc = desc;
//    _tip = tip;
//    _items = items;
//}

- (void)showDesc:(NSString *)descStr tip:(NSString *)tipStr items:(NSArray<NSString *> *)items{
    float viewWidth = kScreenWidth;
    float viewHeight = 290;
    if (items != nil && items.count > 0) {
        viewHeight = 290;
    } else {
        viewHeight = 190;
    }
    
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
        [title setText:@"您的爱车位于"];
        [title setTextAlignment:NSTextAlignmentLeft];
        [title setFont:[UIFont systemFontOfSize:18]];
        [_popView addSubview:title];
    }
    // add car's position description.
    {
        float y = 68;
        CGRect labelFrame = CGRectMake(18, y, viewWidth - 36, 24);
        UILabel *desc = [[UILabel alloc] initWithFrame:labelFrame];
        //[desc setText:@"B3层 C区 201号 泊位 2公里"];
        [desc setText:descStr];
        [desc setTextAlignment:NSTextAlignmentLeft];
        [desc setTextColor:[UIColor darkTextColor]];
        [desc setFont:[UIFont systemFontOfSize:16]];
        [_popView addSubview:desc];
    }
    // add navigation tips.
    {
        float y = 100; // 68+24+8
        float w = 16;
        CGRect infoRect = CGRectMake(16, y, w, w);
        UIImageView *info = [[UIImageView alloc] initWithFrame:infoRect];
        [info setImage:[UIImage imageNamed:@"info_2x.png"
                                  inBundle:[NSBundle bundleForClass:[self class]]
             compatibleWithTraitCollection:nil]];
        [_popView addSubview:info];
        
        CGRect infoRect2 = CGRectMake(40, y, viewWidth - 40, 16);
        UILabel *infoLable = [[UILabel alloc] initWithFrame:infoRect2];
        [infoLable setFont:[UIFont systemFontOfSize:13]];
        //[infoLable setText:@"仅支持同层AR导航，请移步至B3层停车场"];
        [infoLable setText:tipStr];
        [infoLable setTextColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]];
        [infoLable setTextAlignment:NSTextAlignmentLeft];
        [_popView addSubview:infoLable];
    }
    // add confirm button(height:40).
    {
        float y = 130; // 100 + 16 + 14
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
    // add image list(height:[(sw-20)/4 + 40]).
    if (viewHeight == 290)
    {
        float y = 190; // 130 + 46 + 14
        CGRect rect = CGRectMake(0, y, viewWidth, 100);
        UIScrollView *sv = [[UIScrollView alloc] initWithFrame: rect];
        float cellWidth = 80;
        for (int i = 0; i < items.count; i++) {
            NSString *imgName = [items objectAtIndex:i];
            CGRect cellFrame = CGRectMake(10 + (cellWidth + 10) * i, 0, cellWidth, cellWidth);
            UIImageView *cell = [[UIImageView alloc] initWithFrame: cellFrame];
            [cell setImage:[UIImage imageNamed: imgName ? imgName : @"snowman.png"
                                      inBundle:[NSBundle bundleForClass:[self class]]
                 compatibleWithTraitCollection:nil]];
            [sv addSubview:cell];
        }
        //[sv setScrollEnabled:YES];
        [sv setContentSize: CGSizeMake(cellWidth * items.count + 10, 100)];
        //[sv setBackgroundColor:[UIColor blueColor]];
        [_popView addSubview:sv];
    }
    
    // add tap event.
    UITapGestureRecognizer *tapGesturePop = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popTouchUpInside:)];
    _popView.userInteractionEnabled = YES;
    [_popView addGestureRecognizer:tapGesturePop];
}

- (void)btnClick:(UITapGestureRecognizer *)recognizer{
    if (_delegate) {
        [self dismiss];
        [_delegate onConfirmLocation];
    }
}

// close.
- (void)dismiss:(UITapGestureRecognizer *)recognizer{
    //NSLog(@"dismiss(close) ...");
    //[self dismiss];
}

- (void)dismiss{
    if (_popView) {
        [_popView removeFromSuperview];
        
        if (_popView.subviews) {
            for (UIView *v in _popView.subviews) {
                [v removeFromSuperview];
            }
        }
    }
}

// 点击popWindow
-(void) popTouchUpInside:(UITapGestureRecognizer *)recognizer{
    //NSLog(@"clicked pop...");
}

@end
