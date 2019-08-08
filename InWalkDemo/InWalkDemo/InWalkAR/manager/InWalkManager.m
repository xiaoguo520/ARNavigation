//
//  InWalkManager.m
//
//  Created by InWalk on 2019/5/8.
//  Copyright © 2019年 InWalk Co., Ltd. All rights reserved.
//
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#import "InWalkManager.h"
#import "inWalkExtension.h"
#import "InWalkWebImageManager.h"
#import <AVFoundation/AVFoundation.h>
#import "InWalkConstant.h"
#import "InWalkModel.h"
#import "InWalkPath.h"
#import "InWalkARManager.h"
#import "InWalkUIManager.h"
#import "StartPositionModel.h"
#import "UIView+Toast.h"
#import "InWalkReverse4CarModel.h"
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MathUtil.h"
#import "InWalkIbeaconManager.h"
#import "BRTBeaconSDK.h"

#define DEFAULT_KEY @"00000000000000000000000000000000"

@interface InWalkManager()<InWalkUIDelegate, InWalkARManagerDelegate>

@property(nonatomic) UIView *container;
@property(nonatomic) InWalkARManager *arManager;
@property(nonatomic) InWalkUIManager *uiManager; // 管理UI交互

@property(nonatomic) NSString * productId;   // 项目ID
@property(nonatomic) InWalkModel *walkModel; // 整个项目（商场/停车场）的数据
@property(nonatomic) NSDictionary<NSString *, InWalkPath *> *allPaths; // 所有路径
@property(nonatomic) NSDictionary<NSString *, InWalkInnerPoint *> *allPoints; // 所有导航点
@property(nonatomic) NSDictionary<NSString *, InWalkMap *> *allMaps; // 所有楼层的基本信息
@property(nonatomic) NSDictionary<NSString *, InWalkNode *> *allNodes; // 所有节点(连接两段path的点)
@property(nonatomic) NSDictionary<NSString *, NSData *> *multiFloorData;
@property(nonatomic) int currentFloor;
@property(nonatomic) NSDictionary<NSString *, InWalkMap *> *mapList;

@property(nonatomic) NSString *startPointId; // 起始点
@property(nonatomic) NSString *endPointId; // 终点
@property(nonatomic) NSArray<StartPositionModel *> *allNavPoints; // 所有的导航点(用于输入起点时的列表选择，见StartPositionUI.m文件)
@property(nonatomic) NSArray * UUIDS;//ibeacon设备id

@property(nonatomic,getter=isPrepared) BOOL prepared;

@property(nonatomic, strong) NSString *accessToken; // 调用登录接口后，暂存其返回的token
@property(nonatomic, strong) NSString *reverse4CarVal; // 调用反向寻车接口时，需要用到的字段(在项目列表/项目详情接口中返回)
@property(nonatomic, strong) NSArray<InWalkReverse4CarModel *> *rvtsResult; // 反向寻车接口的返回结果

@property(nonatomic) CMMotionManager *motionManager; // 用于获取手机的俯仰角(在PhonePoseUI.m中用到)
@property(nonatomic) NSTimeInterval lastPitchTime;   // 记录手机的俯仰角
@property(nonatomic) NSArray<NavigationModel *> *navDetails; // AR导航提示信息(NavigationUI.m用到)
@property(nonatomic) BOOL hasRectifiedAngle; // 是否纠偏完成
@property(nonatomic) BOOL needVibrate; // 是否需要震动手机

@property(nonatomic) UIColor *restoreBackgroundColor;
@property(nonatomic) UIView *emptyView;
@property(nonatomic) NSString *currentProject;
@end

@implementation InWalkManager

#pragma mark - UI相关

#pragma mark -- WelcomeUI

// 导航点（真实数据）
- (void)setNavPointsData {
    NSString *iconName = @"locate_3x.png";
    NSMutableArray<StartPositionModel *> *items = [[NSMutableArray alloc]init];
    if (![self.currentProject containsString:@"松日"]) {
        for (InWalkInnerPoint *pt in self.allPoints.allValues) {
            [items addObject:[[StartPositionModel alloc] initWithName:[NSString stringWithFormat:@"%@", pt.name]
                                                               detail:[NSString stringWithFormat:@"%@", pt.name]
                                                              imgName:iconName
                                                                  key:pt.hid]];
        }
    } else {
        for (InWalkInnerPoint *pt in self.allPoints.allValues) {
            // name  : B3-%@
            // detail: B3层 %@号泊位
            [items addObject:[[StartPositionModel alloc] initWithName:[NSString stringWithFormat:@"B3-%@", pt.name]
                                                               detail:[NSString stringWithFormat:@"B3层 %@号泊位", pt.name]
                                                              imgName:iconName
                                                                  key:pt.hid]];
        }
    }
    
    self.allNavPoints = [items copy];
}

#pragma mark -- PlateNumberUI
// 点击PlateNumberUI(输入停车泊位号)中的按钮：目前这个界面(PlateNumberUI)没有用到
- (void)onConfirmPlateNumber:(NSString *)plateNumber{
    NSString *upper = [plateNumber uppercaseString];
    //upper = @"3119";
    StartPositionModel *item = [self.allNavPoints objectAtIndex:0];
    for (StartPositionModel *sp in self.allNavPoints) {
        // todo 实际使用时，此处需改动（暂时仅做演示使用）
        if ([sp.name containsString:upper]) {
            item = sp;
            break;
        }
    }
    
    // 确认车牌号是否正确，并给出相应提示（展示车位号，或提示错误信息）
    NSString *desc = item.detail; //[NSString stringWithFormat:@"desc: %@", plateNumber];
    NSString *tip = [NSString stringWithFormat:@"仅支持同层AR导航，请移步至%@停车场", [item.detail substringToIndex:[item.detail rangeOfString:@" "].location]]; //[NSString stringWithFormat:@"tip: %@", plateNumber];
    NSString *num = item.name; //[NSString stringWithFormat:@"num: %@", plateNumber];
    // todo 实际使用时，此处需改动（暂时仅做演示使用）
    NSString *carImgName = @"park.jpg"; // 20190509 该图片已经从SDK删除
    NSMutableArray<NSString *> *data = [[NSMutableArray alloc] init];
    [data addObject:carImgName];
    [data addObject:carImgName];
    [data addObject:carImgName];
    [data addObject:carImgName];
    [data addObject:carImgName];
    [data addObject:carImgName];
    //NSLog(@"on confirm ... 222");
    [self.uiManager showLocationResultDesc:desc tip:tip imgs:data parkingNum:num];
}

