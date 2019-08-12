//
//  NSArray+Extend.m
//
//  Created by ajsong on 15/12/10.
//  Copyright (c) 2015年 guodeng. All rights reserved.
//



#pragma mark - NSMutableArray+Extend
@implementation NSArray (GlobalExtend)
- (void)each:(void (^)(NSInteger index, id object))object{
	if (object==nil) return;
	NSMutableArray *array = [NSMutableArray arrayWithArray:self];
	[array each:object];
}
- (NSArray*)reverse{
	NSMutableArray *newArr = [[NSMutableArray alloc]init];
	for (NSInteger i=self.count-1; i>=0; i--) {
		[newArr addObject:self[i]];
	}
	return [NSArray arrayWithArray:newArr];
}
- (NSArray*)merge:(NSArray*)array{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	for (NSInteger i=0; i<array.count; i++) {
		if ([array[i] inArray:newArr]!=NSNotFound) [newArr addObject:array[i]];
	}
	return [NSArray arrayWithArray:newArr];
}
- (NSInteger)hasChild:(id)object{
	return [object inArray:self];
}
- (id)safeObjectAtIndex:(NSUInteger)index{
    
    if (index >= self.count) {
        return nil;
    }
    
    return [self objectAtIndex:index];
    
}
- (id)minValue{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	return [newArr minValue];
}
- (id)maxValue{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	return [newArr maxValue];
}
- (NSInteger)minValueIndex{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	return [newArr minValueIndex];
}
- (NSInteger)maxValueIndex{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	return [newArr maxValueIndex];
}
- (NSString*)join:(NSString*)symbol{
	return [self implode:symbol];
}
- (NSString*)implode:(NSString*)symbol{
	if (!self.count) return @"";
	return [self componentsJoinedByString:symbol];
}
- (NSString*)descriptionASCII{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	return newArr.descriptionASCII;
}
- (void)UploadToUpyun:(NSString*)upyunFolder each:(void (^)(NSMutableDictionary *json, NSString *imageUrl, NSInteger index))each completion:(void (^)(NSArray *images, NSArray *imageUrls, NSArray *imageNames))completion{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	[newArr UploadToUpyun:upyunFolder each:each completion:completion];
}
- (NSArray*)UpyunSuffix:(NSString*)suffix{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	newArr = [newArr UpyunSuffix:suffix];
	return [NSArray arrayWithArray:newArr];
}
- (NSArray*)addObject:(id)anObject{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	[newArr addObject:anObject];
	return [NSArray arrayWithArray:newArr];
}
- (NSArray*)insertObject:(id)anObject atIndex:(NSUInteger)index{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	[newArr insertObject:anObject atIndex:index];
	return [NSArray arrayWithArray:newArr];
}
- (NSArray*)removeLastObject{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	[newArr removeLastObject];
	return [NSArray arrayWithArray:newArr];
}
- (NSArray*)removeObjectAtIndex:(NSUInteger)index{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	[newArr removeObjectAtIndex:index];
	return [NSArray arrayWithArray:newArr];
}
- (NSArray*)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	[newArr replaceObjectAtIndex:index withObject:anObject];
	return [NSArray arrayWithArray:newArr];
}

-(NSMutableArray*)getRandomArr
{
    if (self.count == 0) {
        return [self mutableCopy];
    }
    NSMutableArray *newArr = [NSMutableArray new];
    while (newArr.count != self.count) {
        //生成随机数
        int x =arc4random() % self.count;
        id obj = self[x];
        if (![newArr containsObject:obj]) {
            [newArr addObject:obj];
        }
    }
    return newArr;
}


@end

@implementation NSMutableArray (GlobalExtend)
//把指定索引移到特定索引
- (void)moveIndex:(NSUInteger)from toIndex:(NSUInteger)to{
	if (to != from) {
		id obj = [self objectAtIndex:from];
		[self removeObjectAtIndex:from];
		if (to >= self.count) {
			[self addObject:obj];
		} else {
			[self insertObject:obj atIndex:to];
		}
	}
}

//执行for循环
- (void)each:(void (^)(NSInteger index, id object))object{
	if (object==nil) return;
	NSInteger i = 0;
	for (id obj in self) {
		object(i, obj);
		i++;
	}
}

//反转数组
- (NSMutableArray*)reverse{
	NSMutableArray *newArr = [[NSMutableArray alloc]init];
	for (NSInteger i=self.count-1; i>=0; i--) {
		[newArr addObject:self[i]];
	}
	return newArr;
}

//合并数组
- (NSMutableArray*)merge:(NSArray*)array{
	for (NSInteger i=0; i<array.count; i++) {
		if ([array[i] inArray:self]!=NSNotFound) [self addObject:array[i]];
	}
	return self;
}

//判断数组是否包含,包含即返回所在索引,否则返回-1
- (NSInteger)hasChild:(id)object{
	return [object inArray:self];
}

