//
//  LocateResultUI.h
//  ARKitDemoUI
//
//  Created by limu on 2019/1/2.
//  Copyright © 2019年 example. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LocateResultDelegate
@required // list of required methods
@optional // list of optional methods
- (void)onConfirmLocation;
@end

@interface LocateResultUI : NSObject
@property (nonatomic, retain) id<LocateResultDelegate> delegate;

- (void)setSuperView:(UIView *)view;
//- (void)setDesc:(NSString *)desc tip:(NSString *)tip items:(NSArray<NSString *> *)items;
- (void)showDesc:(NSString *)desc tip:(NSString *)tip items:(NSArray<NSString *> *)items;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
