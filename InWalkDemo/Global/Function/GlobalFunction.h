//
//  GlobalFunction.h
//  InWalkDemo
//
//  Created by xky_ios on 2019/8/6.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GlobalFunction : NSObject

+(void)saveValue:(id)Value forKey:(NSString *)key;
+(id)getValueForKey:(NSString *)key;




/**
 获取一个随机数组
 
 @param count 个数
 @return return value description
 */
+ (NSString *)getRandomArrayWithCount:(NSInteger)count;

/**
 获取手机型号
 
 @return 型号
 */
+ (NSString *)getIphoneType;

#pragma mark - 时间
/**
 获取时间戳
 
 @return 时间戳
 */
+ (NSString*)getCurrentFormatterTimes;

#pragma mark - 圆角边框
/**
 切圆角
 
 @param cornerRadius 圆角半径
 */
+ (void)setRoundWithView:(UIView *)view cornerRadius:(float)cornerRadius;

/**
 切部分圆角
 
 @param cornerRadius 圆角半径
 */
+ (void)setPartRoundWithView:(UIView *)view corners:(UIRectCorner)corners cornerRadius:(float)cornerRadius;

/**
 设置边宽
 
 @param borderWidth 边宽宽度
 @param borderColor 边宽颜色
 */
+ (void)setBorderWithView:(UIView *)view width:(float)borderWidth color:(UIColor *)borderColor;


/**
 设置阴影
 默认状态下
 */
+(void)setShodawWithView:(UIView *)view;

+(void)setAutoShodawWithView:(UIView *)view color:(UIColor *)color size:(CGSize)size radius:(CGFloat)radius opacity:(CGFloat)opacity;

#pragma mark - 文字

/**
 获取文字宽度
 
 @param text 文本内容
 @param fontSize 字号大小
 @return return value description
 */
+ (CGFloat)getTextWidth:(NSString *)text fontSize:(CGFloat)fontSize;

/**
 获取文字宽度
 
 @param text 文本内容
 @param font 字号大小
 @return return value description
 */
+ (CGFloat)getTextWidth:(NSString *)text font:(UIFont *)font;

/**
 获取文字高度
 
 @param text 文本内容
 @param fontSize 字号大小
 @param width 宽度
 @return return value description
 */
+ (CGFloat)getTextHeight:(NSString *)text fontSize:(CGFloat)fontSize width:(CGFloat)width;


/**
 裁减图片
 
 @param imageView imageView description
 */
+(void)scaleAspectFillWithImageView:(UIImageView *)imageView;


+ (NSString *)getUUID;


//获取接口统一参数
+(NSString *)getClientParam;


#pragma mark - Other
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
+ (NSArray *)arrayWithJsonString:(NSString *)jsonString;
+ (NSString*)jsonStringWithObject:(id)object;


@end

NS_ASSUME_NONNULL_END
