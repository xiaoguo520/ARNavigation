//
//  NSString+Extend.m
//  New_Patient
//
//  Created by 新开元 iOS on 2018/5/15.
//  Copyright © 2018年 新开元 iOS. All rights reserved.
//

#import "NSString+Extend.h"
#import "CommonCrypto/CommonDigest.h"
#import <CoreText/CoreText.h>

#pragma mark - NSString+Extend
@interface NSMutableString (TagReplace)
- (void)replaceAllTagsIntoArray:(NSMutableArray*)array;
@end
@implementation NSMutableString (TagReplace)
- (BOOL)replaceFirstTagItoArray:(NSMutableArray*)array{
    NSRange openTagRange = [self rangeOfString:@"<"];
    if (openTagRange.length == 0) return NO;
    NSRange closeTagRange = [self rangeOfString:@">" options:NSCaseInsensitiveSearch range:NSMakeRange(openTagRange.location+openTagRange.length, self.length - (openTagRange.location+openTagRange.length))];
    if (closeTagRange.length == 0) return NO;
    NSRange range = NSMakeRange(openTagRange.location, closeTagRange.location-openTagRange.location+1);
    NSString *tag = [self substringWithRange:range];
    [self replaceCharactersInRange:range withString:@""];
    BOOL isEndTag = [tag rangeOfString:@"</"].length == 2;
    if (isEndTag) {
        NSString *openTag = [tag stringByReplacingOccurrencesOfString:@"</" withString:@"<"];
        NSInteger count = array.count;
        for (NSInteger i=count-1; i>=0; i--) {
            NSDictionary *dict = array[i];
            NSString* dtag = dict[@"tag"];
            if ([dtag isEqualToString:openTag]) {
                NSNumber *loc = dict[@"loc"];
                if ([loc integerValue] < range.location) {
                    [array removeObjectAtIndex:i];
                    NSString *strippedTag = [openTag substringWithRange:NSMakeRange(1, openTag.length-2)];
                    [array addObject:@{@"loc":loc, @"tag":strippedTag, @"endloc":@(range.location)}];
                }
                break;
            }
        }
    } else {
        [array addObject:@{@"loc":@(range.location), @"tag":tag}];
    }
    return YES;
}
- (void)replaceAllTagsIntoArray:(NSMutableArray*)array{
    while ([self replaceFirstTagItoArray:array]) {}
}
@end


@implementation AttributedStyleAction
- (instancetype)initWithAction:(void(^)(void))action{
    self = [super init];
    if (self) {
        self.action = action;
    }
    return self;
}
- (NSDictionary*)styledAction{
    return @{@"AttributedStyleAction":self};
}
+ (NSDictionary*)action:(void(^)(void))action{
    AttributedStyleAction *styledAction = [[AttributedStyleAction alloc]initWithAction:action];
    return [styledAction styledAction];
}
@end

@implementation NSString (Extend)

- (id)getUserDefaults{
    id obj = [[NSUserDefaults standardUserDefaults] valueForKey:self];
    if ([obj isKindOfClass:[NSString class]] && ![obj length]) obj = @"";
    return obj;
}
- (NSString*)getUserDefaultsString{
    NSString *string = [[NSUserDefaults standardUserDefaults] stringForKey:self];
    if (!string.length) string = @"";
    return string;
}
- (int)getUserDefaultsInt{
    id data = [self getUserDefaults];
    if (![data isInt]) return 0;
    return [data intValue];
}
- (NSInteger)getUserDefaultsInteger{
    return [[NSUserDefaults standardUserDefaults] integerForKey:self];
}
- (CGFloat)getUserDefaultsFloat{
    return [[NSUserDefaults standardUserDefaults] floatForKey:self];
}
- (BOOL)getUserDefaultsBool{
    return [[NSUserDefaults standardUserDefaults] boolForKey:self];
}
- (NSMutableArray*)getUserDefaultsArray{
    NSArray *data = [[NSUserDefaults standardUserDefaults] arrayForKey:self];
    if (data) {
        return [NSMutableArray arrayWithArray:data];
    } else {
        return [[NSMutableArray alloc]init];
    }
}
- (NSMutableDictionary*)getUserDefaultsDictionary{
    NSDictionary *data = [[NSUserDefaults standardUserDefaults] dictionaryForKey:self];
    if (data) {
        return [NSMutableDictionary dictionaryWithDictionary:data];
    } else {
        return [[NSMutableDictionary alloc]init];
    }
    
}

//保存到本地储存
- (void)setUserDefaultsWithData:(id)data{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:self];
    [userDefaults setObject:data forKey:self];
    [userDefaults synchronize];
}

//替换本地储存某些key的值
- (void)replaceUserDefaultsWithData:(NSDictionary*)data{
    NSMutableDictionary *dict = [self getUserDefaultsDictionary];
    if (!dict) dict = [[NSMutableDictionary alloc]init];
    for (NSString *key in data) {
        [dict setObject:data[key] forKey:key];
    }
    [self setUserDefaultsWithData:dict];
}

//删除本地储存
- (void)deleteUserDefaults{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:self];
    [userDefaults synchronize];
}

//自动宽度
- (CGSize)autoWidth:(UIFont*)font height:(CGFloat)height{
    if (!self.length) return CGSizeMake(0, height);
    NSDictionary *attributes = @{NSFontAttributeName:font};
    NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
    CGRect rect = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:options attributes:attributes context:NULL];
    return CGSizeMake(rect.size.width, rect.size.height);
    //NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    //[paragraphStyle setLineBreakMode:NSLineBreakByClipping];
    //[paragraphStyle setAlignment:NSTextAlignmentCenter];
    //NSDictionary *attributes = @{ NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle };
    //[str drawInRect:CGRectMake(0, 0, MAXFLOAT, height) withAttributes:attributes];
}

//自动高度
- (CGSize)autoHeight:(UIFont*)font width:(CGFloat)width{
    
    if (!self.length) return CGSizeMake(width, 0);
    NSDictionary *attributes = @{NSFontAttributeName:font};
    NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:options attributes:attributes context:NULL];
    return CGSizeMake(rect.size.width, rect.size.height);
}

//全小写
- (NSString*)strtolower{
    return [self lowercaseString];
}

