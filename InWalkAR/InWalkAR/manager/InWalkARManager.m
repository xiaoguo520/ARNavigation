//
//  InWalkARManager.m
//  InWalkAR
//
//  Created by InWalk on 2019/5/8.
//  Copyright © 2019年 InWalk Co., Ltd. All rights reserved.
//

//#ifndef SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)
//#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
//#endif SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)

#import "InWalkARManager.h"
#import "InWalkModel.h"
#import "InWalkNavigationPathPoint.h"
#import "InWalkNavigationManager.h"
#import "InWalkMapManager.h"
#import "InWalkARAnchor.h"
#import <UIKit/UIKit.h>
#import <ARKit/ARKit.h>
#import <VideoToolBox/VideoToolBox.h>
#import "ViewUtil.h"
#import "MathUtil.h"
#import <CoreLocation/CoreLocation.h>
#import "GradientLayer.h"
#import <VideoToolBox/VideoToolBox.h>
#import "InWalkPointDesc.h"
#import "InWalkIbeaconManager.h"

@interface InWalkARManager()<ARSessionDelegate,ARSCNViewDelegate,InWalkMapDelegate,CLLocationManagerDelegate>

@property(nonatomic,strong) UIView *container;
@property(nonatomic,strong) InWalkMapManager *mapManager;
@property(nonatomic,strong) InWalkNavigationManager *navigationManager;
@property(nonatomic ,strong) CLLocationManager *mgr;

@property(nonatomic,strong) NSString *productId;
@property(nonatomic) NSArray<InWalkNavigationPathPoint *> *arPath; // ARKit中展示的导航路径(ARKit坐标系中的坐标)
@property(nonatomic,strong) NSArray<InWalkMap *> *allMaps;
@property(nonatomic,strong) NSDictionary<NSString *, InWalkPath *> *allPaths;
@property(nonatomic,strong) NSDictionary<NSString *, InWalkNode *> *allNodes;
@property(nonatomic,strong) NSDictionary<NSString *, InWalkInnerPoint *> *allPoints;

@property(nonatomic) simd_float4 corTransformV;  //坐标转换平移向量
@property(nonatomic) simd_float4x4 tranformMatix; //坐标转换矩阵 从tango坐标系转arkit
@property(nonatomic) simd_float4x4 inverseMatix; //坐标转换矩阵  从arkit坐标系转tango
@property(nonatomic,strong) ARSCNView *arscnView;  //ar渲染view
@property(nonatomic,strong) UILabel *tipTextView;   //显示图片定位结果
@property(nonatomic) NSTimeInterval lastFrameTime;  //ARFrame 刷新时间，用于固定时间检测当前导航位置
@property(nonatomic) NSTimeInterval lastUpdateDirectionTime;  //ARFrame 刷新时间，用于固定时间检测当前导航位置

@property(nonatomic) NSString *recognizePointId;    //定位导航Id
@property(nonatomic) BOOL located;                  //定位成功
@property(nonatomic) BOOL navigating;               //导航状态
@property(nonatomic) int currentIndex;              //当前位置处于导航路径点索引
@property(nonatomic,strong) SCNNode *preNode;       //导航ar贴图
@property(nonatomic,strong) SCNNode *currentNode;   //导航ar贴图
@property(nonatomic,strong) SCNNode *nextNode;      //导航ar贴图
@property(nonatomic,strong) NSMutableArray<SCNNode *> *nxNodes;      //导航ar贴图
@property(nonatomic,strong) SCNNode *preNodeText;
@property(nonatomic,strong) SCNNode *currentNodeText;
@property(nonatomic,strong) SCNNode *nextNodeText;
@property(nonatomic,strong) UILabel *testLabel;
@property(nonatomic) int planeId;
@property(nonatomic,strong) InWalkARAnchor *preAnchor;
@property(nonatomic,strong) InWalkARAnchor *curAnchor;
@property(nonatomic,strong) InWalkARAnchor *nextAnchor;
@property(nonatomic,strong) InWalkARAnchor *tipAnchor;

@property(nonatomic) float height;
@property(nonatomic) UIButton *stairButton;
@property(nonatomic) SCNNode *referNode;
@property(nonatomic) NSArray<NavigationModel *> *navDetails;

@property(nonatomic) simd_float4 startPosInAr; // 起点坐标(ARKit坐标)
@property(nonatomic) simd_float4 turnPosInAr; // 拐点坐标(ARKit坐标)
@property(nonatomic) NSTimeInterval lastFrameUpdateTime;
@property(nonatomic) InWalkInnerPoint *startPoint;
@property(nonatomic) float magNorthValue;
@property(nonatomic, strong) InWalkMap *mapData;
@property(nonatomic, strong) NSArray<NSNumber *> *mapPoint;
@property(nonatomic) simd_float4 prePos;
@property(nonatomic) float walkDistance;
@property(nonatomic) float rectifyDistance;
@property(nonatomic) simd_float4x4 magFrameTransform;
@property(nonatomic) BOOL isNavigationGuideEnabled;
@property(nonatomic) CGFloat xFovDegrees;
@property(nonatomic) UIImageView *directionTip;
//@property(nonatomic) CAShapeLayer *leftLayer;
//@property(nonatomic) CAShapeLayer *rightLayer;
@property(nonatomic) CAReplicatorLayer *leftLayer;
@property(nonatomic) CAReplicatorLayer *rightLayer;

//@property(nonatomic) SCNNode *referNode;
@property(nonatomic) UITapGestureRecognizer *gestureRecognizer;
@property(nonatomic) BOOL isDestViewExpand;
@property(nonatomic) NSMutableDictionary<NSString *, InWalkPointDesc *> *destArPoints;
@property(nonatomic) NSString *destPointId;
@property(nonatomic) float postWidth;
@property(nonatomic,strong) InWalkARAnchor *videoAnchor;
@property(nonatomic) int s1;
@property(nonatomic) int s2; // 视频摆放在第几个图标的位置(从0开始)
@property (nonatomic,strong) NSMutableArray * rectifyBeacons;
@property (nonatomic,strong) NSArray * UUIDS;
//是否进行设备纠偏
@property (nonatomic,assign) BOOL isIBeaconRectify;
@property (nonatomic,strong) InWalkInnerPoint * lastIbeaconPoint;
@property (nonatomic,strong) ARFrame * lastARIbeaconPoint;
@property (nonatomic,strong) InWalkInnerPoint * currentIbeaconPoint;
@property (nonatomic,assign) int rectifyCount;
@property (nonatomic,assign) float distance;
@property(nonatomic) simd_float4 distancePrePos;

//区间纠偏的参数
@property(nonatomic) float sectionWalkDistance;
@property(nonatomic) simd_float4 sectionPrePos;
@property(nonatomic) NSTimeInterval sectionLastFrameUpdateTime;
@property (nonatomic,strong) InWalkInnerPoint * lastSectionPoint;
@property (nonatomic,strong) ARFrame * lastARSectionPoint;
@end

@implementation InWalkARManager

-(instancetype)initWithCountainer:(UIView *)container
                        productId:(NSString *) productId
                            paths:(NSDictionary<NSString *, InWalkPath *> *) paths
                            nodes:(NSDictionary<NSString *, InWalkNode *> *) nodes
                           points:(NSDictionary<NSString *, InWalkInnerPoint *> *) points
                            UUIDS:(NSArray *)uuids
                             maps:(NSArray<InWalkMap *> *)maps{
    if(self = [super init]){
        self.container = container;
        self.productId = productId;
        self.allPaths = paths;
        self.allNodes = nodes;
        self.allPoints = points;
        self.allMaps = maps;
        self.lastFrameTime = 0;
        self.isNavigationGuideEnabled = NO;
        self.lastUpdateDirectionTime = 0;
        self.xFovDegrees = 0;
        self.s2 = 4;
        //
        _tipTextView = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, container.frame.size.width, 100)];
        _tipTextView.textAlignment = NSTextAlignmentCenter;
        _tipTextView.textColor = UIColor.redColor;
        
        //
        _testLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, container.frame.size.width, 100)];
        _testLabel.textAlignment = NSTextAlignmentCenter;
        _testLabel.textColor = UIColor.redColor;
        //[container insertSubview:_tipTextView atIndex:0];
        //[container insertSubview:_testLabel atIndex:0];
        
        self.navigationManager = [[InWalkNavigationManager alloc] initWithPaths:paths nodes:nodes points:points];
        
        self.mapManager = [[InWalkMapManager alloc] initWithPaths:paths];
        self.mapManager.delegate = self;
        [self.container addSubview:self.mapManager.mapView];
        
        _walkDistance = -1;
        _rectifyDistance = 0.1;//0.1;//10; // 10米处纠偏
        //_rectifyDistance = 0.1;
        _rectifyCount = 0;
        _distance = 0;
        [self setupARSession];
        
        self.magNorthValue = 0x2ff;
        self.mgr.delegate = self;
        [self.mgr startUpdatingHeading];
        
        [self hideDebugInfo:YES]; // todo 仅供测试
        
        
        
    }
    return self;
}


#pragma mark - ARKit相关
// ARKit初始化
- (void)setupARSession {
    _arscnView = [[ARSCNView alloc] initWithFrame:_container.bounds];
    // todo 仅供测试
//    _arscnView.debugOptions = ARSCNDebugOptionShowWorldOrigin|ARSCNDebugOptionShowFeaturePoints;
    [_container insertSubview:_arscnView atIndex:0];
    
    ARWorldTrackingConfiguration *config = [ARWorldTrackingConfiguration new];
//    config.planeDetection = ARPlaneDetectionHorizontal; // 检测水平平面
//    config.worldAlignment = ARWorldAlignmentGravityAndHeading; // X、Y、Z 三轴固定朝向正东、正上、正南
    config.worldAlignment = ARWorldAlignmentGravity;
    if (@available(iOS 11.3, *)) {
        config.autoFocusEnabled = NO;
    }
    [_arscnView.session runWithConfiguration:config];
    
    _arscnView.session.delegate = self;
    _arscnView.delegate = self;
    
    [self initDestArPoints];
    self.postWidth = 1.5;
    self.s1 = 1;
    // 点击AR模型/图片，处理相应事件
    _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [_arscnView addGestureRecognizer:_gestureRecognizer];
}

- (void)sessionWasInterrupted:(ARSession *)session {
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    
}

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    
}

- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {
    
    if ([self rectifyAtTenMeters:frame]) {
        // 开始展示AR路径图标
        self.isNavigationGuideEnabled = YES;
        
        [self updateNavigation:-1];
        
        // 小地图缩小
        [self.mapManager showMap:NO];
        [self.mapManager setTouchEnabled:YES];
        
        // 回调
        if (_delegate) {
            [_delegate onAngleRectified];
        }
        
        return;
    }
    
    //开始设备纠偏
    if (_isIBeaconRectify) {
        [self rectifyAtWithLastPoint:_lastIbeaconPoint CurrentPoint:_currentIbeaconPoint withCurrectArFrame:frame];
        //区间纠偏参数置空
        _sectionWalkDistance = 0;
        _sectionPrePos = simd_make_float4(0, 0, 0, 0);
        _sectionLastFrameUpdateTime = 0;
        return;
    }
    
    
    
    
    // 0.1秒刷新一次当前位置及朝向
    if(_located && frame.timestamp - _lastUpdateDirectionTime > 0.1){
        _lastUpdateDirectionTime = frame.timestamp;
        simd_float4 forwardPosition = simd_make_float4(0,0,-100,1);
        forwardPosition = simd_mul(frame.camera.transform, forwardPosition);
        forwardPosition = simd_make_float4(forwardPosition[0],forwardPosition[2],0,forwardPosition[3]); // x,z,0,w
        _forwardPosition =simd_make_float3(simd_mul(_inverseMatix, forwardPosition));
        
        simd_float4 position = simd_make_float4(0,0,0,1);
        position= simd_mul(frame.camera.transform, position);
        position = simd_make_float4(position[0],position[2],position[1],position[3]); // x,z,y,w
        position =simd_mul(_inverseMatix, position);
        _currentPoistion = CGPointMake(position[0], position[1]);
        
        [_mapManager updateCurrentPosition:_currentPoistion];
        [_mapManager updateCurrentForwardPosition:CGPointMake(_forwardPosition[0], _forwardPosition[1])];
        
        // 刷新朝向提示（偏移路径方向时的提示标识 左/右）
        if (self.xFovDegrees == 0) {
            CGSize imageResolution = frame.camera.imageResolution;
            simd_float3x3 intrinsics = frame.camera.intrinsics;
            self.xFovDegrees = 2 * atan(imageResolution.width/(2 * intrinsics.columns[0][0])) * 180/M_PI;
            //CGFloat yFovDegrees = 2 * atan(imageResolution.height/(2 * intrinsics.columns[1][1])) * 180/M_PI;
            //NSLog(@"xFov: %f  yFov: %f", xFovDegrees, yFovDegrees);
            if (!_directionTip) {
                [self initDirectionTipView];
            }
        }
        if (!_directionTip.isHidden) {
            [self refreshDirectionTipView];
        }
    }
    
    // 这个值与每个导航贴图的间距有关
    float secondInterval = 0.5f;
    if(_navigating && frame.timestamp - _lastFrameTime > secondInterval){
        [self updateCurrentNavigatingIndex:frame];
        _lastFrameTime = frame.timestamp;
    } else {
        ////NSLog(@"update frame :");
    }

    //计算距离
    simd_float4 camPos = simd_make_float4(0,0,0,1);
    camPos = simd_mul(frame.camera.transform, camPos);
    if (_distance >= 0) {
        float dx = camPos[0]-_distancePrePos[0];
        float dz = camPos[2]-_distancePrePos[2];
        float distance = sqrtf((dx*dx + dz*dz));
        if (distance > 0.4) {
            _distance += distance;
            _distancePrePos[0] = camPos[0];
            _distancePrePos[1] = camPos[1];
            _distancePrePos[2] = camPos[2];
        }
//        NSLog(@" ** Ar walkDistance: %f", _distance);
    }
}


