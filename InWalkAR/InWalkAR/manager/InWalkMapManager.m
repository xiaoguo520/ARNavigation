//
//  InWalkMapManager.m
//  InWalkAR
//
//  Created by wangfan on 2018/7/19.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//
#import "InWalkMapManager.h"
#import "InWalkMapView.h"
#import "WFLine.h"
#import "WFCircle.h"
#import "WFImage.h"
#import "MathUtil.h"
#import "InWalkWebImageManager.h"
#import "UIImage+ColorPick.h"

@interface InWalkMapManager()
@property(nonatomic,strong) NSDictionary<NSString *, InWalkPath *> *allPaths;
@property(nonatomic,strong) InWalkMap *map;

@property(nonatomic,strong) InWalkMapView *internalMapView;
@property(nonatomic,strong) InWalkMapView *internalBgView;
@property(nonatomic,strong) WFCircle *currentPoint;
@property(nonatomic,strong) WFLine *currentDirection;
@property(nonatomic,strong) WFLine *navigationPath;
@property(nonatomic,strong) WFImage *currentPt; // 当前位置图标
@property(nonatomic) CGFloat currentPtRadius;
@property(nonatomic,strong) WFImage *destPt; // 终点位置图标
@property(nonatomic) CGRect mapFrame;
@property(nonatomic) CGSize contentSize;
@property(nonatomic) float initScale;
@property(nonatomic) BOOL isBigMap;
@property(nonatomic,strong) UIImage *floorMapImage;
@property(nonatomic,strong) WFImage *mapImageShape;
@property(nonatomic) BOOL isMapEnabled;
@property(nonatomic) BOOL hasLoadingAnim; // 是否展示动态加载导航路径的动画
@property(nonatomic) dispatch_source_t timer;
@property(nonatomic) UIView *emptyView; // 展示在小地图上边框的空白区域（用于与ARKit视图进行区分）
@end

@implementation InWalkMapManager

-(instancetype) initWithPaths:(NSDictionary<NSString *, InWalkPath *> *) paths{
    if(self = [super init]){
        _allPaths = paths;
//        _mapFrame = CGRectMake(10, 200, 200, 200); // 小地图缩略图位置及大小
        CGFloat h = UIScreen.mainScreen.bounds.size.height / 2;
        CGFloat w = UIScreen.mainScreen.bounds.size.width;
        //NSLog(@"sc.height : %f", h);
        _mapFrame = CGRectMake(0, h, w, h); // 小地图缩略图位置及大小
        _contentSize = CGSizeMake(1000, 1000); // UIScrollView包含的内容的Size(Tell the scrollView how big its subview is)
        _initScale = 1;//5;
        _isMapEnabled = NO;
        [self setUpMapView];
    }
    return self;
}

- (void)releaseMap {
    if (_timer) {
        dispatch_cancel(_timer);
    }
    if (_internalMapView) {
        [_internalMapView clear];
        [_internalMapView removeFromSuperview];
        _internalMapView = nil;
    }
    if (_mapView) {
        [_mapView removeFromSuperview];
        _mapView = nil;
    }
    _mapImageShape = nil;
    _floorMapImage = nil;
    _currentDirection = nil;
    _navigationPath = nil;
    _currentPoint = nil;
    _map = nil;
    _currentPt = nil;
    _allPaths = nil;
}

