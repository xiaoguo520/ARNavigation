//
//  NSObject+InWalkProperty.m
//  inWalkExtensionExample
//
//  Created by inWalk Lee on 15/4/17.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "NSObject+InWalkProperty.h"
#import "NSObject+InWalkKeyValue.h"
#import "NSObject+InWalkCoding.h"
#import "NSObject+InWalkClass.h"
#import "InWalkProperty.h"
#import "InWalkFoundation.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

static const char inWalkReplacedKeyFromPropertyNameKey = '\0';
static const char inWalkReplacedKeyFromPropertyName121Key = '\0';
static const char inWalkNewValueFromOldValueKey = '\0';
static const char inWalkObjectClassInArrayKey = '\0';

static const char inWalkCachedPropertiesKey = '\0';

@implementation NSObject (Property)

+ (NSMutableDictionary *)propertyDictForKey:(const void *)key
{
    static NSMutableDictionary *replacedKeyFromPropertyNameDict;
    static NSMutableDictionary *replacedKeyFromPropertyName121Dict;
    static NSMutableDictionary *newValueFromOldValueDict;
    static NSMutableDictionary *objectClassInArrayDict;
    static NSMutableDictionary *cachedPropertiesDict;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        replacedKeyFromPropertyNameDict = [NSMutableDictionary dictionary];
        replacedKeyFromPropertyName121Dict = [NSMutableDictionary dictionary];
        newValueFromOldValueDict = [NSMutableDictionary dictionary];
        objectClassInArrayDict = [NSMutableDictionary dictionary];
        cachedPropertiesDict = [NSMutableDictionary dictionary];
    });
    
    if (key == &inWalkReplacedKeyFromPropertyNameKey) return replacedKeyFromPropertyNameDict;
    if (key == &inWalkReplacedKeyFromPropertyName121Key) return replacedKeyFromPropertyName121Dict;
    if (key == &inWalkNewValueFromOldValueKey) return newValueFromOldValueDict;
    if (key == &inWalkObjectClassInArrayKey) return objectClassInArrayDict;
    if (key == &inWalkCachedPropertiesKey) return cachedPropertiesDict;
    return nil;
}

#pragma mark - --私有方法--
+ (id)propertyKey:(NSString *)propertyName
{
    inWalkExtensionAssertParamNotNil2(propertyName, nil);
    
    __block id key = nil;
    // 查看有没有需要替换的key
    if ([self respondsToSelector:@selector(inWalk_replacedKeyFromPropertyName121:)]) {
        key = [self inWalk_replacedKeyFromPropertyName121:propertyName];
    }
    // 兼容旧版本
    if ([self respondsToSelector:@selector(replacedKeyFromPropertyName121:)]) {
        key = [self performSelector:@selector(replacedKeyFromPropertyName121) withObject:propertyName];
    }
    
    // 调用block
    if (!key) {
        [self inWalk_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            inWalkReplacedKeyFromPropertyName121 block = objc_getAssociatedObject(c, &inWalkReplacedKeyFromPropertyName121Key);
            if (block) {
                key = block(propertyName);
            }
            if (key) *stop = YES;
        }];
    }
    
    // 查看有没有需要替换的key
    if ((!key || [key isEqual:propertyName]) && [self respondsToSelector:@selector(inWalk_replacedKeyFromPropertyName)]) {
        key = [self inWalk_replacedKeyFromPropertyName][propertyName];
    }
    // 兼容旧版本
    if ((!key || [key isEqual:propertyName]) && [self respondsToSelector:@selector(replacedKeyFromPropertyName)]) {
        key = [self performSelector:@selector(replacedKeyFromPropertyName)][propertyName];
    }
    
    if (!key || [key isEqual:propertyName]) {
        [self inWalk_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            NSDictionary *dict = objc_getAssociatedObject(c, &inWalkReplacedKeyFromPropertyNameKey);
            if (dict) {
                key = dict[propertyName];
            }
            if (key && ![key isEqual:propertyName]) *stop = YES;
        }];
    }
    
    // 2.用属性名作为key
    if (!key) key = propertyName;
    
    return key;
}

+ (Class)propertyObjectClassInArray:(NSString *)propertyName
{
    __block id clazz = nil;
    if ([self respondsToSelector:@selector(inWalk_objectClassInArray)]) {
        clazz = [self inWalk_objectClassInArray][propertyName];
    }
    // 兼容旧版本
    if ([self respondsToSelector:@selector(objectClassInArray)]) {
        clazz = [self performSelector:@selector(objectClassInArray)][propertyName];
    }
    
    if (!clazz) {
        [self inWalk_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            NSDictionary *dict = objc_getAssociatedObject(c, &inWalkObjectClassInArrayKey);
            if (dict) {
                clazz = dict[propertyName];
            }
            if (clazz) *stop = YES;
        }];
    }
    
    // 如果是NSString类型
    if ([clazz isKindOfClass:[NSString class]]) {
        clazz = NSClassFromString(clazz);
    }
    return clazz;
}