#pragma mark -- RvtsUI
// 点击RvtsUI(输入车牌号)中的按钮
- (void)onConfirmRvts:(NSString *)plateNumber {
    // 从 反向寻车系统 获取车辆所在泊位
    //NSLog(@"InWalkManager ... request rvts to confirm .. %@", plateNumber);
    
    // 注意：模拟反向寻车接口（仅测试用）
    //[self mockRvts:plateNumber];
    
    [self setNavPointsData];
    
    //[self reverseForCar:plateNumber parkingSite:@""];//reverse4CarVal
    [self reverseForCar:plateNumber parkingSite: self.reverse4CarVal];
}


#pragma mark -- LocateResultUI
// 点击LocateResultUI(PlateNumberUI后，确认车辆所在泊位号)中的按钮
- (void)onConfirmLocateResult{
    // 展示起点输入界面UI
    [self.uiManager showStartPositionViewWithItems:self.allNavPoints];
}

// 点击LocateResultUI(RvtsResultUI后，确认车辆所在泊位号)中的按钮
- (void)onConfirmDestParkingNo:(NSString *)destParkingNo {
    
    [self.uiManager showStartPositionViewWithItems:self.allNavPoints];
}

#pragma mark -- StartPositionUI
// 点击StartPositionUI(输入起点泊位号)中的"开始导航"按钮
- (void)startNavigationFrom:(NSString *)from to:(NSString *)to{
    // 起点、终点均不能为空，且不能相同
    BOOL isValid = (from && from.length > 0) && (to && to.length > 0) && ![from isEqualToString:to];
    if (!isValid) {
        return;
    }
    //开始导航
    NSString *startPointId = nil;
    NSString *endPointId = nil;
    int flag = 0;
    for (StartPositionModel *item in self.allNavPoints) {
        if ([item.name isEqualToString:from]) {
            startPointId = item.keyId;
            flag++;
        } else if ([item.name isEqualToString:to]) {
            endPointId = item.keyId;
            flag++;
        }
        if (flag == 2) {
            break;
        }
    }
    
    if (startPointId && startPointId.length > 0) {
        self.startPointId = startPointId;
    } else {
        isValid = NO;
    }
    if (endPointId && endPointId.length > 0) {
        self.endPointId = endPointId;
    } else {
        isValid = NO;
    }
    if (!isValid) {
        //NSLog(@" not found ... ");
        return;
    }
    
    [[InWalkIbeaconManager manager] stopRangingBeacons];
    
    if (!self.arManager) {
        // 消除所有界面UI
        
        // 消除所有界面UI前，先添加一个底部背景，以免出现原有的UI跳动现象
        if (!_emptyView) {
            _emptyView = [[UIView alloc] initWithFrame:self.container.bounds];
            _emptyView.backgroundColor = UIColor.whiteColor;
            [self.container addSubview: _emptyView];
        }
        [self.uiManager dismissInputViews];
        
        //停止搜索设备
//        [InWalkIbeaconManager stopRangingBeacons];
        
        [self initAr];
        
        [self startGyro];
        
        return;
    }
    
    //[self showArPath];
    
}

#pragma mark -- PhonePoseUI
// PhonePoseUI界面后，开始AR导航的相关展示(小地图、AR路径)
- (void)showPhonePosePromptView:(InWalkPhonePose)flag {
    [self.uiManager showPhonePose:flag];
    if (flag == InWalkPhonePoseFree) {
        // 开始导航
        [self showArPath];
    }
}

#pragma mark -- NavigationUI
// 点击NavigationUI界面的"结束"按钮
- (void)finishNavigation{
    //[self.arManager testUpdatePlus];
    //清除定时器
    if (_delegate) {
        //[_delegate manager:self didEndNavigationToPoint:nil];
        [_delegate didEndNavigation];
    }
    
    [[InWalkIbeaconManager manager] stopRangingBeacons];
    
    
}

// 刷新NavigationUI界面(下半部分)中的导航提示列表
- (void)updateNavigationDetails:(NSArray<NavigationModel *> *)details{
    self.navDetails = details;
    //    if (_hasRectifiedAngle)
    [self.uiManager setNavPath:details];
}

