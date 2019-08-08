//
//  RvtsResultUI.m
//  InWalkAR
//
//  Created by limu on 2019/4/25.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width

#import "RvtsResultUI.h"
#import "InWalkWebImageManager.h"
#import "PopView.h"

@interface RvtsResultUI(){
    PopView *_popView;
    UIView *_superView;
    //    NSArray *_items;
    //    NSString *_desc;
    //    NSString *_tip;
    UIImageView *cell;
    InWalkReverse4CarModel *selectedCar;
    CGRect oldFrame;
}
@end

@implementation RvtsResultUI


- (void)setSuperView:(UIView *)view {
    _superView = view;
}

- (void)showRvtsResultItems:(NSArray<InWalkReverse4CarModel *> *)items {
    float viewWidth = kScreenWidth;
    float viewHeight = 244 + 10;
    
    selectedCar = items[0];
    
    CGRect rect = CGRectMake(0, kScreenHeight - viewHeight, viewWidth, viewHeight);
    _popView = [[PopView alloc] initWithFrame:rect];
    [_popView setBackgroundColor:[UIColor whiteColor]];
    // 阴影效果
    _popView.layer.shadowOpacity = 0.5;
    _popView.layer.shadowRadius = 5;
    _popView.layer.shadowColor = [UIColor grayColor].CGColor;
    _popView.layer.shadowOffset = CGSizeMake(0, -1);
    //
    [_superView addSubview:_popView];
    // add header view.
    {
        float w = 32;
        float h = 4;
        CGRect headerFrame = CGRectMake((viewWidth - w) / 2, (24 - h) / 2, w, h);
        UIView *header = [[UIView alloc] initWithFrame:headerFrame];
        [header setBackgroundColor:[UIColor lightGrayColor]];
        [header.layer setCornerRadius:2];
        [_popView addSubview:header];
    }
    // add close button(height:32+12=44).
    {
        float padding = 6;
        float w = 32;
        CGRect closeFrame = CGRectMake(viewWidth - w - padding, padding, w, w);
        UIImageView *img = [[UIImageView alloc] initWithFrame:closeFrame];
        [img setImage:[UIImage imageNamed:@"close_48.png"
                                 inBundle:[NSBundle bundleForClass:[self class]]
            compatibleWithTraitCollection:nil]];
        // add tap event.
        UITapGestureRecognizer *tapGesturePop = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
        img.userInteractionEnabled = YES;
        [img addGestureRecognizer:tapGesturePop];
        [_popView addSubview:img];
    }
    // add title(height:36).
    {
        float y = 32;
        CGRect titleFrame = CGRectMake(16, y, viewWidth - 32, 54);
        UILabel *title = [[UILabel alloc] initWithFrame:titleFrame];
        [title setText:[NSString stringWithFormat:@"%zd个结果", (items ? items.count : 0)]];
        [title setTextAlignment:NSTextAlignmentLeft];
        [title setFont:[UIFont systemFontOfSize:24 weight:UIFontWeightMedium]];
        [_popView addSubview:title];
    }
    
    
    // 注意：这里应该是一个列表UITableView（目前仅展示其中的一个item），待改进
    {
        float y = 32 + 54 + 4;
        // 查询结果xx
        CGRect rect1 = CGRectMake(16, y, 200, 20);
        UILabel *lb1 = [[UILabel alloc] initWithFrame:rect1];
        [lb1 setText:@"查询结果1"];
        [lb1 setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium]];
        [_popView addSubview:lb1];
        // icon
        float y2 = y + 20 + 6;
        float w2 = 32;
        CGRect rect2 = CGRectMake(16, y2, w2, w2);
        UIImageView *img1 = [[UIImageView alloc] initWithFrame:rect2];
        [img1 setImage:[UIImage imageNamed:@"car-connected.png"
                                  inBundle:[NSBundle bundleForClass:[self class]]
             compatibleWithTraitCollection:nil]];
        [_popView addSubview:img1];
        // 位置
        CGRect rect12 = CGRectMake(16 + w2 + 6, y2, 200, w2);
        UILabel *lb12 = [[UILabel alloc] initWithFrame:rect12];
        [lb12 setText:[NSString stringWithFormat:@"%@", selectedCar.parkingPlace]];
        //[lb12 setText:@"L5层 C区 201号 泊位"];
        lb12.textAlignment = NSTextAlignmentLeft;//|NSTextAlignmentCenter;
        [lb12 setFont:[UIFont systemFontOfSize:18]];
        [lb12 setTextColor:[UIColor darkGrayColor]];
        [_popView addSubview:lb12];
        
        // 前往
        float w3 = 36;
        float padding3 = 4;
        CGRect rect3 = CGRectMake(kScreenWidth - w3 - padding3 * 2, y, w3, 60);
        UIView *v2 = [[UIView alloc] initWithFrame:rect3];
        // icon
        float w31 = 32;
        CGRect rect31 = CGRectMake(0, 0, w31, w31);
        UIImageView *img21 = [[UIImageView alloc] initWithFrame:rect31];
        [img21 setImage:[UIImage imageNamed:@"ic_circle.png"
                                  inBundle:[NSBundle bundleForClass:[self class]]
             compatibleWithTraitCollection:nil]];
        [v2 addSubview:img21];
        CGRect rect321 = CGRectMake(8, 8, w31 - 16, w31 - 16);
        UIImageView *img22 = [[UIImageView alloc] initWithFrame:rect321];
        [img22 setImage:[UIImage imageNamed:@"ic_nav.png"
                                   inBundle:[NSBundle bundleForClass:[self class]]
              compatibleWithTraitCollection:nil]];
        [v2 addSubview:img22];
        // text
        CGRect rect32 = CGRectMake(0, padding3 + w31 + 2, w3, 24);
        UILabel *lb32 = [[UILabel alloc] initWithFrame:rect32];
        [lb32 setText:@"前往"];
        [lb32 setFont:[UIFont systemFontOfSize:14]];
        //[lb32 setTextColor:[UIColor darkGrayColor]];
        [v2 addSubview:lb32];
        //v2.backgroundColor = [UIColor lightGrayColor];
        v2.userInteractionEnabled = YES;
        [v2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goTouchUpInside:)]];
        [_popView addSubview:v2];
        
        // 注意：图片列表（应该有0～3张图片），此处待改进
        float y4 = y + 60 + 2; // 130 + 46 + 14
        //NSLog(@"+++++++ %f", y4);
        CGRect rect4 = CGRectMake(0, y4, viewWidth, 100);
        UIScrollView *sv = [[UIScrollView alloc] initWithFrame: rect4];
        float cellWidth = 80;
        NSString *imgName = selectedCar.parkingPhoto;
        CGRect cellFrame = CGRectMake(20, 10, cellWidth, cellWidth);
        cell = [[UIImageView alloc] initWithFrame: cellFrame];
        cell.userInteractionEnabled = YES;
        [cell addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTouchUpInside:)]];
        //imgName = @"http://183.56.160.72:8020/ParkingApi/CarPhoto?id=7908&c=44115";
        [self setImageByUri:imgName];
        
        
        [sv addSubview:cell];
        //[sv setScrollEnabled:YES];
        [sv setContentSize: CGSizeMake(cellWidth * items.count + 10, 100)];
        //[sv setBackgroundColor:[UIColor blueColor]];
        [_popView addSubview:sv];
    }
    
    
    
    
    // add tap event.
    UITapGestureRecognizer *tapGesturePop = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popTouchUpInside:)];
    _popView.userInteractionEnabled = YES;
    [_popView addGestureRecognizer:tapGesturePop];
}