//全大写
- (NSString*)strtoupper{
    return [self uppercaseString];
}

//各单词首字母大写
- (NSString*)strtoupperFirst{
    return [self capitalizedString];
}

//清除首尾空格和换行
- (NSString*)trim{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

//清除首尾指定字符串
- (NSString*)trim:(NSString*)assign{
    return [self preg_replace:[NSString stringWithFormat:@"^(%@)*|(%@)*$", assign, assign] with:@""];
}

//清除换行
- (NSString*)trimNewline{
    NSString *str = [self stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return str;
}

//一个字符串搜索另一个字符串
- (NSInteger)indexOf:(NSString*)str{
    if (self.length<=0) return NSNotFound;
    NSRange range = [self rangeOfString:str];
    NSInteger location = range.location;
    NSInteger length = range.length;
    if (length>0) {
        return location;
    } else {
        return NSNotFound;
    }
}

//替换字符串
- (NSString*)replace:(NSString*)r1 to:(NSString*)r2{
    if (self.length<=0) return @"";
    return [self stringByReplacingOccurrencesOfString:r1 withString:r2];
}

//截取字符串
- (NSString*)substr:(NSInteger)start length:(NSInteger)length{
    if (self.length<start || self.length-start<length) return self;
    return [self substringWithRange:NSMakeRange(start,length)];
}

//截取字符串,从指定位置开始到最后,负数:从字符串结尾的指定位置开始
- (NSString*)substr:(NSInteger)start{
    if (start<0) {
        start = self.length + start;
        if (start<0) start = 0;
    }
    if (self.length<start) return self;
    return [self substringFromIndex:start];
}

//从左边开始截取字符串
- (NSString*)left:(NSInteger)length{
    if (self.length<length) return self;
    return [self substringToIndex:length];
}

//从右边开始截取字符串
- (NSString*)right:(NSInteger)length{
    if (self.length<length) return self;
    NSUInteger len = self.length;
    NSUInteger start = 0;
    if (len>length) start = len - length;
    return [self substringFromIndex:start];
}

//获取中英文混编的字符串长度
- (NSInteger)fontLength{
    if (self.length<=0) return 0;
    NSInteger p = 0;
    for (int i=0; i<self.length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [self substringWithRange:range];
        const char *cString = [subString UTF8String];
        if (strlen(cString) == 3) {
            p += 2;
        } else {
            p++;
        }
    }
    return p;
}

//分割字符串转为数组
- (NSMutableArray*)split:(NSString*)symbol{
    return [self explode:symbol];
}
- (NSMutableArray*)explode:(NSString*)symbol{
    NSArray *array = [self componentsSeparatedByString:symbol];
    return [NSMutableArray arrayWithArray:array];
}

//按指定长度分割字符串
- (NSMutableArray*)explodeStr:(NSInteger)step{
    NSString *str = [self copy];
    NSInteger length = str.length;
    NSMutableArray *res = [[NSMutableArray alloc]init];
    for (int i=0; i<length; i+=step) {
        if (str.length >= step) {
            [res addObject:[str substr:0 length:step]];
            str = [str substr:step];
        } else {
            [res addObject:str];
        }
    }
    return res;
}
//网址参数转字典
- (NSMutableDictionary*)params{
    return [self params:@"?"];
}
- (NSMutableDictionary*)params:(NSString*)mark{
    NSArray *parts = [self split:mark];
    if (parts.count<2) return nil;
    parts = [parts.lastObject split:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    for (int i=0; i<parts.count; i++) {
        NSArray *kv = [parts[i] split:@"="];
        [params setObject:[[kv[1] URLDecode] replace:@"+" to:@" "] forKey:kv[0]];
    }
    return params;
}

//截取所需字符串
//cropHtml(HTML代码, 所需代码前面的特征代码[会被去除], 所需代码末尾的特征代码[会被去除])
//得到代码后请自行使用str_replace所需代码部分中不需要的代码
- (NSString*)cropHtml:(NSString*)startStr overStr:(NSString*)overStr{
    NSString *webHtml = self;
    if(webHtml.length>0){
        if(startStr.length>0 && [webHtml indexOf:startStr]!=NSNotFound){
            NSArray *array = [webHtml split:startStr];
            webHtml = array[1];
        }
        if(overStr.length>0 && [webHtml indexOf:overStr]!=NSNotFound){
            NSArray *array = [webHtml split:overStr];
            webHtml = array[0];
        }
    }
    return webHtml;
}

//删除例如 [xxxx] 组合的字符串段落
- (NSString*)deleteStringPart:(NSString*)prefix suffix:(NSString*)suffix{
    NSString *str = nil;
    NSInteger length = self.length;
    if (length > 0) {
        if ([suffix isEqualToString:[self substringFromIndex:length-suffix.length]]) {
            if ([self rangeOfString:prefix].location == NSNotFound) {
                str = [self substringToIndex:length-prefix.length];
            } else {
                str = [self substringToIndex:[self rangeOfString:prefix options:NSBackwardsSearch].location];
            }
        } else {
            for (int i=1; i<=2; i++) {
                if (length>i) {
                    if ([[self substringFromIndex:length-i] isEmoji]) {
                        return [self substringToIndex:length-i];
                        break;
                    }
                }
            }
            str = [self substringToIndex:length-1];
        }
    }
    return str;
}

//正则表达式test
- (BOOL)preg_test:(NSString*)patton{
    if (!self || self==nil || ![self isKindOfClass:[NSString class]] || !self.length) return NO;
    NSArray *matcher = [self preg_match:patton];
    return matcher.isArray;
    //NSPredicate *match = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", patton];
    //return [match evaluateWithObject:self];
}

//正则表达式replace
- (NSString*)preg_replace:(NSString*)patton with:(NSString*)templateStr{
    if (!self || self==nil || ![self isKindOfClass:[NSString class]] || !self.length) return self;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patton
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSString *modified = [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:templateStr];
    return modified;
}

//正则表达式replace, 根据replacement返回字符串来替换
- (NSString*)preg_replace:(NSString*)patton replacement:(NSString *(^)(NSDictionary *matcher, NSInteger index))replacement{
    if (!self || self==nil || ![self isKindOfClass:[NSString class]] || !self.length || !replacement) return self;
    NSString *modified = self;
    NSArray *matches = [self preg_match:patton];
    if (matches.count) {
        for (NSInteger i=0; i<matches.count; i++) {
            NSDictionary *matcher = matches[i];
            NSUInteger loc = [modified indexOf:matcher[@"value"]];
            NSUInteger len = [matcher[@"value"] length];
            modified = [modified stringByReplacingCharactersInRange:NSMakeRange(loc, len) withString:replacement(matcher, i)];
        }
    }
    return modified;
}

//正则表达式match
- (NSMutableArray*)preg_match:(NSString*)patton{
    NSMutableArray *matcher = [[NSMutableArray alloc]init];
    if (!self || self==nil || ![self isKindOfClass:[NSString class]] || !self.length) return matcher;
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patton
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error) {
        NSLog(@"%@", error);
        return matcher;
    }
    NSArray *matches = [regex matchesInString:self options:NSMatchingReportCompletion range:NSMakeRange(0, self.length)];
    //NSLog(@"%@", matches);
    for (NSTextCheckingResult *match in matches) {
        NSMutableArray *group = [[NSMutableArray alloc]init];
        for (NSInteger i=1; i<=match.numberOfRanges-1; i++) {
            if ([match rangeAtIndex:i].length) {
                [group addObject:[self substringWithRange:[match rangeAtIndex:i]]];
            } else {
                [group addObject:@""];
            }
        }
        NSString *value = [self substringWithRange:match.range];
        [matcher addObject:@{@"group":group, @"value":value}];
    }
    return matcher;
}


//Json字符串转Dictionary、Array
- (id)formatJson{
    if (![self isKindOfClass:[NSString class]] || !self.length) return [[NSMutableDictionary alloc]init];
    NSString *json = self;
    json = [json replace:@":null" to:@":\"\""];
//    json = [json replace:@":[]" to:@":\"\""];
//    json = [json replace:@":{}" to:@":\"\""];
    
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
}


//是否为整型
- (BOOL)isInt{
    return [self isInt:self.length];
}
- (BOOL)isInt:(NSInteger)length{
    if (!self.length) return NO;
    NSScanner *scan = [NSScanner scannerWithString:[self substringToIndex:length]];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (BOOL)isIntCheck:(NSInteger)length{
    if (!self.length) return NO;
    if (self.length < length) return NO;
    if (self.length == length) {
        NSString *str = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (str.length < length){
            return NO;
        }else {
            NSScanner *scan = [NSScanner scannerWithString:[self substringToIndex:length]];
            int val;
            return [scan scanInt:&val] && [scan isAtEnd];
        }
    }
    return NO;
}

- (BOOL)isPureInt{
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

/**
 *  判断名称是否合法
 *  @param name 名称
 *  @return yes / no
 */
-(BOOL)isNameValid
{
    BOOL isValid = NO;
    
    
    
    if (self.length > 0)
    {
        for (NSInteger i=0; i<self.length; i++)
        {
            unichar chr = [self characterAtIndex:i];
            
            if (chr < 0x80)
            { //字符
                if (chr >= 'a' && chr <= 'z')
                {
                    isValid = YES;
                }
                else if (chr >= 'A' && chr <= 'Z')
                {
                    isValid = YES;
                }
                else if (chr >= '0' && chr <= '9')
                {
                    isValid = NO;
                }
                else if (chr == '-' || chr == '_')
                {
                    isValid = YES;
                }
                else
                {
                    isValid = NO;
                }
            }
            else if (chr >= 0x4e00 && chr < 0x9fa5)
            { //中文
                isValid = YES;
            }
            else
            { //无效字符
                isValid = NO;
            }
            
            if (!isValid)
            {
                break;
            }
        }
    }
    
    if (self.length < 2) {
        isValid = NO;
    }
    
    return isValid;
}

//判断是否为浮点形：

- (BOOL)isPureFloat{
    NSScanner* scan = [NSScanner scannerWithString:self];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}

//是否为浮点型
- (BOOL)isFloat{
    return [self isFloat:self.length];
}
- (BOOL)isFloat:(NSInteger)length{
    if (!self.length) return NO;
    NSScanner *scan = [NSScanner scannerWithString:[self substringToIndex:length]];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}


//用户名
- (BOOL)isUsername{
    return [self preg_test:@"^[A-Za-z0-9]{6,20}+$"];
}

//密码
- (BOOL)isPassword{
    return [self preg_test:@"^([a-zA-Z0-9!@#$%^&\\W].*){6,16}+$"];
//    return [self preg_test:@"^([a-zA-Z0-9].*){6,16}+$"];
//    return [self preg_test:@"^(?=.*[a-zA-Z0-9].*)(?=.*[a-zA-Z\\W].*)(?=.*[0-9\\W].*).{6,16}$"];
}

- (BOOL)isPasswordRangeX {
    NSString *passWordRegex = @"^([a-zA-Z0-9!@#$%^&\\W].*){6,16}+$";
    return [self preg_test:passWordRegex];
}

#pragma 正则匹配用户密码6-18位数字和字母组合
- (BOOL)checkPassword:(NSString *) password
{
    NSString *pattern = @"^([a-zA-Z0-9!@#$%^&\\W].*){6,16}+$";//@"^(?=.*[a-zA-Z0-9].*)(?=.*[a-zA-Z\\W].*)(?=.*[0-9\\W].*).{6,16}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    return isMatch;
    
}

//是否存在中文字
- (BOOL)hasChinese{
    BOOL has = NO;
    NSInteger length = self.length;
    for (NSInteger i=0; i<length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [self substringWithRange:range];
        const char *string = [subString UTF8String];
        if (strlen(string) == 3) {
            has = YES;
            break;
        }
    }
    return has;
}


-(BOOL)isSpecialStr{
    return ![self preg_test:@"^[A-Za-z0-9\\u4e00-\u9fa5]+$"];
}

//全中文
- (BOOL)isChinese{
    return [self preg_test:@"^[\u4e00-\u9fa5]+$"];
}

//邮箱
- (BOOL)isEmail{
    return [self preg_test:@"^(\\w)+(\\.\\w+)*@(\\w)+((\\.\\w+)+)$"];
}

//手机号码
- (BOOL)isMobile{
    return [self preg_test:@"^1[1-9]+\\d{9}$"];
    //^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$
}

//日期
- (BOOL)isDate{
    return [self preg_test:@"^\\d{4}-\\d{1,2}-\\d{1,2}( \\d{1,2}:\\d{1,2}:\\d{1,2})?$"];
}

//网址
- (BOOL)isUrl{
    return [self preg_test:@"^(http|https|ftp):(\\/\\/|\\\\)(([\\w\\/\\\\+\\-~`@:%])+\\.)+([\\w\\/\\\\.=\\?\\+\\-~`@\\':!%#]|(&amp;)|&)+"];
}

//身份证
- (BOOL)isIDCard{
    
    NSString *value;
    value = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger length =0;
    if (!value) {
        return NO;
    }else {
        length = value.length;
        //不满足15位和18位，即身份证错误
        if (length !=15 && length !=18) {
            return NO;
        }
    }
    // 省份代码
    NSArray *areasArray = @[@"11",@"12", @"13",@"14", @"15",@"21", @"22",@"23", @"31",@"32", @"33",@"34", @"35",@"36", @"37",@"41", @"42",@"43", @"44",@"45", @"46",@"50", @"51",@"52", @"53",@"54", @"61",@"62", @"63",@"64", @"65",@"71", @"81",@"82", @"91"];
    
    // 检测省份身份行政区代码
    NSString *valueStart2 = [value substringToIndex:2];
    BOOL areaFlag =NO; //标识省份代码是否正确
    for (NSString *areaCode in areasArray) {
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag =YES;
            break;
        }
    }
    
    if (!areaFlag) {
        return NO;
    }
    
    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;
    
    int year =0;
    if (self.length == 15){
        
        //分为15位、18位身份证进行校验
        //获取年份对应的数字
        year = [value substringWithRange:NSMakeRange(6,2)].intValue +1900;

        if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
            //创建正则表达式 NSRegularExpressionCaseInsensitive：不区分字母大小写的模式
            regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"
                                                                    options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
        }else {
            regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"
                                                                    options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
        }
        //使用正则表达式匹配字符串 NSMatchingReportProgress:找到最长的匹配字符串后调用block回调
        numberofMatch = [regularExpression numberOfMatchesInString:self
                                                           options:NSMatchingReportProgress
                                                            range:NSMakeRange(0, self.length)];
        
        if(numberofMatch >0) {
            return YES;
        }else {
            return NO;
        }
        
    }else if (self.length == 18){
        
        NSInteger length = self.length;
        if (length!=15 && length!=18) return NO;
        NSArray *codeArray = @[@"7",@"9",@"10",@"5",@"8",@"4",@"2",@"1",@"6",@"3",@"7",@"9",@"10",@"5",@"8",@"4",@"2"];
        NSDictionary *checkCodeDic = [NSDictionary dictionaryWithObjects:@[@"1",@"0",@"X",@"9",@"8",@"7",@"6",@"5",@"4",@"3",@"2"]
                                                                 forKeys:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"]];
        int sumValue = 0;
        if (length==18) {
            if (![self isInt:17]) return NO;
            for (int i=0; i<17; i++) {
                sumValue += [[self substringWithRange:NSMakeRange(i, 1)]intValue] * [[codeArray objectAtIndex:i]intValue];
            }
            NSString *strlast = [checkCodeDic objectForKey:[NSString stringWithFormat:@"%d", sumValue%11]];
            if ([strlast isEqualToString:[[self substringWithRange:NSMakeRange(17, 1)]uppercaseString]]) return YES;
        } else {
            if (![self isInt:15]) return NO;
            if ([self isEqualToString:@"111111111111111"]) return NO;
            NSRegularExpression *regularExpression;
            int year = [self substringWithRange:NSMakeRange(6,2)].intValue + 1900;
            if (year%4==0 || (year%100==0 && year%4==0)) {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];
            } else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];
            }
            sumValue = (int)[regularExpression numberOfMatchesInString:self
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, length)];
            if (sumValue > 0) return YES;
        }
        return NO;
    }
    
    return NO;
}

