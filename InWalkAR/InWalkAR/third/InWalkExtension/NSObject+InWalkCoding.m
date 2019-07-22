//
//  NSObject+InWalkCoding.m
//  inWalkExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import "NSObject+InWalkCoding.h"
#import "NSObject+InWalkClass.h"
#import "NSObject+InWalkProperty.h"
#import "InWalkProperty.h"

@implementation NSObject (inWalkCoding)

- (void)inWalk_encode:(NSCoder *)encoder
{
    Class clazz = [self class];
    
    NSArray *allowedCodingPropertyNames = [clazz inWalk_totalAllowedCodingPropertyNames];
    NSArray *ignoredCodingPropertyNames = [clazz inWalk_totalIgnoredCodingPropertyNames];
    
    [clazz inWalk_enumerateProperties:^(InWalkProperty *property, BOOL *stop) {
        // 检测是否被忽略
        if (allowedCodingPropertyNames.count && ![allowedCodingPropertyNames containsObject:property.name]) return;
        if ([ignoredCodingPropertyNames containsObject:property.name]) return;
        
        id value = [property valueForObject:self];
        if (value == nil) return;
        [encoder encodeObject:value forKey:property.name];
    }];
}

- (void)inWalk_decode:(NSCoder *)decoder
{
    Class clazz = [self class];
    
    NSArray *allowedCodingPropertyNames = [clazz inWalk_totalAllowedCodingPropertyNames];
    NSArray *ignoredCodingPropertyNames = [clazz inWalk_totalIgnoredCodingPropertyNames];
    
    [clazz inWalk_enumerateProperties:^(InWalkProperty *property, BOOL *stop) {
        // 检测是否被忽略
        if (allowedCodingPropertyNames.count && ![allowedCodingPropertyNames containsObject:property.name]) return;
        if ([ignoredCodingPropertyNames containsObject:property.name]) return;
        
        id value = [decoder decodeObjectForKey:property.name];
        if (value == nil) { // 兼容以前的inWalkExtension版本
            value = [decoder decodeObjectForKey:[@"_" stringByAppendingString:property.name]];
        }
        if (value == nil) return;
        [property setValue:value forObject:self];
    }];
}
@end