#pragma mark - 刷新当前所处位置，通过将{当前所处实际位置}与{当前ARKit坐标}进行映射，建立起{后台数据的坐标系}与{ARKit坐标系}的映射
// 更新当前位置
- (void)updateCurrentPoint:(NSString *)pointId {
    InWalkInnerPoint *point = [self getPointById:pointId];
    
    if(point){
        // 将camera的转换矩阵中的y和z交换(和AR展示有关系，与小地图无关)
        simd_float4x4 transform = _arscnView.session.currentFrame.camera.transform;
        
        _corTransformV = simd_make_float4(0, 0, 0, 1);
        _corTransformV = matrix_multiply(transform, _corTransformV);
        float y = _corTransformV.y;
        _corTransformV.y = _corTransformV.z;
        _corTransformV.z = y;
        _startPoint = [[InWalkInnerPoint alloc] init];
        _startPoint.x = point.x;
        _startPoint.y = point.y;
        
        [self updateMatrix:point];
    }
}

/**
 根据定位点生成后台数据的坐标系到ARKit坐标系的转换矩阵
 @param point 定位点（当前位置对应的导航点）
 */
- (void)updateMatrix:(InWalkInnerPoint *)point {
    //获取当前定位楼层
    _recognizePointId = point.hid;
    InWalkPath *path = [self getPathById:point.pathID];
    NSNumber *planeId = path.floor; //[_currentFloorData nodeForId:nodeID].floor;
    _planeId = planeId.floatValue;
    InWalkMap *map;// = [_dataModel mapForPlaneId:planeId];
    for (InWalkMap *m in self.allMaps) {
        if ([m.planeId isEqualToNumber:planeId]) {
            map = m;
            break;
        }
    }
    if(map == nil){
        return;
    }
    
    // 重新计算角度(需要读取到指南针数据)：从-Z轴到正北方向的角度（先计算当前朝向与-Z轴的角度，再叠加当前指南针读数，两者的差值即为所求）
    if (_mgr != nil && self.magNorthValue < 361) {
        // north to current heading(顺时针)
        [self.mgr stopUpdatingHeading];

        // current heading to ARKit.-Z轴(顺时针)
        simd_float4 forwardPosition = simd_make_float4(0,0,-100,1);
        //magFrameTransform
        forwardPosition = simd_mul(_magFrameTransform, forwardPosition);
        forwardPosition = simd_make_float4(forwardPosition[0],0,forwardPosition[2],forwardPosition[3]); // x,0,z,w
        simd_float4 minusZAxis = simd_make_float4(0,0,-1,1); // 0,0,-1
        float angle = [self calcVectorAngleFrom:forwardPosition to:minusZAxis]; // 顺时针(c -> -z)
        
        
        
        // angle为nan的情况
        
        
        
        //NSLog(@" ** angle: %f", angle);

        // 叠加两个角度 north to ARKit.-Z轴(顺时针) （若-Z轴指向正北，此值应为0）
        float angle2 = self.magNorthValue + angle;
        while (angle2 > 360) {
            angle2 -= 360;
        }
        while (angle2 < -360) {
            angle2 += 360;
        }

        // 与原始数据的叠加
        map.northOffset = [NSNumber numberWithFloat:(map.northOffset.floatValue - angle2)];
        
        _mapData = map;
    }
    
    [_mapManager updateMap:map];
    
    // 此处根据path的实际数据结构改动
    //NSArray<NSNumber *> *realPoistion = [path positionAtIndex:point.pointIndex];
    NSArray<NSNumber *> *realPoistion = @[point.x, point.y, [NSNumber numberWithInt:0]];
    _mapPoint = @[point.x, point.y, [NSNumber numberWithInt:0]];
    _currentPoistion = CGPointMake(realPoistion[0].floatValue, realPoistion[1].floatValue);
    _height = _corTransformV.z;
    _located = YES;
    
    [self updataTranformMatix];
    
    [self.mgr startUpdatingHeading]; // 如果需要实时纠偏的话，在此开启指南针读数更新
}


//更新坐标转换矩阵
-(void)updataTranformMatix{
    //第一次坐标变换
    SCNMatrix4 tranformMatix = SCNMatrix4Identity;
    tranformMatix = SCNMatrix4Translate(tranformMatix, -_mapPoint[0].floatValue, -_mapPoint[1].floatValue,-_mapPoint[2].floatValue);
    //第二次坐标变换
    float rotateAngle = _mapData.northOffset.floatValue *M_PI / 180;
    tranformMatix = SCNMatrix4Rotate(tranformMatix, rotateAngle, 0, 0, 1);
    //第三次坐标变换
    tranformMatix = SCNMatrix4Translate(tranformMatix, _corTransformV.x,_corTransformV.y,_corTransformV.z);
    
    _tranformMatix =  SCNMatrix4ToMat4(tranformMatix);
    _inverseMatix = simd_inverse(_tranformMatix);
}



#pragma mark - 开始导航
/**
 根据目标导航点生成导航路径，并计算出在ARKit坐标系中的路径点
 @param pointId 目标导航点
 */
- (void)startNavigationTo:(NSString*)pointId {
    [self.navigationManager navigateFrom: [self getPointById:_recognizePointId] to:[self getPointById:pointId]];
    _navDetails = [self.navigationManager getNavDetails];
    
    NSMutableArray<InWalkNavigationPathPoint *> *tmpPath = [[NSMutableArray alloc] initWithCapacity:self.navigationManager.navigationPath.count];
    int count = 0;
    for (InWalkNavigationPathPoint *pathPoint in self.navigationManager.navigationPath) {
        InWalkNavigationPathPoint *tmpArPoint = [InWalkNavigationPathPoint new];
        
        InWalkPath *path = [self getPathById: pathPoint.pathID];
        //NSNumber *planeId = path.floor;
        pathPoint.floor = path.floor.intValue;
        //NSArray<NSNumber *> *position = [path positionAtIndex:pathPoint.pointIndex];
        float height = -1.3;
        if (count == _s2) {
            height = 0.2; // 摆放视频(竖立图标)时用到
        }
        count++;
        NSArray<NSNumber *> *position = @[[NSNumber numberWithFloat:pathPoint.pathPosition[0]],
                                          [NSNumber numberWithFloat:pathPoint.pathPosition[1]],
                                          [NSNumber numberWithFloat:height]];
                                          //[NSNumber numberWithFloat:-1.3]];
        simd_float4 simd_position = simd_make_float4(position[0].floatValue,position[1].floatValue,position[2].floatValue,1);
        simd_float4 result = simd_mul(_tranformMatix, simd_position);
        
        tmpArPoint.pathPosition = simd_make_float3(result.x,result.z,result.y);
        tmpArPoint.angleToNext = pathPoint.angleToNext;
        tmpArPoint.turnFlag = pathPoint.turnFlag;
        [tmpPath addObject:tmpArPoint];
    }
    _arPath = tmpPath;
    _arPath.lastObject.hid = pointId;
    _destPointId = pointId;
    NSLog(@"   dest hid : %@", pointId);
    
    _navigating = YES;
    [self updateNavigation:-1];
    _walkDistance = 0;
    
    // 生成地图上导航路径对应的数组
    NSMutableArray<NSValue *> *mapPath = [NSMutableArray arrayWithCapacity:_arPath.count];
    for (InWalkNavigationPathPoint *pathPoint in self.navigationManager.navigationPath) {
        if(pathPoint.floor == _planeId){
            NSValue *value = [NSValue valueWithCGPoint:CGPointMake(pathPoint.pathPosition[0],pathPoint.pathPosition[1])];
            [mapPath addObject:value];
        }
    }
    [_mapManager updateNavigationPath: mapPath];
    [_mapManager showMap:YES];
    
    
}

-(NSArray *)UUIDS{
    if (!_UUIDS) {
        NSMutableArray * tempArray = [NSMutableArray array];
        for (InWalkInnerPoint * p in self.navigationManager.beaconNavigationPath) {
            
            [tempArray addObject:p.hid];
        }
        _UUIDS = [tempArray copy];
    }
    return _UUIDS;
}


#pragma mark - 纠偏尝试：从起点行走到10米处进行角度纠偏
- (BOOL)rectifyAtTenMeters:(ARFrame *)frame {
    // 0.4s记录一次累计行走距离
    if (_walkDistance != -1 && frame.timestamp - _lastFrameUpdateTime > 0.4) {
        // 记录当前cam的AR位置
        simd_float4 camPos = simd_make_float4(0,0,0,1);
        camPos = simd_mul(frame.camera.transform, camPos);
        // 累加行走距离
        if (_walkDistance >= 0) {
            float dx = camPos[0]-_prePos[0];
            float dz = camPos[2]-_prePos[2];
            float distance = sqrtf((dx*dx + dz*dz));
            if (distance > 0.4) {
                _walkDistance += distance;
                _prePos[0] = camPos[0];
                _prePos[1] = camPos[1];
                _prePos[2] = camPos[2];
            }
            //NSLog(@" ** walkDistance: %f", _walkDistance);
        }
        
        // 行走距离达到10m时，进行纠偏，并提示
        if (_walkDistance >= _rectifyDistance) {
            // 找到原始数据中距离起点10m的point，对比{起点AR坐标->Cam的AR坐标}与{起点AR坐标->原始数据距离起点5m的点对应的AR坐标}的角度
            float x0 = self.navigationManager.completeNavigationPath[0].pathPosition[0];
            float y0 = self.navigationManager.completeNavigationPath[0].pathPosition[1];
            float vX = 0, vY = 0;
            for (InWalkNavigationPathPoint *pathPoint in self.navigationManager.completeNavigationPath) {
                float dx = pathPoint.pathPosition[0] - x0;
                float dy = pathPoint.pathPosition[1] - y0;
                float tmpDelta = sqrtf(dx*dx + dy*dy);
                //NSLog(@" tmpDelta: %f", tmpDelta);
                if (tmpDelta > _walkDistance) {
                    vX = pathPoint.pathPosition[0];
                    vY = pathPoint.pathPosition[1];
                    //NSLog(@" tmpDelta.2: %f  %f", tmpDelta, _walkDistance);
                    break;
                }
            }
            // 起点AR坐标
            simd_float4 start = simd_make_float4(x0,y0,0,1);
            start = simd_mul(_tranformMatix, start); // 注意：Tango数据通过转换矩阵转为ARKit坐标后，y值是实际对应ARKit坐标系中Z轴的值
            // 原始数据距离起点5m的点对应的AR坐标
            simd_float4 simd_position = simd_make_float4(vX, vY, 0, 1);
            simd_float4 mapArPos = simd_mul(_tranformMatix, simd_position); // 注意：Tango数据通过转换矩阵转为ARKit坐标后，y值是实际对应ARKit坐标系中Z轴的值
            // 角度1:向量{起点AR坐标->Cam的AR坐标}到向量{起点AR坐标->原始数据距离起点10m的点对应的AR坐标}的顺时针夹角
            simd_float4 t1 = simd_make_float4(camPos[0]-start[0],0,camPos[2]-start[1],1);
            simd_float4 t2 = simd_make_float4(mapArPos[0]-start[0],0,mapArPos[1]-start[1],1);
            float anglet = [self calcVectorAngleFrom:t1 to:t2];
            //NSLog(@" ** wa angle diff: %f", anglet);
            // 叠加到原始数据中
            NSLog(@"十米纠偏角度为%lf",anglet);
            float angle3 = _mapData.northOffset.floatValue;
            angle3 = angle3 + 360 - anglet;
            //NSLog(@" ** wa angle4: %f", angle3);
            _mapData.northOffset = [NSNumber numberWithFloat:angle3];
            
            // step2, update 小地图.
            [_mapManager updateMap:_mapData];
            
            // step3, update Tango坐标到ARKit坐标的转换矩阵.
            // 第一次坐标变换：将新坐标系平移，使Tango起点和新坐标系原点重合
            SCNMatrix4 tranformMatix = SCNMatrix4Identity;
            tranformMatix = SCNMatrix4Translate(tranformMatix, -_mapPoint[0].floatValue, -_mapPoint[1].floatValue,-_mapPoint[2].floatValue);
            float rotateAngle = _mapData.northOffset.floatValue *M_PI / 180;
            // 第二次坐标变换：将新坐标系旋转，使其+Y轴与ARKit坐标系的-Z轴方向一致
            tranformMatix = SCNMatrix4Rotate(tranformMatix, rotateAngle, 0, 0, 1);
            // 第三次坐标变换：将新坐标系平移，使其与ARKit坐标系完全重合
            tranformMatix = SCNMatrix4Translate(tranformMatix, _corTransformV.x,_corTransformV.y,_corTransformV.z);
            //
            _tranformMatix =  SCNMatrix4ToMat4(tranformMatix);
            _inverseMatix = simd_inverse(_tranformMatix);
            
            NSMutableArray<InWalkNavigationPathPoint *> *tmpPath = [[NSMutableArray alloc] initWithCapacity:self.navigationManager.navigationPath.count];
            int count = 0;
            for (InWalkNavigationPathPoint *pathPoint in self.navigationManager.navigationPath) {
                InWalkNavigationPathPoint *tmpArPoint = [InWalkNavigationPathPoint new];
                
                InWalkPath *path = [self getPathById: pathPoint.pathID];
                pathPoint.floor = path.floor.intValue;
                
                float height = -1.3;
                if (count == _s2) {
                    height = 0.2; // 摆放视频(竖立图标)时用到
                }
                count++;
                
                NSArray<NSNumber *> *position = @[[NSNumber numberWithFloat:pathPoint.pathPosition[0]], // tango.x
                                                  [NSNumber numberWithFloat:pathPoint.pathPosition[1]], // tango.y
                                                  [NSNumber numberWithFloat:height]];
                                                  //[NSNumber numberWithFloat:-1.3]];
                simd_float4 simd_position = simd_make_float4(position[0].floatValue,position[1].floatValue,position[2].floatValue,1);
                simd_float4 result = simd_mul(_tranformMatix, simd_position);
                
                tmpArPoint.pathPosition = simd_make_float3(result.x,result.z,result.y); // swap(y,z)
                tmpArPoint.angleToNext = pathPoint.angleToNext;
                tmpArPoint.turnFlag = pathPoint.turnFlag;
                [tmpPath addObject:tmpArPoint];
            }
            _arPath = tmpPath;
            
            // step4, update navigation guide.
            [self updateNavigationGuide];
            
            _walkDistance = -1;
            _lastFrameUpdateTime = frame.timestamp;
            
            //十米纠偏完成，进行纠偏 避免冲突
            //开始搜索ibeacon
            __weak typeof(self) weakSelf = self;
            
//            [[InWalkIbeaconManager manager] startSearchIbeaconWithUUIDS:self.UUIDS iBeaconResultBlcok:^(BRTBeacon * _Nonnull beacon) {
//                [weakSelf rectifyAtBeaconsWithBeacon:beacon];
//            }];
            
            //            [self.container makeToast:@"已经行走10m了，纠偏完成"];
            return YES; // 已进行纠偏
        }
        _lastFrameUpdateTime = frame.timestamp;
    }
    return NO; // 未纠偏
}


