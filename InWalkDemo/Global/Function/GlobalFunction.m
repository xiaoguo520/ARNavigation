//
//  GlobalFunction.m
//  InWalkDemo
//
//  Created by xky_ios on 2019/8/6.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import "GlobalFunction.h"

#import <sys/utsname.h>
#import "SSKeychain.h"

@implementation GlobalFunction

+ (void)saveValue:(id)Value forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setValue:Value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (id)getValueForKey:(NSString *)key
{
    NSUserDefaults *SaveDefaults = [NSUserDefaults standardUserDefaults];
    return [SaveDefaults objectForKey:key];
}


/**
 获取手机型号
 
 @return 型号
 */
+ (NSString *)getIphoneType
{
    
    //需要导入头文件：#import <sys/utsname.h>
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if([platform isEqualToString:@"iPhone1,1"])  return @"iPhone 2G";
    
    if([platform isEqualToString:@"iPhone1,2"])  return @"iPhone 3G";
    
    if([platform isEqualToString:@"iPhone2,1"])  return @"iPhone 3GS";
    
    if([platform isEqualToString:@"iPhone3,1"])  return @"iPhone 4";
    
    if([platform isEqualToString:@"iPhone3,2"])  return @"iPhone 4";
    
    if([platform isEqualToString:@"iPhone3,3"])  return @"iPhone 4";
    
    if([platform isEqualToString:@"iPhone4,1"])  return @"iPhone 4S";
    
    if([platform isEqualToString:@"iPhone5,1"])  return @"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,2"])  return @"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,3"])  return @"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone5,4"])  return @"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone6,1"])  return @"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone6,2"])  return @"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone7,1"])  return @"iPhone 6 Plus";
    
    if([platform isEqualToString:@"iPhone7,2"])  return @"iPhone 6";
    
    if([platform isEqualToString:@"iPhone8,1"])  return @"iPhone 6s";
    
    if([platform isEqualToString:@"iPhone8,2"])  return @"iPhone 6s Plus";
    
    if([platform isEqualToString:@"iPhone8,4"])  return @"iPhone SE";
    
    if([platform isEqualToString:@"iPhone9,1"])  return @"iPhone 7";
    
    if([platform isEqualToString:@"iPhone9,3"])  return @"iPhone 7";
    
    if([platform isEqualToString:@"iPhone9,2"])  return @"iPhone 7 Plus";
    
    if([platform isEqualToString:@"iPhone9,4"])  return @"iPhone 7 Plus";
    
    if([platform isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,3"]) return @"iPhone X";
    
    if([platform isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    
    if([platform isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
    
    if([platform isEqualToString:@"iPod1,1"])    return @"iPod Touch 1G";
    
    if([platform isEqualToString:@"iPod2,1"])    return @"iPod Touch 2G";
    
    if([platform isEqualToString:@"iPod3,1"])    return @"iPod Touch 3G";
    
    if([platform isEqualToString:@"iPod4,1"])    return @"iPod Touch 4G";
    
    if([platform isEqualToString:@"iPod5,1"])    return @"iPod Touch 5G";
    
    if([platform isEqualToString:@"iPad1,1"])    return @"iPad 1G";
    
    if([platform isEqualToString:@"iPad2,1"])    return @"iPad 2";
    
    if([platform isEqualToString:@"iPad2,2"])    return @"iPad 2";
    
    if([platform isEqualToString:@"iPad2,3"])    return @"iPad 2";
    
    if([platform isEqualToString:@"iPad2,4"])    return @"iPad 2";
    
    if([platform isEqualToString:@"iPad2,5"])  return@"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad2,6"])  return@"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad2,7"])  return@"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad3,1"])  return@"iPad 3";
    
    if([platform isEqualToString:@"iPad3,2"])  return@"iPad 3";
    
    if([platform isEqualToString:@"iPad3,3"])  return@"iPad 3";
    
    if([platform isEqualToString:@"iPad3,4"])  return@"iPad 4";
    
    if([platform isEqualToString:@"iPad3,5"])  return@"iPad 4";
    
    if([platform isEqualToString:@"iPad3,6"])  return@"iPad 4";
    
    if([platform isEqualToString:@"iPad4,1"])  return@"iPad Air";
    
    if([platform isEqualToString:@"iPad4,2"])  return@"iPad Air";
    
    if([platform isEqualToString:@"iPad4,3"])  return@"iPad Air";
    
    if([platform isEqualToString:@"iPad4,4"])  return@"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,5"])  return@"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,6"])  return@"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,7"])  return@"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad4,8"])  return@"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad4,9"])  return@"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad5,1"])  return@"iPad Mini 4";
    
    if([platform isEqualToString:@"iPad5,2"])  return@"iPad Mini 4";
    
    if([platform isEqualToString:@"iPad5,3"])  return@"iPad Air 2";
    
    if([platform isEqualToString:@"iPad5,4"])  return@"iPad Air 2";
    
    if([platform isEqualToString:@"iPad6,3"])  return@"iPad Pro 9.7";
    
    if([platform isEqualToString:@"iPad6,4"])  return@"iPad Pro 9.7";
    
    if([platform isEqualToString:@"iPad6,7"])  return@"iPad Pro 12.9";
    
    if([platform isEqualToString:@"iPad6,8"])  return@"iPad Pro 12.9";
    
    if([platform isEqualToString:@"i386"])  return@"iPhone Simulator";
    
    if([platform isEqualToString:@"x86_64"])  return@"iPhone Simulator";
    
    return platform;
    
}

