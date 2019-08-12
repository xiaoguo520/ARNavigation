//
//  UINavigationController+Extend.h
//  BigReading
//
//  Created by 新开元 iOS on 2018/4/11.
//  Copyright © 2018年 新开元 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Extend)<UINavigationBarDelegate, UINavigationControllerDelegate>
@property (copy, nonatomic) NSString *cloudox;
@property (nonatomic,strong) id popDelegate;
- (void)setNeedsNavigationBackground:(CGFloat)alpha;
- (void)setExtendPopDelegate;

@end
