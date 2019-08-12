//
//  NSString+Extend.h
//  New_Patient
//
//  Created by 新开元 iOS on 2018/5/15.
//  Copyright © 2018年 新开元 iOS. All rights reserved.
//
#import <UIKit/UIKit.h>


@interface AttributedStyleAction : NSObject
@property (readwrite,copy) void(^action)();
- (instancetype)initWithAction:(void(^)(void))action;
- (NSDictionary*)styledAction;
+ (NSDictionary*)action:(void(^)(void))action;
@end

@interface NSString (Extend)


- (id)getUserDefaults;
- (NSString*)getUserDefaultsString;
- (int)getUserDefaultsInt;
- (NSInteger)getUserDefaultsInteger;
- (CGFloat)getUserDefaultsFloat;
- (BOOL)getUserDefaultsBool;
- (NSMutableArray*)getUserDefaultsArray;
- (NSMutableDictionary*)getUserDefaultsDictionary;
- (void)setUserDefaultsWithData:(id)data;
- (void)replaceUserDefaultsWithData:(NSDictionary*)data;
- (void)deleteUserDefaults;
- (NSMutableArray*)getList:(NSDictionary*)where;
- (NSMutableDictionary*)getRow:(NSDictionary*)where;
- (NSMutableArray*)getCell:(NSMutableArray*)field where:(NSDictionary*)where;
- (NSInteger)getCount:(NSDictionary*)where;
- (void)insertUserDefaults:(NSDictionary*)data;
- (void)insertUserDefaults:(NSDictionary*)data keepRow:(NSInteger)num;
- (void)updateUserDefaults:(NSDictionary*)data where:(NSDictionary*)where;
- (void)deleteRowUserDefaults:(NSDictionary*)where;
- (CGSize)autoWidth:(UIFont*)font height:(CGFloat)height;
- (CGSize)autoHeight:(UIFont*)font width:(CGFloat)width;
- (NSString*)strtolower;
- (NSString*)strtoupper;
- (NSString*)strtoupperFirst;
- (NSString*)trim;
- (NSString*)trim:(NSString*)assign;
- (NSString*)trimNewline;
- (NSInteger)indexOf:(NSString*)str;
- (NSString*)replace:(NSString*)r1 to:(NSString*)r2;
- (NSString*)substr:(NSInteger)start length:(NSInteger)length;
- (NSString*)substr:(NSInteger)start;
- (NSString*)left:(NSInteger)length;
- (NSString*)right:(NSInteger)length;
- (NSInteger)fontLength;
- (NSString *)imageUrl;
- (NSMutableArray*)split:(NSString*)symbol;
- (NSMutableArray*)explode:(NSString*)symbol;
- (NSMutableArray*)explodeStr:(NSInteger)step;
- (NSMutableDictionary*)params;
- (NSMutableDictionary*)params:(NSString*)mark;
- (NSString*)cropHtml:(NSString*)startStr overStr:(NSString*)overStr;
- (NSString*)deleteStringPart:(NSString*)prefix suffix:(NSString*)suffix;
- (BOOL)preg_test:(NSString*)patton;
- (NSString*)preg_replace:(NSString*)patton with:(NSString*)templateStr;
- (NSString*)preg_replace:(NSString*)patton replacement:(NSString *(^)(NSDictionary *matcher, NSInteger index))replacement;
- (NSMutableArray*)preg_match:(NSString*)patton;
- (id)formatJson;
- (BOOL)isInt;
- (BOOL)isInt:(NSInteger)length;
- (BOOL)isIntCheck:(NSInteger)length;
- (BOOL)isFloat;
- (BOOL)isFloat:(NSInteger)length;
- (BOOL)isUsername;
- (BOOL)isPassword;
- (BOOL)isPasswordRangeX;
- (BOOL)hasChinese;
- (BOOL)isChinese;
- (BOOL)isEmail;
- (BOOL)isMobile;
- (BOOL)isDate;
- (BOOL)isUrl;
- (BOOL)isSpecialStr;
- (BOOL)isIDCard;
- (BOOL)isEmoji;
- (BOOL)isNameValid;
- (NSString*)getFullFilename;
- (NSString*)getFilename;
- (NSString *)filterHTML;
- (NSString*)getSuffix;
- (NSString*)ASCII;
- (NSString*)Unicode;
- (NSString*)URLEncode;
- (NSString*)URLEncode:(NSStringEncoding)encoding;
- (NSString*)URLDecode;
- (NSString*)URLDecode:(NSStringEncoding)encoding;
- (NSString*)base64ToString;
- (NSData*)base64ToData;
- (UIImage*)base64ToImage;
- (NSString*)md5;
//- (NSString*)sha1;
- (NSAttributedString*)simpleHtml;

- (NSAttributedString*)attributedStyle:(NSDictionary*)styleBook;

-(NSString *)formatDataStr;
-(NSString *)formatSecondsStr;
-(NSString *)IDCardHide;

-(NSString *)translation;
-(NSString *)completeTranslation;
-(NSString *)getAgeWithCardNum;
-(NSString *)getBirthdayWithCardNum;
-(NSString *)getAgeWithBirthday;

-(BOOL)isGuard;

-(BOOL)isMoreYear:(NSInteger)year;

-(BOOL)isNumWithABC;
-(BOOL)isNumWithABCAndCH;
-(BOOL)isNumAndABC;

-(NSString *)VerticalString;

/**
 
 *  从身份证上获取性别
 
 */

-(NSString *)getIdentityCardSex;

/**
 
 *  从身份证上获取性别  15 或者 18
 
 */

-(NSString *)getIdentityCardSex_15Or18;

- (NSString *)handlePriceStatus;


#pragma 正则匹配用户密码6-18位数字和字母组合
- (BOOL)checkPassword:(NSString *) password;


+ (NSString *)arrayToJSONString:(NSArray *)array;


//富文本
- (NSMutableAttributedString *) handleLabelAttribute:(NSString *)title
                                          otherTitle:(NSString *)otherTitle
                                               color:(UIColor *)color
                                          otherColor:(UIColor *)otherColor
                                                font:(UIFont*) font
                                           otherFont:(UIFont*) otherFont;
//Label富文本带图片
-(NSMutableAttributedString *) handleLabelWithImage:(NSString *)title
                                              color:(UIColor *)color
                                               font:(UIFont*) font
                                          imageName:(NSString *)imgName
                                                  w:(CGFloat) w
                                                  h:(CGFloat) h
                                              index:(NSInteger) index;
@end
