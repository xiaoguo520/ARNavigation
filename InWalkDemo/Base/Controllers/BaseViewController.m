//
//  BaseViewController.m
//  InWalkDemo
//
//  Created by xky_ios on 2019/8/6.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import "BaseViewController.h"
#import "PlaceholderView.h"

@interface BaseViewController ()
@property (nonatomic,copy)PlaceholderView *holderView;
@end

@implementation BaseViewController

-(instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpAllViews];
    
    [self setUpAllNotification];
    
    self.view.backgroundColor = COLOR_ViewBackgroundColor;
    
//    [JKNetWorkStatusTool checkCurrentReachabilityStatus];
    
    
    //    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    //    self.edgesForExtendedLayout = UIRectEdgeNone;
    
}


-(void)setUpAllViews{}

-(void)viewControllerDealloc{}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    if (_isShowNavLine) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage imageWithColor:COLOR_DefaultLineColor size:CGSizeMake(Size_SCREEN_WIDTH, 0.5)]];
        //        [self.navigationController.navigationBar setShadowImage:nil];
    }else{
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    }
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)] && self.userSlidePopEnabled) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)] && self.userSlidePopEnabled) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

-(void)setUserSlidePopEnabled:(BOOL)userSlidePopEnabled{
    
    if (userSlidePopEnabled) {
        self.fd_interactivePopDisabled = YES;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

#pragma mark - 通知状态

-(void)setUpAllNotification{
    //应用状态
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:JKWillEnterForeground object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:JKWillResignActive object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:JKDidEnterBackground object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive) name:JKDidBecomeActive object:nil];
//
//    //网络状态
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appRealStatusViaWiFi) name:JKRealStatusViaWiFi object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appRealStatusViaWWAN) name:JKRealStatusViaWWAN object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appRealStatusUnknown) name:JKRealStatusUnknown object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appRealStatusNotReachable) name:JKRealStatusNotReachable object:nil];
    
    //新增一个弹出登陆的通知
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoToLogin) name:JKAppGoToLogin object:nil];
    
}

-(void)appWillEnterForeground{}
-(void)appWillResignActive{}
-(void)appDidEnterBackground{}
-(void)appBecomeActive{}
-(void)appGoToLogin{}

-(void)appRealStatusViaWiFi{
    self.isNetError = NO;
    
}
-(void)appRealStatusViaWWAN{
    self.isNetError = NO;
    
}
-(void)appRealStatusUnknown{
    
    self.isNetError = YES;
}
-(void)appRealStatusNotReachable{
    
    self.isNetError = YES;
}

-(void)setUpAllViewsWithBaseData:(id)data setViewBlock:(setUpViewsBlock)viewsBlock holderReloadDataBlcok:(holderReloadDataBlcok)reloadBlcok{
    
    if (data == nil || [data isEqual:[NSNull null]]) {
        [self setHolderViewWithBlock:reloadBlcok];
        return;
    }
    if ([data isKindOfClass:[NSArray class]]) {
        NSArray * dataArray = data;
        if (dataArray.count == 0) {
            [self setHolderViewWithBlock:reloadBlcok];
            return;
        }
    }
    [self.holderView removeFromSuperview];
    viewsBlock();
}

-(void)setHolderViewWithBlock:(holderReloadDataBlcok)block{
    
    if (self.isNetError) {
        [self.holderView setPlaceholderWithSuperView:self.view placeholderType:JKPlaceholderTypeNoNet];
    }else if (self.isServeError){
        [self.holderView setPlaceholderWithSuperView:self.view placeholderType:JKPlaceholderTypeServeError];
    }else{
        [self.holderView setPlaceholderWithSuperView:self.view placeholderType:JKPlaceholderTypeCom];
    }
    self.holderView.blankBlcok = ^{
        block();
    };
}

#pragma mark - setter getter


-(PlaceholderView *)holderView{
    if (!_holderView) {
        _holderView = [[PlaceholderView alloc] init];
    }
    return _holderView;
}


-(void)setNavTitle:(NSString *)navTitle{
    _navTitle = navTitle;
    self.navigationItem.title = _navTitle;
}



#pragma mark - other
//销毁视图
- (void)dealloc{
    Log(@"dealloc");
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:JKWillEnterForeground object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:JKDidBecomeActive object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:JKDidEnterBackground object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:JKRealStatusViaWiFi object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:JKRealStatusViaWWAN object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:JKRealStatusUnknown object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:JKRealStatusNotReachable object:nil];
    [self viewControllerDealloc];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    
}
@end
