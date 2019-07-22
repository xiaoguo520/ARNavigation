//
//  StartPositionModel.h
//  ARKitDemoUI
//
//  Created by limu on 2019/1/4.
//  Copyright © 2019年 example. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StartPositionModel : NSObject

@property NSString *name;
@property NSString *detail;
@property NSString *imgName;
@property NSString *keyId;

- (instancetype)initWithName:(NSString *)name detail:(NSString *)detail imgName:(NSString *)imgName key:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