// 刷新NavigationUI界面(下半部分)中的提示信息
- (void)updateNavigationTip:(NavigationModel *)tip{
    NSString *remainTime;
    NSString *arriveTime;
    
    float seconds = tip.distanceToEnd / 1.1; // 按照1.1m/s的速度估算时间
    if (seconds > 3600) { // xx小时
        int h = seconds / 3600;
        int m = (((int)seconds) % 3600) / 60;
        remainTime = [NSString stringWithFormat:@"%d小时%d分钟", h, m];
    } else if (seconds > 60) { // xx分钟
        int m = seconds / 60;
        remainTime = [NSString stringWithFormat:@"%d分钟", m];
    } else { // 1分钟
        remainTime = [NSString stringWithFormat:@"%d分钟", 1];
    }
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:seconds];
    NSDateFormatter * formatter=[[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-Hans"]]; // 下午 11:52
    [formatter setDateFormat:@"a hh:mm"]; // 下午 11:52
    arriveTime = [formatter stringFromDate:date];
    
    // 展示导航视图（直行/左转/右转/结束）
    [self.uiManager showTip:tip remainTime:remainTime distance:tip.distanceToEndDesc arriveTime:arriveTime];
    //[_navView showTip:tip remainTime:@"20分钟" distance:@"4.2公里" arriveTime:@"上午11:22"];
}


#pragma mark - ARKit相关
// 生成导航路径，并展示在界面上
- (void)showArPath {
    // 将当前位置与ARKit中的位置映射起来
    [self setCurrentPoint:_startPointId error:nil];
    
    // 计算导航路径
    [self navigateTo:_endPointId error:nil];
}

// 在ARKit中设置当前位置为起点
- (void)setCurrentPoint:(NSString *)pointId error:(NSError **)error {
    [self checkPrepared];
    //if([_walkItem pointForId:pointId]){
    if ([self getPointById:pointId]) {
        [_arManager updateCurrentPoint:pointId];
    } else if(error != NULL) {
        NSDictionary *dic = [NSDictionary dictionaryWithObject:@"pointId not exist" forKey:NSLocalizedFailureErrorKey];
        *error = [NSError errorWithDomain:InWalkErrorDomain code:100 userInfo:dic];
    }
}

// 10米纠偏完成
- (void)onAngleRectified {
    _hasRectifiedAngle = YES;
    [self.uiManager refreshMapBtn:NO];
    //    if (_navDetails) {
    //        [self.uiManager setNavPath:_navDetails];
    //    }
}

#pragma mark -- 小地图相关
// 点击NavigationUI中的mapIcon图标：现在没有用到
- (void)showMap:(BOOL)shouldOpenMap{
}

// 小地图完成放大/缩小后的事件
- (void)onMapOpend:(BOOL)isOpenNow{
    if (_hasRectifiedAngle)
    {
        [self.uiManager refreshMapBtn:isOpenNow];
    }
}

// 小地图：将当前位置展示在地图(屏幕)中心
- (void)makeMapCenter {
    if (self.arManager) {
        [self.arManager makeMapCenter];
    }
}

#pragma mark 导航相关
// 计算导航路径，开始AR导航
-(void) navigateTo:(NSString *)pointId error:(NSError *__autoreleasing *)error{
    [self checkPrepared];
    ////NSLog(@"nav to ,,, ");
    //if([_walkItem pointForId:pointId]){
    if([self getPointById:pointId]){
        [self.arManager startNavigationTo:pointId];
    }else if(error != NULL){
        NSDictionary *dic = [NSDictionary dictionaryWithObject:@"pointId not exist" forKey:NSLocalizedFailureErrorKey];
        *error = [NSError errorWithDomain:InWalkErrorDomain code:100 userInfo:dic];
    }
}

#pragma mark - 其他方法
-(void) dealloc{
    [InWalkWebImageManager.sharedManager cancelAll];
    [InWalkWebImageManager.sharedManager.imageCache clearMemory];
    //NSLog(@"  555 >>> dealloc inwalkmanager");
}

#pragma mark 简单的辅助方法
// 监听手机的姿态(俯仰角)，作用：初始化ARKit后，先保持手机竖直稳定3秒，以提高ARKit的初始化完成度
// 该方法仅稍作了解就好，没有大的用处
- (void)startGyro {
    CMMotionManager *manager = [[CMMotionManager alloc] init];
    self.motionManager = manager;
    if([manager isDeviceMotionAvailable]){
        NSOperationQueue *queue = [[NSOperationQueue alloc]init];
        // 设置订阅陀螺仪的值的时间间隔，需要设置的比较小
        manager.deviceMotionUpdateInterval = 1.0/120;
        InWalkManager *__weak weakSelf = self;
        _lastPitchTime = 0;
        _needVibrate = YES;
        [manager startDeviceMotionUpdatesToQueue:queue withHandler:^(CMDeviceMotion *motion, NSError *error){
            InWalkManager *__strong strongSelf = weakSelf;
            
            if(strongSelf){
                // 当前的pitch，标志手机摆放方向是否符合要求
                float pitch = motion.attitude.pitch * 180 / M_PI;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    InWalkManager *__strong strongSelf = weakSelf;
                    if (!strongSelf) {
                        return ;
                    }
                    
                    if (strongSelf.emptyView) {
                        [strongSelf.emptyView removeFromSuperview];
                        strongSelf.emptyView = nil;
                    }
                    
                    if (pitch < 70) {
                        // 展示保持手机竖直的提示
                        ////NSLog(@" >>> 小于 70 ");
                        strongSelf.lastPitchTime = 0;
                        [strongSelf showPhonePosePromptView:InWalkPhonePoseWrong];
                        strongSelf.needVibrate = YES;
                        
                    } else {
                        NSTimeInterval now = strongSelf.motionManager.deviceMotion.timestamp;
                        if (strongSelf.lastPitchTime == 0) {
                            strongSelf.lastPitchTime = now;
                        }
                        if (now - strongSelf.lastPitchTime > 3) {
                            // 不再展示提示界面，开始导航
                            // //NSLog(@" >>> emmm .. ok 70 。。。开始导航");
                            [strongSelf.motionManager stopDeviceMotionUpdates];
                            [strongSelf showPhonePosePromptView:InWalkPhonePoseFree];
                        } else if (now - strongSelf.lastPitchTime > 2) {
                            // 展示保持手机竖直(1秒)的提示
                            // //NSLog(@" >>> emmm .. ok 70 。。。保持1秒");
                            [strongSelf showPhonePosePromptView:InWalkPhonePoseKeep1];
                        } else if (now - strongSelf.lastPitchTime > 1) {
                            // 展示保持手机竖直(2秒)的提示
                            // //NSLog(@" >>> emmm .. ok 70 。。。保持2秒");
                            [strongSelf showPhonePosePromptView:InWalkPhonePoseKeep2];
                        } else {
                            // 展示保持手机竖直(3秒)的提示
                            // //NSLog(@" >>> emmm .. ok 70 。。。保持3秒");
                            [strongSelf showPhonePosePromptView:InWalkPhonePoseKeep3];
                            
                            // 震动手机
                            if (strongSelf.needVibrate) {
                                strongSelf.needVibrate = NO;
                                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                            }
                        }
                        
                    }
                });
            }
        }];
    }
}