//初始化地图view
-(void) setUpMapView{
    UIScrollView *scrollView = [[UIScrollView alloc ] initWithFrame:_mapFrame];
//    [scrollView setCanCancelContentTouches:YES];
//    scrollView.userInteractionEnabled = YES;
//    scrollView.delaysContentTouches = NO;
//    scrollView.canCancelContentTouches = YES;
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigMap)];
//    ////NSLog(@" (add-event)show big map .., ");
//    [scrollView addGestureRecognizer:tapGesture];
    
    
//    scrollView.backgroundColor = UIColor.whiteColor; // 地图背景色
//    scrollView.backgroundColor = [UIColor colorWithRed:248/255. green:249/255. blue:204/255. alpha:1];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.bounces = NO;
    scrollView.scrollsToTop = NO;
    scrollView.minimumZoomScale = 0.5;
    scrollView.maximumZoomScale = 20;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    // 地图内容（包含背景图片、当前位置、导航路径）
    _internalMapView= [[InWalkMapView alloc] initWithFrame:CGRectMake(0, 0,_contentSize.width,  _contentSize.height)];
    _internalMapView.bounds = CGRectMake(-_contentSize.width/2, -_contentSize.height/2, _contentSize.width, _contentSize.height);
    scrollView.contentSize = _contentSize;
    _internalMapView.backgroundColor = UIColor.clearColor; //cyanColor;
    
    _internalBgView = [[InWalkMapView alloc] initWithFrame:CGRectMake(0, 0,_contentSize.width,  _contentSize.height)];
    _internalBgView.bounds = CGRectMake(-_contentSize.width/2, -_contentSize.height/2, _contentSize.width, _contentSize.height);
    _internalBgView.backgroundColor = UIColor.clearColor; //cyanColor;
    [scrollView addSubview:_internalBgView];
    
    [scrollView addSubview:_internalMapView];
    
    UITapGestureRecognizer *tapGesturePop = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popTouchUpInside:)];
    //tapGesturePop.cancelsTouchesInView = NO;
    [_internalMapView setUserInteractionEnabled:NO];
    [scrollView setUserInteractionEnabled:YES];
    [scrollView addGestureRecognizer:tapGesturePop];
    //[scrollView setCanCancelContentTouches:YES];
//    [scrollView addGestureRecognizer:tapGesturePop];
    
    scrollView.delegate = self.internalMapView;
    _internalMapView.syncView = _internalBgView;
    _mapView = scrollView;
    //_mapView.hidden = YES;
}

- (void)refreshMapViewSize {
    float width = _map.contentWidth;
    float height = _map.contentHeight;
    if (width < 1000) width = 1000;
    if (height < 1000) height = 1000;
    _contentSize = CGSizeMake(width, height);
    
    if (_internalMapView) {
        _internalMapView.frame = CGRectMake(0, 0,_contentSize.width,  _contentSize.height);
        _internalMapView.bounds = CGRectMake(-_contentSize.width/2, -_contentSize.height/2, _contentSize.width, _contentSize.height);
    }
    if (_mapView) {
        UIScrollView *scrollView = (UIScrollView *)_mapView;
        if (scrollView) {
            scrollView.contentSize = _contentSize;
        }
    }
}

-(void) updateMap:(InWalkMap *) map{
    if(![_map.planeId isEqualToNumber:map.planeId]){
        [_internalMapView clear];
        _currentPoint = nil;
        _currentDirection = nil;
        _navigationPath = nil;
        _mapImageShape = nil;
        _map = map;
        _hasLoadingAnim = NO;
//        [self refreshMapViewSize];
        [self updateMapView];
//        [self generatePath];
    }
}

