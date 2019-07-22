//
//  NavigationUI.m
//  ARKitDemoUI
//
//  Created by limu on 2019/1/4.
//  Copyright © 2019年 example. All rights reserved.
//

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width

#import "NavigationUI.h"
#import "ZXSNuTableViewCell.h"
#import "PopView.h"

@interface NavigationUI()<UITableViewDelegate,UITableViewDataSource>{
    PopView *_popView;
    UIView *_superView;
    UIView *_listView;
    UITableView *tableView;
    NSArray<NavigationModel *> *_items;
    NavigationModel *currentTip;
    NSString *remainTimeStr;
    NSString *remainDistanceStr;
    NSString *arriveTimeStr;
    UIView *header;
    UIView *line;
    UILabel *lbRemainTime;
    UILabel *lbRemainStr2;
    UIButton *btnFinish;
    UIView *tipView;
    UIImageView *tipIcon;
    UILabel *tipLabel;
    //UIImageView *mapIcon;
    UIView *backToCurrent; // 小地图中心点回到当前位置
    BOOL _isMapOpen;
    int tick;
    UIPanGestureRecognizer *pan;
    NSString *_destParkingNo;
}
@end

@implementation NavigationUI

- (void)setSuperView:(UIView *)view{
    _superView = view;
}

- (void)setItems:(NSArray<NavigationModel *> *)items dest:(NSString *)destParkingNo{
    _items = items;
    _destParkingNo = destParkingNo;
}

//- (void)setTip:(NavigationModel *)tip remainTime:(NSString *)timeStr distance:(NSString *)distance arriveTime:(NSString *)arriveTime{
//    currentTip = tip;
//    remainTimeStr = timeStr;
//    remainDistanceStr = distance;
//    arriveTimeStr = arriveTime;
//}

- (void)showTip:(NavigationModel *)tip remainTime:(NSString *)timeStr distance:(NSString *)distance arriveTime:(NSString *)arriveTime{
    currentTip = tip;
    remainTimeStr = timeStr;
    remainDistanceStr = distance;
    arriveTimeStr = arriveTime;
    
    if (!_popView) {
        //NSLog(@" 333 addView ... 66");
        [self initView];
    }
    
    // set tips.
    [self refreshTips];
}

