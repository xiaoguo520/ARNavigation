//
//  InWalkUIManager.m
//  InWalkAR
//
//  Created by limu on 2019/1/6.
//  Copyright © 2019年 InWalk Co., Ltd. All rights reserved.
//

#import "InWalkUIManager.h"
#import "PlateNumberUI.h"
#import "LocateResultUI.h"
#import "StartPositionUI.h"
#import "NavigationUI.h"
#import "RvtsUI.h"
#import "RvtsResultUI.h"
#import "InputBgMapUI.h"
#import "PhonePoseUI.h"

@interface InWalkUIManager()<PlateNumberDelegate,LocateResultDelegate,StartPositionDelegate,NavigationDelegate,RvtsUIDelegate,RvtsResultDelegate>
@property PlateNumberUI *plateView;
@property LocateResultUI *locateResultView;
@property StartPositionUI *startPositionView;
@property NavigationUI *navView;
@property RvtsUI *rvtsView;
@property RvtsResultUI *rvtsResultView;
@property(nonatomic) InputBgMapUI *inputBgMapView; // 输入起点/终点时展示相应楼层的地图
@property(nonatomic) PhonePoseUI *phonePoseView;
@property NSString *destNum;
@property UIButton *homeBtn;
@property UIButton *helpBtn;
@property UIButton *floorSwitch;
@property UIView *floorSvContainer;
@property UIScrollView *floorSv;
@property NSDictionary<NSString *, InWalkMap *> *mapList;
@end

@implementation InWalkUIManager

- (instancetype) initWithSuperView:(UIView*)view{
    self = [self init];
    if (self) {
        _superView = view;
    }
    return self;
}