- (void)setImageByUri:(NSString *)uri {
    NSURL *url = [NSURL URLWithString:uri];
    __weak typeof(self) wself = self;
    //NSLog(@"  load >> %@", uri);
    [InWalkWebImageManager.sharedManager loadImageWithURL:url options:InWalkWebImageRetryFailed |InWalkWebImageRefreshCached progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, InWalkImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        __strong typeof(wself) sself = wself;
        if(sself && image){
            [sself->cell setImage:image];
        }
    }];
}

-(void) imageTouchUpInside:(UITapGestureRecognizer *)recognizer {
    UIImage *img = ((UIImageView *)recognizer.view).image;
    if (!img) {
        return;
    }
    
    // 放大
    oldFrame = recognizer.view.frame;
    //  当前视图
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //  背景
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    //  当前imageview的原始尺寸->将像素currentImageview.bounds由currentImageview.bounds所在视图转换到目标视图window中，返回在目标视图window中的像素值
    oldFrame = [recognizer.view convertRect:recognizer.view.bounds toView:window];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]];
    
    //  此时视图不会显示
    [backgroundView setAlpha:0];
    //  将所展示的imageView重新绘制在Window中
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:oldFrame];
    [imageView setImage:img];
    imageView.contentMode =UIViewContentModeScaleAspectFit;
    [imageView setTag:1024];
    [backgroundView addSubview:imageView];
    //  将原始视图添加到背景视图中
    [window addSubview:backgroundView];
    
    
    //  添加点击事件同样是类方法 -> 作用是再次点击回到初始大小
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideImageView:)];
    [backgroundView addGestureRecognizer:tapGestureRecognizer];
    
    //  动画放大所展示的ImageView
    [UIView animateWithDuration:0.4 animations:^{
        CGFloat y,width,height;
        y = ([UIScreen mainScreen].bounds.size.height - img.size.height * [UIScreen mainScreen].bounds.size.width / img.size.width) * 0.5;
        //宽度为屏幕宽度
        width = [UIScreen mainScreen].bounds.size.width;
        //高度 根据图片宽高比设置
        height = img.size.height * [UIScreen mainScreen].bounds.size.width / img.size.width;
        [imageView setFrame:CGRectMake(0, y, width, height)];
        //重要！ 将视图显示出来
        [backgroundView setAlpha:1];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideImageView:(UITapGestureRecognizer *)tap{
    UIView *backgroundView = tap.view;
    //  原始imageview
    UIImageView *imageView = [tap.view viewWithTag:1024];
    //  恢复
    [UIView animateWithDuration:0.4 animations:^{
        [imageView setFrame:self->oldFrame];
        [backgroundView setAlpha:0];
    } completion:^(BOOL finished) {
        //完成后操作->将背景视图删掉
        [backgroundView removeFromSuperview];
    }];
}

-(void) goTouchUpInside:(UITapGestureRecognizer *)recognizer{
    if (_delegate) {
        [_popView removeFromSuperview];
        [_delegate onConfirmRvtsResult:selectedCar.spaceCode];
    }
}

- (void)btnClick:(UITapGestureRecognizer *)recognizer{
    if (_delegate) {
//        [self dismiss];
        [_delegate onConfirmRvtsResult:@" ..."];
    }
}

// close.
- (void)close:(UITapGestureRecognizer *)recognizer{
    //NSLog(@"dismiss(close) ...");
    [self dismiss];
    if (_delegate) {
        [_delegate onCloseRvtsResult];
    }
}

- (void)dismiss{
    if (_popView) {
        [_popView removeFromSuperview];
        
        if (_popView.subviews) {
            for (UIView *v in _popView.subviews) {
                [v removeFromSuperview];
            }
        }
    }
}

- (void)restoreView {
    if (_popView) {
        [_superView addSubview:_popView];
    }
}

// 点击popWindow
-(void) popTouchUpInside:(UITapGestureRecognizer *)recognizer{
    //NSLog(@"clicked pop...");
}

@end