#pragma mark - ARKit中的贴图/模型相关
// 更新导航指引贴图(distanceToNext是当前位置到下一个AR贴图的距离)
- (void)updateNavigation:(float)distanceToNext {
    if (!_delegate) {
        [self updateNavigationGuide];
        return;
    }
    
    if (_currentIndex == 0 || _navDetails == nil) {
        _navDetails = [self.navigationManager getNavDetails];//:_arPath];
        [_delegate updateNavigationDetails:_navDetails];
        //float totalDistance = [self.navigationManager totalLength];
        // totalDistance:totalDistance];
    }
    NavigationModel *tip = [self.navigationManager calcRealtimeDistanceAtIndex:_currentIndex];// onPath:_arPath];
    
    // 刷新小地图剩余的导航路径
    if (distanceToNext != -1) {
        // 计算小地图上对应的点，刷新剩余的导航路径
        float distanceToEnd = tip.distanceToEnd + distanceToNext;
        // 已经行走的距离
        float walkedDistance = self.navigationManager.totalLength - distanceToEnd;
        if (walkedDistance <= 0) {
            walkedDistance = self.navigationManager.totalLength;
        } else if (walkedDistance > self.navigationManager.totalLength) {
            walkedDistance = self.navigationManager.totalLength;
        }
        
        // 生成地图上导航路径对应的数组
        NSMutableArray<NSValue *> *mapPath = [[NSMutableArray alloc] init];
        float sum = 0, dx, dy;
        InWalkNavigationPathPoint *prePt;
        BOOL hasFindFirstPt = NO;
        for (InWalkNavigationPathPoint *pathPoint in self.navigationManager.navigationPath) {
            if(pathPoint.floor == _planeId){
                if (!prePt) {
                    prePt = pathPoint;
                } else {
                    if (hasFindFirstPt) {
                        // 已经找到第一个点，直接添加到集合
                        NSValue *value = [NSValue valueWithCGPoint:CGPointMake(pathPoint.pathPosition[0],pathPoint.pathPosition[1])];
                        [mapPath addObject:value];
                    } else {
                        // 还未找到第一个点，继续查找
                        dx = pathPoint.pathPosition[0] - prePt.pathPosition[0];
                        dy = pathPoint.pathPosition[1] - prePt.pathPosition[1];
                        sum += sqrtf(dx*dx+dy*dy);
                        hasFindFirstPt = (sum >= walkedDistance);
                        prePt = pathPoint;
                    }
                }
            }
        }
        if (mapPath.count > 1) {
            [_mapManager updateNavigationPath: mapPath];
        }
    }
    
    [_delegate updateNavigationTip:tip];
    [self updateNavigationGuide];
}

// 更新导航指引贴图
- (void)updateNavigationGuide {
    if (!self.isNavigationGuideEnabled) {
        return;
    }
    
    [self clearNavigationGuide];
    //if(_arPath != nil && _arPath[_currentIndex].isStair) //[self showStairButton];
    
    InWalkARAnchor *previousAnchor = nil;
    InWalkNavigationPathPoint *pt;
    float theta = 90 - _mapData.northOffset.floatValue; // 路径图标的角度计算方法
    
    // 更新第一个点（当前位置）
    if(_currentIndex < _arPath.count && !_videoAnchor){
        pt = _arPath[_currentIndex];
        
        // 先旋转，再平移
        SCNMatrix4 matrix;
        if (_currentIndex + 1 == _arPath.count) {
            matrix = SCNMatrix4MakeTranslation(pt.pathPosition[0], pt.pathPosition[1], pt.pathPosition[2]);
        } else {
            // 图片默认是竖直展示的，需要经过几次旋转后才能正确的水平展示
//            matrix = SCNMatrix4MakeRotation(M_PI/2, 0, 0, 1);
            matrix = SCNMatrix4MakeRotation(M_PI*2, 0, 0, 1); // 使用GIF图
            matrix = SCNMatrix4Rotate(matrix, 0, -M_PI/2, 0, 1); // 水平铺设时用到
            matrix = SCNMatrix4Rotate(matrix, ((theta + pt.angleToNext) / 180 * M_PI), 0, 1, 0);
            matrix = SCNMatrix4Translate(matrix, pt.pathPosition[0], pt.pathPosition[1], pt.pathPosition[2]);
        }
        simd_float4x4 preTransform = SCNMatrix4ToMat4(matrix);
        
        _preAnchor = [[InWalkARAnchor alloc] initWithTransform:preTransform];
        _preAnchor.title = @"navigationGuide";
        _preAnchor.flag = 1;
        _preAnchor.turnFlag = pt.turnFlag;
        _preAnchor.hid = pt.hid;
        _preAnchor.tag = _currentIndex;
        //if( _arPath[_currentIndex].isStair) _preAnchor.title = @"navigationEnd";
        previousAnchor = _preAnchor;
        [_arscnView.session addAnchor:_preAnchor];
    }
    
    NSMutableArray<SCNNode *> *tmpNxNodes = [[NSMutableArray alloc] init];
//    // 更新第二个点～第四个点(na小于等于4)
//    int na = (int)_arPath.count - _currentIndex - 1;
//    if (na > 4) {
//        na = 4;
//    } else {
//        na--;
//    }
    // 更新第二个点～倒数第二个点(na值为arPath.count-currentIndex-2)
    int na = (int)_arPath.count - _currentIndex - 2;
    
    for (int i = 1; i <= na; i++) {
        pt = _arPath[_currentIndex + i];

        // 先旋转，再平移
//        SCNMatrix4 matrix = SCNMatrix4MakeRotation(M_PI/2, 0, 0, 1);
//        matrix = SCNMatrix4Rotate(matrix, -M_PI/2, 1, 0, 0);
//        matrix = SCNMatrix4Rotate(matrix, ((theta + pt.angleToNext) / 180 * M_PI), 0, 1, 0);
//        matrix = SCNMatrix4Translate(matrix, pt.pathPosition[0], pt.pathPosition[1], pt.pathPosition[2]);
        SCNMatrix4 matrix;
        if (_currentIndex + i == _s2) {
            //matrix = SCNMatrix4MakeRotation(((theta + pt.angleToNext + 90) / 180 * M_PI), 0, 1, 0);
            matrix = SCNMatrix4MakeTranslation(2, 0, 0);
            matrix = SCNMatrix4Rotate(matrix, ((theta + pt.angleToNext + 90) / 180 * M_PI), 0, 1, 0);
                                      
            matrix = SCNMatrix4Translate(matrix, pt.pathPosition[0], pt.pathPosition[1], pt.pathPosition[2]);
            simd_float4x4 curTransform = SCNMatrix4ToMat4(matrix);
            
            if (!_videoAnchor) {
                _videoAnchor = [[InWalkARAnchor alloc] initWithTransform:curTransform];
                _videoAnchor.title = @"navigationGuide";
                _videoAnchor.flag = 2;
                _videoAnchor.turnFlag = pt.turnFlag;
                _videoAnchor.hid = pt.hid;
                _videoAnchor.tag = _s2;
                
                if (previousAnchor) {
                    SCNBillboardConstraint *constraint = [SCNBillboardConstraint billboardConstraint];
                    constraint.freeAxes = SCNBillboardAxisY;
                    previousAnchor.constraints = @[constraint];
                }
                [_arscnView.session addAnchor:_videoAnchor];
            }
        } else {
//            matrix = SCNMatrix4MakeRotation(M_PI/2, 0, 0, 1);
            matrix = SCNMatrix4MakeRotation(M_PI*2, 0, 0, 1); // 使用GIF图
            matrix = SCNMatrix4Rotate(matrix, 0, -M_PI/2, 0, 1); // 水平铺设时用到
            matrix = SCNMatrix4Rotate(matrix, ((theta + pt.angleToNext) / 180 * M_PI), 0, 1, 0);
            matrix = SCNMatrix4Translate(matrix, pt.pathPosition[0], pt.pathPosition[1], pt.pathPosition[2]);
            simd_float4x4 curTransform = SCNMatrix4ToMat4(matrix);
            
            //        _curAnchor = [[InWalkARAnchor alloc] initWithTransform:curTransform];
            //        _curAnchor.title = @"navigationGuide";
            //        _curAnchor.flag = 2;
            //        //if(_arPath[_currentIndex + 1].isStair){
            //        //    _curAnchor.title = @"navigationEnd";
            //        //}
            //        [_arscnView.session addAnchor:_curAnchor];
            
            InWalkARAnchor *n1 = [[InWalkARAnchor alloc] initWithTransform:curTransform];
            n1.title = @"navigationGuide";
            n1.flag = 2;
            n1.turnFlag = pt.turnFlag;
            n1.hid = pt.hid;
            n1.tag = _currentIndex + i;
            [tmpNxNodes addObject:(SCNNode *)n1];
            if (previousAnchor) {
                SCNBillboardConstraint *constraint = [SCNBillboardConstraint billboardConstraint];
                constraint.freeAxes = SCNBillboardAxisY;
                previousAnchor.constraints = @[constraint];
                previousAnchor = n1;
            }
            [_arscnView.session addAnchor:n1];
        }
    }
    _nxNodes = tmpNxNodes;
    
    // 更新第五个点/最后一个点
    na++;
    if(_currentIndex + na < _arPath.count){
        pt = _arPath[_currentIndex + na];

        // 先旋转，再平移
        SCNMatrix4 matrix;
        if (_currentIndex + na + 1 == _arPath.count) {
            matrix = SCNMatrix4MakeTranslation(pt.pathPosition[0], 1.3, pt.pathPosition[2]);
            
            if (_currentIndex + na > 1) {
                InWalkNavigationPathPoint *prePt = _arPath[_currentIndex + na - 1];
                matrix = SCNMatrix4MakeRotation(((theta + prePt.angleToNext + 90) / 180 * M_PI), 0, 1, 0);
                matrix = SCNMatrix4Translate(matrix, pt.pathPosition[0], 1.3, pt.pathPosition[2]);
            } else {
                matrix = SCNMatrix4MakeTranslation(pt.pathPosition[0], 1.3, pt.pathPosition[2]);
            }
            
        } else {
//            matrix = SCNMatrix4MakeRotation(M_PI/2, 0, 0, 1);
            matrix = SCNMatrix4MakeRotation(M_PI*2, 0, 0, 1); // 使用GIF图
            matrix = SCNMatrix4Rotate(matrix, 0, -M_PI/2, 0, 1); // 水平铺设时用到
            matrix = SCNMatrix4Rotate(matrix, ((theta + pt.angleToNext) / 180 * M_PI), 0, 1, 0);
            matrix = SCNMatrix4Translate(matrix, pt.pathPosition[0], pt.pathPosition[1], pt.pathPosition[2]);
        }
        simd_float4x4 nextTransform = SCNMatrix4ToMat4(matrix);
        
        _nextAnchor = [[InWalkARAnchor alloc] initWithTransform:nextTransform];
        if (_currentIndex + na + 1 == _arPath.count) {
            _nextAnchor.title = @"navigationEnd";
        } else {
            _nextAnchor.title = @"navigationGuide";
            if (previousAnchor) {
                SCNBillboardConstraint *constraint = [SCNBillboardConstraint billboardConstraint];
                constraint.freeAxes = SCNBillboardAxisY;
                previousAnchor.constraints = @[constraint];
                previousAnchor = _nextAnchor;
                previousAnchor = nil;
            }
            _nextAnchor.constraints = nil;
        }
        _nextAnchor.flag = 3;
        _nextAnchor.turnFlag = pt.turnFlag;
        _nextAnchor.tag = _currentIndex + na;
        _nextAnchor.hid = pt.hid;
        [_arscnView.session addAnchor:_nextAnchor];
    }
}