// 根据PointId获取导航点
- (InWalkInnerPoint *)getPointById:(NSString *)pointId{
    return [self.allPoints objectForKey:pointId];
}

// 判断URL的有效性
- (NSString *)validUrl:(NSString *)url{
    NSString *result = url;
    if(![url hasPrefix:@"http"]){
        result = [NSString stringWithFormat:@"https:%@",url];
    }
    return result;
}

// 检测当前状态，若状态为inital 抛出异常
- (void)checkPrepared {
    if(!self.prepared){
        [NSException raise:NSObjectNotAvailableException format:@"this must be called after prepared"];
        return;
    }
}

// 通知SDK调用者使用出错
- (void)postError:(NSError *)error {
    if(self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(manager:didOccurError:)])
    {
        [self.delegate manager:self didOccurError:error];
    }
}

//// 隐藏界面上的调试信息
//-(void) hideDebugInfo:(BOOL) isHidden{
//    [_arManager hideDebugInfo:isHidden];
//}


#pragma mark - 新版本（调用后台接口请求项目数据）
// 初始化方法：通过调用后台接口获取数据
-(instancetype) initWithContainer:(UIView *)container productId:(NSString * ) productId{
    if (self = [self init]) {
        self.container = container;
        self.productId = productId;
        self.restoreBackgroundColor = self.container.backgroundColor;
        [self loadDataS1_login]; // 登录，获取token
        [self loadDataS3_projectDetail: self.productId]; // 加载项目详情(需要token，productId)
        InWalkWebImageManager.sharedManager.imageDownloader.shouldDecompressImages = NO;
        InWalkWebImageManager.sharedManager.imageCache.config.shouldDecompressImages = NO;
        InWalkWebImageManager.sharedManager.imageCache.config.shouldCacheImagesInMemory = NO;
    }
    return self;
}

#pragma mark 后台接口
// 登录
// 多个接口(比如加载项目列表projectList)需要用到登录接口返回的accessToken
- (void)loadDataS1_login {
    __weak typeof(self) weakSelf = self;
    NSURL *url = [NSURL URLWithString:[[_INWALKAR_API_SERVER stringByAppendingPathComponent:_INWALKAR_SUB] stringByAppendingPathComponent:@"pb/login/local"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    // addBody
    // 注意：这里暂时使用硬编码的账户 "username=test&password=123123"
    NSString *keyValueBody = [NSString stringWithFormat:@"username=%@&password=%@", _INWALKAR_TEST_ACC, _INWALKAR_TEST_PWD];
    request.HTTPBody = [keyValueBody dataUsingEncoding:NSUTF8StringEncoding];
    
    // addHeader
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{@"Content-Type":@"application/x-www-form-urlencoded;charset=utf-8"};
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    //NSURLSession *session = NSURLSession.sharedSession;
    
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            if(strongSelf == nil){
                return ;
            }
            
            if(!error){
                NSDictionary * dir =  [NSJSONSerialization JSONObjectWithData:data options:kNilOptions  error:nil];
                self.accessToken = [dir objectForKey:@"accessToken"];
                if (!self.accessToken) {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Server Error 1" forKey:@"message"];
                    NSError * tmpError = [NSError errorWithDomain:InWalkErrorDomain code:InWalkErrorCodeInit userInfo:userInfo];
                    [strongSelf postError: tmpError];
                }
            } else {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error.localizedDescription forKey:@"message"];
                NSError * tmpError = [NSError errorWithDomain:InWalkErrorDomain code:InWalkErrorCodeInit userInfo:userInfo];
                [strongSelf postError: tmpError];
            }
        });
    }];
    [task resume];
}

// 加载项目详情
- (void)loadDataS3_projectDetail:(NSString *)projectId {
    ////NSLog(@" load ... %@", projectId);
    NSURLSession *session = NSURLSession.sharedSession;
    __weak typeof(self) weakSelf = self;
    
    NSURL *url = [NSURL URLWithString:[[_INWALKAR_API_SERVER stringByAppendingPathComponent:_INWALKAR_SUB] stringByAppendingPathComponent:[NSString stringWithFormat:@"pb/ar/%@", projectId]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    // add Header(暂时不加token)
    //[request setValue:[NSString stringWithFormat:@"Bearer %@", self.accessToken] forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            if(strongSelf == nil){
                return ;
            }
            
            if(error){
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error.localizedDescription forKey:@"message"];
                NSError * tmpError = [NSError errorWithDomain:InWalkErrorDomain code:InWalkErrorCodeInit userInfo:userInfo];
                [strongSelf postError:tmpError];
            }else{
                // 手动映射JSON与Model
                [self setClassPropertiesForDashi];
                
                // 解析数据
                NSDictionary * dir =  [NSJSONSerialization JSONObjectWithData:data options:kNilOptions  error:nil];
                [self updateData:dir];
                self.prepared = YES;
//                if(self.delegate && [((NSObject *)self.delegate) respondsToSelector:@selector(didPreparedWithManager:)]){
//                    [self.delegate didPreparedWithManager:self];
//                }
            }
            
        });
    }];
    [task resume];
}

