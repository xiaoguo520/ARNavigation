//
//  ConstString.h
//  New_Patient
//
//  Created by 新开元 iOS on 2018/5/17.
//  Copyright © 2018年 新开元 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - key 相关


#define UMPushKey  [[NSUserDefaults standardUserDefaults] integerForKey:JKHttpBaseUrl] == 1 ? UMPushTureKey : UMPushTestKey
#define WechatAppID  [[NSUserDefaults standardUserDefaults] integerForKey:JKHttpBaseUrl] == 1 ? WechatTureAppID : WechatTestAppID
#define XKYPayServerEnvironment [[NSUserDefaults standardUserDefaults] integerForKey:JKHttpBaseUrl] == 1 ? XKYPayServerTureEnvironment : [[NSUserDefaults standardUserDefaults] integerForKey:JKHttpBaseUrl] == 2 ? XKYPayServerUatTestEnvironment : XKYPayServerTestEnvironment
#define bzServerEnvironment  [[NSUserDefaults standardUserDefaults] integerForKey:JKHttpBaseUrl] == 1 ? bzServerTureEnvironment : bzServerTestEnvironment
#define JKPublicKey  [[NSUserDefaults standardUserDefaults] integerForKey:JKHttpBaseUrl] == 1 ? JKPublicTureKey : JKPublicTestKey
#define ESafeUploadImageUrl [[NSUserDefaults standardUserDefaults] integerForKey:JKHttpBaseUrl] == 1 ? ESafe_UploadImageTureUrl : ESafe_UploadImageTestUrl
#define ESafeCommentUrl [[NSUserDefaults standardUserDefaults] integerForKey:JKHttpBaseUrl] == 1 ? ESafe_CommentTureUrl : ESafe_CommentTestUrl
#define ESafeSecrret [[NSUserDefaults standardUserDefaults] integerForKey:JKHttpBaseUrl] == 1 ? ESafe_tureSecrret : ESafe_testSecrret



#pragma mark - 常用图片名称 相关
/*
 --------------------------------------------------------------------------------------------------------------------------------------------------
 */
//返回键图片
static NSString * const JKbackImageName = @"BACK";
//返回键高亮图片
static NSString * const JKbackHImageName = @"BACK";

#pragma mark - 通知 相关
/*
 --------------------------------------------------------------------------------------------------------------------------------------------------
 */




#pragma mark - base blcok

typedef void(^BaseClickBlock)(void);

typedef void(^BaseClickValueBlock)(id data);



#pragma mark - 协议相关