//获取最小的子元素(所有子元素类型必须一致，对比大小规则:NSNumber大或小、NSString或NSData的字节数多或少、NSDate前或后、NSArray或NSDictionary的子元素多或少)
- (id)minValue{
	id obj = nil;
	for (NSInteger i=0; i<self.count; i++) {
		if (!obj) {
			obj = self[i];
		} else {
			if ( [self[i] isKindOfClass:[NSNumber class]] ) {
				if ([obj longLongValue] > [self[i] longLongValue]) obj = self[i];
			} else if ( [self[i] isKindOfClass:[NSString class]] || [self[i] isKindOfClass:[NSData class]] ) {
				if ([obj length] > [self[i] length]) obj = self[i];
			} else if ( [self[i] isKindOfClass:[NSDate class]] ) {
				if ([obj isEqualToDate:[obj laterDate:self[i]]]) obj = self[i];
			} else if ( [self[i] isKindOfClass:[NSArray class]] || [self[i] isKindOfClass:[NSDictionary class]] ) {
				if ([obj count] > [self[i] count]) obj = self[i];
			}
		}
	}
	return obj;
}
//获取最大的子元素
- (id)maxValue{
	id obj = nil;
	for (NSInteger i=0; i<self.count; i++) {
		if (!obj) {
			obj = self[i];
		} else {
			if ( [self[i] isKindOfClass:[NSNumber class]] ) {
				if ([obj longLongValue] < [self[i] longLongValue]) obj = self[i];
			} else if ( [self[i] isKindOfClass:[NSString class]] || [self[i] isKindOfClass:[NSData class]] ) {
				if ([obj length] < [self[i] length]) obj = self[i];
			} else if ( [self[i] isKindOfClass:[NSDate class]] ) {
				if ([obj isEqualToDate:[obj earlierDate:self[i]]]) obj = self[i];
			} else if ( [self[i] isKindOfClass:[NSArray class]] || [self[i] isKindOfClass:[NSDictionary class]] ) {
				if ([obj count] < [self[i] count]) obj = self[i];
			}
		}
	}
	return obj;
}

//获取最小的子元素的索引(元素只能是数字类型)
- (NSInteger)minValueIndex{
	id obj = nil;
	NSInteger index = -1;
	for (NSInteger i=0; i<self.count; i++) {
		if (!obj) {
			obj = self[i];
			index = i;
		} else {
			if ( [self[i] isKindOfClass:[NSNumber class]] ) {
				if ([obj longLongValue] > [self[i] longLongValue]) {
					obj = self[i];
					index = i;
				}
			} else if ( [self[i] isKindOfClass:[NSString class]] || [self[i] isKindOfClass:[NSData class]] ) {
				if ([obj length] > [self[i] length]) {
					obj = self[i];
					index = i;
				}
			} else if ( [self[i] isKindOfClass:[NSDate class]] ) {
				if ([obj isEqualToDate:[obj laterDate:self[i]]]) {
					obj = self[i];
					index = i;
				}
			} else if ( [self[i] isKindOfClass:[NSArray class]] || [self[i] isKindOfClass:[NSDictionary class]] ) {
				if ([obj count] > [self[i] count]) {
					obj = self[i];
					index = i;
				}
			}
		}
	}
	return index;
}
//获取最大的子元素的索引
- (NSInteger)maxValueIndex{
	id obj = nil;
	NSInteger index = -1;
	for (NSInteger i=0; i<self.count; i++) {
		if (!obj) {
			obj = self[i];
			index = i;
		} else {
			if ( [self[i] isKindOfClass:[NSNumber class]] ) {
				if ([obj longLongValue] < [self[i] longLongValue]) {
					obj = self[i];
					index = i;
				}
			} else if ( [self[i] isKindOfClass:[NSString class]] || [self[i] isKindOfClass:[NSData class]] ) {
				if ([obj length] < [self[i] length]) {
					obj = self[i];
					index = i;
				}
			} else if ( [self[i] isKindOfClass:[NSDate class]] ) {
				if ([obj isEqualToDate:[obj earlierDate:self[i]]]) {
					obj = self[i];
					index = i;
				}
			} else if ( [self[i] isKindOfClass:[NSArray class]] || [self[i] isKindOfClass:[NSDictionary class]] ) {
				if ([obj count] < [self[i] count]) {
					obj = self[i];
					index = i;
				}
			}
		}
	}
	return index;
}

//数组转字符串
- (NSString*)join:(NSString*)symbol{
	return [self implode:symbol];
}
- (NSString*)implode:(NSString*)symbol{
	if (![self isArray]) return @"";
	return [self componentsJoinedByString:symbol];
}

- (NSString*)descriptionASCII{
	NSMutableString *str = [NSMutableString stringWithString:@"(\n"];
	for (id obj in self) {
		[str appendFormat:@"\t%@,\n", [obj descriptionASCII]];
	}
	[str appendString:@")"];
	return str;
}


