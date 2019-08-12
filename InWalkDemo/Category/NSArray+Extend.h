//
//  NSArray+Extend.h
//
//  Created by ajsong on 15/12/10.
//  Copyright (c) 2015年 guodeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - NSMutableArray+Extend
@interface NSArray (GlobalExtend)
- (void)each:(void (^)(NSInteger index, id object))object;
- (NSArray*)reverse;
- (NSArray*)merge:(NSArray*)array;
- (NSInteger)hasChild:(id)object;
- (id)safeObjectAtIndex:(NSUInteger)index;
- (id)minValue;
- (id)maxValue;
- (NSInteger)minValueIndex;
- (NSInteger)maxValueIndex;
- (NSString*)join:(NSString*)symbol;
- (NSString*)implode:(NSString*)symbol;
- (NSString*)descriptionASCII;
- (void)UploadToUpyun:(NSString*)upyunFolder each:(void (^)(NSMutableDictionary *json, NSString *imageUrl, NSInteger index))each completion:(void (^)(NSArray *images, NSArray *imageUrls, NSArray *imageNames))completion;
- (NSArray*)UpyunSuffix:(NSString*)suffix;
- (NSArray*)addObject:(id)anObject;
- (NSArray*)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (NSArray*)removeLastObject;
- (NSArray*)removeObjectAtIndex:(NSUInteger)index;
- (NSArray*)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
//数组打乱
- (NSMutableArray*)getRandomArr;
@end



@interface NSMutableArray (GlobalExtend)
- (void)moveIndex:(NSUInteger)from toIndex:(NSUInteger)to;
- (void)each:(void (^)(NSInteger index, id object))object;
- (NSMutableArray*)reverse;
- (NSMutableArray*)merge:(NSArray*)array;
- (NSInteger)hasChild:(id)object;
- (id)minValue;
- (id)maxValue;
- (NSInteger)minValueIndex;
- (NSInteger)maxValueIndex;
- (NSString*)join:(NSString*)symbol;
- (NSString*)implode:(NSString*)symbol;
- (NSString*)descriptionASCII;
- (NSMutableArray*)getList:(NSDictionary*)where;
- (NSMutableDictionary*)getRow:(NSDictionary*)where;
- (NSMutableArray*)getCell:(NSMutableArray*)field where:(NSDictionary*)where;
- (NSInteger)getCount:(NSDictionary*)where;
- (void)insert:(NSDictionary*)data;
- (void)insert:(NSDictionary*)data keepRow:(NSInteger)num;
- (void)insertUserDefaults:(NSString*)key data:(NSDictionary*)data;
- (void)insertUserDefaults:(NSString*)key data:(NSDictionary*)data keepRow:(NSInteger)num;
- (void)update:(NSDictionary*)data where:(NSDictionary*)where;
- (void)updateUserDefaults:(NSString*)key data:(NSDictionary*)data where:(NSDictionary*)where;
- (void)deleteRow:(NSDictionary*)where;
- (void)deleteRowUserDefaults:(NSString*)key where:(NSDictionary*)where;

@end
