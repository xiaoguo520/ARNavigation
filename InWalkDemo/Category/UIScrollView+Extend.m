//
//  UIScrollView+Extend.m
//  New_Patient
//
//  Created by 新开元 iOS on 2018/7/14.
//  Copyright © 2018年 新开元 iOS. All rights reserved.
//

#import "UIScrollView+Extend.h"

@implementation UIScrollView (Extend )

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if (self.contentOffset.x <= 0) {
        if ([otherGestureRecognizer.delegate isKindOfClass:NSClassFromString(@"_FDFullscreenPopGestureRecognizerDelegate")] && ([gestureRecognizer.delegate isKindOfClass:NSClassFromString(@"WMScrollView")]|| [gestureRecognizer.delegate isKindOfClass:NSClassFromString(@"BMKMapView")]) ) {
            return YES;
        }
    }
    return NO;
}

@end