// 更新背景地图
-(void) updateMapView{
    _initScale = _map.contentScale != nil ? _map.contentScale.floatValue :1;
    UIScrollView *scrollView = (UIScrollView *)_mapView;
    [scrollView setZoomScale:_initScale];
    
    if ([_map.uri containsString:@"http:"]) {
        NSURL *url = [NSURL URLWithString:_map.uri];
        __weak typeof(self) wself = self;
        [InWalkWebImageManager.sharedManager loadImageWithURL:url options:InWalkWebImageRetryFailed |InWalkWebImageRefreshCached progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, InWalkImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            __strong typeof(wself) sself = wself;
            if(sself && image){
                sself->_floorMapImage = image;
                
                if (!sself.hasLoadingAnim) {
                    UIScrollView *scrollView = (UIScrollView *) sself.mapView;
                    if (scrollView) {
                        [scrollView setZoomScale:1];
                        [scrollView setZoomScale:0.5 animated:YES];
                    }
                }
                
                sself->_mapImageShape.image = image;
                [sself->_internalBgView setNeedsDisplay];
                // 背景色：选取图片的(1,1)像素点的颜色
                sself->_mapView.backgroundColor = [image colorAtPixel:CGPointMake(1, 1)];//[UIColor redColor];
                //sself->_mapView.backgroundColor = [UIColor lightTextColor];
            }
            //        [scrollView setZoomScale:1];
        }];
        
        _mapImageShape = [WFImage new];
        _mapImageShape.position = CGPointMake(_map.xOffset.floatValue, _map.yOffset.floatValue);
        _mapImageShape.scale = CGSizeMake(_map.scale.floatValue, _map.scale.floatValue);
        _mapImageShape.rotateAngle = _map.rotation.floatValue;
        [_internalBgView addShape:_mapImageShape];
    } else {
        _mapImageShape = [WFImage new];
        _mapImageShape.position = CGPointMake(_map.xOffset.floatValue, _map.yOffset.floatValue);
        _mapImageShape.scale = CGSizeMake(_map.scale.floatValue, _map.scale.floatValue);
        _mapImageShape.rotateAngle = _map.rotation.floatValue;
        [_internalBgView addShape:_mapImageShape];
        
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:_map.uri ofType:nil];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        self->_floorMapImage = image;
        
        if (!self.hasLoadingAnim) {
            UIScrollView *scrollView = (UIScrollView *) self.mapView;
            if (scrollView) {
                [scrollView setZoomScale:1];
                [scrollView setZoomScale:0.5 animated:YES];
            }
        }
        
        self->_mapImageShape.image = image;
        [self->_internalBgView setNeedsDisplay];
        // 背景色：选取图片的(1,1)像素点的颜色
        self->_mapView.backgroundColor = [image colorAtPixel:CGPointMake(1, 1)];//[UIColor redColor];
    }
    
}

