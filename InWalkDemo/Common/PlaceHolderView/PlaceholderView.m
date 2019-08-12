//
//  PlaceholderView.m
//  InWalkDemo
//
//  Created by xky_ios on 2019/8/6.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import "PlaceholderView.h"

@implementation PlaceholderView


-(instancetype)initWithImageName:(NSString *)imageName withMsg:(NSString *)msg BtnTitle:(NSString *)title superView:(UIView *)view{
    if (self = [super init]) {
        self.holderTitle.text = msg;
        self.holderView.image = [UIImage imageNamed:imageName];
        if (title && ![title isEqualToString:@""]) {
            [self.holderBtn setTitle:@"title" forState:UIControlStateNormal];
            self.holderBtn.hidden = NO;
        }else{
            self.holderBtn.hidden = YES;
        }
        [view addSubview:self];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view);
        }];
        
    }
    return self;
}


-(void)setPlaceholderWithSuperView:(UIView *)view placeholderType:(PlaceholderType)type{
    [view addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    NSString * imageName;
    NSString * titel;
    NSString *holderBtnTitle;
    switch (type) {
        case JKPlaceholderTypeCom:{
            imageName = @"icon_record_blank";
            titel = @"暂无相关记录";
        }
            break;
        case JKPlaceholderTypeNoNet:{
            imageName = @"icon_network_blank";
            titel = @"网络未连接，点击刷新";
            self.isClickBlank = YES;
        }
            break;
        case JKPlaceholderTypeServeError:{
            imageName = @"icon_error_blank";
            titel = @"请求服务器失败，点击重试";
            self.isClickBlank = YES;
        }
            break;
        default:{
            imageName = @"icon_record_blank";
            titel = @"暂无相关信息";
        }
            break;
    }
    self.holderView.image = [UIImage imageNamed:imageName];
    self.holderTitle.text = titel;
    [self.holderBtn setTitle:holderBtnTitle forState:UIControlStateNormal];
}


#pragma mark - getter setter
-(void)setIsClickBlank:(BOOL)isClickBlank{
    WeakSelf;
    _isClickBlank = isClickBlank;
    if (isClickBlank) {
        [self click:^(UIView *view, UIGestureRecognizer *sender) {
            if (weakSelf.blankBlcok) {
                weakSelf.blankBlcok();
            }
        }];
    }
}

-(void)setIsShowBtn:(BOOL)isShowBtn{
    _isShowBtn = isShowBtn;
    if (isShowBtn) {
        self.holderBtn.hidden = NO;
    }else{
        self.holderBtn.hidden = YES;
    }
}

-(UIImageView *)holderView{
    if (!_holderView) {
        UIImageView * i = [[UIImageView alloc] init];
        [self addSubview:i];
        _holderView = i;
    }
    return _holderView;
}

-(UILabel *)holderTitle{
    if (!_holderTitle) {
        UILabel * l = [[UILabel alloc] init];
        l.textColor = COLOR_COLOR999;
        l.font = [UIFont systemFontOfSize:14 * Size_SizeScale];
        [self addSubview:l];
        _holderTitle = l;
    }
    return _holderTitle;
}

-(UIButton *)holderBtn{
    WeakSelf;
    if (!_holderBtn) {
        UIButton * b = [UIButton buttonWithType:UIButtonTypeCustom];
        [b setTitle:@"点击刷新" forState:UIControlStateNormal];
        [b setBackgroundColor:COLOR_APPBlueColor];
        [GlobalFunction setRoundWithView:b cornerRadius:5];
        [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        b.hidden = YES;
        b.titleLabel.font = [UIFont systemFontOfSize:16 * Size_SizeScale];
        [b addControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            if (weakSelf.btnClickBlock) {
                weakSelf.btnClickBlock();
            }
        }];
        [self addSubview:b];
        _holderBtn = b;
    }
    return _holderBtn;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self.holderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self.mas_centerY).offset(-100 * Size_FIT_WIDTH);
    }];
    
    [self.holderTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.holderView.mas_bottom).offset(15 * Size_FIT_WIDTH);
    }];
    
    [self.holderBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.holderTitle.mas_bottom).offset(30 * Size_FIT_WIDTH);
        make.size.mas_equalTo(CGSizeMake(110 * Size_SizeScale, 36 * Size_SizeScale));
    }];
}

@end
