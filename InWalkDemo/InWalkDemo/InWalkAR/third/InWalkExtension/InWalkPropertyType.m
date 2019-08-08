//
//  inWalkPropertyType.m
//  inWalkExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import "InWalkPropertyType.h"
#import "InWalkExtension.h"
#import "InWalkFoundation.h"
#import "InWalkExtensionConst.h"

@implementation InWalkPropertyType

+ (instancetype)cachedTypeWithCode:(NSString *)code
{
    inWalkExtensionAssertParamNotNil2(code, nil);
    
    static NSMutableDictionary *types;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        types = [NSMutableDictionary dictionary];
    });
    
    inWalkExtensionSemaphoreCreate
    inWalkExtensionSemaphoreWait
    InWalkPropertyType *type = types[code];
    if (type == nil) {
        type = [[self alloc] init];
        type.code = code;
        types[code] = type;
    }
    inWalkExtensionSemaphoreSignal
    return type;
}

#pragma mark - 公共方法
- (void)setCode:(NSString *)code
{
    _code = code;
    
    inWalkExtensionAssertParamNotNil(code);
    
    if ([code isEqualToString:inWalkPropertyTypeId]) {
        _idType = YES;
    } else if (code.length == 0) {
        _KVCDisabled = YES;
    } else if (code.length > 3 && [code hasPrefix:@"@\""]) {
        // 去掉@"和"，截取中间的类型名称
        _code = [code substringWithRange:NSMakeRange(2, code.length - 3)];
        _typeClass = NSClassFromString(_code);
        _fromFoundation = [inWalkFoundation isClassFromFoundation:_typeClass];
        _numberType = [_typeClass isSubclassOfClass:[NSNumber class]];
        
    } else if ([code isEqualToString:inWalkPropertyTypeSEL] ||
               [code isEqualToString:inWalkPropertyTypeIvar] ||
               [code isEqualToString:inWalkPropertyTypeMethod]) {
        _KVCDisabled = YES;
    }
    
    // 是否为数字类型
    NSString *lowerCode = _code.lowercaseString;
    NSArray *numberTypes = @[inWalkPropertyTypeInt, inWalkPropertyTypeShort, inWalkPropertyTypeBOOL1, inWalkPropertyTypeBOOL2, inWalkPropertyTypeFloat, inWalkPropertyTypeDouble, inWalkPropertyTypeLong, inWalkPropertyTypeLongLong, inWalkPropertyTypeChar];
    if ([numberTypes containsObject:lowerCode]) {
        _numberType = YES;
        
        if ([lowerCode isEqualToString:inWalkPropertyTypeBOOL1]
            || [lowerCode isEqualToString:inWalkPropertyTypeBOOL2]) {
            _boolType = YES;
        }
    }
}
@end