// 清除所有导航指引贴图
- (void)clearNavigationGuide {
    if(_preAnchor){
        [_arscnView.session removeAnchor:_preAnchor];
        _preAnchor = nil ;
    }
    if(_curAnchor){
        [_arscnView.session removeAnchor:_curAnchor];
        _curAnchor = nil;
    }
    if(_nxNodes && _nxNodes.count > 0) {
        for (InWalkARAnchor *node in _nxNodes) {
            [_arscnView.session removeAnchor:node];
        }
        _nxNodes = nil;
    }
    if(_nextAnchor){
        [_arscnView.session removeAnchor:_nextAnchor];
        _nextAnchor = nil;
    }
    if(_tipAnchor){
        [_arscnView.session removeAnchor:_tipAnchor];
        _tipAnchor = nil;
    }
    if(_referNode){
        _referNode = nil;
    }
    if (_videoAnchor && _arPath.count > _s2) {
        // Video所在的AR坐标
        float x = _arPath[_videoAnchor.tag].pathPosition[0];
        float y = _arPath[_videoAnchor.tag].pathPosition[2]; // 注意：Tango数据通过转换矩阵转为ARKit坐标后，y值是实际对应ARKit坐标系中Z轴的值
        // 当前所在的AR坐标
        simd_float4 camPos = simd_make_float4(0,0,0,1);
        camPos = simd_mul(_arscnView.session.currentFrame.camera.transform, camPos);
        // 累加行走距离
        float dx = camPos[0]-x;
        float dy = camPos[2]-y;
        float distance = sqrtf((dx*dx + dy*dy));
        if (distance > 5.0) {
            [_arscnView.session removeAnchor:_videoAnchor];
            _videoAnchor = nil;
        }
    }
}

// 返回每个ARAnchor对应的SCNNode
- (SCNNode *)renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor {
    if(![anchor isKindOfClass:InWalkARAnchor.class]){
        return nil;
    }
    
    InWalkARAnchor *arAnchor = (InWalkARAnchor *)anchor;
    NSString *imgName;
    int w;
    
    switch (arAnchor.flag) {
        case 3:
            // 终点
            imgName = @"art.scnassets/终点dae模型";
            w = 2;
            break;
        case 1:
        case 2:
        case 0:
        default:
            // 起点/直行
            imgName = @"art.scnassets/ship.scn";
            w = 1;
            break;
    }
    
    NSString * path = [[NSBundle bundleForClass:[self class]] pathForResource:imgName ofType:nil];
//    NSString * path = [NSBundle bu]
    // 终点Node对应的SCNNode
    if (arAnchor.flag == 3) {
//        SCNBox *box = [SCNBox boxWithWidth:2 height:2 length:0.01 chamferRadius:0.01];
//        SCNMaterial *firstMaterial = SCNMaterial.material;
//        UIImage *img = [UIImage imageNamed:imgName
//                                  inBundle:[NSBundle bundleForClass:[self class]]
//             compatibleWithTraitCollection:nil];
//        firstMaterial.diffuse.contents = img;
//        SCNMaterial *otherMaterial = SCNMaterial.material;
//        otherMaterial.diffuse.contents = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
//        // @[front,right,back,left,top,bottom];
//        box.materials = @[firstMaterial,otherMaterial,firstMaterial,otherMaterial,otherMaterial,otherMaterial];
//
//        SCNNode *node = [SCNNode nodeWithGeometry:box];
//        // 为SCNNode添加旋转动画
//        [node runAction: [SCNAction repeatActionForever: [SCNAction rotateByX:0 y:2*M_PI z:0 duration:3]]];
//
//        return node;
        
        _isDestViewExpand = NO;
//        UIView *view = [self destView001ById:arAnchor.hid];
//        UIImage *img = [self imageFromView:view];
        
        InWalkPointDesc *ap = [_destArPoints objectForKey:_destPointId];
        //
//        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:ap.imgSmall ofType:nil];
//        UIImage *img = [UIImage imageWithContentsOfFile:path];
        //
        float height = _postWidth * ap.scaleSmall;
        SCNBox *box = [SCNBox boxWithWidth:_postWidth height:height length:0.01 chamferRadius:0.01];
        
//        SCNMaterial *firstMaterial = SCNMaterial.material;
//        firstMaterial.diffuse.contents = img;
//        SCNMaterial *otherMaterial = SCNMaterial.material;
//        otherMaterial.diffuse.contents = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
//        // @[front,right,back,left,top,bottom];
//        box.materials = @[firstMaterial,otherMaterial,firstMaterial,otherMaterial,otherMaterial,otherMaterial];
//        SCNNode *node = [SCNNode nodeWithGeometry:box];
        box.firstMaterial.diffuse.contents = [UIColor clearColor];
        // 4. 创建一个基于3D物体模型的节点
        SCNNode *planeNode = [SCNNode nodeWithGeometry:box];
        // 5. 设置节点的位置为捕捉到的平地的锚点的中心位置
        // SceneKit中节点的位置position是一个基于3D坐标系的矢量坐标SCNVector3Make
//        planeNode.position = SCNVector3Make(arAnchor.center.x, 0, arAnchor.center.z);
        
        
        // 6. 创建一个花瓶场景
        SCNScene *scene = [SCNScene sceneWithURL:[NSURL URLWithString:imgName] options:nil error:nil];
        // 7. 获取花瓶节点
        // 一个场景有多个节点，所有场景有且只有一个根节点，其它所有节点都是根节点的子节点
        SCNNode *vaseNode = scene.rootNode.childNodes.firstObject;
        // 8. 设置花瓶节点的位置为捕捉到的平地的位置，如果不设置，则默认为原点位置也就是相机位置
//        vaseNode.position = SCNVector3Make(arAnchor.center.x, 0, arAnchor.center.z);
        // 9. 将花瓶节点添加到屏幕中
        // !!!!FBI WARNING: 花瓶节点是添加到代理捕捉到的节点中，而不是AR视图的根接节点。
        // 因为捕捉到的平地锚点是一个本地坐标系，而不是世界坐标系
        [planeNode addChildNode:vaseNode];
        planeNode.name = @"dest_node";
        
        return planeNode;
    }
    
    if (arAnchor.flag == 2 && arAnchor.tag == _s2) {
        // video
        //NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"douyin_ad_video.mp4" ofType:nil]; //@"gif"
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"ad_video.mp4" ofType:nil]; //@"gif"
        AVPlayer *player = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:path]];
        
        SKScene *skScene = [[SKScene alloc] init];
        [skScene setSize:CGSizeMake(1000, 1000)];
        
        SKVideoNode *vNode = [[SKVideoNode alloc] initWithAVPlayer:player];
        vNode.position = CGPointMake(skScene.size.width / 2, skScene.size.height / 2);
        [vNode setSize: skScene.size];
        [vNode setYScale: -1.0];
        [vNode play];
        
        [skScene addChild:vNode];
        
        float scale = 0.5625; // 高/宽
        float width = 3;//_postWidth;
        float height = width * scale;
        SCNNode *node = [[SCNNode alloc] init];
        SCNBox *box = [SCNBox boxWithWidth:width height:height length:0.01 chamferRadius:0.01];
        node.geometry = box;
        SCNMaterial *mat = [[SCNMaterial alloc] init];
        [mat.diffuse setContents: skScene];
        node.geometry.materials = @[mat];
        node.name = @"normal_node";
        //node.scale = SCNVector3Make(1.7, 1, 1);
        return node;
    }
    
//    // 使用GIF图
//    if (arAnchor.tag % 1 == 0) {
//        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"gif_arrow_2.gif" ofType:nil]; //@"gif"
//        NSURL *url = [NSURL fileURLWithPath:path];
//        CFURLRef urlRef = (__bridge CFURLRef)url;
//        //
//        CALayer* subLayer = [CALayer layer];
//        subLayer.bounds = CGRectMake(0, 0, 900, 900);
//        subLayer.anchorPoint = CGPointMake(0, 1);
//        CAKeyframeAnimation *animation = [self createGIFAnimation: urlRef];
//        [subLayer addAnimation:animation forKey:@"contents"];
//        //
//        //firstMaterial.diffuse.contents = subLayer;
//        SCNPlane *tvPlane = [[SCNPlane alloc] init];
//        [tvPlane setWidth: 1.7];
//        [tvPlane setHeight:0.64];
//        [tvPlane.firstMaterial.diffuse setContents: subLayer];
//        [tvPlane.firstMaterial setDoubleSided:YES];
//        //
//        SCNNode *node = [SCNNode nodeWithGeometry:tvPlane];
//        node.name = @"normal_node";
//
//        return node;
//    }
    
    
    // 其他Node对应的SCNNode(展示为箭头图标)
    SCNBox *box = [SCNBox boxWithWidth:_postWidth height:1 length:0.01 chamferRadius:0.01];
    
    //        SCNMaterial *firstMaterial = SCNMaterial.material;
    //        firstMaterial.diffuse.contents = img;
    //        SCNMaterial *otherMaterial = SCNMaterial.material;
    //        otherMaterial.diffuse.contents = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    //        // @[front,right,back,left,top,bottom];
    //        box.materials = @[firstMaterial,otherMaterial,firstMaterial,otherMaterial,otherMaterial,otherMaterial];
    //        SCNNode *node = [SCNNode nodeWithGeometry:box];
    box.firstMaterial.diffuse.contents = [UIColor clearColor];
    // 4. 创建一个基于3D物体模型的节点
    SCNNode *planeNode = [SCNNode nodeWithGeometry:box];
    // 5. 设置节点的位置为捕捉到的平地的锚点的中心位置
    // SceneKit中节点的位置position是一个基于3D坐标系的矢量坐标SCNVector3Make
//    planeNode.position = SCNVector3Make(arAnchor.center.x, 0, arAnchor.center.z);
    
    NSError * error;
    SCNScene *scene;
    if (path.length != 0) {
       scene =[SCNScene sceneWithURL:[NSURL fileURLWithPath:path] options:nil error:&error];
    }else{
        scene = [SCNScene sceneNamed:imgName];
    }
    // 7. 获取花瓶节点
    // 一个场景有多个节点，所有场景有且只有一个根节点，其它所有节点都是根节点的子节点
    SCNNode *vaseNode = scene.rootNode.childNodes.firstObject;
    // 8. 设置花瓶节点的位置为捕捉到的平地的位置，如果不设置，则默认为原点位置也就是相机位置
    vaseNode.position = SCNVector3Make(0, 0, 0);
    // 9. 将花瓶节点添加到屏幕中
    // !!!!FBI WARNING: 花瓶节点是添加到代理捕捉到的节点中，而不是AR视图的根接节点。
    // 因为捕捉到的平地锚点是一个本地坐标系，而不是世界坐标系
    [planeNode addChildNode:vaseNode];
    planeNode.name = @"normal_node";
    
    return planeNode;
}

// 更新当前在导航路径中的位置
- (void)updateCurrentNavigatingIndex:(ARFrame *)frame {
    ////NSLog(@"update frame : refresh");
    if(_navigating && _currentIndex +1 < _arPath.count){
        simd_float4 position = simd_make_float4(0,0,0,1);
        position= simd_mul(frame.camera.transform, position); // 矩阵与向量相乘
        
        // 从_currentIndex开始往后搜索，找到与当前位置最近的点
        [self findNearestPointIndex:position];
        
        float x0 = _arPath[_currentIndex].pathPosition[0];
        float y0 = _arPath[_currentIndex].pathPosition[2];
        float x1 = _arPath[_currentIndex + 1].pathPosition[0];
        float y1 = _arPath[_currentIndex + 1].pathPosition[2];
        
        // 假设两个点在一条直线(y=kx+b)上，根据点(x0,y0)和点(x1,y1)求k和b
        float k = (y1 - y0)/(x1 - x0);
        float b = (x1 * y0 - x0 * y1)/(x1 - x0);
        
        // 相机位置在直线上的投影
        // 参考 https://blog.csdn.net/guyuealian/article/details/53954005
        float t1 = position[2]/position[3] - b;
        float t2 = position[0]/position[3];
        float resultX = (k*t1 + t2) / (k*k +1);
        float resultY = k*resultX+b;
        
        // 点(resultX,resultY)到点(x1,y1)的距离
        float length = sqrtf((x1 - resultX) * (x1 - resultX) + (y1 - resultY) * (y1 - resultY));
        //        _testLabel.text = [NSString stringWithFormat:@"length:%f",length];
        if(length < 1){
            _currentIndex +=1;
            [self updateNavigation:length];
        }
    }
}

// 找到最近的导航贴图，记录其下标index
- (void)findNearestPointIndex:(simd_float4)position {
    float x = _arPath[_currentIndex].pathPosition[0];
    float y = _arPath[_currentIndex].pathPosition[2];
    float dx = x - position[0];
    float dy = y - position[2];
    float len = dx*dx + dy*dy;
    float minLength = len;
    int minIndex = _currentIndex;
    
    for (int i = _currentIndex + 1; i < _arPath.count; i++) {
        x = _arPath[i].pathPosition[0];
        y = _arPath[i].pathPosition[2];
        dx = x - position[0];
        dy = y - position[2];
        len = dx*dx + dy*dy;
        
        if (minLength >= len) {
            minLength = len;
            minIndex = i;
        }
    }
    
    // 比较当前位置分别与 minIndex的前一个点、后一个点的距离，确定当前位置是处于(minIndex-1,minIndex)区间还是(minIndex,minIndex+1)区间
    float preLen = 65535;
    if (minIndex > 0) {
        x = _arPath[minIndex - 1].pathPosition[0];
        y = _arPath[minIndex - 1].pathPosition[2];
        dx = x - position[0];
        dy = y - position[2];
        preLen = dx*dx + dy*dy;
    }
    float postLen = 65535;
    if (minIndex + 1 < _arPath.count) {
        x = _arPath[minIndex + 1].pathPosition[0];
        y = _arPath[minIndex + 1].pathPosition[2];
        dx = x - position[0];
        dy = y - position[2];
        postLen = dx*dx + dy*dy;
    }
    if (preLen < postLen) {
        _currentIndex = minIndex - 1;
    } else {
        _currentIndex = minIndex;
    }
}


#pragma mark - 指南针相关
- (CLLocationManager *)mgr {
    if (!_mgr) {
        _mgr = [[CLLocationManager alloc] init];
    }
    return _mgr;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    //    //NSLog(@"********************%f", newHeading.magneticHeading);
    self.magNorthValue = newHeading.magneticHeading;
    self.magFrameTransform = self.arscnView.session.currentFrame.camera.transform;
    //[self calcAngleDiff];
}