//是否Emoji表情
- (BOOL)isEmoji{
    __block BOOL returnValue = NO;
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        const unichar hs = [substring characterAtIndex:0];
        if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    returnValue = YES;
                }
            }
        } else if (substring.length > 1) {
            const unichar ls = [substring characterAtIndex:1];
            if (ls == 0x20e3) {
                returnValue = YES;
            }
        } else {
            if (0x2100 <= hs && hs <= 0x27ff) {
                returnValue = YES;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                returnValue = YES;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                returnValue = YES;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                returnValue = YES;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                returnValue = YES;
            }
        }
    }];
    return returnValue;
}

//获取完整文件名(带后缀名)(支持网址)
- (NSString*)getFullFilename{
    return [self lastPathComponent];
}

//获取文件名(不带后缀名)
- (NSString*)getFilename{
    return [self stringByDeletingPathExtension];
}

//获取后缀名
- (NSString*)getSuffix{
    return [self pathExtension];
}

- (NSString*)ASCII{
    NSString *str = [NSString stringWithCString:[self cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
    return str;
}

- (NSString*)Unicode{
    NSString *str = [NSString stringWithCString:[self cStringUsingEncoding:NSNonLossyASCIIStringEncoding] encoding:NSUTF8StringEncoding];
    return str;
}

//数字转时间字符串
-(NSString *)formatDataStr{
    //秒数
    NSInteger intTime = self.integerValue;
    
    NSInteger seconds = intTime % 60;
    NSInteger minutes = (intTime / 60) % 60;
    NSInteger hours = (intTime / 3600) % 24;
    NSInteger day = intTime / 3600 / 24;
    
    if (day > 0) {
        return [NSString stringWithFormat:@"%ld天%ld小时%02ld分%02ld秒",(long)day,hours, minutes, seconds];
    }
    if (day == 0 && hours > 0) {
        return [NSString stringWithFormat:@"%ld小时%ld分%02ld秒",(long)hours, minutes, seconds];
    }
    if (day == 0 && hours == 0 && minutes > 0) {
        [NSString stringWithFormat:@"%02ld分%02ld秒", (long)minutes, seconds];
    }
    
    return [NSString stringWithFormat:@"%02ld分%02ld秒", (long)minutes, seconds];
}


-(NSString *)formatSecondsStr{
    NSArray *array = [self componentsSeparatedByString:@":"]; //从字符A中分隔成2个元素的数组
    NSString *HH = array[0];
    NSString *MM= array[1];
    NSString *ss = array[2];
    NSInteger h = [HH integerValue];
    NSInteger m = [MM integerValue];
    NSInteger s = [ss integerValue];
    NSInteger zonghms = h*3600 + m*60 +s;
    //需要的在转 NSString类型
    NSString *stringInt = [NSString stringWithFormat:@"%ld",(long)zonghms];//转字符串
    return stringInt;
}

//URL编码
- (NSString*)URLEncode{
    return [self URLEncode:NSUTF8StringEncoding];
}

//URL编码,可设置字符编码
- (NSString*)URLEncode:(NSStringEncoding)encoding{
    NSArray *escapeChars = [NSArray arrayWithObjects:@";", @"/", @"?", @":",
                            @"@", @"&", @"=", @"+", @"$", @",", @"!", @"'", @"(", @")", @"*",nil];
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F", @"%3F" , @"%3A" ,
                             @"%40", @"%26", @"%3D", @"%2B", @"%24", @"%2C",
                             @"%21", @"%27", @"%28", @"%29", @"%2A", nil];
    NSInteger len = [escapeChars count];
    NSMutableString *temp = [[self
                              stringByAddingPercentEscapesUsingEncoding:encoding]
                             mutableCopy];
    int i;
    for (i=0; i<len; i++) {
        [temp replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
                              withString:[replaceChars objectAtIndex:i]
                                 options:NSLiteralSearch
                                   range:NSMakeRange(0, [temp length])];
    }
    NSString *outStr = [NSString stringWithString:temp];
    return outStr;
}

//URL解码
- (NSString*)URLDecode{
    return [self URLDecode:NSUTF8StringEncoding];
}

//URL解码,可设置字符编码
- (NSString*)URLDecode:(NSStringEncoding)encoding{
    return [self stringByReplacingPercentEscapesUsingEncoding:encoding];
}



//Base64转NSString
- (NSString*)base64ToString{
    NSData *data = [self base64ToData];
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

-(NSString *)imageUrl{
    return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

//Base64转NSData
- (NSData*)base64ToData{
    if (self == nil) [NSException raise:NSInvalidArgumentException format:@""];
    if (self.length == 0) return [NSData data];
    static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    static char *decodingTable = NULL;
    if (decodingTable == NULL) {
        decodingTable = malloc(256);
        if (decodingTable == NULL) return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++) decodingTable[(short)encodingTable[i]] = i;
    }
    const char *characters = [self cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL) return nil; //Not an ASCII string!
    char *bytes = malloc(((self.length + 3) / 4) * 3);
    if (bytes == NULL) return nil;
    NSUInteger length = 0;
    NSUInteger i = 0;
    while (YES) {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++) {
            if (characters[i] == '\0') break;
            if (isspace(characters[i]) || characters[i] == '=') continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX) { //Illegal character!
                free(bytes);
                return nil;
            }
        }
        if (bufferLength == 0) break;
        if (bufferLength == 1) { //At least two characters are needed to produce one byte!
            free(bytes);
            return nil;
        }
        //Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2) bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3) bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    realloc(bytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}

//Base64转UIImage
- (UIImage*)base64ToImage{
    NSURL *url = [NSURL URLWithString:self];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

//转MD5, 16位:CC_MD5_DIGEST_LENGTH, 64位:CC_MD5_BLOCK_BYTES
- (NSString*)md5{
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) [output appendFormat:@"%02x", digest[i]];
    return output;
}

//转SHA1, 20位:CC_SHA1_DIGEST_LENGTH, 64位:CC_SHA1_BLOCK_BYTES
//- (NSString*)sha1{
//    NSInteger length = CC_SHA1_BLOCK_BYTES;
//    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
//    NSData *data = [NSData dataWithBytes:cstr length:self.length];
//    uint8_t digest[length];
//    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
//    NSMutableString* output = [NSMutableString stringWithCapacity:length * 2];
//    for (int i = 0; i < length; i++) [output appendFormat:@"%02x", digest[i]];
//    return output;
//}

//转化简单HTML代码为iOS文本
- (NSAttributedString*)simpleHtml{
    NSAttributedString *html = [[NSAttributedString alloc] initWithData:[self dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    return html;
}

- (NSMutableAttributedString *)setTextColorWithStr:(NSString *)str Color:(UIColor *)color Range:(NSRange)range{
    if (str == nil) return nil;
    NSMutableAttributedString *newStr = [[NSMutableAttributedString alloc] initWithString:str];
    [newStr addAttribute:NSForegroundColorAttributeName value:color range:range];
    return newStr;
}

-(NSString *)filterHTML
{
    NSRegularExpression *regularExpretion=[NSRegularExpression regularExpressionWithPattern:@"<[^>]*>|\n|&nbsp;"
                                                                                    options:0
                                                                                      error:nil];
    NSString * string=[regularExpretion stringByReplacingMatchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length) withTemplate:@""];
    return string;
}


//使用标签自定义UILabel字体
//www.itnose.net/detail/6177538.html
/*
 NSString *string = [NSString stringWithFormat:@"<e>￥</e><bp>%.1f</bp>", [dic[@"price"]floatValue]];
 NSDictionary *style = @{@"body":@[FONT(12),COLORRGB(@"c0c0c0")], @"e":FONTBOLD(10), @"bp":FONT(16)};
 price.attributedText = [string attributedStringWithStyleDictionary:style];
 */
- (NSAttributedString*)attributedStyle:(NSDictionary*)styleBook{
    NSMutableArray *tags = [[NSMutableArray alloc]init];
    NSMutableString *ms = [self mutableCopy];
    [ms replaceOccurrencesOfString:@"<br>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, ms.length)];
    [ms replaceOccurrencesOfString:@"<br/>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, ms.length)];
    [ms replaceOccurrencesOfString:@"<br >" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, ms.length)];
    [ms replaceOccurrencesOfString:@"<br />" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, ms.length)];
    [ms replaceAllTagsIntoArray:tags];
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc]initWithString:ms];
    NSObject *bodyStyle = styleBook[@"body"];
    if (bodyStyle) [self styleAttributedString:as range:NSMakeRange(0, as.length) withStyle:bodyStyle withStyleBook:styleBook];
    for (NSDictionary *tag in tags) {
        if (tag[@"loc"]!=nil && tag[@"endloc"]!=nil) {
            NSString *t = tag[@"tag"];
            NSNumber *loc = tag[@"loc"];
            NSNumber *endloc = tag[@"endloc"];
            NSRange range = NSMakeRange([loc integerValue], [endloc integerValue] - [loc integerValue]);
            NSObject *style = styleBook[t];
            if (style) {
                //*//
                if ([t isEqualToString:@"b"]) { //字体宽度,正值中空,负值填充
                    [as removeAttribute:NSStrokeWidthAttributeName range:range];
                    [as addAttribute:NSStrokeWidthAttributeName value:style range:range];
                } else if ([t isEqualToString:@"u"]) { //下划线,值越大线条越粗
                    [as removeAttribute:NSUnderlineStyleAttributeName range:range];
                    [as addAttribute:NSUnderlineStyleAttributeName value:style range:range];
                } else if ([t isEqualToString:@"i"]) { //字形倾斜度,正值右倾,负值左倾
                    [as removeAttribute:NSObliquenessAttributeName range:range];
                    [as addAttribute:NSObliquenessAttributeName value:style range:range];
                } else if ([t isEqualToString:@"s"]) { //中划线,值越大线条越粗
                    [as removeAttribute:NSStrikethroughStyleAttributeName range:range];
                    [as addAttribute:NSStrikethroughStyleAttributeName value:style range:range];
                } else if ([t isEqualToString:@"line-height"]) { //行高
                    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                    [paragraphStyle setLineSpacing:[(NSNumber*)style floatValue]];
                    [as removeAttribute:NSParagraphStyleAttributeName range:range];
                    [as addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
                } else if ([t isEqualToString:@"margin-bottom"]) { //文字位置偏移,正值上偏,负值下偏
                    [as removeAttribute:NSBaselineOffsetAttributeName range:range];
                    [as addAttribute:NSBaselineOffsetAttributeName value:style range:range];
                } else if ([t isEqualToString:@"letter-spacing"]) { //字体间隔,值越大间隔越大
                    [as removeAttribute:NSKernAttributeName range:range];
                    [as addAttribute:NSKernAttributeName value:style range:range];
                } else if ([t isEqualToString:@"style"]) { //字体样式,值为NSMutableParagraphStyle
                    [as removeAttribute:NSParagraphStyleAttributeName range:range];
                    [as addAttribute:NSParagraphStyleAttributeName value:style range:range];
                }
                //*/
                //自定义标签
                [self styleAttributedString:as range:range withStyle:style withStyleBook:styleBook];
            }
        }
    }
    return as;
}
- (void)styleAttributedString:(NSMutableAttributedString*)as range:(NSRange)range withStyle:(NSObject*)style withStyleBook:(NSDictionary*)styleBook{
    if ([style isKindOfClass:[NSArray class]]) {
        for (NSObject *subStyle in (NSArray*)style) {
            [self styleAttributedString:as range:range withStyle:subStyle withStyleBook:styleBook];
        }
    } else if ([style isKindOfClass:[NSString class]]) {
        [self styleAttributedString:as range:range withStyle:styleBook[(NSString*)style] withStyleBook:styleBook];
    } else if ([style isKindOfClass:[NSDictionary class]]) {
        [as setAttributes:(NSDictionary*)style range:range];
    } else if ([style isKindOfClass:[UIFont class]]) {
        UIFont *font = (UIFont*)style;
        CTFontRef aFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
        if (aFont) {
            [as removeAttribute:(__bridge NSString*)kCTFontAttributeName range:range];
            [as addAttribute:(__bridge NSString*)kCTFontAttributeName value:(__bridge id)aFont range:range];
            CFRelease(aFont);
        }
    } else if ([style isKindOfClass:[UIColor class]]) {
        [as removeAttribute:NSForegroundColorAttributeName range:range];
        [as addAttribute:NSForegroundColorAttributeName value:(UIColor*)style range:range];
    } else if ([style isKindOfClass:[NSURL class]]) {
        [as removeAttribute:NSLinkAttributeName range:range];
        [as addAttribute:NSLinkAttributeName value:(NSURL*)style range:range];
    } else if ([style isKindOfClass:[UIImage class]]) {
        UIImage *image = (UIImage*)style;
        NSTextAttachment *attachment = [[NSTextAttachment alloc]init];
        attachment.image = image;
        //CGSize s = [self sizeWithAttributes:@{NSFontAttributeName:_textFont}];
        //attachment.bounds = CGRectMake(0, (s.height-image.size.height)/2-(_textFont.lineHeight*0.1), image.size.width, image.size.height);
        [as replaceCharactersInRange:range withAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    }
}

-(BOOL)isGuard{
    NSArray * tempArray = [self componentsSeparatedByString:@"-"];
    NSInteger age = 0;
    if (tempArray.count > 2) {
        NSString * year = tempArray[0];
        //        NSString * month = tempArray[1];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        int unit = NSCalendarUnitYear;
        //        int m = NSCalendarUnitMonth;
        // 1.获得当前时间的年月
        NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
        //        NSDateComponents * nowMonth = [calendar components:m fromDate:[NSDate date]];
        age = nowCmps.year - [year integerValue];
    }
    if (age <= 14) {
        return YES;
    }else return NO;
}

//5.25 更改儿童规则 以年为准 小于=于14岁为儿童
-(BOOL)isMoreYear:(NSInteger)year{
    NSArray * tempArray = [self componentsSeparatedByString:@"-"];
    
    NSInteger age = 0;
    if (tempArray.count > 2) {
        NSString * year = tempArray[0];
        NSString * month = tempArray[1];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        int unit = NSCalendarUnitYear;
        int m = NSCalendarUnitMonth;
        // 1.获得当前时间的年月
        NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
        NSDateComponents * nowMonth = [calendar components:m fromDate:[NSDate date]];
        age = nowCmps.year - [year integerValue];
        if ([month integerValue] > nowMonth.month) {
            age--;
        }
    }
    if (age > year) {
        return YES;
    }else return NO;
}

//是否为数字与字母组合
-(BOOL)isNumWithABC{
    //数字条件
    NSRegularExpression *tNumRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    //符合数字条件的有几个字节
    NSUInteger tNumMatchCount = [tNumRegularExpression numberOfMatchesInString:self
                                                                       options:NSMatchingReportProgress
                                                                         range:NSMakeRange(0, self.length)];
    //英文字条件
    NSRegularExpression *tLetterRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
    //符合英文字条件的有几个字节
    NSUInteger tLetterMatchCount = [tLetterRegularExpression numberOfMatchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length)];
    
    if (tNumMatchCount + tLetterMatchCount == self.length){
        return YES;
    }
    return NO;
}

//是否为数字与字母组合
-(BOOL)isNumAndABC{
    //数字条件
    NSRegularExpression *tNumRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
    //符合数字条件的有几个字节
    NSUInteger tNumMatchCount = [tNumRegularExpression numberOfMatchesInString:self
                                                                       options:NSMatchingReportProgress
                                                                         range:NSMakeRange(0, self.length)];
    //英文字条件
    NSRegularExpression *tLetterRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    
    NSRegularExpression * sss = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger ee = [sss numberOfMatchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length)];
    //符合英文字条件的有几个字节
    NSUInteger tLetterMatchCount = [tLetterRegularExpression numberOfMatchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length)];
    if ((self.length - ee) == 0) {
        if (tNumMatchCount == 0) {
            return NO;
        }
        if (tLetterMatchCount == 0) {
            return NO;
        }
        if (tNumMatchCount + tLetterMatchCount == self.length){
            return YES;
        }
    }else{
        if (tNumMatchCount == 0 && tLetterMatchCount == 0) {
            return NO;
        }
        return YES;
    }
    
    return NO;
}