//+ (NSString *)getUUID{
//    NSString  *openUUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"OpenSessionID"];
//    //    NSLog(@"openUUID 一: %@",openUUID);
//    if (openUUID == nil) {
//
//        CFUUIDRef puuid = CFUUIDCreate(kCFAllocatorDefault);
//        CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault,puuid);
//        NSString *udidStr = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
//        CFRelease(puuid);
//        CFRelease(uuidString);
//        openUUID =  [udidStr md5];
//        //        NSLog(@"openUUID 二: %@",openUUID);
//        NSString *uniqueKeyItem = [SSKeychain  passwordForService:@"kUniqueIdentifier" account:@"kUniqueIdentifierValue"];
//        if (uniqueKeyItem == nil || [uniqueKeyItem length] == 0) {
//            uniqueKeyItem = openUUID;
//            [SSKeychain  setPassword:openUUID forService:@"kUniqueIdentifier" account:@"kUniqueIdentifierValue"];
//        }
//        [[NSUserDefaults standardUserDefaults] setObject:uniqueKeyItem forKey:@"OpenSessionID"];
//        [[NSUserDefaults  standardUserDefaults] synchronize];
//        //        NSLog(@"uniqueKeyItem: %@",uniqueKeyItem);
//        openUUID = uniqueKeyItem;
//    }
//    //    NSLog(@"openUUID 三: %@",openUUID);
//    return openUUID;
//}


//获取接口统一参数
+(NSString *)getClientParam{
    return  [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@",@"1",@"1",[GlobalFunction getUUID],SYS_APP_VERSION,@"GDshenzhen",[GlobalFunction getCurrentFormatterTimes]];
}


+ (NSString *)getRandomArrayWithCount:(NSInteger)count
{
    //随机数从这里边产生
    NSMutableArray *startArray=[[NSMutableArray alloc] initWithObjects:@0,@1,@2,@3,@4,@5,@6,@7,@8,@9, nil];
    //随机数产生结果
    NSMutableArray *resultArray=[[NSMutableArray alloc] initWithCapacity:0];
    //随机数个数
    for (int i=0; i<count; i++) {
        int t =arc4random()%startArray.count;
        resultArray[i]=startArray[t];
        startArray[t]=[startArray lastObject]; //为更好的乱序，故交换下位置
        
        [startArray removeLastObject];
    }
    
    NSString * randomStr = @"";
    for (NSNumber * i in resultArray) {
        randomStr = [randomStr stringByAppendingString:[NSString stringWithFormat:@"%@",i]];
    }
    return randomStr;
}

#pragma mark - 时间

/**
 获取时间戳
 
 @return 时间戳
 */
+ (NSString*)getCurrentFormatterTimes
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //----------格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYYMMddHHmmss"]; //YYYYMMddHHmmss  yyyymmddhhmmss
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];//东八区时间
    NSDate *datenow = [NSDate date];
    //----------将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    return currentTimeString;
}