// 绘制指定楼层的所有可连通的路径
-(void)generatePath{
    // 绘制所有可连通的路径
    float angle = toRadians(self.map.rotation.floatValue);
    float sinTheta = sin(angle);
    float cosTheta = cos(angle);
    [_allPaths.allValues enumerateObjectsUsingBlock:^(InWalkPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 只绘制当前楼层的路径
        //BOOL isCurrentFloor = node.floor.intValue == self->_map.planeId.intValue;
        BOOL isCurrentFloor = [obj.floor isEqualToNumber:self.map.planeId];
        if(isCurrentFloor && obj.data.count > 0){
            WFLine *line = [[WFLine alloc] init];
            line.lineWidth = 9;
            // 蓝色线条
            line.lineColor = UIColor.blueColor;
            NSMutableArray<NSValue *> *linePoints = [NSMutableArray arrayWithCapacity:obj.data.count / 2];
            for (int i = 0; i < obj.data.count; i += 2) {
////                float y = obj.data[i + 1].floatValue;
////                y = -y; // 注意此处取-y
////                [linePoints addObject:[NSValue valueWithCGPoint:CGPointMake(obj.data[i].floatValue, y)]];
//
//                float x = self.initScale * obj.data[i].floatValue + [self.map.xOffset floatValue];
//                float y = self.initScale * obj.data[i + 1].floatValue + [self.map.yOffset floatValue];
//                [linePoints addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                
                float x, y;
                // scale
                x = self.initScale * obj.data[i].floatValue;// + [self.map.xOffset floatValue];
                y = self.initScale * obj.data[i + 1].floatValue;// + [self.map.yOffset floatValue];
                // rotate
                float x0 = x*cosTheta - y*sinTheta;
                float y0 = x*sinTheta + y*cosTheta;
                // translate
                x = x0 + [self.map.xOffset floatValue];
                y = y0 + [self.map.yOffset floatValue];
                [linePoints addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
            }
            line.pointArray = linePoints;
            [self.internalMapView addShape:line];
        }
    }];
}

// 设备当前所在位置
-(void) updateCurrentPosition:(CGPoint) point{
    if (self.mapView.isHidden) {
        return;
    }
    
    // 缩放、拖拽小地图时，不进行 当前位置更新 操作
    if (self.internalMapView && [self.internalMapView isZoomingOrDragging]) {
        return;
    }
    
    
////    //point.y = -point.y; // 注意此处取-y
////    float x = (point.x - self.currentPoint.center.x) * (point.x - self.currentPoint.center.x);
////    float y = (point.y - self.currentPoint.center.y) * (point.y - self.currentPoint.center.y);
////    float length = sqrt(x + y);
////    if(length > 3 || !_currentPoint || CGPointEqualToPoint(self.currentPoint.center,CGPointZero)){
////        UIScrollView *scrollView = (UIScrollView *)self.mapView;
////        CGFloat cx = (self.contentSize.width * scrollView.zoomScale - self.mapView.frame.size.width) / 2 + point.x * scrollView.zoomScale;
////        CGFloat cy = (self.contentSize.height * scrollView.zoomScale - self.mapView.frame.size.height) / 2 - point.y * scrollView.zoomScale;
////        scrollView.contentOffset = CGPointMake(cx, cy);
////    }
//
//    point.x = self.initScale * point.x + [self.map.xOffset floatValue];
//    point.y = self.initScale * point.y + [self.map.yOffset floatValue];
    
    float angle = toRadians(self.map.rotation.floatValue);
    float sinTheta = sin(angle);
    float cosTheta = cos(angle);
    float x, y;
    // scale
    x = self.initScale * point.x;// + [self.map.xOffset floatValue];
    y = self.initScale * point.y;// + [self.map.yOffset floatValue];
    // rotate
    float x0 = x*cosTheta - y*sinTheta;
    float y0 = x*sinTheta + y*cosTheta;
    // translate
    x = x0 + [self.map.xOffset floatValue];
    y = y0 + [self.map.yOffset floatValue];
    point.x = x;
    point.y = y;
    
    // 当前位置
    if(!_currentPoint){
        _currentPoint = [[WFCircle alloc] initWithCenter:point radius:2];
        _currentPoint.lineColor = UIColor.redColor;   // 红色线条
        _currentPoint.fillColor = UIColor.whiteColor; // 白色填充
        _currentPoint.lineWidth = 18;
        [_internalMapView addShape:_currentPoint];
    }
    
//    // 原点位置
//    CGPoint zp = CGPointMake(0, 0);
//    WFCircle *zero = [[WFCircle alloc] initWithCenter:zp radius:2];
//    zero.lineColor = UIColor.cyanColor;
//    zero.fillColor = UIColor.orangeColor;
//    zero.lineWidth = 18;
//    [_internalMapView addShape:zero];
    
    self.currentPoint.center = point;
    
    //if (!((UIScrollView *) _mapView).scrollEnabled) ;
    if (!self.isBigMap) {
        [self makeMapCenter];
        
        CGRect rect = self.emptyView.frame;
        rect.origin.x = self.mapView.bounds.origin.x;
        rect.origin.y = self.mapView.bounds.origin.y;
        self.emptyView.frame = rect;
    }
    
    [self.internalMapView setNeedsDisplay];
}

// 当前设备朝向
-(void) updateCurrentForwardPosition:(CGPoint) forwardPoint{
    if (self.mapView.isHidden) {
        return;
    }
    
    // 缩放、拖拽小地图时，不进行 设备朝向更新 操作
    if (self.internalMapView && [self.internalMapView isZoomingOrDragging]) {
        return;
    }
    
////    forwardPoint.y = -forwardPoint.y; // 注意此处取-y
//    forwardPoint.x = self.initScale * forwardPoint.x + [self.map.xOffset floatValue];
//    forwardPoint.y = self.initScale * forwardPoint.y + [self.map.yOffset floatValue];
    
    float angle = toRadians(self.map.rotation.floatValue);
    float sinTheta = sin(angle);
    float cosTheta = cos(angle);
    float x, y;
    // scale
    x = self.initScale * forwardPoint.x;// + [self.map.xOffset floatValue];
    y = self.initScale * forwardPoint.y;// + [self.map.yOffset floatValue];
    // rotate
    float x0 = x*cosTheta - y*sinTheta;
    float y0 = x*sinTheta + y*cosTheta;
    // translate
    forwardPoint.x = x0 + [self.map.xOffset floatValue];
    forwardPoint.y = y0 + [self.map.yOffset floatValue];
    
    
    CGPoint point = _currentPoint.center;
    CGPoint forward = CGPointMake(forwardPoint.x, forwardPoint.y);
    CGPoint toward = CGPointMake(forward.x - point.x, forward.y - point.y);
    float towardLength = sqrtf(toward.x * toward.x + toward.y * toward.y);
    toward.x *= 50 / towardLength;
    toward.y *= 50 / towardLength;
    forward = CGPointMake(point.x + toward.x, point.y+ toward.y);
    
    // 方向线条不要覆盖当前点
    point.x = (forward.x - point.x) / 50 + point.x;
    point.y = (forward.y - point.y) / 50 + point.y;
    
//    // （已废弃） 1. 添加指示当前朝向的线条
//    if(!_currentDirection){
//        _currentDirection = [[WFLine alloc] init];
//        // 绿色线条
//        _currentDirection.lineColor = UIColor.greenColor;
//        [_internalMapView addShape:_currentDirection];
//    }
//    self.currentDirection.pointArray = [NSArray arrayWithObjects:
//                                        [NSValue valueWithCGPoint:point],
//                                        [NSValue valueWithCGPoint:forward],
//                                        nil];
//    [self.internalMapView setNeedsDisplay];
    
    // 2. 添加当前位置图标
    if (!_currentPt) {
        _currentPt = [[WFImage alloc] init];
        _currentPt.image = [UIImage imageNamed:@"icon_current.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        _currentPt.scale = CGSizeMake(0.1f, 0.1f);
        float w = _currentPt.image.size.width;
        float h = _currentPt.image.size.height;
        _currentPtRadius = sqrt(w*w + h*h) * 0.05f;
        [_internalMapView addShape:_currentPt];
    }

    float a1 = [self calcAngle:point to:forward];
    _currentPt.rotateAngle = a1;
    // 偏移量dx,dy的计算：已知圆心，求圆上任意点坐标
    // 参考 https://blog.csdn.net/xiamentingtao/article/details/85804823
    float a2 = toRadians(180 - a1 - 45);
    float dx = _currentPtRadius * cos(a2);
    float dy = - _currentPtRadius * sin(a2);
    _currentPt.position = CGPointMake(point.x + dx, point.y + dy);
    
    
    [self.internalMapView setNeedsDisplay];
}

// +y轴向下，+x轴向右，计算-y轴到(from,to)向量的夹角，取值范围[0,360)
- (float)calcAngle:(CGPoint)from to:(CGPoint)to {
    if (from.x == to.x) {
        if (from.y < to.y) {
            return 0;//;180;//toRadians(180);
        } else {
            return 180;
        }
    }
    
    if (from.y == to.y) {
        if (from.x > to.x) {
            return 90;//270;//toRadians(270);
        } else {
            return 270;// 90;//toRadians(90);
        }
    }
    
    float dx = to.x - from.x;
    float dy = to.y - from.y;
    float v = dx / dy;
    if (v < 0) {
        v *= -1;
    }
    float a = atanf(v);
    
    float t = 0;
    if (dx > 0 && dy > 0) {
        t = 180 - toDegrees(a);
    } else if (dx > 0 && dy < 0) {
        t = toDegrees(a);
    } else if (dx < 0 && dy > 0) {
        t = 180 + toDegrees(a);
    } else {
        t = 360 - toDegrees(a);
    }
    
    return t;// a;//toRadians(a);
}

// 绘制导航路径（起始点到终点）
-(void) updateNavigationPath:(NSArray *) path{
    float destX = 0, destY = 0;
    
    // 1. 导航路径
    if(_navigationPath){
        [_internalMapView removeShape:_navigationPath];
    }
    _navigationPath = [[WFLine alloc] init];
    if (!_hasLoadingAnim) {
        [_navigationPath setAlpha:0];
    }
    // 红色线条
    _navigationPath.fillColor = [UIColor colorWithRed:47./255 green:197./255 blue:83./255 alpha:1]; // 填充颜色(绿色) 2FC553
    _navigationPath.lineColor = [UIColor colorWithRed:60./255 green:146./255 blue:212./255 alpha:1]; // 边框颜色(红色) 3C92D4
    _navigationPath.lineWidth = 14;
    NSMutableArray *pathPoints = [NSMutableArray arrayWithCapacity:path.count];
    for (NSValue *value in path) {
        CGPoint point = value.CGPointValue;
////        point.y = -point.y; // 注意此处取-y
//        point.x = self.initScale * point.x + [self.map.xOffset floatValue];
//        point.y = self.initScale * point.y + [self.map.yOffset floatValue];
        
        float angle = toRadians(self.map.rotation.floatValue);
        float sinTheta = sin(angle);
        float cosTheta = cos(angle);
        float x, y;
        // scale
        x = self.initScale * point.x;// + [self.map.xOffset floatValue];
        y = self.initScale * point.y;// + [self.map.yOffset floatValue];
        // rotate
        float x0 = x*cosTheta - y*sinTheta;
        float y0 = x*sinTheta + y*cosTheta;
        // translate
        x = x0 + [self.map.xOffset floatValue];
        y = y0 + [self.map.yOffset floatValue];
        
        point.x = x;//self.initScale * point.x + [self.map.xOffset floatValue];
        point.y = y;//self.initScale * point.y + [self.map.yOffset floatValue];
        
        // 终点位置
        destX = x;
        destY = y;
        
        [pathPoints addObject:[NSValue valueWithCGPoint:point] ];
    }
    
    _navigationPath.pointArray = pathPoints;
    [_internalMapView addShape:_navigationPath];
    
    
    // 2. 终点图标
    if (!_destPt) {
        _destPt = [[WFImage alloc] init];
        _destPt.image = [UIImage imageNamed:@"icon_dest.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        float scale = 0.42;
        _destPt.scale = CGSizeMake(scale, scale);
        float w = _destPt.image.size.width * 0.5 * scale;
        float h = _destPt.image.size.height * 0.9 * scale;
        _destPt.position = CGPointMake(destX - w, destY - h);
        _destPt.rotateAngle = 0;
    }
    [_internalMapView addShape:_destPt];
}

-(void) popTouchUpInside:(UITapGestureRecognizer *)recognizer{
    if (!_isMapEnabled) return;
    
    if(!self.isBigMap){
        // 将小地图放大到全屏
        [self enlargeMap];
    } else {
        // 将小地图缩小到底部
        [self narrowMap];
    }
}


// 将小地图缩小到底部(占屏36%)
- (void)narrowMap {
    // 隐藏相关tip图层
    if (self.delegate) {
        [self.delegate onClickMap:NO];
    }
    
    // 小地图缩小时，将zoomScale重置为1
    UIScrollView *scrollView = (UIScrollView *) (self.mapView);
    if (scrollView) {
        [scrollView setZoomScale:1 animated:YES];
        
        if (!_emptyView) {
            CGRect mainBounds = UIScreen.mainScreen.bounds;
            CGFloat y = 0;
            _emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, y, mainBounds.size.width, 12)];
            _emptyView.backgroundColor = [UIColor whiteColor];
        }
        _emptyView.alpha = 0;
        [scrollView addSubview:_emptyView];
    }
    
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:1 animations:^{
        __strong typeof(wself) sself = wself;
        
        CGRect screenBounds = UIScreen.mainScreen.bounds;
        CGFloat h = screenBounds.size.height * 0.36;
        wself.mapView.frame = CGRectMake(0, screenBounds.size.height - h, sself.mapView.frame.size.width, h);
        
        [wself makeMapCenter];
        
    } completion:^(BOOL finished) {
        if(finished){
            wself.isBigMap = NO;
            
//            if (wself.delegate) {
//                [wself.delegate onClickMap:NO];
//            }
//
//            // 小地图缩小时，将zoomScale重置为1
//            UIScrollView *scrollView = (UIScrollView *) (wself.mapView);
//            if (scrollView) {
//                [scrollView setZoomScale:1 animated:YES];
//            }
//
//            [wself makeMapCenter];
            
            CGRect rect = wself.emptyView.frame;
            rect.origin.x = wself.mapView.bounds.origin.x;
            rect.origin.y = wself.mapView.bounds.origin.y;
            wself.emptyView.frame = rect;
            [UIView animateWithDuration:0.2 animations:^(void) {
                wself.emptyView.alpha = 1;
            }];
            
            // 小地图放大时可以放大缩小和平移，缩小时不允许操作
            [wself setScrollEnabled:NO];
            
            if (wself.delegate) {
                [wself.delegate makeDirectionTipVisible:YES];
            }
        }
    }];
}