#pragma mark - 辅助方法
// X0Y坐标系中：计算从 起始向量 到 目标向量 的夹角(顺时针)
- (float)calcVectorAngleFrom:(simd_float4)fromVector to:(simd_float4)toVector {
    // 先求出两个向量的模，再求出两个向量的向量积
    // cos<a,b>=a*b/[|a|*|b|]=(x1x2+y1y2)/[√[x1^2+y1^2]*√[x2^2+y2^2]]
    float x1 = fromVector[2]; // 右手坐标系中，取z的值
    float y1 = fromVector[0]; // 右手坐标系中，取x的值
    float x2 = toVector[2];
    float y2 = toVector[0];
    float aa = (sqrt(x1*x1+y1*y1)*sqrt(x2*x2+y2*y2));
    
    // 此时夹角应该是多少？
    if (aa == 0) {
        return 1;
    }
    
    double cosab = (x1*x2+y1*y2) / aa;
    float angle = toDegrees(acos(cosab));
    
    double crossab = x1*y2-y1*x2; // 向量叉乘，为正数说明from到to是顺时针(angle)，否则是逆时针(360-angle)
    if (crossab > 0) {
        return 360 - angle;
    } else {
        return angle;
    }
}

// 根据pointId查找pointId对应的导航点
- (InWalkInnerPoint *)getPointById:(NSString *)pointId {
    return [self.allPoints objectForKey:pointId];
}

// 根据pathId查找pathId对应的路径
- (InWalkPath *)getPathById:(NSString *)pathId {
    return [self.allPaths objectForKey:pathId];
}

// InWalkMapDelegate
- (void)onClickMap:(BOOL)isMapOpenNow{
    if (_delegate) {
        [_delegate onMapOpend:isMapOpenNow];
    }
}

// 小地图：使用户当前所处位置展示在小地图(屏幕)中心
- (void)makeMapCenter {
    if (_mapManager) {
        [_mapManager makeMapCenter];
    }
}

- (void)makeDirectionTipVisible:(BOOL)visible {
    if (!_directionTip) return;
    
    if (visible) {
        _directionTip.hidden = NO;
    } else {
        _directionTip.hidden = YES;
    }
}

// 隐藏调试信息，目前未用到
- (void)hideDebugInfo:(BOOL)isHidden {
    _tipTextView.hidden = YES;//isHidden;
    _testLabel.hidden= YES;//isHidden;
    _mapManager.mapView.hidden = isHidden;
}

// 测试方法，目前已废弃
- (void)testUpdatePlus {
    _currentIndex++;
    if (_currentIndex >= _arPath.count)return;
    //NSLog(@" 333 902 navUi.initView ... ");
    [self updateNavigation:-1];
}

// 释放InWalkARManager持有的资源
- (void)releaseArResouce {
    if (_arscnView) {
        [_arscnView removeFromSuperview];
        _arscnView = nil;
    }
    if (_mgr) {
        [_mgr stopUpdatingHeading];
        _mgr = nil;
    }
    if (_mapManager) {
        [_mapManager releaseMap];
    }
    [_navigationManager releaseNavigation];
    _arPath = nil;
    _allMaps = nil;
    _allPaths = nil;
    _allNodes = nil;
    _allPoints = nil;
    _navDetails = nil;
    _startPoint = nil;
    _mapData = nil;
    _mapPoint = nil;
    _rectifyBeacons = nil;

    if (_directionTip) {
        [_directionTip removeFromSuperview];
    }
}


#pragma mark - 导航到达终点时，展示店铺海报
- (void)initDestArPoints{
    NSLog(@"--->>>> initDestArPoints ..");
    _destArPoints = [[NSMutableDictionary alloc] init];
    [_destArPoints setObject: [[InWalkPointDesc alloc] initWithShopName:@"yiger" smallImage:@"shop_1_yiger.png" scale:0.18 expandImage:@"gif_1_yiger.gif" scale:0.75]
                      forKey:@"a212aed0-81c3-11e9-b353-d7e37cddaaf4"];
    [_destArPoints setObject: [[InWalkPointDesc alloc] initWithShopName:@"aika" smallImage:@"shop_2_aika.png" scale:0.18 expandImage:@"gif_2_aika.gif" scale:0.425]
                      forKey:@"cdf1c310-81c3-11e9-b353-d7e37cddaaf4"];
    [_destArPoints setObject: [[InWalkPointDesc alloc] initWithShopName:@"yigao" smallImage:@"shop_3_yigao.png" scale:0.18 expandImage:@"gif_3_yigao.gif" scale:0.667]
                      forKey:@"b484b580-81c4-11e9-b353-d7e37cddaaf4"];
}

- (void)tap:(UITapGestureRecognizer *)recognizer {
    NSArray<SCNHitTestResult *> *result = [_arscnView hitTest:[recognizer locationOfTouch:0 inView:_arscnView] options:nil];
    if (result && result.count > 0) {
        
        for (SCNHitTestResult *it in result) {
            NSLog(@" .... 111222 %@", it.node.name);
            if ([it.node.name isEqualToString:@"dest_node"]) {
                
                //NSString *hid = _arPath.lastObject.hid;
                InWalkPointDesc *ap = [_destArPoints objectForKey:_destPointId];
                //InWalkPointDesc *ap = [_destArPoints objectForKey:@"cdf1c310-81c3-11e9-b353-d7e37cddaaf4"];
                //InWalkPointDesc *ap = [_destArPoints objectForKey:@"b484b580-81c4-11e9-b353-d7e37cddaaf4"];
                
                //float height = _isDestViewExpand ? 0.15 : 1;
                float height = _isDestViewExpand ? _postWidth * ap.scaleSmall : _postWidth * ap.scaleExpand;
                SCNBox *box = [SCNBox boxWithWidth:_postWidth height:height length:0.01 chamferRadius:0.01];
                SCNMaterial *firstMaterial = SCNMaterial.material;
                
                if (_isDestViewExpand) {
                    // 加载图片
                    //UIView *view = [self destView001ById:hid];
                    //firstMaterial.diffuse.contents = [self imageFromView:view];
                    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:ap.imgSmall ofType:nil];
                    firstMaterial.diffuse.contents = [UIImage imageWithContentsOfFile:path];
                } else {
                    // 加载Gif
                    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:ap.imgExpand ofType:nil]; //@"gif"
                    NSURL *url = [NSURL fileURLWithPath:path];
                    CFURLRef urlRef = (__bridge CFURLRef)url;
                    //
                    CALayer* subLayer = [CALayer layer];
                    subLayer.bounds = CGRectMake(0, 0, 900, 900);
                    subLayer.anchorPoint = CGPointMake(0, 1);
                    CAKeyframeAnimation *animation = [self createGIFAnimation: urlRef];
                    [subLayer addAnimation:animation forKey:@"contents"];
                    //
                    firstMaterial.diffuse.contents = subLayer;
                }
                
                SCNMaterial *otherMaterial = SCNMaterial.material;
                otherMaterial.diffuse.contents = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
                // @[front,right,back,left,top,bottom];
                box.materials = @[firstMaterial,otherMaterial,firstMaterial,otherMaterial,otherMaterial,otherMaterial];
                
                [it.node runAction: [SCNAction fadeOpacityTo:0 duration:0.25] completionHandler:^{
                    it.node.geometry = box;
                    [it.node runAction: [SCNAction fadeOpacityTo:1 duration:0.25]];
                    _isDestViewExpand = !_isDestViewExpand;
                }];
                
                NSLog(@" ... hid : %@", _destPointId);
                break;
            }
        }
        
    }
}

// UIView转UIImage
- (UIImage *)imageFromView:(UIView *)view {
    CGSize s = view.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// 店铺名称
- (UIView *)destView001ById:(NSString *)pointId {
    InWalkPointDesc *ap = [_destArPoints objectForKey:pointId];
    int w = 315;
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 5, w, 60)];
    header.backgroundColor = [UIColor whiteColor];
    
    UIImageView *img0 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, w, 60)];
    [img0 setImage:[UIImage imageNamed:ap.imgSmall]];
    [header addSubview:img0];
    
    return header;
}

// 店铺完整海报
- (UIView *)destView002ById:(NSString *)pointId {
    InWalkPointDesc *ap = [_destArPoints objectForKey:pointId];
    int w = 315;
    int h = 410;
    
    UIView *v2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    v2.backgroundColor = [UIColor whiteColor];
    v2.layer.cornerRadius = 4;
    // img1(top)
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, 150)];
    [img setImage:[UIImage imageNamed:ap.imgAd]]; // @"img2"
    // 圆角（上边框）
    {
        float radius = 4;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:v2.bounds
                                                       byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                             cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = v2.bounds;
        maskLayer.path = maskPath.CGPath;
        img.layer.mask = maskLayer;
    }
    [v2 addSubview:img];
    // img2(middle)
    UIImageView *img2 = [[UIImageView alloc] initWithFrame:CGRectMake(24, 164, 88, 32)];
    [img2 setImage:[UIImage imageNamed:ap.imgSlogan]]; // @"img1"
    [v2 addSubview:img2];
    // text(bottom)
    UITextView *lb = [[UITextView alloc] initWithFrame:CGRectMake(24, 210, w - 48, h - 210 - 24)];
    //    [lb setText:@"1一二三四五六七八九十 2一二三四五六七八九十 3一二三四五六七八九十 4一二三四五六七八九十 5一二三四五六七八九十 6一二三四五六七八九十 7一二三四五六七八九十 "];
    [lb setText:ap.imgDesc];
    [lb setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:20]];
    [v2 addSubview:lb];
    
    return v2;
}

- (CAKeyframeAnimation *)createGIFAnimation:(CFURLRef)urlRef {
    CGImageSourceRef src = CGImageSourceCreateWithURL(urlRef, nil);
    size_t frameCount = (int)CGImageSourceGetCount(src);
    
    // Total loop time
    float time = 0;
    
    // Arrays
    NSMutableArray *framesArray = [NSMutableArray array];
    NSMutableArray *tempTimesArray = [NSMutableArray array];
    
    // Loop
    for (size_t i = 0; i < frameCount; i++){
        
        // Frame default duration
        float frameDuration = 0.1f;
        
        // Frame duration
        CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(src,i,nil);
        NSDictionary *frameProperties = (__bridge NSDictionary*)cfFrameProperties;
        NSDictionary *gifProperties = frameProperties[(NSString*)kCGImagePropertyGIFDictionary];
        
        // Use kCGImagePropertyGIFUnclampedDelayTime or kCGImagePropertyGIFDelayTime
        NSNumber *delayTimeUnclampedProp = gifProperties[(NSString*)kCGImagePropertyGIFUnclampedDelayTime];
        if(delayTimeUnclampedProp) {
            frameDuration = [delayTimeUnclampedProp floatValue];
        } else {
            NSNumber *delayTimeProp = gifProperties[(NSString*)kCGImagePropertyGIFDelayTime];
            if(delayTimeProp) {
                frameDuration = [delayTimeProp floatValue];
            }
        }
        
        // Make sure its not too small
        if (frameDuration < 0.011f){
            frameDuration = 0.100f;
        }
        
        [tempTimesArray addObject:[NSNumber numberWithFloat:frameDuration]];
        
        // Release
        CFRelease(cfFrameProperties);
        
        // Add frame to array of frames
        CGImageRef frame = CGImageSourceCreateImageAtIndex(src, i, nil);
        [framesArray addObject:(__bridge id)(frame)];
        
        // Compile total loop time
        time = time + frameDuration;
    }
    
    NSMutableArray *timesArray = [NSMutableArray array];
    float base = 0;
    for (NSNumber* duration in tempTimesArray){
        //duration = [NSNumber numberWithFloat:(duration.floatValue/time) + base];
        base = base + (duration.floatValue/time);
        [timesArray addObject:[NSNumber numberWithFloat:base]];
    }
    
    // Create animation
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    
    animation.duration = time;
    animation.repeatCount = HUGE_VALF;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.values = framesArray;
    animation.keyTimes = timesArray;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.calculationMode = kCAAnimationDiscrete;
    
    return animation;
}