//是否为数字与字母汉字组合
-(BOOL)isNumWithABCAndCH{
    //数字条件
    NSRegularExpression *tNumRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    //符合数字条件的有几个字节
    NSUInteger tNumMatchCount = [tNumRegularExpression numberOfMatchesInString:self
                                                                       options:NSMatchingReportProgress
                                                                         range:NSMakeRange(0, self.length)];
    //数字条件
    NSRegularExpression *tCHRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[\u4e00-\u9fa5]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    //符合数字条件的有几个字节
    NSUInteger tCHMatchCount = [tCHRegularExpression numberOfMatchesInString:self
                                                                     options:NSMatchingReportProgress
                                                                       range:NSMakeRange(0, self.length)];
    //英文字条件
    NSRegularExpression *tLetterRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    //符合英文字条件的有几个字节
    NSUInteger tLetterMatchCount = [tLetterRegularExpression numberOfMatchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length)];
    
    if (tNumMatchCount + tLetterMatchCount + tCHMatchCount == self.length){
        return YES;
    }
    return NO;
}
//前3后4
-(NSString *)IDCardHide{
    if([self length]>3){
        NSInteger length = self.length - 7;
        NSString *nStr = [self stringByReplacingCharactersInRange:NSMakeRange(3, length) withString:[@"" stringByPaddingToLength:length withString:@"*" startingAtIndex:0]];
        return nStr;
    }
    return self;
}

