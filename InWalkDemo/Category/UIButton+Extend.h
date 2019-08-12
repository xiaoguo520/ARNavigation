//
//  UIButton+Extend.h
//  New_Patient
//
//  Created by 新开元 iOS on 2018/6/20.
//  Copyright © 2018年 新开元 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^JKButtonConuntFinshBlcok)(void);
typedef void(^JKButtonConuntBlcok)(void);

@interface UIButton (Extend)

-(dispatch_source_t)startWithTime:(NSInteger)timeLine title:(NSString *)title countDownTitle:(NSString *)subTitle mainColor:(UIColor *)mColor countColor:(UIColor *)color conuntBlcok:(JKButtonConuntBlcok)conuntBlcok finishBlock:(JKButtonConuntFinshBlcok)finishblock;

-(dispatch_source_t)startGetCodeWithTime:(NSInteger)timeLine title:(NSString *)title countDownTitle:(NSString *)subTitle mainColor:(UIColor *)mColor countColor:(UIColor *)color conuntBlcok:(JKButtonConuntBlcok)conuntBlcok finishBlock:(JKButtonConuntFinshBlcok)finishblock;


-(void)ExchangingPositionLabelAndImage;

@end
