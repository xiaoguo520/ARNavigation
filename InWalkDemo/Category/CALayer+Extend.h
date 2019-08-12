//
//  CALayer+Extend.h
//  New_Patient
//
//  Created by 新开元 iOS on 2019/3/5.
//  Copyright © 2019年 新开元 iOS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (Extend)
+ (CALayer *)addSubLayerWithFrame:(CGRect)frame
                  backgroundColor:(UIColor *)color
                         backView:(UIView *)baseView;

@end

NS_ASSUME_NONNULL_END
