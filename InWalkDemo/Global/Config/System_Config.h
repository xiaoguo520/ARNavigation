//
//  System_Config.h
//  InWalkDemo
//
//  Created by xky_ios on 2019/8/6.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#ifndef System_Config_h
#define System_Config_h


//当前系统显示页面
#define SYS_KEYWINDOW ((UIWindow*)[[UIApplication sharedApplication].windows objectAtIndex:0]) //当前窗口
#define SYS_APPCurrentController SYS_KEYWINDOW.currentController //当前显示的控制器
#define SYS_APPCurrentView SYS_KEYWINDOW.currentController.view //当前显示的页面

//APP Version
#define SYS_APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

//UUID
#define SYS_UUID [[[UIDevice currentDevice] identifierForVendor] UUIDString]

//当前系统版本
#define IPHONE_IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue] //系统版本
#define IPHONE_IOS6 (IPHONE_IOS_VERSION<7.0) //系统是否iOS6及以下
#define IPHONE_IOS7 (IPHONE_IOS_VERSION>=7.0 && IPHONE_IOS_VERSION<8.0) //系统是否iOS7
#define IPHONE_IOS8 (IPHONE_IOS_VERSION>=8.0) //系统是否iOS8及以上
#define IPHONE_IOS9 (IPHONE_IOS_VERSION>=9.0) //系统是否iOS9及以上
#define IPHONE_IOS10 (IPHONE_IOS_VERSION>=10.0) //系统是否iOS10及以上
#define IPHONE_IOS11 @available(iOS 11.0, *)

//打印相关
#ifdef DEBUG
#define Log(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define Log(...)
#endif

//循环引用
#define WeakSelf __weak typeof(self) weakSelf = self;



//机型 待增加
//iPhone 4 4S 3GS 机型
#define IPHONE_iPhone_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)

//iPhone 5 5S SE 机型
#define IPHONE_iPhone_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)

//iPhone 6 6S 7 8 机型
#define IPHONE_iPhone_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)

//iPhone 6P 7P 8P 机型
#define IPHONE_iPhone_6_Plus (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

//iPhoen X以上机型
#define IPHONE_iPhoneX ([UIScreen mainScreen].bounds.size.width == 375 && [UIScreen mainScreen].bounds.size.height >= 812)

#define IPHONE_VirtualHomeHeight (IPHONE_iPhoneX ? 34.f : 0.f)

//扫码
//LBXScan 如果需要使用LBXScanViewController控制器代码，那么下载了那些模块，请定义对应的宏
#define LBXScan_Define_Native  //包含native库
#define LBXScan_Define_ZXing   //包含ZXing库
#define LBXScan_Define_ZBar   //包含ZBar库
#define LBXScan_Define_UI     //包含界面库

#define SYS_DocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define SYS_ErrorlogPath [JKDocumentPath stringByAppendingPathComponent:@"errorLog"]
#define SYS_ExceptionPath [JKErrorlogPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.archiver",JKExceptionModelKey]]
#define SYS_ExceptionFilePath [JKErrorlogPath stringByAppendingPathComponent:JKExceptionFileKey]

#define noDisableVerticalScrollTag 836913
#define noDisableHorizontalScrollTag 836914

#endif /* System_Config_h */