// 将小地图放大到全屏
- (void)enlargeMap {
    if (_emptyView) {
        [_emptyView removeFromSuperview];
    }
    
    if (_delegate) {
        [_delegate makeDirectionTipVisible:NO];
    }
    
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:1 animations:^{
        __strong typeof(wself) sself = wself;
        
        sself.mapView.frame = UIScreen.mainScreen.bounds;
        //UIScrollView *scrollView =(UIScrollView *) wself.mapView;
        
//        CGPoint point = sself->_currentPoint.center;
//        float cx = (sself.contentSize.width  * scrollView.zoomScale - sself.mapView.frame.size.width ) / 2 + point.x * scrollView.zoomScale;
//        float cy = (sself.contentSize.height * scrollView.zoomScale - sself.mapView.frame.size.height) / 2 - point.y * scrollView.zoomScale;
//        scrollView.contentOffset = CGPointMake(cx, cy);

//        [sself.mapView.superview bringSubviewToFront:sself.mapView];
        //[[UIApplication sharedApplication].keyWindow addSubview:_mapView];
    } completion:^(BOOL finished) {
        if(finished){
            wself.isBigMap = YES;
            
            if (wself.delegate) {
                [wself.delegate onClickMap:YES];
            }
            
            // 小地图放大时可以放大缩小和平移，缩小时不允许操作
            [wself setScrollEnabled:YES];
            
            [wself makeMapCenter];
            
            if (!wself.hasLoadingAnim) {
                // 首次展示导航路径时使用动画 动态展示导航路径的动画
                [wself loadingAnim];
            }
        }
    }];
}

