//
//  NSObject+Extend.h
//  New_Patient
//
//  Created by 新开元 iOS on 2018/5/15.
//  Copyright © 2018年 新开元 iOS. All rights reserved.
//  NSObject 分类

#import <Foundation/Foundation.h>

@interface NSObject (Extend)
- (NSMutableDictionary*)elementDic;
- (void)removeElement:(NSString*)key;
- (NSString*)removeElement;
- (void)setRemoveElement:(NSString*)key;
- (void)removeAllElement;
- (BOOL)isInt;
- (BOOL)isFloat;
- (BOOL)isArray;
- (BOOL)isDictionary;
- (BOOL)isDate;
- (BOOL)isset;
- (BOOL)isNull;
- (NSInteger)inArray:(NSArray*)array;
- (NSString*)inDictionary:(NSDictionary*)dictionary;
- (NSInteger)inArraySearch:(NSArray*)array;
- (id)changeType:(NSString*)className;
- (NSString*)stringValue;
- (NSNumber*)numberValue;
- (NSData*)dataValue;
- (NSDate*)dateValue;
- (NSArray*)arrayValue;
- (NSDictionary*)dictionaryValue;
- (id)jsonValue;
- (NSString*)jsonString;
- (NSDictionary*)getPropertiesAndVaules;
- (NSArray*)getProperties;
- (void)getMethods;


@end