#pragma mark - 圆角边框
/**
 切圆角
 
 @param cornerRadius 圆角半径
 */
+ (void)setRoundWithView:(UIView *)view cornerRadius:(float)cornerRadius
{
    view.layer.cornerRadius = cornerRadius;
    view.layer.masksToBounds = YES;
}

/**
 设置边宽
 
 @param borderWidth 边宽宽度
 @param borderColor 边宽颜色
 */
+ (void)setBorderWithView:(UIView *)view width:(float)borderWidth color:(UIColor *)borderColor
{
    view.layer.borderWidth = borderWidth;
    view.layer.borderColor = borderColor.CGColor;
}

/**
 切部分圆角
 
 UIRectCorner有五种
 UIRectCornerTopLeft //上左
 UIRectCornerTopRight //上右
 UIRectCornerBottomLeft // 下左
 UIRectCornerBottomRight // 下右
 UIRectCornerAllCorners // 全部
 
 @param cornerRadius 圆角半径
 */
+ (void)setPartRoundWithView:(UIView *)view corners:(UIRectCorner)corners cornerRadius:(float)cornerRadius {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)].CGPath;
    //    view.layer.masksToBounds = YES;
    view.layer.mask = shapeLayer;
}


+(void)setAutoShodawWithView:(UIView *)view color:(UIColor *)color size:(CGSize)size radius:(CGFloat)radius opacity:(CGFloat)opacity
{
    view.layer.shadowOffset = size;
    view.layer.shadowColor = color.CGColor;
    view.layer.shadowRadius = radius;
    view.layer.shadowOpacity = opacity;
}


/**
 设置阴影
 
 浅灰阴影
 
 */
+(void)setShodawWithView:(UIView *)view{
    view.layer.shadowOffset = CGSizeMake(0, 5);
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowRadius = 3;
    view.layer.shadowOpacity = 0.3;
    
}


#pragma mark - 文字
/**
 获取文字宽度
 
 @param text 文本内容
 @param fontSize 字号大小
 @return return value description
 */
+ (CGFloat)getTextWidth:(NSString *)text fontSize:(CGFloat)fontSize
{
    CGSize size=[text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]}];
    
    return size.width;
}

/**
 获取文字高度
 
 @param text 文本内容
 @param fontSize 字号大小
 @param width 宽度
 @return return value description
 */
+ (CGFloat)getTextHeight:(NSString *)text fontSize:(CGFloat)fontSize width:(CGFloat)width {
    CGSize size = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil].size;
    return size.height;
}

/**
 获取文字宽度
 
 @param text 文本内容
 @param font 字号大小
 @return return value description
 */
+ (CGFloat)getTextWidth:(NSString *)text font:(UIFont *)font
{
    CGSize size=[text sizeWithAttributes:@{NSFontAttributeName:font}];
    
    return size.width;
}

/**
 裁减图片
 
 @param imageView imageView description
 */
+(void)scaleAspectFillWithImageView:(UIImageView *)imageView{
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    //裁剪图片
    imageView.clipsToBounds = YES;
}


#pragma mark - Other
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err){
        Log(@"json解析失败：%@",err);
        return nil;
    }
    
    return dic;
}


+ (NSArray *)arrayWithJsonString:(NSString *)jsonString
{
    NSArray *array = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments|NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers error:nil];
    return array;
}

//@end

+ (NSString*)jsonStringWithObject:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        Log(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

@end