- (void)loadingAnim {
    if (_navigationPath) {
        _hasLoadingAnim = YES;
        
        __block float time = 0;
        __weak typeof(self) wself = self;
        if (_timer) {
            dispatch_cancel(_timer);
        }
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_timer, ^{
            __strong typeof(self) strongSelf = wself;
            if(time < 0.6){
                time += 0.1;
                [strongSelf.navigationPath setAlpha:time*2];
                [strongSelf.internalMapView setNeedsDisplay];
            }else{
                dispatch_cancel(self->_timer);
                strongSelf->_timer = nil;
            }
        });
        dispatch_resume(_timer);
    }
}

// 小地图能否缩放、移动
- (void)setScrollEnabled:(BOOL)enabled {
    if (!_mapView) return;
    
    UIScrollView *scrollView =(UIScrollView *) _mapView;
    if (scrollView) {
        scrollView.scrollEnabled = enabled;
        
       // 禁用/启用 ScrollView的移动、缩放
       if (enabled) {
           scrollView.delegate = self.internalMapView;
       } else {
           scrollView.delegate = nil;
       }
    }
}

- (void)makeMapCenter {
    UIScrollView *scrollView = (UIScrollView *) self.mapView;
//    CGPoint point = _currentPoint.center;
//    float cx = (_contentSize.width  * scrollView.zoomScale - _mapView.frame.size.width ) / 2 + point.x * scrollView.zoomScale;
//    float cy = (_contentSize.height * scrollView.zoomScale - _mapView.frame.size.height) / 2 - point.y * scrollView.zoomScale;
//    scrollView.contentOffset = CGPointMake(cx, cy);
    
//    // 保持原点展示在小地图的正中央(考虑缩放)
//    CGFloat cx = (_contentSize.width * scrollView.zoomScale - _mapView.frame.size.width) / 2;
//    CGFloat cy = (_contentSize.height * scrollView.zoomScale - _mapView.frame.size.height) / 2;
//    scrollView.contentOffset = CGPointMake(cx, cy); // 可见区域的左上角坐标(相对于{0,0}的偏移量)
    
    // 保持当前位置展示在小地图的正中央(考虑缩放)
    ////NSLog(@"    center.currentPoint: %f   %f ", _currentPoint.center.x, _currentPoint.center.y);
    CGFloat cx = (_contentSize.width * scrollView.zoomScale - _mapView.frame.size.width) / 2 + _currentPoint.center.x * scrollView.zoomScale;
    CGFloat cy = (_contentSize.height * scrollView.zoomScale - _mapView.frame.size.height) / 2  + _currentPoint.center.y * scrollView.zoomScale;
    
//    // 当前位置处于地图左侧or下侧时，不需要将左侧/下侧当作contentOffset，而是将(0,0)当作contentOffset
//    if (cx < 0) cx = 0;
//    if (cy < 0) cy = 0;
//    NSLog(@"cx, cy: %f %f", cx,cy);
//    NSLog(@"center: %f, %f", _internalMapView.center.x, _internalMapView.center.y);
//    NSLog(@"map-c : %f  %f", _mapView.center.x, _mapView.center.y);
    
    // 防止向上/下偏移过多
    if (scrollView.bounds.size.height > scrollView.contentSize.height) {
        if (cy < 0) cy = 0;
    } else {
        if (cy > 0) {
            // 防止向上偏移过多：偏移后最下侧的点的x不能大于scrollView的height
            CGFloat dy = _internalMapView.frame.origin.y + _internalMapView.frame.size.height - cy - scrollView.bounds.size.height;
            if (dy < 0) {
                cy = cy + dy;
                if (cy < 0) cy = 0;
            }
        } else if (cy < 0) {
            // 防止向下偏移过多：偏移后最上侧的点的y不能大于0
            CGFloat dy = _internalMapView.frame.origin.y - cy;
            if (dy > 0) {
                cy = cy + dy;
                if (cy > 0) {
                    cy = 0;
                }
            }
        }
    }
    
    // 防止向左/右偏移过多
    if (scrollView.bounds.size.width > scrollView.contentSize.width) {
        if (cx < 0) cx = 0;
    } else {
        if (cx > 0) {
            // 防止向左偏移过多：偏移后最右侧的点的x不能大于scrollView的width
            CGFloat dx = _internalMapView.frame.origin.x + _internalMapView.frame.size.width - cx - scrollView.bounds.size.width;
            if (dx < 0) {
                cx = cx + dx;
                if (cx < 0) cx = 0;
            }
        } else if (cx < 0) { // ok
            // 防止向右偏移过多：偏移后最左侧的点的x不能大于0
            CGFloat dx = _internalMapView.frame.origin.x - cx;
            if (dx > 0) {
                cx = cx + dx;
                if (cx > 0) cx = 0;
            }
        }
    }
    
    scrollView.contentOffset = CGPointMake(cx, cy); // 可见区域的左上角坐标(相对于{0,0}的偏移量)
}

