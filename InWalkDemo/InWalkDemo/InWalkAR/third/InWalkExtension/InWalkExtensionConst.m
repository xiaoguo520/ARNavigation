#ifndef __inWalkExtensionConst__M__
#define __inWalkExtensionConst__M__

#import <Foundation/Foundation.h>

/**
 *  成员变量类型（属性类型）
 */
NSString *const inWalkPropertyTypeInt = @"i";
NSString *const inWalkPropertyTypeShort = @"s";
NSString *const inWalkPropertyTypeFloat = @"f";
NSString *const inWalkPropertyTypeDouble = @"d";
NSString *const inWalkPropertyTypeLong = @"l";
NSString *const inWalkPropertyTypeLongLong = @"q";
NSString *const inWalkPropertyTypeChar = @"c";
NSString *const inWalkPropertyTypeBOOL1 = @"c";
NSString *const inWalkPropertyTypeBOOL2 = @"b";
NSString *const inWalkPropertyTypePointer = @"*";

NSString *const inWalkPropertyTypeIvar = @"^{objc_ivar=}";
NSString *const inWalkPropertyTypeMethod = @"^{objc_method=}";
NSString *const inWalkPropertyTypeBlock = @"@?";
NSString *const inWalkPropertyTypeClass = @"#";
NSString *const inWalkPropertyTypeSEL = @":";
NSString *const inWalkPropertyTypeId = @"@";

#endif