//数组模拟数据库操作
- (NSMutableArray*)getList:(NSDictionary*)where{
	if (!self.count) return nil;
	NSMutableArray *list = [[NSMutableArray alloc]init];
	if (where) {
		for (NSDictionary *d in self) {
			BOOL correct = YES;
			for (NSString *key in where) {
				if ( !d[key] || ![d[key] isEqual:where[key]] ) {
					correct = NO;
					break;
				}
			}
			if (correct) [list addObject:d];
		}
	} else {
		list = [NSMutableArray arrayWithArray:self];
	}
	return list;
}

- (NSMutableDictionary*)getRow:(NSDictionary*)where{
	if (!self.count) return nil;
	NSMutableDictionary *row = [[NSMutableDictionary alloc]init];
	if (where) {
		for (NSDictionary *d in self) {
			BOOL correct = YES;
			for (NSString *key in where) {
				if ( ![d[key] isset] || ![d[key] isEqual:where[key]] ) {
					correct = NO;
					break;
				}
			}
			if (correct) {
				row = [NSMutableDictionary dictionaryWithDictionary:d];
				break;
			}
		}
	} else {
		row = [NSMutableDictionary dictionaryWithDictionary:self[0]];
	}
	return row;
}

- (NSMutableArray*)getCell:(NSMutableArray*)field where:(NSDictionary*)where{
	if (!self.count) return nil;
	NSMutableArray *list = [[NSMutableArray alloc]init];
	for (NSDictionary *d in self) {
		BOOL correct = YES;
		for (NSString *key in where) {
			if ( ![d[key] isset] || ![d[key] isEqual:where[key]] ) {
				correct = NO;
				break;
			}
		}
		if (correct) {
			for (NSString *key in field) {
				if ( [d[key] isset] ) [list addObject:d[key]];
			}
		}
	}
	return list;
}

- (NSInteger)getCount:(NSDictionary*)where{
	if (!self.count) return 0;
	NSMutableArray *list = [[NSMutableArray alloc]init];
	if (where) {
		for (NSDictionary *d in self) {
			BOOL correct = YES;
			for (NSString *key in where) {
				if ( ![d[key] isset] || ![d[key] isEqual:where[key]] ) {
					correct = NO;
					break;
				}
			}
			if (correct) [list addObject:d];
		}
	}
	return list.count;
}

- (void)insert:(NSDictionary*)data{
	[self insert:data keepRow:0];
}
- (void)insert:(NSDictionary*)data keepRow:(NSInteger)num{
	[self addObject:data];
	if (num>0 && self.count>num) [self removeObjectsInRange:NSMakeRange(0, self.count - num)];
}
- (void)insertUserDefaults:(NSString*)key data:(NSDictionary*)data{
	[self insertUserDefaults:key data:data keepRow:0];
}
- (void)insertUserDefaults:(NSString*)key data:(NSDictionary*)data keepRow:(NSInteger)num{
	[self insert:data keepRow:num];
	[key setUserDefaultsWithData:self];
}

- (void)update:(NSDictionary*)data where:(NSDictionary*)where{
	if (!self.count) return;
	if (where) {
		for (int i=0; i<self.count; i++) {
			BOOL correct = YES;
			NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:self[i]];
			for (NSString *key in where) {
				if ( ![d[key] isset] || ![d[key] isEqual:where[key]] ) {
					correct = NO;
					break;
				}
			}
			if (correct) {
				for (NSString *key in data) {
					[d setObject:data[key] forKey:key];
				}
				[self replaceObjectAtIndex:i withObject:d];
			}
		}
	} else {
		for (int i=0; i<self.count; i++) {
			NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:self[i]];
			for (NSString *key in data) {
				if ( [d[key] isset] ) [d setObject:data[key] forKey:key];
			}
			[self replaceObjectAtIndex:i withObject:d];
		}
	}
}
- (void)updateUserDefaults:(NSString*)key data:(NSDictionary*)data where:(NSDictionary*)where{
	[self update:data where:where];
	[key setUserDefaultsWithData:self];
}

- (void)deleteRow:(NSDictionary*)where{
	if (!self.count) return;
	if (where) {
		for (int i=0; i<self.count; i++) {
			BOOL correct = YES;
			NSDictionary *d = [NSDictionary dictionaryWithDictionary:self[i]];
			for (NSString *key in where) {
				if ( ![d[key] isset] || ![d[key] isEqual:where[key]] ) {
					correct = NO;
					break;
				}
			}
			if (correct) [self removeObject:d];
		}
	} else {
		[self removeAllObjects];
	}
}
- (void)deleteRowUserDefaults:(NSString*)key where:(NSDictionary*)where{
	[self deleteRow:where];
	[key setUserDefaultsWithData:self];
}





@end