- (void)setTouchEnabled:(BOOL)enabled {
    _isMapEnabled = enabled;
}

-(void) showMap:(BOOL)showBigMap{
    if (_mapView.isHidden) {
        [self.mapView setHidden:NO];
    }
    
    if (showBigMap) {
        [self enlargeMap];
    } else {
        [self narrowMap];
    }
    
////    if (_mapView.isHidden) {
////        [_mapView setHidden:NO];
////        [self showBigMap];
////    }
//    if (_mapView.isHidden) {
//        [self.mapView setHidden:NO];
//        __weak typeof(self) wself = self;
//        if (wself.delegate) {
//            [wself.delegate onClickMap:YES];
//        }
//        [UIView animateWithDuration:1 animations:^{
//            __strong typeof(wself) sself = wself;
//            [sself.mapView setAlpha:1];
//            sself.mapView.frame = UIScreen.mainScreen.bounds;
////            UIScrollView *scrollView =(UIScrollView *) wself.mapView;
////            CGPoint point = sself->_currentPoint.center;
////            float cx = (sself.contentSize.width  * scrollView.zoomScale - sself.mapView.frame.size.width ) / 2 + point.x * scrollView.zoomScale;
////            float cy = (sself.contentSize.height * scrollView.zoomScale - sself.mapView.frame.size.height) / 2 - point.y * scrollView.zoomScale;
////            scrollView.contentOffset = CGPointMake(cx, cy);
//            [sself.mapView.superview bringSubviewToFront:sself.mapView];
//            //[[UIApplication sharedApplication].keyWindow addSubview:_mapView];
//        } completion:^(BOOL finished) {
//            if(finished){
//                wself.isBigMap = showBigMap;
//            }
//        }];
//    }
}



-(void)removeNavigationPath{
    if(_navigationPath){
        [_internalMapView removeShape:_navigationPath];
    }
}

@end
