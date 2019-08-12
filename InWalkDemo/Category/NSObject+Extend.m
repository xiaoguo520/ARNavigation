//
//  NSObject+Extend.m
//  New_Patient
//
//  Created by 新开元 iOS on 2018/5/15.
//  Copyright © 2018年 新开元 iOS. All rights reserved.
//

#import "NSObject+Extend.h"
#import <objc/runtime.h>

@implementation NSObject (Extend)

- (NSMutableDictionary*)elementDic{
    NSMutableDictionary *ele = objc_getAssociatedObject(self, @"elementDic");
    if (!ele) {
        ele = [[NSMutableDictionary alloc]init];
        objc_setAssociatedObject(self, @"elementDic", ele, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return ele;
}

- (void)removeElement:(NSString*)key{
    NSMutableDictionary *ele = objc_getAssociatedObject(self, @"elementDic");
    if (!ele) return;
    if (!ele.count) return;
    if (!ele[key]) return;
    [ele removeObjectForKey:key];
    objc_setAssociatedObject(self, @"elementDic", ele, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)removeElement{
    return nil;
}

- (void)setRemoveElement:(NSString*)key{
    NSMutableDictionary *ele = objc_getAssociatedObject(self, @"elementDic");
    [self removeElement:key];
}
- (void)removeAllElement{
    NSMutableDictionary *ele = [[NSMutableDictionary alloc]init];
    objc_setAssociatedObject(self, @"elementDic", ele, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//是否为整型
- (BOOL)isInt{
    NSString *string = [NSString stringWithFormat:@"%@", self];
    if (!string.length) return NO;
    NSScanner *scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

//是否为浮点型
- (BOOL)isFloat{
    NSString *string = [NSString stringWithFormat:@"%@", self];
    if (!string.length) return NO;
    NSScanner *scan = [NSScanner scannerWithString:string];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

//判断是否数组
- (BOOL)isArray{
    if (![self isset] || ![self isKindOfClass:[NSArray class]]) return NO;
    return [((NSArray*)self) count]>0;
}

//判断是否字典
- (BOOL)isDictionary{
    if (![self isset] || ![self isKindOfClass:[NSDictionary class]]) return NO;
    return [((NSDictionary*)self) count]>0;
}

//是否为日期字符串
- (BOOL)isDate{
    if (![self isset]) return NO;
    if ([self isKindOfClass:[NSDate class]]) return YES;
    if ([self isKindOfClass:[NSString class]]) {
        return [(NSString*)self preg_test:@"^\\d{4}-\\d{1,2}-\\d{1,2}( \\d{1,2}:\\d{1,2}:\\d{1,2})?$"];
    }
    return NO;
}

//判断对象是否有内容
- (BOOL)isset{
    if (!self || self==nil || [self isKindOfClass:[NSNull class]]) return NO;
    if ([self isKindOfClass:[NSString class]]) {
        return [(NSString*)self length]>0;
    } else if ([self isKindOfClass:[NSData class]]) {
        return [(NSData*)self length]>0;
    } else if ([self isKindOfClass:[NSArray class]]) {
        return [((NSArray*)self) count]>0;
    } else if ([self isKindOfClass:[NSDictionary class]]) {
        return [((NSDictionary*)self) count]>0;
    }
    return YES;
}

//判断数组是否包含, 包含即返回所在索引, 否则返回NSNotFound
- (NSInteger)inArray:(NSArray*)array{
    NSInteger index = NSNotFound;
    if (!array.isArray) return index;
    if ([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSDictionary class]]) {
        NSString *own = self.jsonString;
        for (int i=0; i<array.count; i++) {
            NSString *item = [array[i] jsonString];
            if ([own isEqualToString:item]) {
                index = i;
                break;
            }
        }
    } else {
        index = [array indexOfObject:self];
    }
    return index;
}

//判断字典是否包含, 包含即返回所在key, 否则返回空字符
- (NSString*)inDictionary:(NSDictionary*)dictionary{
    NSString *keyName = @"";
    if (!dictionary.isDictionary) return keyName;
    if ([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSDictionary class]]) {
        NSString *own = self.jsonString;
        for (NSString *key in dictionary) {
            NSString *item = [dictionary[key] jsonString];
            if ([own isEqualToString:item]) {
                keyName = key;
                break;
            }
        }
    } else {
        for (NSString *key in dictionary) {
            if ([self isEqual:dictionary[key]]) {
                keyName = key;
                break;
            }
        }
    }
    return keyName;
}

////判断数组是否包含元素, 使用模糊查找, 包含即返回所在索引, 否则返回NSNotFound
- (NSInteger)inArraySearch:(NSArray*)array{
    NSInteger index = NSNotFound;
    if (!array.isArray) return index;
    NSString *own = self.jsonString.lowercaseString;
    for (int i=0; i<array.count; i++) {
        NSString *item = [[array[i] jsonString] lowercaseString];
        if ([item indexOf:own]!=NSNotFound) {
            index = i;
            break;
        }
    }
    return index;
}

//判断数组是否包含, 使用内存地址查找, 包含即返回所在索引, 否则返回NSNotFound
- (NSInteger)inArrayRam:(NSArray*)array{
    if (!array.isArray) return NSNotFound;
    return [array indexOfObject:self];
}

//强制转换类型
- (id)changeType:(NSString*)className{
    id obj = nil;
    if (className.length) {
        Class cls = NSClassFromString(className);
        if (cls) {
            if ([self isKindOfClass:cls]) obj = self;
        }
    }
    return obj;
}

- (NSString*)stringValue{
    return (NSString*)[self changeType:@"NSString"];
}
- (NSNumber*)numberValue{
    return (NSNumber*)[self changeType:@"NSNumber"];
}
- (NSData*)dataValue{
    return (NSData*)[self changeType:@"NSData"];
}
- (NSDate*)dateValue{
    return (NSDate*)[self changeType:@"NSDate"];
}
- (NSArray*)arrayValue{
    return (NSArray*)[self changeType:@"NSArray"];
}
- (NSDictionary*)dictionaryValue{
    return (NSDictionary*)[self changeType:@"NSDictionary"];
}

//Json字符串转Dictionary、Array
- (id)jsonValue{
    return [((NSString*)self) formatJson];
}

//Dictionary、Array转Json字符串
- (NSString*)jsonString{
    if (self==nil) return @"";
    if (![self isKindOfClass:[NSArray class]] && ![self isKindOfClass:[NSDictionary class]]) return [NSString stringWithFormat:@"%@", self];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error]; //NSJSONWritingPrettyPrinted
    if (!jsonData || error!=nil) {
        NSLog(@"%@",error);
        return @"";
    } else {
        NSString *str = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        str = [str preg_replace:@"\\s*:\\s*null" with:@":\"\""];
        str = [str preg_replace:@"\\s*:\\s*\\[\\]" with:@":\"\""];
        str = [str preg_replace:@"\\s*:\\s*\\{\\}" with:@":\"\""];
        return str;
    }
}

//NSObject(Model)转NSDictionary, 获取对象的所有属性和属性内容
- (NSDictionary*)getPropertiesAndVaules{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i=0; i<outCount; i++) {
        objc_property_t property = properties[i];
        const char *char_f = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
    }
    free(properties);
    return props;
}
//获取对象的所有属性
- (NSArray*)getProperties{
    u_int count;
    objc_property_t *properties  =class_copyPropertyList([self class], &count);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    for (int i=0; i<count ; i++) {
        const char *propertyName =property_getName(properties[i]);
        [propertiesArray addObject:[NSString stringWithUTF8String:propertyName]];
    }
    free(properties);
    return propertiesArray;
}
//获取对象的所有方法
- (void)getMethods{
    unsigned int mothCout_f =0;
    Method* mothList_f = class_copyMethodList([self class], &mothCout_f);
    for (int i=0;i<mothCout_f;i++) {
        Method temp_f = mothList_f[i];
        //        IMP imp_f = method_getImplementation(temp_f);
        //        SEL name_f = method_getName(temp_f);
        const char *name_s = sel_getName(method_getName(temp_f));
        int arguments = method_getNumberOfArguments(temp_f);
        const char *encoding =method_getTypeEncoding(temp_f);
        NSLog(@"方法名:%@, 参数个数:%d, 编码方式:%@",
              [NSString stringWithUTF8String:name_s],
              arguments,
              [NSString stringWithUTF8String:encoding]);
    }
    free(mothList_f);
}

-(BOOL)isNull{
    if (self == nil ||[self isEqual:[NSNull null]]) {
        return YES;
    }
    return NO;
}

@end
