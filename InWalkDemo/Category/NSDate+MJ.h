//
//  NSDate+MJ.h
//  NetWalking
//
//  Created by apple on 14-8-9.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (MJ)

@property (nonatomic, copy, readonly) NSString * StrFormat;

@property (nonatomic, copy, readonly) NSString * reStrFormat;
/**
 *  是否为今天
 */
- (BOOL)isToday;
/**
 *  是否为昨天
 */
- (BOOL)isYesterday;
/**
 *  是否为今年
 */
- (BOOL)isThisYear;

/**
 *  返回一个只有年月日的时间
 */
- (NSDate *)dateWithYMD;

/**
 *  获得与当前时间的差距
 */
- (NSDateComponents *)deltaWithNow;



/**
 *  获得与两个时间的差距
 */
- (NSDateComponents *)deltaWithDate:(NSDate *)date;

+ (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate;


+ (NSString *)getCurrentTimestamp;

+ (NSString *)getCurrentTimes;

/**
 获取当前时间 年月日

 @return return value description
 */
-(NSString *)getCurrentOnlyYMD;

+ (NSArray *)getMonthFirstAndLastDayWith:(NSDate *)date;

@end