-(NSString *)translation;

{   NSString *str = self;
    NSArray *arabic_numerals = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
    NSArray *chinese_numerals = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"〇"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:chinese_numerals forKeys:arabic_numerals];
    
    NSMutableArray *sums = [NSMutableArray array];
    for (int i = 0; i < str.length; i ++) {
        NSString *substr = [str substringWithRange:NSMakeRange(i, 1)];
        NSString *a = [dictionary objectForKey:substr];
        [sums addObject:a];
        //        if ([a isEqualToString:chinese_numerals[9]])
        //        {
        //            if([b isEqualToString:digits[4]] || [b isEqualToString:digits[8]])
        //            {
        //                sum = b;
        //                if ([[sums lastObject] isEqualToString:chinese_numerals[9]])
        //                {
        //                    [sums removeLastObject];
        //                }
        //            }else
        //            {
        //                sum = chinese_numerals[9];
        //            }
        //
        //            if ([[sums lastObject] isEqualToString:sum])
        //            {
        //                continue;
        //            }
        //        }
        //
        //        [sums addObject:sum];
    }
    
    NSString *sumStr = [sums  componentsJoinedByString:@""];
    NSString *chinese = [sumStr substringToIndex:sumStr.length];
    NSLog(@"%@ to %@",str,chinese);
    return chinese;
}

