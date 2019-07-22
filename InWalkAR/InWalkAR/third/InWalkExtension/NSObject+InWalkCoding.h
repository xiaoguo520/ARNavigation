//
//  NSObject+InWalkCoding.h
//  inWalkExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InWalkExtensionConst.h"

/**
 *  Codeing协议
 */
@protocol inWalkCoding <NSObject>
@optional
/**
 *  这个数组中的属性名才会进行归档
 */
+ (NSArray *)inWalk_allowedCodingPropertyNames;
/**
 *  这个数组中的属性名将会被忽略：不进行归档
 */
+ (NSArray *)inWalk_ignoredCodingPropertyNames;
@end

@interface NSObject (inWalkCoding) <inWalkCoding>
/**
 *  解码（从文件中解析对象）
 */
- (void)inWalk_decode:(NSCoder *)decoder;
/**
 *  编码（将对象写入文件中）
 */
- (void)inWalk_encode:(NSCoder *)encoder;
@end

/**
 归档的实现
 */
#define inWalkCodingImplementation \
- (id)initWithCoder:(NSCoder *)decoder \
{ \
if (self = [super init]) { \
[self inWalk_decode:decoder]; \
} \
return self; \
} \
\
- (void)encodeWithCoder:(NSCoder *)encoder \
{ \
[self inWalk_encode:encoder]; \
}

#define inWalkExtensionCodingImplementation inWalkCodingImplementation