// 反向寻车接口
- (void)reverseForCar:(NSString *)plateNo parkingSite:(NSString *)site {
    __weak typeof(self) weakSelf = self;
    NSURL *url = [NSURL URLWithString:[[_INWALKAR_API_SERVER stringByAppendingPathComponent:_INWALKAR_SUB] stringByAppendingPathComponent:@"reverse4car"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    // add Header
    [request setValue:[NSString stringWithFormat:@"Bearer %@", self.accessToken] forHTTPHeaderField:@"Authorization"];
    
    // add Body
    NSString *keyValueBody = [NSString stringWithFormat:@"plateNo=%@&site=%@", plateNo, site];
    request.HTTPBody = [keyValueBody dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{@"Content-Type":@"application/x-www-form-urlencoded;charset=utf-8"};
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            if(strongSelf == nil){
                return ;
            }
            
            if(!error){
                NSDictionary * dir =  [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                
                if ([[NSString stringWithUTF8String: object_getClassName(dir)] isEqualToString:@"__NSSingleObjectArrayI"]) {
                    // 解析数据
                    if (dir.count > 0) {
                        NSMutableArray<InWalkReverse4CarModel *> *results = [[NSMutableArray alloc] initWithCapacity:dir.count];
                        
                        NSArray *list = (NSArray *)dir;
                        InWalkReverse4CarModel *item;
                        for (int i = 0; i < list.count; i++) {
                            item = [InWalkReverse4CarModel inWalk_objectWithKeyValues:list[i]];
                            [results addObject: item];
                        }
                        
                        // 展示到页面
                        self.rvtsResult = [results copy];
                        //[self showRvtsResultUI];
                        [self.uiManager showRvtsResult:self.rvtsResult];
                    } else {
                        [self searchCarFailed:@"未能找到匹配的结果"];
                    }
                    return;
                }
                
//                if ([dir.allKeys containsObject:@"code"]) {
//                    //NSNumber * code = [dir objectForKey:@"code"];
//                    //{"code":2,"message":"no authrization"}
//                    [self searchCarFailed:@"查找失败"];
//                    return;
//                }
            }
            
            // 错误处理
            [self searchCarFailed:@"未能找到匹配的结果"];
        });
    }];
    [task resume];
}

#pragma mark 辅助方法
// 弹出错误提示toast(反向寻车失败)
- (void)searchCarFailed:(NSString *)msg {
     [self.container makeToast:msg];
}

// 新版本(达实智能项目)的数据结构调整：手动映射JSON与Model的字段
// 注意：此处请尽量将所有用的字段都标识出来
- (void)setClassPropertiesForDashi{
    // 用本地JSON数据初始化
    [InWalkModel inWalk_setupObjectClassInArray:^{
        return @{
                 @"mapMeta":@"InWalkItem"
                 };
    }];
    
    [InWalkInnerPoint inWalk_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"hid" : @"id",
                 @"pathID" : @"path",
                 @"x" : @"position.x",
                 @"y" : @"position.y",
                 @"realX" : @"realPosition.x",
                 @"realY" : @"realPosition.y"
                 };
    }];
    [InWalkNode inWalk_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"nodeID" : @"id"
                 };
    }];
    [InWalkMap inWalk_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"planeId" : @"floor",
                 @"rotation" : @"mapRotate",
                 @"contentScale" : @"plotScale",
                 @"uri" : @"mapUri"
                 };
    }];
    [InWalkPath inWalk_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"pathID" : @"id",
                 @"pathName" : @"name",
                 @"headNodeID" : @"headNode",
                 @"tailNodeID" : @"tailNode"
                 };
    }];
    
    // InWalkItem类中的数组
    [InWalkItem inWalk_setupObjectClassInArray:^{
        return @{
                 //@"drawer":@"InWalkMap",
                 @"nodes":@"InWalkNode",
                 @"pathes":@"InWalkPath",
                 @"navs":@"InWalkInnerPoint"
                 };
    }];
}

