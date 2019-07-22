//
//  Global.h
//  InWalkDemo
//
//  Created by limu on 2019/4/20.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Global : NSObject

@property(nonatomic, strong) NSString *val;
//@property(nonatomic, strong) NSArray<NSString *> *idList;
@property(nonatomic, strong) NSDictionary<NSString *, NSObject *> *projectList;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
