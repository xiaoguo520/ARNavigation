//
//  UILabel+Extend.h
//  patient
//
//  Created by 新开元 iOS on 2016/11/29.
//  Copyright © 2016年 com.xky.app. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Extend)

+(UILabel *)initWithColor:(UIColor *)color font:(UIFont *)font;

/**
 *  改变行间距
 */
- (void)changeLineSpaceWithSpace:(float)space;

/**
 *  改变字间距
 */
- (void)changeWordSpaceWithSpace:(float)space;

/**
 *  改变行间距和字间距
 */
- (void)changeSpacewithLineSpace:(float)lineSpace WordSpace:(float)wordSpace;

-(void)setNullText:(NSString *)text;


+ (CGFloat) adaptLabel_Width:(UILabel *)label;
+ (CGFloat )adaptLabel_height:(UILabel *)label width:(CGFloat) width;


@property (nonatomic,assign) CGFloat singleFont;

//上对齐
- (void)alignTop;
//下对齐
- (void)alignBottom;

@end