- (void)refreshTips{
    //[lb setText:@"20米后右转"];
    switch (currentTip.tip) {
        case NavigationTipTurnLeft:{
            // turn left.
            [tipIcon setImage:[UIImage imageNamed:@"tip_left_3x.png"
                                         inBundle:[NSBundle bundleForClass:[self class]]
                    compatibleWithTraitCollection:nil]];
            
            NSMutableDictionary *attributesDic1 = [NSMutableDictionary dictionary];
            [attributesDic1 setObject:[UIFont systemFontOfSize:24 weight:UIFontWeightMedium] forKey:NSFontAttributeName];
            NSMutableAttributedString *attrStr1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", currentTip.distanceToTurnDesc] attributes:attributesDic1];
            
            NSMutableDictionary *attributesDic2 = [NSMutableDictionary dictionary];
            [attributesDic2 setObject:[UIFont systemFontOfSize:22 weight:UIFontWeightRegular] forKey:NSFontAttributeName];
            NSMutableAttributedString *attrStr2 = [[NSMutableAttributedString alloc] initWithString:@"后左转" attributes:attributesDic2];
            
            [attrStr1 appendAttributedString:attrStr2];
            tipLabel.attributedText = attrStr1;
        }break;
        case NavigationTipTurnRight:{
            // turn right.
            [tipIcon setImage:[UIImage imageNamed:@"tip_right_3x.png"
                                         inBundle:[NSBundle bundleForClass:[self class]]
                    compatibleWithTraitCollection:nil]];
            
            NSMutableDictionary *attributesDic1 = [NSMutableDictionary dictionary];
            [attributesDic1 setObject:[UIFont systemFontOfSize:24 weight:UIFontWeightMedium] forKey:NSFontAttributeName];
            NSMutableAttributedString *attrStr1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", currentTip.distanceToTurnDesc] attributes:attributesDic1];
            
            NSMutableDictionary *attributesDic2 = [NSMutableDictionary dictionary];
            [attributesDic2 setObject:[UIFont systemFontOfSize:22 weight:UIFontWeightRegular] forKey:NSFontAttributeName];
            NSMutableAttributedString *attrStr2 = [[NSMutableAttributedString alloc] initWithString:@"后右转" attributes:attributesDic2];
            
            [attrStr1 appendAttributedString:attrStr2];
            tipLabel.attributedText = attrStr1;
        }break;
        case NavigationTipStraight:{
            // go straight.
            [tipIcon setImage:[UIImage imageNamed:@"tip_straight_3x.png"
                                         inBundle:[NSBundle bundleForClass:[self class]]
                    compatibleWithTraitCollection:nil]];
            
            NSMutableDictionary *attributesDic1 = [NSMutableDictionary dictionary];
            [attributesDic1 setObject:[UIFont systemFontOfSize:24 weight:UIFontWeightMedium] forKey:NSFontAttributeName];
            NSMutableAttributedString *attrStr1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", currentTip.distanceToTurnDesc] attributes:attributesDic1];
            
            NSMutableDictionary *attributesDic2 = [NSMutableDictionary dictionary];
            [attributesDic2 setObject:[UIFont systemFontOfSize:22 weight:UIFontWeightRegular] forKey:NSFontAttributeName];
            NSMutableAttributedString *attrStr2 = [[NSMutableAttributedString alloc] initWithString:@"后到达目的地" attributes:attributesDic2];
            
            [attrStr1 appendAttributedString:attrStr2];
            tipLabel.attributedText = attrStr1;
        }break;
        case NavigationTipEnd:{
            if (currentTip.distanceToEnd > 3) {
                // straight.
                [tipIcon setImage:[UIImage imageNamed:@"tip_straight_3x.png"
                                             inBundle:[NSBundle bundleForClass:[self class]]
                        compatibleWithTraitCollection:nil]];
                
                NSMutableDictionary *attributesDic1 = [NSMutableDictionary dictionary];
                [attributesDic1 setObject:[UIFont systemFontOfSize:24 weight:UIFontWeightMedium] forKey:NSFontAttributeName];
                NSMutableAttributedString *attrStr1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", currentTip.distanceToTurnDesc] attributes:attributesDic1];
                
                NSMutableDictionary *attributesDic2 = [NSMutableDictionary dictionary];
                [attributesDic2 setObject:[UIFont systemFontOfSize:22 weight:UIFontWeightRegular] forKey:NSFontAttributeName];
                NSMutableAttributedString *attrStr2 = [[NSMutableAttributedString alloc] initWithString:@"后到达目的地" attributes:attributesDic2];
                
                [attrStr1 appendAttributedString:attrStr2];
                tipLabel.attributedText = attrStr1;
            } else {
                // end.
                [tipIcon setImage:[UIImage imageNamed:@"tip_dest_3x.png"
                                             inBundle:[NSBundle bundleForClass:[self class]]
                        compatibleWithTraitCollection:nil]];
                [tipLabel setFont:[UIFont systemFontOfSize:24 weight:UIFontWeightRegular]];
                [tipLabel setText:@"已到达目的地附近"];
                [self showNavigationEndButton];
            }
        }break;
        default:
            break;
    }
    [lbRemainTime setText:remainTimeStr];
    [lbRemainStr2 setText:[NSString stringWithFormat:@"%@  %@", remainDistanceStr, arriveTimeStr]];
}

- (void)showNavigationEndButton{
    if (_popView.frame.size.height > 100) {
        [_listView removeFromSuperview];
        [tableView removeFromSuperview];
        float deltaY = -241;
        
        //在0.25s内完成self.view的Frame的变化，等于是给self.view添加一个向上移动deltaY的动画
        __weak typeof(self) wself = self;
        [UIView animateWithDuration:0.25f animations:^{
            __strong typeof(wself) sself = wself;
            // 重新设置弹出窗口的frame
            float viewHeight = sself->_popView.frame.size.height + deltaY;
            CGRect rect = CGRectMake(0, kScreenHeight - viewHeight, kScreenWidth, viewHeight);
            [sself->_popView setFrame:rect];
        }];
    }
    
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.25f animations:^{
        __strong typeof(wself) sself = wself;
        // 只保留按钮
        [sself->lbRemainTime removeFromSuperview];
        [sself->lbRemainStr2 removeFromSuperview];
        [sself->header removeFromSuperview];
        [sself->line removeFromSuperview];
        
        [sself->_popView setFrame:CGRectMake(0, kScreenHeight - 64, kScreenWidth, 64)];
        [sself->btnFinish setFrame:CGRectMake(16, 12, kScreenWidth - 32, 40)];
        [sself->btnFinish setTitle:@"结束路线" forState:UIControlStateNormal];
    }];
}


