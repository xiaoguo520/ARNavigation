
#ifndef __inWalkExtensionConst__H__
#define __inWalkExtensionConst__H__

#import <Foundation/Foundation.h>

// 信号量
#define inWalkExtensionSemaphoreCreate \
static dispatch_semaphore_t signalSemaphore; \
static dispatch_once_t onceTokenSemaphore; \
dispatch_once(&onceTokenSemaphore, ^{ \
    signalSemaphore = dispatch_semaphore_create(1); \
});

#define inWalkExtensionSemaphoreWait \
dispatch_semaphore_wait(signalSemaphore, DISPATCH_TIME_FOREVER);

#define inWalkExtensionSemaphoreSignal \
dispatch_semaphore_signal(signalSemaphore);


// 构建错误
#define inWalkExtensionBuildError(clazz, msg) \
NSError *error = [NSError errorWithDomain:msg code:250 userInfo:nil]; \
[clazz setMj_error:error];

// 日志输出
#ifdef DEBUG
#define inWalkExtensionLog(...) //NSLog(__VA_ARGS__)
#else
#define inWalkExtensionLog(...)
#endif

/**
 * 断言
 * @param condition   条件
 * @param returnValue 返回值
 */
#define inWalkExtensionAssertError(condition, returnValue, clazz, msg) \
[clazz setMj_error:nil]; \
if ((condition) == NO) { \
    inWalkExtensionBuildError(clazz, msg); \
    return returnValue;\
}

#define inWalkExtensionAssert2(condition, returnValue) \
if ((condition) == NO) return returnValue;

/**
 * 断言
 * @param condition   条件
 */
#define inWalkExtensionAssert(condition) inWalkExtensionAssert2(condition, )

/**
 * 断言
 * @param param         参数
 * @param returnValue   返回值
 */
#define inWalkExtensionAssertParamNotNil2(param, returnValue) \
inWalkExtensionAssert2((param) != nil, returnValue)

/**
 * 断言
 * @param param   参数
 */
#define inWalkExtensionAssertParamNotNil(param) inWalkExtensionAssertParamNotNil2(param, )

/**
 * 打印所有的属性
 */
#define inWalkLogAllIvars \
-(NSString *)description \
{ \
    return [self inWalk_keyValues].description; \
}
#define inWalkExtensionLogAllProperties inWalkLogAllIvars

/**
 *  类型（属性类型）
 */
extern NSString *const inWalkPropertyTypeInt;
extern NSString *const inWalkPropertyTypeShort;
extern NSString *const inWalkPropertyTypeFloat;
extern NSString *const inWalkPropertyTypeDouble;
extern NSString *const inWalkPropertyTypeLong;
extern NSString *const inWalkPropertyTypeLongLong;
extern NSString *const inWalkPropertyTypeChar;
extern NSString *const inWalkPropertyTypeBOOL1;
extern NSString *const inWalkPropertyTypeBOOL2;
extern NSString *const inWalkPropertyTypePointer;

extern NSString *const inWalkPropertyTypeIvar;
extern NSString *const inWalkPropertyTypeMethod;
extern NSString *const inWalkPropertyTypeBlock;
extern NSString *const inWalkPropertyTypeClass;
extern NSString *const inWalkPropertyTypeSEL;
extern NSString *const inWalkPropertyTypeId;

#endif
