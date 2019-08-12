//
//  Size_Config.h
//  InWalkDemo
//
//  Created by xky_ios on 2019/8/6.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#ifndef Size_Config_h
#define Size_Config_h


//屏幕宽度
#define Size_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
//屏幕高度
#define Size_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
//TabBar高度
#define Size_TabBarH        49.0f
//状态栏高度
#define Size_StatusBarH   SYS_KEYWINDOW.statusBarHeight
//导航栏高度
#define Size_NavigationBarH 44.0f

#define Size_SCREEN_POINT (float)SCREEN_WIDTH/320.f
#define Size_SCREEN_H_POINT (float)SCREEN_HEIGHT/480.f
//宽度适配
#define Size_FIT_WIDTH  [UIScreen mainScreen].bounds.size.width/375
//字体适配
#define Size_SizeScale  (IPHONE_iPhone_6_Plus ? Size_FIT_WIDTH : 1)

#define SizeNavigationButtonFontSize 16.0f

#define SizeProgressHeight 2*Size_FIT_WIDTH

#define menuCellH 49 * Size_FIT_WIDTH

#define menuViewWidth 200 * Size_FIT_WIDTH

#define tipHeight 30.0f * Size_FIT_WIDTH
#define tipMargen 10.0f * Size_FIT_WIDTH
#define kMargen   8 * Size_FIT_WIDTH



#endif /* Size_Config_h */