- (void)initView{
    //NSLog(@" 333 navUi.initView ... ");
    float viewWidth = kScreenWidth;
    float viewHeight = 76 + 240 + 1;//24 + 40 + 20;
    
    //    // map button.
    //    {
    //        float padding = 16;
    //        float w = 60;
    //        float x = kScreenWidth - w - padding;
    //        float y = kScreenHeight - 84 - w - padding - 12;
    //
    //        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, w)];
    //        view.layer.cornerRadius = 30;
    //        view.backgroundColor = [UIColor whiteColor];
    //        // add image.
    //        //mapIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
    //        mapIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, w)];
    //        [mapIcon setImage:[UIImage imageNamed:@"map_3x.png"
    //                                     inBundle:[NSBundle bundleForClass:[self class]]
    //                compatibleWithTraitCollection:nil]];
    //        [view addSubview:mapIcon];
    //
    //        // add tap event.
    //        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureMap:)];
    //        view.userInteractionEnabled = YES;
    //        [view addGestureRecognizer:tapGesture];
    //        [_superView addSubview:view];
    //        _isMapOpen = NO;
    //    }
    
    if (!backToCurrent) {
        float padding = 16;
        float w = 60;
        float x = kScreenWidth - w - padding;
        float y = kScreenHeight - 84 - w - padding - 12;
        CGRect rect = CGRectMake(x, y, w, w);
        backToCurrent = [[UIView alloc] initWithFrame:rect];
        backToCurrent.layer.cornerRadius = 30;
        backToCurrent.backgroundColor = [UIColor whiteColor];
        // image
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, w)];
        // rotate and scale image
        CGAffineTransform transform = CGAffineTransformMakeRotation(45*M_PI/180.f);
        transform = CGAffineTransformScale(transform, 0.5, 0.5);
        iv.transform = transform;
        //
        [iv setImage:[UIImage imageNamed:@"ic_nav.png"
                                     inBundle:[NSBundle bundleForClass:[self class]]
                compatibleWithTraitCollection:nil]];
        [backToCurrent addSubview:iv];
        backToCurrent.layer.shadowColor = [UIColor grayColor].CGColor;
        backToCurrent.layer.shadowRadius = 5.f;
        backToCurrent.layer.shadowOffset = CGSizeMake(0.f, 0.f);
        backToCurrent.layer.shadowOpacity = 1.f;
        // add tap event.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setCurrentCenter:)];
        backToCurrent.userInteractionEnabled = YES;
        [backToCurrent addGestureRecognizer:tapGesture];
        [_superView addSubview:backToCurrent];
    }
    
    CGRect rect = CGRectMake(0, kScreenHeight - viewHeight, viewWidth, viewHeight);
    if (_popView) {
        [_popView removeFromSuperview];
    } else {
        _popView = [[PopView alloc] initWithFrame:rect];
    }
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
        header = [[UIView alloc] initWithFrame:CGRectMake(24, 0, kScreenWidth - 48, 24)];
        
        float w = 32;
        float h = 4;
        CGRect headerFrame = CGRectMake((kScreenWidth - 48 - w) / 2, (22 - h) / 2, w, h);
        UIView *line = [[UIView alloc] initWithFrame:headerFrame];
        [line setBackgroundColor:[UIColor lightGrayColor]];
        [line.layer setCornerRadius:2];
        [header addSubview:line];
        [_popView addSubview:header];
        
        // add tap event.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeader:)];
        header.userInteractionEnabled = YES;
        [header addGestureRecognizer:tapGesture];
    }
    // add finish button(height:32+12=44).
    {
        float y = 22;
        float padding = 20;
        float w = 82;
        float h = 36;
        CGRect btnFrame = CGRectMake(viewWidth - w - padding, y, w, h);
        btnFinish = [[UIButton alloc] initWithFrame:btnFrame];
        [btnFinish setTitle:@"结束" forState:UIControlStateNormal];
        [btnFinish setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnFinish setBackgroundColor:[UIColor colorWithRed:232/255.0 green:50/255.0 blue:44/255.0 alpha:1.0]];
        [btnFinish.layer setCornerRadius:4];
        // 点击事件
        [btnFinish addTarget:self action:@selector(finishBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_popView addSubview:btnFinish];
        
        // add line
        float lineX = btnFrame.origin.x - padding;
        line = [[UIView alloc] initWithFrame:CGRectMake(lineX, y, 1, h)];
        [line setBackgroundColor:[UIColor colorWithRed:227/255.0 green:227/255.0 blue:227/255.0 alpha:1.0]];
        [_popView addSubview:line];
        
        // add remain time str.
        lbRemainTime = [[UILabel alloc] initWithFrame:CGRectMake(padding, y - 2, lineX - padding, 18)];
        [lbRemainTime setTextColor:[UIColor blackColor]];
        [lbRemainTime setFont:[UIFont systemFontOfSize:18 weight:UIFontWeightMedium]];
        [lbRemainTime setText:remainTimeStr];
        [_popView addSubview:lbRemainTime];
        
        // add (remain distance) and (arrive time) str.
        lbRemainStr2 = [[UILabel alloc] initWithFrame:CGRectMake(padding, y + 24, lineX - padding, 18)];
        [lbRemainStr2 setTextColor:[UIColor darkTextColor]];
        [lbRemainStr2 setFont:[UIFont systemFontOfSize:18]];
        [lbRemainStr2 setText:[NSString stringWithFormat:@"%@  %@", remainDistanceStr, arriveTimeStr]];
        [_popView addSubview:lbRemainStr2];
    }
    // add list view(UITableView).
    {
        // add gap(gray rect).
        float y = 76;
        CGRect rect = CGRectMake(16, y, kScreenWidth - 32, 2);
        _listView = [[UIView alloc] initWithFrame:rect];
        [_listView setBackgroundColor:[UIColor colorWithRed:224.0/255 green:224.0/255 blue:224.0/255 alpha:1.0]]; // #0xe0e0e0
        [_popView addSubview:_listView];
        
        // add list(UITableView).
        tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, y + 1, kScreenWidth, 240)];//240
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorInset =UIEdgeInsetsMake(0, 32, 0, 16);
        [tableView registerClass:[ZXSNuTableViewCell class] forCellReuseIdentifier:@"ZXSNuTableViewCell"];
        [_popView addSubview:tableView];
    }
    
    // 先展示按钮（把列表移除，但列表需要先占位，否则滚动/点击等交互存在问题）
    viewHeight = 76;
    CGRect rect3 = CGRectMake(0, kScreenHeight - viewHeight, kScreenWidth, viewHeight);
    [_popView setFrame:rect3];
    [_listView removeFromSuperview];
    [tableView removeFromSuperview];
    
    // add tips.
    {
        float statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGRect rect = CGRectMake(16, statusBarHeight, viewWidth - 32, 100);
        if (tipView) {
            [tipView removeFromSuperview];
        } else {
            tipView = [[UIView alloc] initWithFrame:rect];
        }
        [tipView setBackgroundColor:[UIColor colorWithRed:39/255.0 green:42/255.0 blue:58/255.0 alpha:0.5]];
        tipView.layer.cornerRadius = 6;
        //tipView.alpha = 0.5;
        
        // add icon.
        tipIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 60, 60)];
        [tipIcon setImage:[UIImage imageNamed:@"snowman.png"
                                     inBundle:[NSBundle bundleForClass:[self class]]
                compatibleWithTraitCollection:nil]]; // switch...
        [tipView addSubview:tipIcon];
        
        // add label.
        tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, viewWidth - 132, 100)];
        [tipLabel setTextColor:[UIColor whiteColor]];
        [tipLabel setTextAlignment:NSTextAlignmentLeft];
        [tipView addSubview:tipLabel];
        
        [_superView addSubview:tipView];
    }
    
    // add tap event.
    UITapGestureRecognizer *tapGesturePop = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popTouchUpInside:)];
    _popView.userInteractionEnabled = YES;
    [_popView addGestureRecognizer:tapGesturePop];
    
    [self addPanGesture];
}