// 解析数据
- (void)updateData:(NSDictionary *)dir {
    if (![dir.allKeys containsObject:@"mapMeta"]) {
        //[self.container makeToast:@"该项目数据无效"];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"该项目数据无效" forKey:@"message"];
        NSError * tmpError = [NSError errorWithDomain:InWalkErrorDomain code:InWalkErrorCodeInit userInfo:userInfo];
        [self postError: tmpError];
        
        [self finishNavigation];
        return;
    }
    
    
    // 反向寻车
    self.reverse4CarVal = dir[@"reverse4Car"];
    
    // 注意：此处为临时代码（松日鼎盛停车场不支持反向寻车系统）
    _currentProject = [NSString stringWithFormat:@"%@", dir[@"name"]];
    if ([_currentProject containsString:@"松日"]) {
        self.reverse4CarVal = nil;
    }
    
    
    InWalkItem *singleFloorData = [InWalkItem inWalk_objectWithKeyValues:dir[@"mapMeta"]];
    self.walkModel = [[InWalkModel alloc] init];
    self.walkModel.meta = @[singleFloorData];
    // floor map
    self.walkModel.meta[0].drawer = [self floorMapWithData:dir];
    
    
    // maps, nodes, paths, points
    NSMutableDictionary<NSString *, InWalkMap *> *maps = [[NSMutableDictionary alloc] init];
    NSMutableDictionary<NSString *, InWalkNode *> *nodes = [[NSMutableDictionary alloc] init];
    NSMutableDictionary<NSString *, InWalkPath *> *paths = [[NSMutableDictionary alloc] init];
    NSMutableDictionary<NSString *, InWalkInnerPoint *> *points = [[NSMutableDictionary alloc] init];
    for (InWalkItem *singleFloorData in self.walkModel.meta) {
        for (InWalkPath *pi in singleFloorData.pathes) {
            if (pi.weight == nil) {
                pi.weight = [NSNumber numberWithFloat:1000000];
            }
            pi.floor = @-1; // 注意：此为必需项！
            [paths setObject:pi forKey:pi.pathID];
        }
        for (InWalkInnerPoint * pt in singleFloorData.navs) {
            [points setObject:pt forKey:pt.hid];
        }
        for (InWalkNode *node in singleFloorData.nodes) {
            [nodes setObject:node forKey:node.nodeID];
        }
        [maps setObject:singleFloorData.drawer forKey:singleFloorData.drawer.planeId];
    }
    self.allMaps = maps;
    self.allPaths = paths;
    self.allPoints = points;
    
    // nodes
    for (InWalkNode *node in nodes.allValues) {
        NSMutableArray<NSString *> *nodeIDs = [[NSMutableArray alloc] init];
        NSMutableArray<NSString *> *pathIDs = [[NSMutableArray alloc] init];
        for (InWalkPath *path in paths.allValues) {
            if ([path.headNodeID isEqualToString:node.nodeID]) {
                [nodeIDs addObject:path.tailNodeID ? path.tailNodeID : @"-1"];
                [pathIDs addObject:path.pathID];
            } else if ([path.tailNodeID isEqualToString:node.nodeID]) {
                [nodeIDs addObject:path.headNodeID ? path.headNodeID : @"-1"];
                [pathIDs addObject:path.pathID];
            }
        }
        node.nodeIDs = nodeIDs;
        node.pathIDs = pathIDs;
    }
    self.allNodes = nodes;
    
    // [self initAr]; // 初始化ARKit（完成起点、终点的输入后，点击"开始导航"再初始化ARKit）
    
    // init UIManager
    self.uiManager = [[InWalkUIManager alloc] initWithSuperView:_container];
    self.uiManager.delegate = self;
    
    // 设置输入界面的背景图片(楼层的地图)
    [self setBgMap: singleFloorData.drawer];    
    // add 主页按钮、提示按钮
    [self.uiManager showTipButtons];
    
    if (self.reverse4CarVal && ![self.reverse4CarVal isEqualToString:@"none"]) {
        // 展示反向寻车的输入UI
        self.walkModel.supportRvts = YES;
        [self.uiManager showPlateNumberView2];
    } else {
        // 展示手动输入泊位号的UI
        self.walkModel.supportRvts = NO;
        [self setNavPointsData];
        [self.uiManager showStartPositionViewWithItems:self.allNavPoints];
    }
}

// 解析楼层地图数据
- (InWalkMap *)floorMapWithData:(NSDictionary *)dir {
    // 楼层的地图数据(InWalkMap)
    InWalkMap * singleFloorMap = [InWalkMap inWalk_objectWithKeyValues:dir];
    singleFloorMap.planeId = @-1; // 注意：此为必需项！
    singleFloorMap.rotation = [NSNumber numberWithFloat: [dir[@"mapRotate"] floatValue]];
    singleFloorMap.northOffset = [NSNumber numberWithFloat: [dir[@"mapRotate"] floatValue]]; // 真实导航路径的方向的准确性相关
    //
    // scale：与小地图的展示有关
    float w = [dir[@"width"] floatValue];
    float h = [dir[@"height"] floatValue];
    float s = w > h ? 1000 / w : 1000 / h;
    singleFloorMap.scale = [NSNumber numberWithFloat:s]; // 小地图将按照此比例缩放展示（背景图片）
    //
    // contentScale：与小地图的展示有关
    float s2 = singleFloorMap.contentScale.floatValue * s;
    singleFloorMap.contentScale = [NSNumber numberWithFloat:s2];
    //
    // xOffset, yOffset: 与小地图的展示有关
    float theta = [singleFloorMap.rotation floatValue];
    float cosTheta = cos(toRadians(theta));
    float sinTheta = sin(toRadians(theta));
    // 原理Step0：小地图初始状态：左上角的顶点P1的坐标(0,0)，中心点C1的坐标(w/2,h/2)
    // 原理Step1-translate：小地图绕左上角的顶点P1(0,0)平移(xOffset,yOffset)后：左上角的顶点为P2(xOffset,yOffset)，中心点C2的坐标(w/2+xOffset,h/2+yOffset)
    // 原理Step2-rotate：然后小地图继续绕P2旋转(顺时针)theta角度后：左上角的顶点为P2(xOffset,yOffset)，中心点C3的坐标为(?,?)
    // 原理Step3-scale：然后小地图以P2为基点进行缩放(比例为s)后：左上角的顶点为P2(xOffset,yOffset)，中心点C4的坐标为(0,0)
    // 其中w,h分别为小地图图片的宽高，xOffset,yOffset为所求，theta为旋转角度(顺时针)，s为缩放比例。
    // 按照上述步骤，结合圆的知识(已知圆心位置和旋转角度求圆上任意点坐标)，即可求出xOffset与yOffset。
    // 注意：此处应结合InWalkMapManager的实现(小地图实现)进行理解，也就是到了需要修改小地图的实现时再来看就可以了。
    float dx = s * (h * sinTheta - w * cosTheta) / 2;
    float dy = s * (h * cosTheta + w * sinTheta) / (-2);
    singleFloorMap.xOffset = [NSNumber numberWithFloat:dx];
    singleFloorMap.yOffset = [NSNumber numberWithFloat:dy];
    //
    // 缩放后的地图尺寸(对应ScrollView的contentSize)
    float cosAlpha, sinAlpha;
    float rotation = [singleFloorMap.rotation floatValue];
    while (rotation < 0) {
        rotation += 360;
    }
    while (rotation > 360) {
        rotation -= 360;
    }
    if (rotation >= 0 && rotation < 90) {
        cosAlpha = cos(toRadians(rotation));
        sinAlpha = sin(toRadians(rotation));
    } else if (rotation >= 90 && rotation < 180) {
        cosAlpha = - cos(toRadians(rotation));
        sinAlpha = sin(toRadians(rotation));
    } else if (rotation >= 180 && rotation < 270) {
        cosAlpha = - cos(toRadians(rotation));
        sinAlpha = - sin(toRadians(rotation));
    } else {
        cosAlpha = cos(toRadians(rotation));
        sinAlpha = - sin(toRadians(rotation));
    }
    // 原理Step1：已知地图图片的宽高，以及旋转的角度(顺时针)，求旋转后的图片占据的宽高
    float w2 = w * cosAlpha + h * sinAlpha;
    float h2 = w * sinAlpha + h * cosAlpha;
    // 原理Step2：再乘以压缩比，得到ScrollView的contentSize
    singleFloorMap.contentWidth = w2 * s;
    singleFloorMap.contentHeight = h2 * s;
    
    return singleFloorMap;
}