-(NSString *)completeTranslation;

{   NSString *str = self;
    NSArray *arabic_numerals = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
    NSArray *chinese_numerals = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"〇"];
    NSArray *digits = @[@"个",@"十",@"百",@"千",@"万",@"十",@"百",@"千",@"亿",@"十",@"百",@"千",@"兆"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:chinese_numerals forKeys:arabic_numerals];
    NSMutableArray *sums = [NSMutableArray array];
    for (int i = 0; i < str.length; i ++) {
        NSString *substr = [str substringWithRange:NSMakeRange(i, 1)];
        NSString *a = [dictionary objectForKey:substr];
        NSString *b = digits[str.length -i-1];
        NSString *sum = [a stringByAppendingString:b];
        if ([a isEqualToString:chinese_numerals[9]])
        {
            if([b isEqualToString:digits[4]] || [b isEqualToString:digits[8]])
            {
                sum = b;
                if ([[sums lastObject] isEqualToString:chinese_numerals[9]])
                {
                    [sums removeLastObject];
                }
            }else
            {
                sum = chinese_numerals[9];
            }
            
            if ([[sums lastObject] isEqualToString:sum])
            {
                continue;
            }
        }
        
        [sums addObject:sum];
    }
    
    NSString *sumStr = [sums  componentsJoinedByString:@""];
    NSString *chinese = [sumStr substringToIndex:sumStr.length-1];
    NSLog(@"%@ to %@",str,chinese);
    return chinese;
}