// 点击popWindow
-(void) popTouchUpInside:(UITapGestureRecognizer *)recognizer{
    ////NSLog(@"clicked pop...");
    CGPoint pt = [recognizer locationInView: _superView];
    if (pt.y > kScreenHeight / 2) {
        // 点击小地图
        //NSLog(@"   点击小地图   ");
    } else {
        //NSLog(@"   点击小地图 ???  ");
    }
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
    if ((tp.y > 50 || tp.y < -50) && pan.state == UIGestureRecognizerStateEnded) {
        [self removePanGesture];
        
        [self animateShowTableView];
    }
}

- (void)tapHeader:(UITapGestureRecognizer *)recognizer{
    [self animateShowTableView];
}

// 点击mapIcon按钮图标
- (void)tapGestureMap:(UITapGestureRecognizer *)recognizer{
    //NSLog(@" tap map ...");
    if (_delegate) {
        [_delegate onClickMapBtn:!_isMapOpen];
    }
}

// 小地图的中心点回到当前位置
- (void)setCurrentCenter:(UITapGestureRecognizer *)recognizer{
    if (_delegate) {
        [_delegate makeMapCenter];
    }
    NSLog(@"makeMapCenter ....");
}

- (void)refreshMapBtn:(BOOL)isMapOpen{
//    //mapIcon = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 28, 28)];
//    [mapIcon setImage:[UIImage imageNamed:isMapOpen ? @"map_close_3x.png" : @"map_3x.png"
//                                 inBundle:[NSBundle bundleForClass:[self class]]
//            compatibleWithTraitCollection:nil]];
    
    _isMapOpen = isMapOpen;
    if (_popView) {
        //[_popView setHidden:isMapOpen];
        if (!isMapOpen) {
            [_popView.superview bringSubviewToFront:_popView];
        }
    }
    if (tipView) {
        [tipView setHidden:!isMapOpen];
    }
    if (backToCurrent) {
        [backToCurrent setHidden:!isMapOpen];
    }
}

