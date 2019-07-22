//
//  NSObject+InWalkClass.m
//  inWalkExtensionExample
//
//  Created by inWalk Lee on 15/8/11.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "NSObject+InWalkClass.h"
#import "NSObject+InWalkCoding.h"
#import "NSObject+InWalkKeyValue.h"
#import "InWalkFoundation.h"
#import <objc/runtime.h>

static const char inWalkAllowedPropertyNamesKey = '\0';
static const char inWalkIgnoredPropertyNamesKey = '\0';
static const char inWalkAllowedCodingPropertyNamesKey = '\0';
static const char inWalkIgnoredCodingPropertyNamesKey = '\0';

@implementation NSObject (InWalkClass)

+ (NSMutableDictionary *)classDictForKey:(const void *)key
{
    static NSMutableDictionary *allowedPropertyNamesDict;
    static NSMutableDictionary *ignoredPropertyNamesDict;
    static NSMutableDictionary *allowedCodingPropertyNamesDict;
    static NSMutableDictionary *ignoredCodingPropertyNamesDict;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allowedPropertyNamesDict = [NSMutableDictionary dictionary];
        ignoredPropertyNamesDict = [NSMutableDictionary dictionary];
        allowedCodingPropertyNamesDict = [NSMutableDictionary dictionary];
        ignoredCodingPropertyNamesDict = [NSMutableDictionary dictionary];
    });
    
    if (key == &inWalkAllowedPropertyNamesKey) return allowedPropertyNamesDict;
    if (key == &inWalkIgnoredPropertyNamesKey) return ignoredPropertyNamesDict;
    if (key == &inWalkAllowedCodingPropertyNamesKey) return allowedCodingPropertyNamesDict;
    if (key == &inWalkIgnoredCodingPropertyNamesKey) return ignoredCodingPropertyNamesDict;
    return nil;
}

+ (void)inWalk_enumerateClasses:(InWalkClassesEnumeration)enumeration
{
    // 1.没有block就直接返回
    if (enumeration == nil) return;
    
    // 2.停止遍历的标记
    BOOL stop = NO;
    
    // 3.当前正在遍历的类
    Class c = self;
    
    // 4.开始遍历每一个类
    while (c && !stop) {
        // 4.1.执行操作
        enumeration(c, &stop);
        
        // 4.2.获得父类
        c = class_getSuperclass(c);
        
        if ([inWalkFoundation isClassFromFoundation:c]) break;
    }
}

+ (void)inWalk_enumerateAllClasses:(InWalkClassesEnumeration)enumeration
{
    // 1.没有block就直接返回
    if (enumeration == nil) return;
    
    // 2.停止遍历的标记
    BOOL stop = NO;
    
    // 3.当前正在遍历的类
    Class c = self;
    
    // 4.开始遍历每一个类
    while (c && !stop) {
        // 4.1.执行操作
        enumeration(c, &stop);
        
        // 4.2.获得父类
        c = class_getSuperclass(c);
    }
}

#pragma mark - 属性黑名单配置
+ (void)inWalk_setupIgnoredPropertyNames:(InWalkIgnoredPropertyNames)ignoredPropertyNames
{
    [self inWalk_setupBlockReturnValue:ignoredPropertyNames key:&inWalkIgnoredPropertyNamesKey];
}

+ (NSMutableArray *)inWalk_totalIgnoredPropertyNames
{
    return [self inWalk_totalObjectsWithSelector:@selector(inWalk_ignoredPropertyNames) key:&inWalkIgnoredPropertyNamesKey];
}

#pragma mark - 归档属性黑名单配置
+ (void)inWalk_setupIgnoredCodingPropertyNames:(InWalkIgnoredCodingPropertyNames)ignoredCodingPropertyNames
{
    [self inWalk_setupBlockReturnValue:ignoredCodingPropertyNames key:&inWalkIgnoredCodingPropertyNamesKey];
}

+ (NSMutableArray *)inWalk_totalIgnoredCodingPropertyNames
{
    return [self inWalk_totalObjectsWithSelector:@selector(inWalk_ignoredCodingPropertyNames) key:&inWalkIgnoredCodingPropertyNamesKey];
}

#pragma mark - 属性白名单配置
+ (void)inWalk_setupAllowedPropertyNames:(InWalkAllowedPropertyNames)allowedPropertyNames;
{
    [self inWalk_setupBlockReturnValue:allowedPropertyNames key:&inWalkAllowedPropertyNamesKey];
}

+ (NSMutableArray *)inWalk_totalAllowedPropertyNames
{
    return [self inWalk_totalObjectsWithSelector:@selector(inWalk_allowedPropertyNames) key:&inWalkAllowedPropertyNamesKey];
}

#pragma mark - 归档属性白名单配置
+ (void)inWalk_setupAllowedCodingPropertyNames:(InWalkAllowedCodingPropertyNames)allowedCodingPropertyNames
{
    [self inWalk_setupBlockReturnValue:allowedCodingPropertyNames key:&inWalkAllowedCodingPropertyNamesKey];
}

+ (NSMutableArray *)inWalk_totalAllowedCodingPropertyNames
{
    return [self inWalk_totalObjectsWithSelector:@selector(inWalk_allowedCodingPropertyNames) key:&inWalkAllowedCodingPropertyNamesKey];
}

#pragma mark - block和方法处理:存储block的返回值
+ (void)inWalk_setupBlockReturnValue:(id (^)(void))block key:(const char *)key
{
    if (block) {
        objc_setAssociatedObject(self, key, block(), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(self, key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    // 清空数据
    [[self classDictForKey:key] removeAllObjects];
}

+ (NSMutableArray *)inWalk_totalObjectsWithSelector:(SEL)selector key:(const char *)key
{
    inWalkExtensionSemaphoreCreate
    inWalkExtensionSemaphoreWait
    
    NSMutableArray *array = [self classDictForKey:key][NSStringFromClass(self)];
    if (array == nil) {
        // 创建、存储
        [self classDictForKey:key][NSStringFromClass(self)] = array = [NSMutableArray array];
        
        if ([self respondsToSelector:selector]) {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            NSArray *subArray = [self performSelector:selector];
    #pragma clang diagnostic pop
            if (subArray) {
                [array addObjectsFromArray:subArray];
            }
        }
        
        [self inWalk_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            NSArray *subArray = objc_getAssociatedObject(c, key);
            [array addObjectsFromArray:subArray];
        }];
    }
    
    inWalkExtensionSemaphoreSignal
    
    return array;
}
@end