#pragma mark - 展示返回(Home)按钮、帮助(Help)按钮
- (void)showTipButtons {
//    CGFloat sw = [UIScreen mainScreen].bounds.size.width;
    CGFloat w = 40;
    float a = 8;
    if (_homeBtn == nil) {
        _homeBtn = [[UIButton alloc] init];
        UIImage *img = [UIImage imageNamed:@"home_gray.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        _homeBtn.imageEdgeInsets = UIEdgeInsetsMake(a,a,a,a);
        [_homeBtn setImage:img forState:UIControlStateNormal];
        
        _homeBtn.frame = CGRectMake(20, 40, w, w);
        _homeBtn.backgroundColor = [UIColor whiteColor];
        _homeBtn.layer.cornerRadius = 6;
        _homeBtn.tag = 1;
        // shadow
        _homeBtn.layer.shadowOpacity = 0.5;
        _homeBtn.layer.shadowRadius = 5;
        _homeBtn.layer.shadowColor = [UIColor grayColor].CGColor;
        _homeBtn.layer.shadowOffset = CGSizeMake(0, 0);
        
        [_homeBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.superView addSubview:_homeBtn];
    
//    if (_helpBtn == nil) {
//        _helpBtn = [[UIButton alloc] init];
//        //[_helpBtn setImage:[UIImage imageNamed:@"help_gray.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
//        UIImage *img = [UIImage imageNamed:@"help_gray.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
//        _helpBtn.imageEdgeInsets = UIEdgeInsetsMake(a,a,a,a);
//        [_helpBtn setImage:img forState:UIControlStateNormal];
//
//        _helpBtn.frame = CGRectMake(sw - 20 - 40, 40, w, w);
//        _helpBtn.backgroundColor = [UIColor whiteColor];
//        _helpBtn.layer.cornerRadius = 6;
//        _helpBtn.tag = 2;
//        [_helpBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    [self.superView addSubview:_helpBtn];
}

// 切换楼层的列表
- (void)showFloors:(NSDictionary<NSString *, InWalkMap *> *)mapList {
    self.mapList = mapList;
    
    //(int)floors
    CGFloat w = 40;
    float a = 8;
    if (_floorSwitch == nil) {
        CGFloat sw = [UIScreen mainScreen].bounds.size.width;
        
        _floorSwitch = [[UIButton alloc] init];
        UIImage *img = [UIImage imageNamed:@"ic_floor_sw_1.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        _floorSwitch.imageEdgeInsets = UIEdgeInsetsMake(a,a,a,a);
        [_floorSwitch setImage:img forState:UIControlStateNormal];
        UIImage *img2 = [UIImage imageNamed:@"ic_floor_sw_2.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        [_floorSwitch setImage:img2 forState:UIControlStateSelected];
        
        _floorSwitch.frame = CGRectMake(sw - 20 - 40, 40, w, w);
        _floorSwitch.backgroundColor = [UIColor whiteColor];
        _floorSwitch.layer.cornerRadius = 6;
        _floorSwitch.tag = 3;
        _floorSwitch.selected = NO;
        // shadow
        _floorSwitch.layer.shadowOpacity = 0.5;
        _floorSwitch.layer.shadowRadius = 5;
        _floorSwitch.layer.shadowColor = [UIColor grayColor].CGColor;
        _floorSwitch.layer.shadowOffset = CGSizeMake(0, 0);
        
        [_floorSwitch addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.superView addSubview:_floorSwitch];
    }
    
    if (_floorSvContainer == nil) {
        int floors = (int)mapList.count;
        CGFloat sw = [UIScreen mainScreen].bounds.size.width;
        
        _floorSvContainer = [[UIView alloc] init];
        _floorSv = [[UIScrollView alloc] init];
        CGFloat padding = 20;
        CGFloat width = 40;
        if (floors < 3) {
            _floorSvContainer.frame = CGRectMake(sw - width - padding, padding + 80, width, floors * 40);
            _floorSv.frame = CGRectMake(0, 0, width, floors * 40);
        } else {
            _floorSvContainer.frame = CGRectMake(sw - width - padding, padding + 80, width, 120);
            _floorSv.frame = CGRectMake(0, 0, width, 120);
        }
        _floorSv.contentSize = CGSizeMake(width, floors * 40);
        _floorSv.userInteractionEnabled = YES;
        _floorSv.scrollEnabled = YES;
        _floorSvContainer.backgroundColor = [UIColor whiteColor];
        [_floorSv setShowsVerticalScrollIndicator:NO];
        [_floorSv setShowsHorizontalScrollIndicator:NO];
        UIColor *blue = [UIColor colorWithRed:67./255 green:122./255 blue:248./255 alpha:1];// #437af8 67,122,248
        InWalkMap *map;
        for (int i = 0; i < floors; i++) {
            map = [mapList objectForKey:[NSString stringWithFormat:@"%@", mapList.allKeys[i]]];
            UILabel *lb = [[UILabel alloc] init];
            lb.textAlignment = NSTextAlignmentCenter;
            lb.frame = CGRectMake(0, i * 40, 40, 40);
            [lb setText:map.name];
            lb.tag = map.tag;
            [lb setHighlightedTextColor: blue];
            if (map.tag == 0) {
                [lb setHighlighted:YES];
            }
            lb.userInteractionEnabled = YES;
            [lb addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popTouchUpInside:)]];
            [_floorSv addSubview:lb];
        }
        _floorSvContainer.hidden = YES;
        
        // shadow
        _floorSvContainer.layer.cornerRadius = 6;
        _floorSvContainer.layer.shadowOpacity = 0.5;
        _floorSvContainer.layer.shadowRadius = 5;
        _floorSvContainer.layer.shadowColor = [UIColor grayColor].CGColor;
        _floorSvContainer.layer.shadowOffset = CGSizeMake(0, 0);
        
        [_floorSvContainer addSubview:_floorSv];
        [self.superView addSubview:_floorSvContainer];
    }
}

- (void)popTouchUpInside:(UITapGestureRecognizer *)recognizer {
    NSLog(@"click %zd", recognizer.view.tag);
    UILabel *lb = (UILabel *)recognizer.view;
    if (lb) {
        int pos = 0;
        for (UILabel *label in _floorSv.subviews) {
            if (label && label.isHighlighted) {
                [label setHighlighted:NO];
                pos = (int)label.tag;
            }
        }
        [lb setHighlighted:YES];
        
        if (pos != lb.tag && _delegate) {
            // change map
            [_delegate onClickFloor:(int)lb.tag];
        }
    }
}

- (void)btnClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (btn == nil) {
        return;
    }
    
    if (btn.tag == 1) {
        // back to home page(exit ar nav)
        //NSLog(@"exit to home page...");
        [self onClickFinishBtn];
    } else if (btn.tag == 2) {
        // show help view.
        //NSLog(@"show help view...");
        
        
        
        
        
        
    } else if (btn.tag == 3) {
        // show floors list.
        BOOL seleced = btn.selected;
        [btn setSelected:!seleced];
        NSLog(@" on click tag 3 ... %@", (seleced ? @"YES" : @"NO"));
        _floorSvContainer.hidden = seleced;
    }
}

#pragma mark - 输入起点、终点等窗口的背景图片(展示楼层的地图)
// 刷新输入起点/终点界面的背景图片
- (void)showFloorBgView:(InWalkMap *)floor {

    
    
    if (!_inputBgMapView) {
        _inputBgMapView = [[InputBgMapUI alloc] init];
        [_inputBgMapView setSuperView:self.superView];
    }
    [_inputBgMapView setFloor:floor];
    
    //[_inputBgMapView hide];
    
    
    
}

- (void)hideFloorBgView {
    if (_inputBgMapView) {
        [_inputBgMapView hide];
    }
}

#pragma mark - 点击开始导航，用户需要按照提示保持手机竖直3秒不动
- (void)showPhonePose:(InWalkPhonePose)flag {
    if (!_phonePoseView) {
        _phonePoseView = [[PhonePoseUI alloc] init];
        [_phonePoseView setSuperView:self.superView];
    }
    [_phonePoseView setPhonePose:flag];
}

#pragma mark - 展示车牌号码输入页面
// 支持反向寻车的停车场：展示输入车牌号界面
- (void)showPlateNumberView2{
    _rvtsView = [[RvtsUI alloc] init];
    _rvtsView.delegate = self;
    [_rvtsView setSuperView: self.superView];
    [_rvtsView setTitle:@"请输入您的车牌号码"];
    [_rvtsView show];
}

// 支持反向寻车的停车场：输入车牌号，点击确定
- (void)onClickRvts:(NSString *)carNum{
    if (_delegate) {
        [_delegate onConfirmRvts:carNum];
        
        
        
        
        
        
        
        
        
        
//        [_delegate onConfirmRvts:@"BF63300"]; // TEst
    }
}

- (void)showPlateNumberView{
    
    // 弹出输入车牌号码界面
    _plateView = [[PlateNumberUI alloc] init];
    _plateView.delegate = self;
    [_plateView setSuperView: self.superView];
    [_plateView show];
}

// plateNumber delegate.
- (void)onConfirm:(NSString *)plateNumber {
    //NSLog(@"on confirm (ui) ..");
    if (_delegate) {
        [_delegate onConfirmPlateNumber:plateNumber];
        //NSLog(@"on confirm (ui) .. %@", plateNumber);
    }
}

- (void)showLocationResultDesc:(NSString *)desc tip:(NSString *)tip imgs:(NSArray<NSString *> *)imgs parkingNum:(NSString *)num{
    [_plateView dismiss];
    //NSLog(@"confirm(ui/2) : %@", desc);
    
    _destNum = num;
    _locateResultView = [[LocateResultUI alloc] init];
    _locateResultView.delegate = self;
    [_locateResultView setSuperView:self.superView];
    //[_locateResultView setDesc:desc tip:tip items:imgs];
    [_locateResultView showDesc:desc tip:tip items:imgs];
}

// locate result delegate.
- (void)onConfirmLocation{
    if (_delegate) {
        [_delegate onConfirmLocateResult];
    }
}

// 反向寻车结果
- (void)showRvtsResult:(NSArray<InWalkReverse4CarModel *> *)list {
    [_rvtsView hideView];
    _rvtsResultView = [[RvtsResultUI alloc] init];
    _rvtsResultView.delegate = self;
    [_rvtsResultView setSuperView:self.superView];
    [_rvtsResultView showRvtsResultItems:list];
}

// RvtsResultDelegate
- (void)onConfirmRvtsResult:(NSString *)destParkingNo {
    if (_delegate) {
        
        
        
        
        
        //NSLog(@" gogogo");
        _destNum = destParkingNo;
        //[self.uiManager showStartPositionViewWithItems:self.allNavPoints];
        [_delegate onConfirmDestParkingNo:destParkingNo];
        
        
    }
}

- (void)onCloseRvtsResult {
    [_rvtsView restoreView];
}

// 点击关闭按钮
- (void)onCloseRvts {
    [self onClickFinishBtn];
}

- (void)showStartPositionViewWithItems:(NSArray<StartPositionModel *> *)items{
    if (_startPositionView) {
        [_startPositionView refreshDest:_destNum items:items];
        return;
    }
    _startPositionView = [[StartPositionUI alloc] init];
    _startPositionView.delegate = self;
    [_startPositionView setSuperView:self.superView];
    //[_startPositionView setItems:items];
    [_startPositionView showDest:_destNum items:items];
}

// startPositionUI delegate.
- (void)startNavigationFrom:(NSString *)from to:(NSString *)to{
    if (_delegate) {
        [_delegate startNavigationFrom:from to:to];
        
        
        
        
//        [_delegate startNavigationFrom:@"B2-41" to:to];// TEst
    }
}

- (void)onCloseStartPositionUI:(BOOL)isDestConfirmed {
    // 针对两种情况：
    // 支持反向寻车的停车场，isDestConfirmed应该为YES，此时关闭该输入窗口，返回的是前一个窗口
    // 不支持反向寻车的停车场，isDestConfirmed应该为NO，此时关闭该输入窗口，返回的是主页面
    if (!isDestConfirmed) {
        [self onClickFinishBtn];
    } else {
        [_rvtsResultView restoreView];
    }
}

- (void)setNavPath:(NSArray<NavigationModel *> *)items{
    if (!_navView) {
        _navView = [[NavigationUI alloc] init];
        _navView.delegate = self;
    }
    [_navView setSuperView:self.superView];
    // set items.
    //[_navView setTip:[NavigationModel new] remainTime:@"20分钟" distance:@"4.2公里" arriveTime:@"上午11:22"];
    [_navView setItems:items dest:_destNum];
    //// show tips.
    ////NavigationModel *tip = [[NavigationModel alloc] initWithLength:@"3.0" tip:NavigationTipTurnLeft];
    //
    //[_navView showTip:tip remainTime:@"20分钟" distance:@"4.2公里" arriveTime:@"上午11:22"];
}

- (void)showTip:(NavigationModel *)tip remainTime:(NSString *)t1 distance:(NSString *)distance arriveTime:(NSString *)t2{
    [_navView showTip:tip remainTime:t1 distance:distance arriveTime:t2];
}

// NavigationUI delegate.
- (void)onClickFinishBtn{
    if (_delegate) {
        [_delegate finishNavigation];
        
        [self releaseUIResource];
    }
}

- (void)makeMapCenter {
    if (_delegate) {
        [_delegate makeMapCenter];
    }
}

// 释放UIManager持有的资源
- (void)releaseUIResource {
    
    
    [self dismissInputViews];
    
    
    
}

// 点击NavigationUI中的mapIcon图标：现在没有用到
- (void)onClickMapBtn:(BOOL)shouldOpenMap{
    //NSLog(@"   287 .. onClickMapBtn .. %@", (shouldOpenMap ? @"YES" :@"NO"));
    if (_delegate) {
        [_delegate showMap:shouldOpenMap];
    }
}

- (void)refreshMapBtn:(BOOL)isMapOpen{
    [_navView refreshMapBtn:isMapOpen];
//    if (_navView) {
//        [_navView setTipsVisible:isMapOpen];
//    }
    //NSLog(@"   295. .. refreshMapBtn .. %@", (isMapOpen ? @"YES" :@"NO"));
}

- (void)dismissInputViews {
    // dismiss所有UI
    if (_plateView) [_plateView dismiss];
    if (_locateResultView) [_locateResultView dismiss];
    if (_startPositionView) [_startPositionView dismiss];
    if (_rvtsView) [_rvtsView dismiss];
    if (_rvtsResultView) [_rvtsResultView dismiss];
    if (_inputBgMapView) [_inputBgMapView dismiss];
    if (_homeBtn) [_homeBtn setHidden:YES];
    if (_helpBtn) [_helpBtn setHidden:YES];
    if (_floorSwitch) {
        [_floorSwitch removeFromSuperview];
        _floorSwitch = nil;
    }
    if (_floorSv) {
        for (UIView *view in _floorSv.subviews) {
            [view removeFromSuperview];
        }
        [_floorSv removeFromSuperview];
        _floorSv = nil;
    }
    if (_floorSvContainer) {
        [_floorSvContainer removeFromSuperview];
        _floorSvContainer = nil;
    }
}

- (void)upDataOriginFormPosition:(StartPositionModel *)model{
    [_startPositionView upDataOriginFormPosition:model];
}

@end
