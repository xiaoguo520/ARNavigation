//
//  BaseViewController.h
//  InWalkDemo
//
//  Created by xky_ios on 2019/8/6.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^setUpViewsBlock)(void);
typedef void(^holderReloadDataBlcok)(void);

@interface BaseViewController : UIViewController

/**
 导航title
 */
@property (nonatomic,copy) NSString * navTitle;

/**
 是否显示导航底部线.默认不显示
 */
@property (nonatomic,assign) BOOL isShowNavLine;

/**
 是否网络错误
 */
@property (nonatomic,assign) BOOL isNetError;

/**
 是否服务器错误
 */
@property (nonatomic,assign) BOOL isServeError;

//是否弃用滑动返回，默认为NO
@property (nonatomic,assign) BOOL userSlidePopEnabled;


/**
 设置根视图
 */
- (void)setUpAllViews;


/*
 app状态
 */
-(void)appWillEnterForeground;
-(void)appWillResignActive;
-(void)appDidEnterBackground;
-(void)appBecomeActive;
-(void)appRealStatusViaWiFi;
-(void)appRealStatusViaWWAN;
-(void)appRealStatusUnknown;
-(void)appRealStatusNotReachable;
-(void)appGoToLogin;


/**
 设置子视图
 
 @param data data description
 @param viewsBlock viewsBlock description
 */
-(void)setUpAllViewsWithBaseData:(id)data
                    setViewBlock:(setUpViewsBlock)viewsBlock
           holderReloadDataBlcok:(holderReloadDataBlcok)reloadBlcok ;


#pragma mark - Action




/**
 vc 销毁的时候调用
 */
- (void)viewControllerDealloc;


@end

NS_ASSUME_NONNULL_END