// 设置输入界面的背景图片(楼层的地图)
- (void)setBgMap:(InWalkMap *)map {
    [self.uiManager showFloorBgView: map];
}

// 初始化 ARManager
- (void)initAr {
    self.arManager = [[InWalkARManager alloc] initWithCountainer:_container
                                                       productId:self.productId
                                                           paths:self.allPaths
                                                           nodes:self.allNodes
                                                          points:self.allPoints
                                                           UUIDS:self.UUIDS
                                                            maps:self.allMaps.allValues];
    self.arManager.delegate = self;
    
    [self.uiManager hideFloorBgView]; // 隐藏输入界面的背景图片
    
    self.hasRectifiedAngle = NO; // 未完成纠偏
}

// 释放持有的资源
- (void)releaseResource {
    if (_motionManager) {
        [_motionManager stopDeviceMotionUpdates];
        _motionManager = nil;
    }
    if (self.arManager) {
        [self.arManager releaseArResouce];
        _arManager = nil;
    }
    if (_uiManager) {
        [_uiManager releaseUIResource];
        _uiManager = nil;
    }
    _walkModel = nil;
    _allPaths = nil;
    _allPoints = nil;
    _allMaps = nil;
    _allNodes = nil;
    _allNavPoints = nil;
    _rvtsResult = nil;
    _navDetails = nil;
    self.container.backgroundColor = self.restoreBackgroundColor;
}

- (instancetype)initWithContainer:(nonnull UIView *)container data:(nonnull NSArray<NSData *> *)data {
    if (self = [self init]) {
        self.container = container;
        self.productId = @"5cbffd2664c2af7b7e53eaxx";
        self.restoreBackgroundColor = self.container.backgroundColor;
        
        [self updateMultiFloorData:data];
        
        InWalkWebImageManager.sharedManager.imageDownloader.shouldDecompressImages = NO;
        InWalkWebImageManager.sharedManager.imageCache.config.shouldDecompressImages = NO;
        InWalkWebImageManager.sharedManager.imageCache.config.shouldCacheImagesInMemory = NO;
    }
    return self;
}

// 解析多楼层数据
- (void)updateMultiFloorData:(nonnull NSArray<NSData *> *)data {
    // 0. cache
    NSMutableDictionary<NSString *, NSData *> *multiFloorData = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < data.count; i++) {
        [multiFloorData setObject:data[i] forKey:[NSString stringWithFormat:@"f%d", i]];
    }
    _multiFloorData = multiFloorData;

    // 1. 手动映射JSON与Model
    [self setClassPropertiesForDashi];
    
    // 2. 解析map数据
    NSMutableDictionary<NSString *, InWalkMap *> *mapList = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < data.count; i++) {
        InWalkMap *map = [[InWalkMap alloc] init];
        
        NSDictionary *dir = [NSJSONSerialization JSONObjectWithData:data[i] options:kNilOptions error:nil];
        map.uri = dir[@"mapSrc"];
        map.planeId = [NSNumber numberWithInt:i];
        map.name = dir[@"name"];
        map.tag = i;
        
        [mapList setObject:map forKey:[NSString stringWithFormat:@"f%d", i]];
    }
    
    _mapList = mapList;
    
    // 3. 默认展示第一个map
    self.uiManager = [[InWalkUIManager alloc] initWithSuperView:_container];
    self.uiManager.delegate = self;
    self.prepared = YES;
    
    // 设置输入界面的背景图片(楼层的地图)
    self.currentFloor = 0;
    [self setBgMap: [_mapList objectForKey:[NSString stringWithFormat:@"f%d", _currentFloor]]];
    
    // add 主页按钮、提示按钮
    [self.uiManager showTipButtons];
    [self.uiManager showFloors:mapList];
    
    [self showFloor];
}

- (void)onClickFloor:(int)tag {
    if (tag == _currentFloor) {
        return;
    }
    
    _currentFloor = tag;
    [self setBgMap: [_mapList objectForKey:[NSString stringWithFormat:@"f%d", _currentFloor]]];
    
    [self showFloor];
}

- (void)showFloor {
    
    // 4. 初始化第一个floor的数据，并进行展示
    [self initFloor];
    
    // 5. 展示输入界面
    [self.uiManager showStartPositionViewWithItems:self.allNavPoints];
}