- (void)setTipsVisible:(BOOL)visible {
    if (tipView) {
        [tipView setHidden:!visible];
    }
}

- (void)finishBtnClick:(UITapGestureRecognizer *)recognizer{
    if (_delegate) {
        [self dismiss];
        [_delegate onClickFinishBtn];
    }
}

- (void)animateShowTableView{
    float deltaY;
    if (_popView.frame.size.height < 100) {
        [_popView addSubview:_listView];
        [_popView addSubview:tableView];
        deltaY = 241;
    } else {
        [_listView removeFromSuperview];
        [tableView removeFromSuperview];
        deltaY = -241;
    }
    
    //在0.25s内完成self.view的Frame的变化，等于是给self.view添加一个向上移动deltaY的动画
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.25f animations:^{
        __strong typeof(wself) sself = wself;
        
        // 重新设置弹出窗口的frame
        float viewHeight = sself->_popView.frame.size.height + deltaY;
        CGRect rect = CGRectMake(0, kScreenHeight - viewHeight, kScreenWidth, viewHeight);
        [sself->_popView setFrame:rect];
        
        [self addPanGesture];
    }];
}

- (void)dismiss{
    if (_popView) {
        [tipView removeFromSuperview];
        if (tipView.subviews) {
            for (UIView *v in tipView.subviews) {
                [v removeFromSuperview];
            }
        }
        
        [_popView removeFromSuperview];
        if (_popView.subviews) {
            for (UIView *v in _popView.subviews) {
                [v removeFromSuperview];
            }
        }
    }
}

