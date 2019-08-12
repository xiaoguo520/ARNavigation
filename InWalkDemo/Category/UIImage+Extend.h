//
//  UIImage+Extend.h
//  New_Patient
//
//  Created by xky_ios on 2018/6/5.
//  Copyright © 2018年 新开元 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extend)

+ (UIImage *)imageWithLineWithImageView:(UIImageView *)imageView;

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

//压缩到指定大小
- (NSData *)compressQualityWithMaxLength:(NSInteger)maxLength;

@end