#pragma mark - 路径方向提示相关
- (void)initDirectionTipView {
    _directionTip = [[UIImageView alloc] initWithFrame:CGRectMake(self.container.bounds.origin.x + 40, self.container.bounds.origin.y + self.container.bounds.size.height / 2, 0.1, 0.1)];
    _directionTip.backgroundColor = [UIColor clearColor];
    _directionTip.hidden = YES;
    [self.container addSubview:_directionTip];
    
    UIColor *blue = [UIColor colorWithRed:67./255 green:122./255 blue:248./255 alpha:1];
    CGFloat duration = 1;
    CGFloat duration_2 = 0.2;
    
    _leftLayer = [CAReplicatorLayer layer];
    _leftLayer.instanceCount = 1;
    {
        CAShapeLayer *lay0 = [[CAShapeLayer alloc] init];
        
        // 径向动画
        [lay0 addSublayer:[self getGradientLayerWithDuration:duration]];
        
        lay0.backgroundColor = [UIColor whiteColor].CGColor;
        CGFloat x1 = 0;
        UIBezierPath *leftPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x1, 0) radius:18 startAngle:0.75*M_PI endAngle:M_PI*1.25 clockwise:NO];
        [leftPath addLineToPoint:CGPointMake(-25, 0)];
        [leftPath closePath];
        {
            CGFloat radius = 14;
            UIBezierPath *c1 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x1 - radius, -radius, radius*2, radius*2)];
            CAShapeLayer *lay1 = [[CAShapeLayer alloc] init];
            lay1.path = c1.CGPath;
            lay1.fillColor = blue.CGColor;
            [lay0 addSublayer:lay1];
            
            lay0.path = leftPath.CGPath;
            lay0.fillColor = [UIColor whiteColor].CGColor;
            lay0.fillRule = kCAFillRuleEvenOdd;
        }
        
        // 抖动动画
        [lay0 addAnimation:[self getAnimGroupWithDuration:duration_2 duration2:duration] forKey:nil];
        
        [_leftLayer addSublayer:lay0];
    }
    
    _rightLayer = [[CAReplicatorLayer alloc] init];
    _rightLayer.backgroundColor = [UIColor whiteColor].CGColor;
    {
        CAShapeLayer *lay0 = [[CAShapeLayer alloc] init];
        
        // 径向动画
        [lay0 addSublayer:[self getGradientLayerWithDuration:duration]];
        
        lay0.backgroundColor = [UIColor whiteColor].CGColor;
        CGFloat x2 = 0;
        UIBezierPath *rightPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x2, 0) radius:18 startAngle:0.25*M_PI endAngle:1.75*M_PI clockwise:YES];
        [rightPath addLineToPoint:CGPointMake(25, 0)];
        [rightPath closePath];
        {
            CGFloat radius = 14;
            UIBezierPath *c1 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x2 - radius, -radius, radius*2, radius*2)];
            CAShapeLayer *lay1 = [[CAShapeLayer alloc] init];
            lay1.path = c1.CGPath;
            lay1.fillColor = blue.CGColor;
            [lay0 addSublayer:lay1];
            
            lay0.path = rightPath.CGPath;
            lay0.fillColor = [UIColor whiteColor].CGColor;
            lay0.fillRule = kCAFillRuleEvenOdd;
        }
        
        // 抖动动画
        [lay0 addAnimation:[self getAnimGroupWithDuration:duration_2 duration2:duration] forKey:nil];
        
        [_rightLayer addSublayer:lay0];
    }
}

// 抖动动画
- (CAAnimationGroup *)getAnimGroupWithDuration:(CGFloat)duration1 duration2:(CGFloat)duration2 {
    // scale anim
    CABasicAnimation *basicAnim2 = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    basicAnim2.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.85, 0.85, 1)];
    basicAnim2.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
    basicAnim2.duration = duration1;
    basicAnim2.autoreverses = YES;
    basicAnim2.removedOnCompletion = NO;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = @[basicAnim2];
    animGroup.duration = duration2;
    animGroup.repeatCount = MAXFLOAT;
    animGroup.removedOnCompletion = NO;
    
    return animGroup;
}

// 径向动画
- (GradientLayer *)getGradientLayerWithDuration:(CGFloat)duration {
    GradientLayer *gradientLayer = [[GradientLayer alloc] init];
    CGFloat w = 40;
    //gradientLayer.backgroundColor = [UIColor lightTextColor].CGColor;
    gradientLayer.backgroundColor = [UIColor colorWithRed:255./255 green:255./255 blue:255./255 alpha:0.8].CGColor;
    gradientLayer.frame = CGRectMake(-20, -20, w, w);
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(20, 20) radius:20 startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
    gradientLayer.mask = layer;
    
    CABasicAnimation *basicAnim2 = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    basicAnim2.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.2, 0.2, 1)];
    basicAnim2.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2, 2, 1)];
    basicAnim2.duration = duration;
    basicAnim2.autoreverses = NO;
    basicAnim2.removedOnCompletion = NO;
    basicAnim2.repeatCount = MAXFLOAT;
    
    [gradientLayer addAnimation:basicAnim2 forKey:nil];
    return gradientLayer;
}

- (void)refreshDirectionTipView {
    simd_float3 nextPosition;
    if (_currentIndex + 1 < self.navigationManager.navigationPath.count) {
        nextPosition = self.navigationManager.navigationPath[_currentIndex + 1].pathPosition;
    } else {
        nextPosition = self.navigationManager.navigationPath.lastObject.pathPosition;
    }
    simd_float4 c2dest = simd_make_float4(_currentPoistion.y - nextPosition[1], 0, nextPosition[0] - _currentPoistion.x, 1);
    simd_float4 c2c = simd_make_float4(_currentPoistion.y - _forwardPosition[1], 0, _forwardPosition[0] - _currentPoistion.x, 1);
    CGFloat angle = [self calcVectorAngleFrom:c2dest to:c2c];
    CGFloat a1 = _xFovDegrees / 2 + 10;
    if (angle > a1 && angle < 180) {
        // 需要向左看
        //NSLog(@" left <<<<<<<<<< -------- angle: %f", angle);
        if (_directionTip.backgroundColor != [UIColor redColor]) {
            CGRect rect = _directionTip.frame;
            rect.origin.x = self.container.bounds.origin.x + 40;
            _directionTip.frame = rect;
            _directionTip.backgroundColor = [UIColor redColor];
            if (_directionTip.layer.sublayers) {
                for (CAShapeLayer *layer in _directionTip.layer.sublayers) {
                    [layer removeFromSuperlayer];
                }
            }
            [_directionTip.layer addSublayer:_leftLayer];
        }
    } else if (angle > 180 && angle < (360 - a1)) {
        // 需要向右看
        //NSLog(@" right >>>> -------- angle: %f", angle);
        if (_directionTip.backgroundColor != [UIColor blueColor]) {
            CGRect rect = _directionTip.frame;
            rect.origin.x = self.container.bounds.origin.x + self.container.bounds.size.width - 40;
            _directionTip.frame = rect;
            _directionTip.backgroundColor = [UIColor blueColor];
            if (_directionTip.layer.sublayers) {
                for (CAShapeLayer *layer in _directionTip.layer.sublayers) {
                    [layer removeFromSuperlayer];
                }
            }
            [_directionTip.layer addSublayer:_rightLayer];
        }
    } else {
        // 方向正确
        _directionTip.backgroundColor = [UIColor clearColor];
        if (_directionTip.layer.sublayers) {
            for (CAShapeLayer *layer in _directionTip.layer.sublayers) {
                [layer removeFromSuperlayer];
            }
        }
    }
    //        NSLog(@"arkit is visible ?? %@", self.arscnView.is);
}

// 已过时方法
- (void)initDirectionTipView1 {
    _directionTip = [[UIImageView alloc] initWithFrame:CGRectMake(self.container.bounds.origin.x, self.container.bounds.origin.y + self.container.bounds.size.height / 2, 0.1, 0.1)];
    _directionTip.backgroundColor = [UIColor clearColor];
    _directionTip.hidden = YES;
    [self.container addSubview:_directionTip];
    
    UIColor *blue = [UIColor colorWithRed:67./255 green:122./255 blue:248./255 alpha:1];
    CGFloat duration = 1;
    
    _leftLayer = [CAReplicatorLayer layer];
    //_leftLayer.backgroundColor = [UIColor whiteColor].CGColor;
    _leftLayer.instanceCount = 1;
    {
        CAShapeLayer *lay0 = [[CAShapeLayer alloc] init];
        lay0.backgroundColor = [UIColor whiteColor].CGColor;
        CGFloat x1 = 30;
        UIBezierPath *leftPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x1, 0) radius:18 startAngle:0.75*M_PI endAngle:M_PI*1.25 clockwise:NO];
        [leftPath addLineToPoint:CGPointMake(5, 0)];
        [leftPath closePath];
        {
            CGFloat radius = 14;
            UIBezierPath *c1 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x1 - radius, -radius, radius*2, radius*2)];
            CAShapeLayer *lay1 = [[CAShapeLayer alloc] init];
            lay1.path = c1.CGPath;
            lay1.fillColor = blue.CGColor;
            [lay0 addSublayer:lay1];
            
            lay0.path = leftPath.CGPath;
            lay0.fillColor = [UIColor whiteColor].CGColor;
            lay0.fillRule = kCAFillRuleEvenOdd;
        }
        
        // scale anim
        CABasicAnimation *basicAnim2 = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
        basicAnim2.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.85, 0.85, 1)];
        basicAnim2.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
        basicAnim2.duration = 0.2;
        basicAnim2.autoreverses = YES;
        basicAnim2.removedOnCompletion = NO;
        
        // opacity anim
        CAKeyframeAnimation *basicAnim3 = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        basicAnim3.values = @[@1,@0.35,@0.65,@0.35,@0.65];
        basicAnim3.duration = duration;
        basicAnim3.autoreverses = YES;
        basicAnim3.removedOnCompletion = NO;
        
        CAAnimationGroup *animGroup = [CAAnimationGroup animation];
        animGroup.animations = @[basicAnim2, basicAnim3];
        animGroup.duration = duration;
        animGroup.repeatCount = MAXFLOAT;
        animGroup.removedOnCompletion = NO;
        
        // 4.将动画添加到layer层上
        [lay0 addAnimation:animGroup forKey:nil];
        
        [_leftLayer addSublayer:lay0];
        
        //        CAShapeLayer *lay1 = [[CAShapeLayer alloc] init];
        //        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0, 0) radius:18 startAngle:0.75*M_PI endAngle:M_PI*1.25 clockwise:NO];
        //        [path addLineToPoint:CGPointMake(5, 0)];
        //        [path closePath];
        //        lay1.path = path.CGPath;
        //        lay1.fillColor = [UIColor redColor].CGColor;
        //
        //        _leftLayer.instanceTransform = CATransform3DMakeTranslation(45, 0, 0);
        //        // 1.3.设置复制层的动画延迟事件
        //        _leftLayer.instanceDelay = 0.1;
        //        // 1.4.设置复制层的背景色，如果原始层设置了背景色，这里设置就失去效果
        //        _leftLayer.instanceColor = [UIColor greenColor].CGColor;
        //        // 1.5.设置复制层颜色的偏移量
        //        _leftLayer.instanceGreenOffset = -0.1;
        //
        //        // 3.创建一个基本动画
        //        CABasicAnimation *basicAnimation = [CABasicAnimation animation];
        //        // 3.1.设置动画的属性
        //        basicAnimation.keyPath = @"transform.scale.xy";
        //        basicAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
        //        basicAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2, 2, 1)];
        //        basicAnimation.duration = duration;
        //        basicAnimation.autoreverses = YES;
        //        basicAnimation.removedOnCompletion = NO;
        //        basicAnimation.repeatCount = MAXFLOAT;
        //
        //        // 4.将动画添加到layer层上
        //        [lay1 addAnimation:basicAnimation forKey:nil];
        //
        //        // 5.将layer层添加到复制层上
        //        [_leftLayer addSublayer:lay1];
    }
    
    _rightLayer = [[CAReplicatorLayer alloc] init];
    _rightLayer.backgroundColor = [UIColor whiteColor].CGColor;
    {
        CAShapeLayer *lay0 = [[CAShapeLayer alloc] init];
        lay0.backgroundColor = [UIColor whiteColor].CGColor;
        CGFloat x2 = -30;
        UIBezierPath *rightPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x2, 0) radius:18 startAngle:0.25*M_PI endAngle:1.75*M_PI clockwise:YES];
        [rightPath addLineToPoint:CGPointMake(-5, 0)];
        [rightPath closePath];
        {
            CGFloat radius = 14;
            UIBezierPath *c1 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x2 - radius, -radius, radius*2, radius*2)];
            CAShapeLayer *lay1 = [[CAShapeLayer alloc] init];
            lay1.path = c1.CGPath;
            lay1.fillColor = blue.CGColor;
            [lay0 addSublayer:lay1];
        }
        
        // scale anim
        CABasicAnimation *basicAnim2 = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
        basicAnim2.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1,1,1)];
        basicAnim2.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2, 2, 1)];
        basicAnim2.duration = duration;
        basicAnim2.autoreverses = YES;
        basicAnim2.removedOnCompletion = NO;
        
        // opacity anim
        CAKeyframeAnimation *basicAnim3 = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        basicAnim3.values = @[@1,@0.35,@0.65,@0.35,@0.65];
        basicAnim3.duration = duration;
        basicAnim3.autoreverses = YES;
        basicAnim3.removedOnCompletion = NO;
        
        CAAnimationGroup *animGroup = [CAAnimationGroup animation];
        animGroup.animations = @[basicAnim2, basicAnim3];
        animGroup.duration = duration;
        animGroup.repeatCount = MAXFLOAT;
        animGroup.removedOnCompletion = NO;
        
        lay0.path = rightPath.CGPath;
        lay0.fillColor = [UIColor whiteColor].CGColor;
        lay0.fillRule = kCAFillRuleEvenOdd;
        
        // 4.将动画添加到layer层上
        [lay0 addAnimation:animGroup forKey:nil];
        
        [_rightLayer addSublayer:lay0];
    }
    
}
// 已过时方法
- (void)initDirectionTipView0 {
    //    _directionTip = [[UIImageView alloc] initWithFrame:CGRectMake(self.container.bounds.origin.x, self.container.bounds.origin.y + self.container.bounds.size.height / 2, 0.1, 0.1)];
    //    _directionTip.backgroundColor = [UIColor clearColor];
    //    _directionTip.hidden = YES;
    //    [self.container addSubview:_directionTip];
    //
    //    UIColor *blue = [UIColor colorWithRed:67./255 green:122./255 blue:248./255 alpha:1];
    //
    //    _leftLayer = [[CAShapeLayer alloc] init];
    //    _leftLayer.backgroundColor = [UIColor whiteColor].CGColor;
    //    CGFloat x1 = 30;
    //    UIBezierPath *leftPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x1, 0) radius:18 startAngle:0.75*M_PI endAngle:M_PI*1.25 clockwise:NO];
    //    [leftPath addLineToPoint:CGPointMake(5, 0)];
    //    [leftPath closePath];
    //    {
    //        CGFloat radius = 14;
    //        UIBezierPath *c1 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x1 - radius, -radius, radius*2, radius*2)];
    //        CAShapeLayer *lay1 = [[CAShapeLayer alloc] init];
    //        lay1.path = c1.CGPath;
    //        lay1.fillColor = blue.CGColor;
    //        [_leftLayer addSublayer:lay1];
    //    }
    //    _leftLayer.path = leftPath.CGPath;
    //    _leftLayer.fillColor = [UIColor whiteColor].CGColor;
    //    _leftLayer.fillRule = kCAFillRuleEvenOdd;
    //
    //    _rightLayer = [[CAShapeLayer alloc] init];
    //    _rightLayer.backgroundColor = [UIColor whiteColor].CGColor;
    //    CGFloat x2 = -30;
    //    UIBezierPath *rightPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x2, 0) radius:18 startAngle:0.25*M_PI endAngle:1.75*M_PI clockwise:YES];
    //    [rightPath addLineToPoint:CGPointMake(-5, 0)];
    //    [rightPath closePath];
    //    {
    //        CGFloat radius = 14;
    //        UIBezierPath *c1 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x2 - radius, -radius, radius*2, radius*2)];
    //        CAShapeLayer *lay1 = [[CAShapeLayer alloc] init];
    //        lay1.path = c1.CGPath;
    //        lay1.fillColor = blue.CGColor;
    //        [_rightLayer addSublayer:lay1];
    //    }
    //    _rightLayer.path = rightPath.CGPath;
    //    _rightLayer.fillColor = [UIColor whiteColor].CGColor;
    //    _rightLayer.fillRule = kCAFillRuleEvenOdd;
}


