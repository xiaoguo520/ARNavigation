//
//  InputBgMapUI.m
//  InWalkAR
//
//  Created by limu on 2019/4/27.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width

#import "InputBgMapUI.h"
#import "InWalkWebImageManager.h"

@interface InputBgMapUI(){
    UIView *_superView;
    UIImageView *imageView;
    NSString *mapUri;
    UIImage *image;
    CGFloat lastScale;
    CGRect oldFrame;    //保存图片原来的大小
    CGRect largeFrame;  //确定图片放大最大的程度
    CGRect lastFrame;   //
    CGFloat imageWidthPx;   // 初次加载图片后，图片占据的像素(宽度)
    CGFloat imageHeightPx;  // 初次加载图片后，图片占据的像素(高度)
    CGFloat imageInitScaleX; // 初次加载图片后，图片像素相对屏幕的比例(宽度)
    CGFloat imageInitScaleY; // 初次加载图片后，图片像素相对屏幕的比例(高度)
}
@end

@implementation InputBgMapUI

- (void)setSuperView:(UIView *)view {
    _superView = view;
}

- (void)setFloor:(InWalkMap *)floor {
    if (!imageView) {
        mapUri = floor.uri;
        
//        CGFloat x = kScreenWidth * -1;
//        CGFloat y = kScreenHeight * -1;
//        CGFloat w = x * -2 + kScreenWidth;
//        CGFloat h = y * -2 + kScreenHeight;
//        CGRect rect = CGRectMake(x, y, w, h);
        CGRect rect = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        oldFrame = imageView.frame;
        lastFrame = imageView.frame;
        largeFrame = CGRectMake(0 - kScreenWidth, 0 - kScreenHeight, 3 * oldFrame.size.width, 3 * oldFrame.size.height);
        
        // 添加手势
        [imageView setMultipleTouchEnabled:YES];
        [imageView setUserInteractionEnabled:YES];
        [self addGestureRecognizerToView:imageView];
        
        [_superView addSubview: imageView];
        
        // 重新设置背景图片
        [self loadImage];
    } else {
        if (floor && floor.uri && mapUri) {
            mapUri = floor.uri;
            // 重新设置背景图片
            [self loadImage];
        }
    }
}

- (void)loadImage {
    imageInitScaleX = 0;
    imageInitScaleY = 0;
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:mapUri ofType:nil];
    self->image = [UIImage imageWithContentsOfFile:path];
    [self updateImage];
    
//    __weak typeof(self) wself = self;
//    NSURL *url = [NSURL URLWithString:mapUri];
//    [InWalkWebImageManager.sharedManager loadImageWithURL:url options:InWalkWebImageRetryFailed |InWalkWebImageRefreshCached progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, InWalkImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
//        __strong typeof(wself) sself = wself;
//        if(sself && image){
//            //sself->imageView.image = image;
//            //[sself->imageView setNeedsDisplay];
//            sself->image = image;
//            [sself updateImage];
//        }
//    }];
}

- (void)updateImage {
    if (imageView) {
        imageView.image = image;
        [imageView setNeedsDisplay];
    }
}

- (void)hide {
    if (imageView) {
        [imageView removeFromSuperview];
        image = nil;
        imageView = nil;
    }
}

- (void)dismiss {
    if (imageView) {
        [imageView removeFromSuperview];
        image = nil;
        imageView = nil;
    }
}

// 添加手势
- (void) addGestureRecognizerToView:(UIView *)view {
    // 缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [view addGestureRecognizer:pinchGestureRecognizer];
    
    // 移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [panGestureRecognizer setMinimumNumberOfTouches:1];
    [panGestureRecognizer setMaximumNumberOfTouches:1];
    [view addGestureRecognizer:panGestureRecognizer];
}

// 处理缩放手势
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    //NSLog(@"pinch ....");
    UIView *view = pinchGestureRecognizer.view;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        if (imageView.frame.size.width < oldFrame.size.width * 0.5) {
            // 图片最多只能缩小为原图一半
            CGFloat w = oldFrame.size.width / 2;
            CGFloat h = oldFrame.size.height / 2;
            imageView.frame = CGRectMake(lastFrame.origin.x, lastFrame.origin.y, w, h);
        }
        if (imageView.frame.size.width > 3 * oldFrame.size.width) {
            imageView.frame = largeFrame;
        }
        
        // 纠正center（防止图片和屏幕边界产生空白）
        CGPoint pt = [self rectifyCenterWithX:view.center.x Y:view.center.y];
        view.center = pt;
        
        lastFrame = imageView.frame;
        pinchGestureRecognizer.scale = 1;
    }
}

// 处理拖拉手势
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer {
    UIView *view = panGestureRecognizer.view;
    //    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
    //        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
    //        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
    //        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    //    }
    
    //    NSLog(@"img.size %f %f", imageView.image.size.width, imageView.image.size.height);
    
    //NSLog(@"pan  222 ....");
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        
        // 纠正center（防止图片和屏幕边界产生空白）
        CGPoint pt = [self rectifyCenterWithX:(view.center.x + translation.x) Y:(view.center.y + translation.y)];
        [view setCenter:pt];
        
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    
}

// 仅适用于 imageView.contentMode 为 UIViewContentModeScaleAspectFill 的情况
- (void)initArgs {
    imageInitScaleX = imageView.image.size.width / kScreenWidth;
    imageInitScaleY = imageView.image.size.height / kScreenHeight;
    if (imageInitScaleX > imageInitScaleY) {
        // 图片的宽高比 > 屏幕的宽高比（意味着图片可以左右移动）
        imageHeightPx = oldFrame.size.height;
        imageWidthPx = imageView.image.size.width * (imageHeightPx / imageView.image.size.height);
    } else {
        // 图片的宽高比 <= 屏幕的宽高比（意味着图片可以上下移动）
        imageWidthPx = oldFrame.size.width;
        imageHeightPx = imageView.image.size.height * (imageWidthPx / imageView.image.size.width);
    }
}

// 判断中心点有没有越界（即图片移动后保证不和屏幕边界产生空白处），若出现越界，进行纠正
- (CGPoint) rectifyCenterWithX:(CGFloat)x Y:(CGFloat)y {
    // min/max_translatedCenterPoint
    CGFloat minX, maxX, minY, maxY;
    
    // 初始化相关参数
    if (imageInitScaleX == 0) {
        [self initArgs];
    }
    
    // 图片当前相对于初始状态时的缩放比
    float scale = imageView.frame.size.width / oldFrame.size.width;
    
    float pxWc = imageWidthPx * scale;  // 图片当前占据的像素(宽度)
    if (pxWc > kScreenWidth) {
        minX = kScreenWidth - (pxWc / 2);
        maxX = pxWc / 2;
    } else {
        minX = pxWc / 2;
        maxX = kScreenWidth - minX;
    }
    
    float pxHc = imageHeightPx * scale; // 图片当前占据的像素(高度)
    if (pxHc > kScreenHeight) {
        minY = kScreenHeight - (pxHc / 2);
        maxY = pxHc / 2;
    } else {
        minY = pxHc / 2;
        maxY = kScreenHeight - minY;
    }
    
    if (x < minX) {
        x = minX;
    } else if (x > maxX) {
        x = maxX;
    } // else ;
    
    if (y < minY) {
        y = minY;
    } else if (y > maxY) {
        y = maxY;
    } // else ;
    
    return (CGPoint){x, y};
}

@end