#pragma mark - UITableView 部分

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //为Cell设置重用的ID
    ZXSNuTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ZXSNuTableViewCell" forIndexPath:indexPath];
    //如果cell没有才创建
    if (cell == nil) {
        cell = [[ZXSNuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZXSNuTableViewCell"];
    }
    
    NavigationModel *tip = [_items objectAtIndex:indexPath.row];
    switch (tip.tip) {
        case NavigationTipStart:
            // start position.
            cell.lb.text = @"向前直行";
            [cell.img setImage: [UIImage imageNamed:@"start_3x.png"
                                           inBundle:[NSBundle bundleForClass:[self class]]
                      compatibleWithTraitCollection:nil]];
            cell.lb.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
            break;
        case NavigationTipEnd:
            // end position.
            //cell.lb.text = @"到达您的爱车";
            if (_destParkingNo) {
                cell.lb.text = [NSString stringWithFormat:@"到达目的地", _destParkingNo];
            } else {
                cell.lb.text = @"到达目的地";
            }
            [cell.img setImage: [UIImage imageNamed:@"end_3x.png"
                                           inBundle:[NSBundle bundleForClass:[self class]]
                      compatibleWithTraitCollection:nil]];
            cell.lb.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
            break;
        case NavigationTipStraight:
            // go straight.
            [cell.img setImage: [UIImage imageNamed:@"straight_3x.png"
                                           inBundle:[NSBundle bundleForClass:[self class]]
                      compatibleWithTraitCollection:nil]];
            cell.lb.text = [NSString stringWithFormat:@"直行%@米", tip.distanceToTurnDesc];
            cell.lb.font = [UIFont systemFontOfSize:18 weight:UIFontWeightRegular];
            break;
        case NavigationTipTurnLeft:{
            // turn left.
            [cell.img setImage: [UIImage imageNamed:@"left_3x.png"
                                           inBundle:[NSBundle bundleForClass:[self class]]
                      compatibleWithTraitCollection:nil]];
            NSMutableDictionary *attributesDic1 = [NSMutableDictionary dictionary];
            [attributesDic1 setObject:[UIFont systemFontOfSize:18 weight:UIFontWeightRegular] forKey:NSFontAttributeName];
            NSMutableAttributedString *attrStr1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@米后 ", tip.distanceToTurnDesc] attributes:attributesDic1];
            
            NSMutableDictionary *attributesDic2 = [NSMutableDictionary dictionary];
            [attributesDic2 setObject:[UIFont systemFontOfSize:18 weight:UIFontWeightMedium] forKey:NSFontAttributeName];
            NSMutableAttributedString *attrStr2 = [[NSMutableAttributedString alloc] initWithString:@"左转" attributes:attributesDic2];
            
            [attrStr1 appendAttributedString:attrStr2];
            
            //cell.lb.text = [NSString stringWithFormat:@"%@米后 左转", tip.length];
            cell.lb.attributedText = attrStr1;
            //cell.lb.font = [UIFont systemFontOfSize:18 weight:UIFontWeightRegular];
        }break;
        case NavigationTipTurnRight:{
            // turn right.
            [cell.img setImage: [UIImage imageNamed:@"right_3x.png"
                                           inBundle:[NSBundle bundleForClass:[self class]]
                      compatibleWithTraitCollection:nil]];
            NSMutableDictionary *attributesDic1 = [NSMutableDictionary dictionary];
            [attributesDic1 setObject:[UIFont systemFontOfSize:18 weight:UIFontWeightRegular] forKey:NSFontAttributeName];
            NSMutableAttributedString *attrStr1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@米后 ", tip.distanceToTurnDesc] attributes:attributesDic1];
            
            NSMutableDictionary *attributesDic2 = [NSMutableDictionary dictionary];
            [attributesDic2 setObject:[UIFont systemFontOfSize:18 weight:UIFontWeightMedium] forKey:NSFontAttributeName];
            NSMutableAttributedString *attrStr2 = [[NSMutableAttributedString alloc] initWithString:@"右转" attributes:attributesDic2];
            
            [attrStr1 appendAttributedString:attrStr2];
            
            //cell.lb.text = [NSString stringWithFormat:@"%@米后 右转", tip.length];
            cell.lb.attributedText = attrStr1;
            //cell.lb.font = [UIFont systemFontOfSize:18 weight:UIFontWeightRegular];
        }break;
        default:
            //NSLog(@" ??? ....");
            break;
    }
    //[cell.img setImage: [UIImage imageNamed: (tip ? tip.tip :@"snowman.png")]];
//    [cell.img setImage: [UIImage imageNamed:@"snowman.png"
//                                   inBundle:[NSBundle bundleForClass:[self class]]
//              compatibleWithTraitCollection:nil]];
    
//    [cell.contentView setUserInteractionEnabled:YES];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

@end