-(NSMutableArray *)rectifyBeacons{
    if (!_rectifyBeacons) {
        _rectifyBeacons = [NSMutableArray array];
    }
    return _rectifyBeacons;
}
//新增根据beacon设备纠偏
- (void)rectifyAtBeaconsWithBeacon:(BRTBeacon *)beacon{
    if (beacon == nil) {
        return;
    }
    //第一个设备
    
    NSArray * array = self.navigationManager.beaconNavigationPath;
    
//    InWalkInnerPoint * fristPoint = [self.navigationManager.beaconNavigationPath firstObject];
//    if (fristPoint != nil && [fristPoint.hid.uppercaseString isEqualToString:beacon.proximityUUID.UUIDString] && self.rectifyBeacons.count == 0) {
//        //装载进纠偏数组
//        [self.rectifyBeacons addObject:fristPoint];
//    }
    
    //纠偏过的不纠偏了
    for (InWalkInnerPoint * p in self.rectifyBeacons) {
        if ([p.hid.uppercaseString isEqualToString:beacon.proximityUUID.UUIDString]) {
            return;
        }
    }
    
//    if (self.rectifyBeacons > 0) {
        NSArray * tempArray = [self.navigationManager.beaconNavigationPath copy];
        for (InWalkInnerPoint * point in tempArray) {
            //在设备内，将当前的定位点设置为起始点，重新生成AR路线
            if ([point.hid.uppercaseString isEqualToString:beacon.proximityUUID.UUIDString]) {
                if (self.rectifyBeacons.count == 0) {
                    NSLog(@"检测到第一个点,第一个点的uuid为%@",point.hid);
//                    [self reloadMapNavPathWithPoint:point];
                    
                    //记录当前位置的AR坐标系
                    _lastARIbeaconPoint = self.arscnView.session.currentFrame;
                    _lastSectionPoint = point;
                    _lastARSectionPoint = self.arscnView.session.currentFrame;
                    [self.rectifyBeacons addObject:point];
                }else{
                    
                    InWalkInnerPoint * lastPoint = [self.rectifyBeacons lastObject];
                    
                    if (lastPoint.pointIndex < point.pointIndex) {
                        //进行纠偏
                        NSLog(@"检测到第二点,第二个点的uuid为%@",point.hid);
                        _lastIbeaconPoint = lastPoint;
                        _currentIbeaconPoint = point;
                        _isIBeaconRectify = YES;
                        [self.rectifyBeacons addObject:point];
//                        [self newRectifyAtWithLastPoint:lastPoint CurrentPoint:point];
                    }else{
                        //提示路径线路错误
                        NSLog(@"路径线路错误。请重试");
                    }
                    
                }
                
//                //更新当前位置，重新生成AR线路
//                [self updateCurrentPoint:point.hid];
//                //清除之前所有纠偏设备
//                [self.rectifyBeacons removeAllObjects];
//                //清除这个点之前所有的位置点
//
//                //加入当前位置点，作为起点
//                [self.rectifyBeacons addObject:point];
                return;
            }else{
                //不在预设线路序列内，提示用户行走线路错误
#warning 提示用户行走线路错误
            }
//        NSInteger currentIndex = self.rectifyBeacons.count - 1;
//        NSInteger nextIndex = currentIndex + 1;
////        for (<#initialization#>; <#condition#>; <#increment#>) {
////            <#statements#>
////        }
//        if (currentIndex < self.rectifyBeacons.count) {
//            InWalkInnerPoint * nextPoint = self.navigationManager.beaconNavigationPath[nextIndex];
//            //判断当前设备点是否为安装顺序的设备点，是进行纠偏操作，否则判断是否为线路序列内的点
//            if ([nextPoint.hid.uppercaseString isEqualToString:beacon.proximityUUID.UUIDString]) {
//                //进行纠偏
//                [self rectifyAtWithLastPoint:self.navigationManager.beaconNavigationPath[currentIndex] CurrentPoint:self.navigationManager.beaconNavigationPath[nextIndex]];
//                //并加入到数组内
//                [self.rectifyBeacons addObject:nextPoint];
//
//            }else{
//
////                NSInteger i = 0;
//////                判断当前设备点是否在预设线路序列内
//
////                    i++;
////                }
//            }
//        }
    }
}


///*
// 新增纠偏逻辑
// 1、选定当前位置，去除原有的路径点
// 2,通过两点控制角度，刷新位置点，及小地图
// */
//
//
//-(void)newRectifyAtWithLastPoint:(InWalkInnerPoint *)lastPoint CurrentPoint:(InWalkInnerPoint *)currentPoint{
//
//
//    // 记录当前cam的AR位置
//    simd_float4 camPos = simd_make_float4(0,0,0,1);
//    camPos = simd_mul(self.arscnView.session.currentFrame.camera.transform, camPos);
//    //根据偏移角度设置位置
//    // 上一位置AR坐标
//    simd_float4 start = simd_make_float4(lastPoint.x.floatValue,lastPoint.y.floatValue,0,1);
//    start = simd_mul(_tranformMatix, start); // 注意：Tango数据通过转换矩阵转为ARKit坐标后，y值是实际对应ARKit坐标系中Z轴的值
//    // 当前位置的AR坐标
//    simd_float4 simd_position = simd_make_float4(currentPoint.x.floatValue, currentPoint.y.floatValue, 0, 1);
//    simd_float4 mapArPos = simd_mul(_tranformMatix, simd_position); // 注意：Tango数据通过转换矩阵转为ARKit坐标后，y值是实际对应ARKit坐标系中Z轴的值
//    // 角度1:向量{上一位置AR坐标->Cam的AR坐标}到向量{起点AR坐标->当前位置的AR坐标}的顺时针夹角
//    simd_float4 t1 = simd_make_float4(camPos[0]-start[0],0,camPos[2]-start[1],1);
//    simd_float4 t2 = simd_make_float4(mapArPos[0]-start[0],0,mapArPos[1]-start[1],1);
//    float anglet = [self calcVectorAngleFrom:t1 to:t2];
//    //NSLog(@" ** wa angle diff: %f", anglet);
//    // 叠加到原始数据中
//    float angle3 = _mapData.northOffset.floatValue;
//    angle3 = angle3 + 360 - anglet;
//    //NSLog(@" ** wa angle4: %f", angle3);
//    _mapData.northOffset = [NSNumber numberWithFloat:angle3 + 20];
//
//    // step2, update 小地图.
//    [_mapManager updateMap:_mapData];
//
//    // step3, update Tango坐标到ARKit坐标的转换矩阵.
//    // 第一次坐标变换：将新坐标系平移，使Tango起点和新坐标系原点重合
////    SCNMatrix4 tranformMatix = SCNMatrix4Identity;
////    tranformMatix = SCNMatrix4Translate(tranformMatix, -_mapPoint[0].floatValue, -_mapPoint[1].floatValue,-_mapPoint[2].floatValue);
////    float rotateAngle = _mapData.northOffset.floatValue *M_PI / 180;
////    // 第二次坐标变换：将新坐标系旋转，使其+Y轴与ARKit坐标系的-Z轴方向一致
////    tranformMatix = SCNMatrix4Rotate(tranformMatix, rotateAngle, 0, 0, 1);
////    // 第三次坐标变换：将新坐标系平移，使其与ARKit坐标系完全重合
////    tranformMatix = SCNMatrix4Translate(tranformMatix, _corTransformV.x,_corTransformV.y,_corTransformV.z);
////    //
////    _tranformMatix =  SCNMatrix4ToMat4(tranformMatix);
////    _inverseMatix = simd_inverse(_tranformMatix);
//
//    [self updataTranformMatix];
//
//    [self newUpdateCurrentPoint:currentPoint.hid];
//
//    //重新开始导航
//    [self startNavigationTo:_destPointId];
//
//}


//设备纠偏暂时沿用以前的十米纠偏流程，暂时还未测试
- (void)rectifyAtWithLastPoint:(InWalkInnerPoint *)lastPoint CurrentPoint:(InWalkInnerPoint *)currentPoint withCurrectArFrame:(ARFrame *)currentFrame{

    //起点的角度
    simd_float4 camARPos = simd_make_float4(0,0,0,1);
    camARPos = simd_mul(currentFrame.camera.transform, camARPos);
    
    // 转换上一点位cam的AR位置

    simd_float4 lastCamPos = simd_make_float4(0,0,0,1);
    lastCamPos = simd_mul(_lastARIbeaconPoint.camera.transform, lastCamPos);
    
    // 起点AR坐标
    simd_float4 last = simd_make_float4(lastPoint.x.floatValue,lastPoint.y.floatValue,0,1);
//    simd_float4 last = simd_make_float4(self.navigationManager.completeNavigationPath[0].pathPosition[0],self.navigationManager.completeNavigationPath[0].pathPosition[1],0,1);
    last = simd_mul(_tranformMatix, last); // 注意：Tango数据通过转换矩阵转为ARKit坐标后，y值是实际对应ARKit坐标系中Z轴的值
    //当前点对应的AR坐标
    simd_float4 current = simd_make_float4(currentPoint.x.floatValue, currentPoint.y.floatValue, 0, 1);
    current = simd_mul(_tranformMatix, current); // 注意：Tango数据通过转换矩阵转为ARKit坐标后，y值是实际对应ARKit坐标系中Z轴的值
    
//    _currentPoistion = CGPointMake(cs///////                                                                                                                                                                                                                              urrent[0], current[1]);
//    [_mapManager updateCurrentForwardPosition:_currentPoistion];
    // 角度1:向量{起上一点位AR坐标->Cam的AR坐标}到向量{上一点位转换后AR坐标->当前点对应转换后的AR坐标}的顺时针夹角
    simd_float4 t1 = simd_make_float4(camARPos[0]-lastCamPos[0],0,camARPos[2]-lastCamPos[2],1);
    simd_float4 t2 = simd_make_float4(current[0]-last[0],0,current[1]-last[1],1);
    
    float anglet = [self calcVectorAngleFrom:t1 to:t2];
    NSLog(@"%lf",anglet);    // 叠加到原始数据中
    float angle3 = _mapData.northOffset.floatValue;
//    if (_rectifyCount == 0) {
//        angle3 = angle3 + 360 - anglet +5;
//    }else{
//
//    }
     angle3 = angle3 + 360 - anglet;
    //NSLog(@" ** wa angle4: %f", angle3);_
    _mapData.northOffset = [NSNumber numberWithFloat:angle3];
    
//    if(_rectifyCount == 0){
//        _mapData.northOffset = [NSNumber numberWithFloat:angle3 - 5];
//    }else{
//        _mapData.northOffset = [NSNumber numberWithFloat:angle3];
//    }
    
    // step2, update 小地图.
    [_mapManager updateMap:_mapData];
    
    // step3, update Tango坐标到ARKit坐标的转换矩阵.
    // 第一次坐标变换：将新坐标系平移，使Tango起点和新坐标系起点重合
    SCNMatrix4 tranformMatix = SCNMatrix4Identity;
    tranformMatix = SCNMatrix4Translate(tranformMatix, -_mapPoint[0].floatValue, -_mapPoint[1].floatValue,-_mapPoint[2].floatValue);
    float rotateAngle = _mapData.northOffset.floatValue *M_PI / 180;
    // 第二次坐标变换：将新坐标系旋转，使其+Y轴与ARKit坐标系的-Z轴方向一致
    tranformMatix = SCNMatrix4Rotate(tranformMatix, rotateAngle, 0, 0, 1);
    // 第三次坐标变换：将新坐标系平移，使其与ARKit坐标系完全重合
    tranformMatix = SCNMatrix4Translate(tranformMatix, _corTransformV.x,_corTransformV.y,_corTransformV.z);
    //
    _tranformMatix =  SCNMatrix4ToMat4(tranformMatix);
    _inverseMatix = simd_inverse(_tranformMatix);
    
    
    NSMutableArray<InWalkNavigationPathPoint *> *tmpPath = [[NSMutableArray alloc] initWithCapacity:self.navigationManager.navigationPath.count];
    int count = 0;
    for (InWalkNavigationPathPoint *pathPoint in self.navigationManager.navigationPath) {
        InWalkNavigationPathPoint *tmpArPoint = [InWalkNavigationPathPoint new];

        InWalkPath *path = [self getPathById: pathPoint.pathID];
        pathPoint.floor = path.floor.intValue;

        float height = -1.3;
        if (count == _s2) {
            height = 0.2; // 摆放视频(竖立图标)时用到
        }
        count++;

        NSArray<NSNumber *> *position = @[[NSNumber numberWithFloat:pathPoint.pathPosition[0]], // tango.x
                                          [NSNumber numberWithFloat:pathPoint.pathPosition[1]], // tango.y
                                          [NSNumber numberWithFloat:height]];
        //[NSNumber numberWithFloat:-1.3]];
        //此处为转换为AR坐标
        simd_float4 simd_position = simd_make_float4(position[0].floatValue,position[1].floatValue,position[2].floatValue,1);
        simd_float4 result = simd_mul(_tranformMatix, simd_position);

        tmpArPoint.pathPosition = simd_make_float3(result.x,result.z,result.y); // swap(y,z)
        tmpArPoint.angleToNext = pathPoint.angleToNext;
        tmpArPoint.turnFlag = pathPoint.turnFlag;
        [tmpPath addObject:tmpArPoint];
    }
    _arPath = tmpPath;
//
//    //step5 更新路径点
    [self updateNavigationGuide];
    
//    _lastFrameUpdateTime = currentFrame.timestamp;
    
    _isIBeaconRectify = NO;
    
//    纠偏完成，取纠偏完成对应的真实坐标
    _lastARIbeaconPoint = self.arscnView.session.currentFrame;
    //记录下来做三米纠偏
    _lastSectionPoint = currentPoint;
    _lastARSectionPoint = self.arscnView.session.currentFrame;
    _rectifyCount++;
    NSLog(@"纠偏完成");
    
    
    //重新生成AR路线 ，用当前位置点刷新路线
    
    
      //设置当前点位起点并重新开始导航
//
//    _mapPoint = @[currentPoint.x, currentPoint.y, [NSNumber numberWithInt:0]];
//
//    //不用做偏移，只需要设置起点
//    simd_float4x4 transform = _arscnView.session.currentFrame.camera.transform;
//
//    //设置路径向量
//    _corTransformV = simd_make_float4(0, 0, 0, 1);
//    _corTransformV = matrix_multiply(transform, _corTransformV);
//    float y = _corTransformV.y;
//    _corTransformV.y = _corTransformV.z;
//    _corTransformV.z = y;
//
//    //重新生成矩阵
//    [self updataTranformMatix];
//
//
//    _recognizePointId = currentPoint.hid;
//    [self newStartNavigationTo:_destPointId];
    
}