- (void)initFloor {
    NSData *data = [_multiFloorData objectForKey:[NSString stringWithFormat:@"f%d", _currentFloor]];
    NSDictionary *dir = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
     
    if (![dir.allKeys containsObject:@"mapMeta"]) {
        //[self.container makeToast:@"该项目数据无效"];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"该项目数据无效" forKey:@"message"];
        NSError * tmpError = [NSError errorWithDomain:InWalkErrorDomain code:InWalkErrorCodeInit userInfo:userInfo];
        [self postError: tmpError];
        
        [self finishNavigation];
        return;
    }
    
    
    // 反向寻车
    self.reverse4CarVal = dir[@"reverse4Car"];
    
    // 注意：此处为临时代码（松日鼎盛停车场不支持反向寻车系统）
    _currentProject = [NSString stringWithFormat:@"%@", dir[@"name"]];
    if ([_currentProject containsString:@"松日"]) {
        self.reverse4CarVal = nil;
    }
    NSLog(@" ============= %@", _currentProject);
    
    InWalkItem *singleFloorData = [InWalkItem inWalk_objectWithKeyValues:dir[@"mapMeta"]];
    
    self.walkModel = [[InWalkModel alloc] init];
    self.walkModel.meta = @[singleFloorData];
    // floor map
    self.walkModel.meta[0].drawer = [self floorMapWithData:dir];
    self.walkModel.meta[0].drawer.northOffset = @45;
    if ([_currentProject containsString:@"B2"]) {
        self.walkModel.meta[0].drawer.northOffset = @90;
    }
    
    
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"gif_arrow.gif" ofType:nil]; //@"gif"
    NSLog(@"   path is %@", path);
    
    // maps, nodes, paths, points
    NSMutableDictionary<NSString *, InWalkMap *> *maps = [[NSMutableDictionary alloc] init];
    NSMutableDictionary<NSString *, InWalkNode *> *nodes = [[NSMutableDictionary alloc] init];
    NSMutableDictionary<NSString *, InWalkPath *> *paths = [[NSMutableDictionary alloc] init];
    NSMutableDictionary<NSString *, InWalkInnerPoint *> *points = [[NSMutableDictionary alloc] init];
    for (InWalkItem *singleFloorData in self.walkModel.meta) {
        //修改为double 提升精度
        double scale = [singleFloorData.drawer.plotScale doubleValue];
        for (InWalkPath *pi in singleFloorData.pathes) {
            if (pi.weight == nil) {
                pi.weight = [NSNumber numberWithFloat:1000000];
            }
            pi.floor = @-1; // 注意：此为必需项！
            NSMutableArray<NSNumber *> *numbers = [[NSMutableArray alloc] init];
            for (NSNumber *n in pi.data) {
                [numbers addObject:[NSNumber numberWithFloat:([n floatValue] / scale)]];
            }
            pi.data = numbers;
            [paths setObject:pi forKey:pi.pathID];
        }
        for (InWalkInnerPoint * pt in singleFloorData.navs) {
    
            pt.x = [NSNumber numberWithFloat:([pt.x floatValue] / scale)];
            pt.y = [NSNumber numberWithFloat:([pt.y floatValue] / scale)];
            pt.realX = [NSNumber numberWithFloat:([pt.realX floatValue] / scale)];
            pt.realY = [NSNumber numberWithFloat:([pt.realY floatValue] / scale)];
            
            [points setObject:pt forKey:pt.hid];
        }
        for (InWalkNode *node in singleFloorData.nodes) {
            NSMutableArray<NSNumber *> *numbers = [[NSMutableArray alloc] init];
            for (NSNumber *n in node.position) {
                [numbers addObject:[NSNumber numberWithFloat:([n floatValue] / scale)]];
            }
            node.position = numbers;
            [nodes setObject:node forKey:node.nodeID];
        }
        [maps setObject:singleFloorData.drawer forKey:singleFloorData.drawer.planeId];
    }
    self.allMaps = maps;
    self.allPaths = paths;
    self.allPoints = points;
    
    // nodes
    for (InWalkNode *node in nodes.allValues) {
        NSMutableArray<NSString *> *nodeIDs = [[NSMutableArray alloc] init];
        NSMutableArray<NSString *> *pathIDs = [[NSMutableArray alloc] init];
        for (InWalkPath *path in paths.allValues) {
            if ([path.headNodeID isEqualToString:node.nodeID]) {
                [nodeIDs addObject:path.tailNodeID ? path.tailNodeID : @"-1"];
                [pathIDs addObject:path.pathID];
            } else if ([path.tailNodeID isEqualToString:node.nodeID]) {
                [nodeIDs addObject:path.headNodeID ? path.headNodeID : @"-1"];
                [pathIDs addObject:path.pathID];
            }
        }
        node.nodeIDs = nodeIDs;
        node.pathIDs = pathIDs;
    }
    self.allNodes = nodes;
    
    self.walkModel.supportRvts = NO;

    [self setNavPointsData];
    
    //开始搜索ibeacon
//    __weak typeof(self) weakSelf = self;
//    
//    [[InWalkIbeaconManager manager] startSearchIbeaconWithUUIDS:self.UUIDS iBeaconResultBlcok:^(BRTBeacon * _Nonnull beacon) {
//        [weakSelf getUserNavPointWithBeacon:beacon];
//    }];
    
}

/*
 -------------------------------------
 -------------------------------------
 2019.06.25新增 ibeacon定位 角度纠偏相关
 */

-(NSArray *)UUIDS{
    NSMutableArray * tempArray = [NSMutableArray array];
    for (StartPositionModel * model in self.allNavPoints) {
        [tempArray addObject:model.keyId];
    }
    return [tempArray copy];
}





-(void)getUserNavPointWithBeacon:(BRTBeacon *)beacon{
    //否则定位用户当前位置
    for (StartPositionModel * model in self.allNavPoints) {
        if ([model.keyId.uppercaseString isEqualToString:beacon.proximityUUID.UUIDString]) {
            //更新ui
            [self.uiManager upDataOriginFormPosition:model];
            return;
        }
    }
}




@end