-(NSString *)getAgeWithCardNum{
    if ([self isEqualToString:@""]) {
        return @"";
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear;
    // 1.获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    NSString* Ai = [self substringWithRange:NSMakeRange(0, 17)];
    NSString *strYear = [Ai substringWithRange:NSMakeRange(6, 4)];
    
    NSInteger age = nowCmps.year - [strYear integerValue];
    
    return [NSString stringWithFormat:@"%ld",age];
}

-(NSString *)getAgeWithBirthday{
    if ([self isEqualToString:@""]) {
        return @"";
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear;
    // 1.获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyyMMdd";
    NSDate * date = [fmt dateFromString:self];
    
    NSDateComponents *cmps = [calendar components:unit fromDate:date];
    
    NSInteger age = nowCmps.year - cmps.year;
    
    return [NSString stringWithFormat:@"%ld",age];
}


//18位身份证
-(NSString *)getBirthdayWithCardNum{
    
    if ([self isEqualToString:@""]) {
        return @"";
    }
    
    NSString *birthday = @"";
    if (self.length == 18){
        
        NSString* Ai = [self substringWithRange:NSMakeRange(0, 17)];
        NSString *strYear = [Ai substringWithRange:NSMakeRange(6, 4)];// 年份
        NSString *strMonth = [Ai substringWithRange:NSMakeRange(10, 2)];// 月份
        NSString *strDay = [Ai substringWithRange:NSMakeRange(12, 2) ];// 日期
        
        birthday = [NSString stringWithFormat:@"%@-%@-%@",strYear,strMonth,strDay];
        
    }else if (self.length == 15) {

        NSString* Ai = [self substringWithRange:NSMakeRange(0, 14)];
        NSString *strYear = [NSString stringWithFormat:@"19%@",[Ai substringWithRange:NSMakeRange(6, 2)]];// 年份
        NSString *strMonth = [Ai substringWithRange:NSMakeRange(8, 2)];// 月份
        NSString *strDay = [Ai substringWithRange:NSMakeRange(10, 2) ];// 日期
        birthday = [NSString stringWithFormat:@"%@-%@-%@",strYear,strMonth,strDay];
    }
    return birthday;
}

- (NSString *)VerticalString{
    NSMutableString * str = [[NSMutableString alloc] initWithString:self];
    NSInteger count = str.length;
    for (int i = 1; i < count; i ++) {
        [str insertString:@"\n" atIndex:i*2 - 1];
    }
    return str;
}


/**
 
 *  18从身份证上获取性别
 
 */

-(NSString *)getIdentityCardSex
{
    if ([self isEqualToString:@""]) {
        return @"";
    }
    NSString *sex = @"";
    //获取18位 二代身份证  性别
    if (self.length==18){
        int sexInt=[[self substringWithRange:NSMakeRange(16,1)] intValue];
        if(sexInt%2!=0){
            NSLog(@"1");
            sex = @"男";
        }else{
            NSLog(@"2");
            sex = @"女";
        }
    }
    return sex;
}

/**
 
 *  从身份证上获取性别  15 或者 18
 
 */

-(NSString *)getIdentityCardSex_15Or18

{
    if ([self isEqualToString:@""]) {
        return @"";
    }
    NSString *sex = @"";
    
    //获取18位 二代身份证  性别
    if (self.length==18){
        int sexInt=[[self substringWithRange:NSMakeRange(16,1)] intValue];

        if(sexInt%2!=0){
            
            NSLog(@"1");
            
            sex = @"男";
        }else{
            NSLog(@"2");
            sex = @"女";
        }
    }

    //  获取15位 一代身份证  性别
    if (self.length==15){
        
        int sexInt=[[self substringWithRange:NSMakeRange(14,1)] intValue];
 
        if(sexInt%2!=0){
            NSLog(@"1");
            sex = @"男";

        } else {
            NSLog(@"2");
            sex = @"女";
        }
    }
    return sex;
}


+ (NSString *)arrayToJSONString:(NSArray *)array{
    
    NSError *error = nil;

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (NSString *)dictionaryToJSONString:(NSDictionary *)dictionary
{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

//富文本
- (NSMutableAttributedString *) handleLabelAttribute:(NSString *)title otherTitle:(NSString *)otherTitle color:(UIColor *)color otherColor:(UIColor *)otherColor font:(UIFont*) font otherFont:(UIFont*) otherFont{
    
    NSString *allStr = [NSString stringWithFormat:@"%@%@",title,otherTitle];
    
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]initWithString:allStr];
    
    NSRange leftRange = NSMakeRange([allStr rangeOfString:title].location, [allStr rangeOfString:title].length);
    NSRange rightRange = NSMakeRange([allStr rangeOfString:otherTitle].location, [allStr rangeOfString:otherTitle].length);
    
    [attributeStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0,title.length)];
    [attributeStr addAttribute:NSFontAttributeName value:otherFont range:NSMakeRange(title.length,otherTitle.length)];
    
    [attributeStr addAttribute:NSForegroundColorAttributeName value:color range:leftRange];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:otherColor range:rightRange];
    
//    [attributeStr addAttribute:NSLinkAttributeName value:otherFont range:NSMakeRange(title.length,otherTitle.length)];
    
    return attributeStr;
}

-(NSMutableAttributedString *) handleLabelWithImage:(NSString *)title color:(UIColor *)color font:(UIFont*) font imageName:(NSString *)imgName w:(CGFloat) w h:(CGFloat) h index:(NSInteger) index{
    //创建富文本
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:title];
    
    NSRange range = NSMakeRange([title rangeOfString:title].location, [title rangeOfString:title].length);
    
    [attri addAttribute:NSFontAttributeName value:font range:NSMakeRange(0,title.length)];
    
    [attri addAttribute:NSForegroundColorAttributeName value:color range:range];
    
    //NSTextAttachment可以将要插入的图片作为特殊字符处理
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    //定义图片内容及位置和大小
    attch.image = [UIImage imageNamed:imgName];
    attch.bounds = CGRectMake(0, -1, w, h);
    //创建带有图片的富文本
    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
    //将图片放在最后一位
    //[attri appendAttributedString:string];
    //将图片放在第一位
    [attri insertAttributedString:string atIndex:index];
    //用label的attributedText属性来使用富文本
    
    return attri;
    
}

- (NSString *)handlePriceStatus{
    return [NSString stringWithFormat:@"￥%@",self];
}

@end