/**
 根据目标导航点生成导航路径，并计算出在ARKit坐标系中的路径点
 @param pointId 目标导航点
 */
- (void)newStartNavigationTo:(NSString*)pointId {
    
    //重新生成路径
    [self.navigationManager navigateFrom: [self getPointById:_recognizePointId] to:[self getPointById:pointId]];
    _navDetails = [self.navigationManager getNavDetails];
    
    NSMutableArray<InWalkNavigationPathPoint *> *tmpPath = [[NSMutableArray alloc] initWithCapacity:self.navigationManager.navigationPath.count];
    int count = 0;
    for (InWalkNavigationPathPoint *pathPoint in self.navigationManager.navigationPath) {
        InWalkNavigationPathPoint *tmpArPoint = [InWalkNavigationPathPoint new];
        
        InWalkPath *path = [self getPathById: pathPoint.pathID];
        //NSNumber *planeId = path.floor;
        pathPoint.floor = path.floor.intValue;
        //NSArray<NSNumber *> *position = [path positionAtIndex:pathPoint.pointIndex];
        float height = -1.3;
        if (count == _s2) {
            height = 0.2; // 摆放视频(竖立图标)时用到
        }
        count++;
        NSArray<NSNumber *> *position = @[[NSNumber numberWithFloat:pathPoint.pathPosition[0]],
                                          [NSNumber numberWithFloat:pathPoint.pathPosition[1]],
                                          [NSNumber numberWithFloat:height]];
        //[NSNumber numberWithFloat:-1.3]];
        simd_float4 simd_position = simd_make_float4(position[0].floatValue,position[1].floatValue,position[2].floatValue,1);
        simd_float4 result = simd_mul(_tranformMatix, simd_position);
        
        tmpArPoint.pathPosition = simd_make_float3(result.x,result.z,result.y);
        tmpArPoint.angleToNext = pathPoint.angleToNext;
        tmpArPoint.turnFlag = pathPoint.turnFlag;
        [tmpPath addObject:tmpArPoint];
    }
    _arPath = tmpPath;
    _arPath.lastObject.hid = pointId;
    _destPointId = pointId;
    NSLog(@"   dest hid : %@", pointId);
    //统一清空。重新生成导航数据
    _walkDistance = 0;
    _currentIndex = 0;
    _navigating = YES;
    [self updateNavigation:-1];
    
    // 生成地图上导航路径对应的数组
    NSMutableArray<NSValue *> *mapPath = [NSMutableArray arrayWithCapacity:_arPath.count];
    for (InWalkNavigationPathPoint *pathPoint in self.navigationManager.navigationPath) {
        if(pathPoint.floor == _planeId){
            NSValue *value = [NSValue valueWithCGPoint:CGPointMake(pathPoint.pathPosition[0],pathPoint.pathPosition[1])];
            [mapPath addObject:value];
        }
    }
    
    //更新路径
    [_mapManager updateNavigationPath: mapPath];
    
    
//    [_mapManager updateMap:_mapData];
    
    
}


#pragma mark - 纠偏尝试：中间距离的三米纠偏
- (BOOL)subRectifyAtTenMeters:(ARFrame *)frame {
    // 0.5s记录一次累计行走距离
    if (_sectionWalkDistance != -1 && frame.timestamp - _sectionLastFrameUpdateTime > 0.5) {
        // 记录当前cam的AR位置
        simd_float4 camPos = simd_make_float4(0,0,0,1);
        camPos = simd_mul(frame.camera.transform, camPos);
        // 累加行走距离
        if (_sectionWalkDistance >= 0) {
            float dx = camPos[0]-_sectionPrePos[0];
            float dz = camPos[2]-_sectionPrePos[2];
            float distance = sqrtf((dx*dx + dz*dz));
            if (distance > 0.4) {
                _sectionWalkDistance += distance;
                _sectionPrePos[0] = camPos[0];
                _sectionPrePos[1] = camPos[1];
                _sectionPrePos[2] = camPos[2];
            }
            //NSLog(@" ** walkDistance: %f", _walkDistance);
        }
        
        //当前行走距离到三米的时候纠偏一次
        if (_sectionWalkDistance >= 3) {
            // 找到原始数据中距离起点10m的point，对比{起点AR坐标->Cam的AR坐标}与{起点AR坐标->原始数据距离起点5m的点对应的AR坐标}的角度
            float x0 = self.navigationManager.completeNavigationPath[0].pathPosition[0];
            float y0 = self.navigationManager.completeNavigationPath[0].pathPosition[1];
//
//            float vX = 0, vY = 0;
            InWalkNavigationPathPoint * currentPoint;
            for (InWalkNavigationPathPoint *pathPoint in self.navigationManager.completeNavigationPath) {
                float dx = pathPoint.pathPosition[0] - x0;
                float dy = pathPoint.pathPosition[1] - y0;
                float tmpDelta = sqrtf(dx*dx + dy*dy);
                //NSLog(@" tmpDelta: %f", tmpDelta);
                if (tmpDelta > _distance) {
                    currentPoint = pathPoint;
                    //NSLog(@" tmpDelta.2: %f  %f", tmpDelta, _walkDistance);
                    break;
                }
            }
            //当前位置的AR点
            simd_float4 camARPos = simd_make_float4(0,0,0,1);
            camARPos = simd_mul(frame.camera.transform, camARPos);
            
            // 转换上一点位cam的AR位置
            
            simd_float4 lastCamPos = simd_make_float4(0,0,0,1);
            lastCamPos = simd_mul(_lastARSectionPoint.camera.transform, lastCamPos);
            
            // 起点AR坐标
            simd_float4 last = simd_make_float4(_lastSectionPoint.x.floatValue,_lastSectionPoint.y.floatValue,0,1);
            //    simd_float4 last = simd_make_float4(self.navigationManager.completeNavigationPath[0].pathPosition[0],self.navigationManager.completeNavigationPath[0].pathPosition[1],0,1);
            last = simd_mul(_tranformMatix, last); // 注意：Tango数据通过转换矩阵转为ARKit坐标后，y值是实际对应ARKit坐标系中Z轴的值
            //当前点对应的AR坐标
            simd_float4 current = simd_make_float4(currentPoint.x.floatValue, currentPoint.y.floatValue, 0, 1);
            current = simd_mul(_tranformMatix, current); // 注意：Tango数据通过转换矩阵转为ARKit坐标后，y值是实际对应ARKit坐标系中Z轴的值
            
            //    _currentPoistion = CGPointMake(cs///////                                                                                                                                                                                                                              urrent[0], current[1]);
            //    [_mapManager updateCurrentForwardPosition:_currentPoistion];
            // 角度1:向量{起上一点位AR坐标->Cam的AR坐标}到向量{上一点位转换后AR坐标->当前点对应转换后的AR坐标}的顺时针夹角
            simd_float4 t1 = simd_make_float4(camARPos[0]-lastCamPos[0],0,camARPos[2]-lastCamPos[2],1);
            simd_float4 t2 = simd_make_float4(current[0]-last[0],0,current[1]-last[1],1);
            
            float anglet = [self calcVectorAngleFrom:t1 to:t2];
            NSLog(@"%lf",anglet);    // 叠加到原始数据中
            float angle3 = _mapData.northOffset.floatValue;
            //    if (_rectifyCount == 0) {
            //        angle3 = angle3 + 360 - anglet +5;
            //    }else{
            //
            //    }
            angle3 = angle3 + 360 - anglet;
            //NSLog(@" ** wa angle4: %f", angle3);_
            _mapData.northOffset = [NSNumber numberWithFloat:angle3];
            
            //    if(_rectifyCount == 0){
            //        _mapData.northOffset = [NSNumber numberWithFloat:angle3 - 5];
            //    }else{
            //        _mapData.northOffset = [NSNumber numberWithFloat:angle3];
            //    }
            
            // step2, update 小地图.
            [_mapManager updateMap:_mapData];
            
            // step3, update Tango坐标到ARKit坐标的转换矩阵.
            // 第一次坐标变换：将新坐标系平移，使Tango起点和新坐标系起点重合
            SCNMatrix4 tranformMatix = SCNMatrix4Identity;
            tranformMatix = SCNMatrix4Translate(tranformMatix, -_mapPoint[0].floatValue, -_mapPoint[1].floatValue,-_mapPoint[2].floatValue);
            float rotateAngle = _mapData.northOffset.floatValue *M_PI / 180;
            // 第二次坐标变换：将新坐标系旋转，使其+Y轴与ARKit坐标系的-Z轴方向一致
            tranformMatix = SCNMatrix4Rotate(tranformMatix, rotateAngle, 0, 0, 1);
            // 第三次坐标变换：将新坐标系平移，使其与ARKit坐标系完全重合
            tranformMatix = SCNMatrix4Translate(tranformMatix, _corTransformV.x,_corTransformV.y,_corTransformV.z);
            //
            _tranformMatix =  SCNMatrix4ToMat4(tranformMatix);
            _inverseMatix = simd_inverse(_tranformMatix);
            
            
            NSMutableArray<InWalkNavigationPathPoint *> *tmpPath = [[NSMutableArray alloc] initWithCapacity:self.navigationManager.navigationPath.count];
            int count = 0;
            for (InWalkNavigationPathPoint *pathPoint in self.navigationManager.navigationPath) {
                InWalkNavigationPathPoint *tmpArPoint = [InWalkNavigationPathPoint new];
                
                InWalkPath *path = [self getPathById: pathPoint.pathID];
                pathPoint.floor = path.floor.intValue;
                
                float height = -1.3;
                if (count == _s2) {
                    height = 0.2; // 摆放视频(竖立图标)时用到
                }
                count++;
                
                NSArray<NSNumber *> *position = @[[NSNumber numberWithFloat:pathPoint.pathPosition[0]], // tango.x
                                                  [NSNumber numberWithFloat:pathPoint.pathPosition[1]], // tango.y
                                                  [NSNumber numberWithFloat:height]];
                //[NSNumber numberWithFloat:-1.3]];
                //此处为转换为AR坐标
                simd_float4 simd_position = simd_make_float4(position[0].floatValue,position[1].floatValue,position[2].floatValue,1);
                simd_float4 result = simd_mul(_tranformMatix, simd_position);
                
                tmpArPoint.pathPosition = simd_make_float3(result.x,result.z,result.y); // swap(y,z)
                tmpArPoint.angleToNext = pathPoint.angleToNext;
                tmpArPoint.turnFlag = pathPoint.turnFlag;
                [tmpPath addObject:tmpArPoint];
            }
            _arPath = tmpPath;
            //
            //    //step5 更新路径点
            [self updateNavigationGuide];
            
            //    _lastFrameUpdateTime = currentFrame.timestamp;
            NSLog(@"三米纠偏完成");
            
            _sectionWalkDistance = 0;
            _sectionLastFrameUpdateTime = frame.timestamp;
            _lastSectionPoint = currentPoint;
            _sectionPrePos = simd_make_float4(0, 0, 0, 0);
            //十米纠偏完成，进行纠偏 避免冲突
            //开始搜索ibeacon
//            __weak typeof(self) weakSelf = self;
            
            //            [[InWalkIbeaconManager manager] startSearchIbeaconWithUUIDS:self.UUIDS iBeaconResultBlcok:^(BRTBeacon * _Nonnull beacon) {
            //                [weakSelf rectifyAtBeaconsWithBeacon:beacon];
            //            }];
            
            //            [self.container makeToast:@"已经行走10m了，纠偏完成"];
            return YES; // 已进行纠偏
        }
        _sectionLastFrameUpdateTime = frame.timestamp;
    }
    return NO; // 未纠偏
}


@end
