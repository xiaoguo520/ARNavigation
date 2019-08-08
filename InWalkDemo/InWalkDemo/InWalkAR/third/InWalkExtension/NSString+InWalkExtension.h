//
//  NSString+InWalkExtension.h
//  inWalkExtensionExample
//
//  Created by inWalk Lee on 15/6/7.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InWalkExtensionConst.h"

@interface NSString (InWalkExtension)
/**
 *  驼峰转下划线（loveYou -> love_you）
 */
- (NSString *)inWalk_underlineFromCamel;
/**
 *  下划线转驼峰（love_you -> loveYou）
 */
- (NSString *)inWalk_camelFromUnderline;
/**
 * 首字母变大写
 */
- (NSString *)inWalk_firstCharUpper;
/**
 * 首字母变小写
 */
- (NSString *)inWalk_firstCharLower;

- (BOOL)inWalk_isPureInt;

- (NSURL *)inWalk_url;
@end