#pragma mark - --公共方法--
+ (void)inWalk_enumerateProperties:(inWalkPropertiesEnumeration)enumeration
{
    // 获得成员变量
    NSArray *cachedProperties = [self properties];
    
    // 遍历成员变量
    BOOL stop = NO;
    for (InWalkProperty *property in cachedProperties) {
        enumeration(property, &stop);
        if (stop) break;
    }
}

#pragma mark - 公共方法
+ (NSMutableArray *)properties
{
    NSMutableArray *cachedProperties = [self propertyDictForKey:&inWalkCachedPropertiesKey][NSStringFromClass(self)];
    
    if (cachedProperties == nil) {
        cachedProperties = [NSMutableArray array];
        
        [self inWalk_enumerateClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            // 1.获得所有的成员变量
            unsigned int outCount = 0;
            objc_property_t *properties = class_copyPropertyList(c, &outCount);
            
            // 2.遍历每一个成员变量
            for (unsigned int i = 0; i<outCount; i++) {
                InWalkProperty *property = [InWalkProperty cachedPropertyWithProperty:properties[i]];
                // 过滤掉Foundation框架类里面的属性
                if ([inWalkFoundation isClassFromFoundation:property.srcClass]) continue;
                property.srcClass = c;
                [property setOriginKey:[self propertyKey:property.name] forClass:self];
                [property setObjectClassInArray:[self propertyObjectClassInArray:property.name] forClass:self];
                [cachedProperties addObject:property];
            }
            
            // 3.释放内存
            free(properties);
        }];
        
        [self propertyDictForKey:&inWalkCachedPropertiesKey][NSStringFromClass(self)] = cachedProperties;
    }
    
    return cachedProperties;
}

#pragma mark - 新值配置
+ (void)inWalk_setupNewValueFromOldValue:(inWalkNewValueFromOldValue)newValueFormOldValue
{
    objc_setAssociatedObject(self, &inWalkNewValueFromOldValueKey, newValueFormOldValue, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (id)inWalk_getNewValueFromObject:(__unsafe_unretained id)object oldValue:(__unsafe_unretained id)oldValue property:(InWalkProperty *__unsafe_unretained)property{
    // 如果有实现方法
    if ([object respondsToSelector:@selector(inWalk_newValueFromOldValue:property:)]) {
        return [object inWalk_newValueFromOldValue:oldValue property:property];
    }
    // 兼容旧版本
    if ([self respondsToSelector:@selector(newValueFromOldValue:property:)]) {
        return [self performSelector:@selector(newValueFromOldValue:property:)  withObject:oldValue  withObject:property];
    }
    
    // 查看静态设置
    __block id newValue = oldValue;
    [self inWalk_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
        inWalkNewValueFromOldValue block = objc_getAssociatedObject(c, &inWalkNewValueFromOldValueKey);
        if (block) {
            newValue = block(object, oldValue, property);
            *stop = YES;
        }
    }];
    return newValue;
}

#pragma mark - array model class配置
+ (void)inWalk_setupObjectClassInArray:(inWalkObjectClassInArray)objectClassInArray
{
    [self inWalk_setupBlockReturnValue:objectClassInArray key:&inWalkObjectClassInArrayKey];
    
    [[self propertyDictForKey:&inWalkCachedPropertiesKey] removeAllObjects];
}

#pragma mark - key配置
+ (void)inWalk_setupReplacedKeyFromPropertyName:(inWalkReplacedKeyFromPropertyName)replacedKeyFromPropertyName
{
    [self inWalk_setupBlockReturnValue:replacedKeyFromPropertyName key:&inWalkReplacedKeyFromPropertyNameKey];
    
    [[self propertyDictForKey:&inWalkCachedPropertiesKey] removeAllObjects];
}

+ (void)inWalk_setupReplacedKeyFromPropertyName121:(inWalkReplacedKeyFromPropertyName121)replacedKeyFromPropertyName121
{
    objc_setAssociatedObject(self, &inWalkReplacedKeyFromPropertyName121Key, replacedKeyFromPropertyName121, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [[self propertyDictForKey:&inWalkCachedPropertiesKey] removeAllObjects];
}
@end
#pragma clang diagnostic pop
