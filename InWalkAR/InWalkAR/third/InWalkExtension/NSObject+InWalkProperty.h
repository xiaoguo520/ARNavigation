//
//  NSObject+InWalkProperty.h
//  inWalkExtensionExample
//
//  Created by inWalk Lee on 15/4/17.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InWalkExtensionConst.h"

@class InWalkProperty;

/**
 *  遍历成员变量用的block
 *
 *  @param property 成员的包装对象
 *  @param stop   YES代表停止遍历，NO代表继续遍历
 */
typedef void (^inWalkPropertiesEnumeration)(InWalkProperty *property, BOOL *stop);

/** 将属性名换为其他key去字典中取值 */
typedef NSDictionary * (^inWalkReplacedKeyFromPropertyName)(void);
typedef id (^inWalkReplacedKeyFromPropertyName121)(NSString *propertyName);
/** 数组中需要转换的模型类 */
typedef NSDictionary * (^inWalkObjectClassInArray)(void);
/** 用于过滤字典中的值 */
typedef id (^inWalkNewValueFromOldValue)(id object, id oldValue, InWalkProperty *property);

/**
 * 成员属性相关的扩展
 */
@interface NSObject (InWalkProperty)
#pragma mark - 遍历
/**
 *  遍历所有的成员
 */
+ (void)inWalk_enumerateProperties:(inWalkPropertiesEnumeration)enumeration;

#pragma mark - 新值配置
/**
 *  用于过滤字典中的值
 *
 *  @param newValueFormOldValue 用于过滤字典中的值
 */
+ (void)inWalk_setupNewValueFromOldValue:(inWalkNewValueFromOldValue)newValueFormOldValue;
+ (id)inWalk_getNewValueFromObject:(__unsafe_unretained id)object oldValue:(__unsafe_unretained id)oldValue property:(__unsafe_unretained InWalkProperty *)property;

#pragma mark - key配置
/**
 *  将属性名换为其他key去字典中取值
 *
 *  @param replacedKeyFromPropertyName 将属性名换为其他key去字典中取值
 */
+ (void)inWalk_setupReplacedKeyFromPropertyName:(inWalkReplacedKeyFromPropertyName)replacedKeyFromPropertyName;
/**
 *  将属性名换为其他key去字典中取值
 *
 *  @param replacedKeyFromPropertyName121 将属性名换为其他key去字典中取值
 */
+ (void)inWalk_setupReplacedKeyFromPropertyName121:(inWalkReplacedKeyFromPropertyName121)replacedKeyFromPropertyName121;

#pragma mark - array model class配置
/**
 *  数组中需要转换的模型类
 *
 *  @param objectClassInArray          数组中需要转换的模型类
 */
+ (void)inWalk_setupObjectClassInArray:(inWalkObjectClassInArray)objectClassInArray;
@end

