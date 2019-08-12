//
//  Color_Config.h
//  New_Patient
//
//  Created by 新开元 iOS on 2018/5/15.
//  Copyright © 2018年 新开元 iOS. All rights reserved.
//  颜色相关

#ifndef Color_Config_h
#define Color_Config_h


#define COLOR_CLEAR [UIColor clearColor]
#define COLOR_WHITE [UIColor whiteColor]
#define COLOR_BLACK [UIColor blackColor]

//常见色值
#define COLOR_RED [UIColor colorWithRed:220/255.f green:4/255.f blue:49/255.f alpha:1.f] //dc0431
#define COLOR_ORANGE [UIColor colorWithRed:235/255.f green:155/255.f blue:0/255.f alpha:1.f] //eb9b00
#define COLOR_GREEN [UIColor colorWithRed:0/255.f green:190/255.f blue:20/255.f alpha:1.f] //00be14
#define COLOR_BLUE [UIColor colorWithRed:0/255.f green:149/255.f blue:217/255.f alpha:1.f] //0095d9
#define COLOR_YELLOW [UIColor colorWithRed:255/255.f green:199/255.f blue:0/255.f alpha:1.f] //ffc700
#define COLOR_PINK [UIColor colorWithRed:240/255.f green:96/255.f blue:165/255.f alpha:1.f] //f060a5
#define COLOR_PURPLE [UIColor colorWithRed:163/255.f green:93/255.f blue:181/255.f alpha:1.f] //a35db5
#define COLOR_SYSTEM_BLUE [UIColor colorWithRed:0/255.f green:122/255.f blue:255/255.f alpha:1.f] //007aff
#define COLOR_COLOR_GE [UIColor colorWithRed:199/255.f green:199/255.f blue:199/255.f alpha:1.f] //c7c7c7
#define COLOR_COLOR_GE_LIGHT [UIColor colorWithRed:234/255.f green:234/255.f blue:234/255.f alpha:1.f] //eaeaea
#define COLOR_COLOR_PLACEHOLDER [UIColor colorWithRed:199/255.f green:199/255.f blue:199/255.f alpha:1.f] //c7c7c7

#define COLOR_BLUE_BTN  [UIColor colorWithRed:64/255.f green:134/255.f blue:255/255.f alpha:1.f] //64 134 255

//基础色值
#define COLOR_COLORCCC [UIColor colorWithRed:204/255.f green:204/255.f blue:204/255.f alpha:1.f] //ccc
#define COLOR_COLOR999 [UIColor colorWithRed:153/255.f green:153/255.f blue:153/255.f alpha:1.f] //999
#define COLOR_COLOR777 [UIColor colorWithRed:119/255.f green:119/255.f blue:119/255.f alpha:1.f] //777
#define COLOR_COLOR666 [UIColor colorWithRed:102/255.f green:102/255.f blue:102/255.f alpha:1.f] //666
#define COLOR_COLOR333 [UIColor colorWithRed:51/255.f green:51/255.f blue:51/255.f alpha:1.f] //333


//APP主题色
#define THEMECOLOR [UIColor colorWithHexString:@"528df0" alpha:1.0f]

//
#define COLOR_APPBlueColor [UIColor colorWithHexString:@"4086FF" alpha:1.0f]

//APP基类背景色
#define COLOR_ViewBackgroundColor  [UIColor colorWithHexString:@"f9f9f9" alpha:1.0f]

//随机颜色
#define COLOR_RandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]

//线条颜色
#define COLOR_DefaultLineColor [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0]

#endif /* Color_Config_h */
