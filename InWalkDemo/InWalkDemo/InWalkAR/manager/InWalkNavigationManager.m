//
//  NavigationManager.m
//  InWalkAR
//
//  Created by wangfan on 2018/5/25.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "InWalkNavigationManager.h"
#import "InWalkNavigationPathPoint.h"
#import "InWalkDijkstra.h"
#import "InWalkConstant.h"
#import "InWalkPath.h"
#import "MathUtil.h"
#import "NavigationModel.h"

static const int STEP_LENGTH = 3;

@interface InWalkNavigationManager(){
    NSDictionary<NSString *, InWalkPath *> *_allPaths;
    NSDictionary<NSString *, InWalkNode *> *_allNodes;
    NSDictionary<NSString *, InWalkInnerPoint *> * _allPoints;
    NSArray * _paths;
    float _stepLength;
    NSDictionary *_map;
    int _navigationIndex;
    InWalkInnerPoint *_startPoint;
    InWalkInnerPoint *_endPoint;
}
@property(nonatomic,readonly) InWalkNavigationPathPoint *currentNavigationPathPoint;
@property(nonatomic,readonly) InWalkNavigationPathPoint *nextNavigationPathPoint;
@property(nonatomic,readonly) InWalkNavigationPathPoint *previousNavigationPathPoint;
@end

@implementation InWalkNavigationManager

-(instancetype) initWithPaths:(NSDictionary<NSString *, InWalkPath *> *)paths
                        nodes:(NSDictionary<NSString *, InWalkNode *> *)nodes
                       points:(NSDictionary<NSString *, InWalkInnerPoint *> *)points{
    if([self init]){
        _stepLength = STEP_LENGTH * 2; // *2是因为point的x和y占用连续两个数组元素
        _allPaths = paths;
        _allNodes = nodes;
        _allPoints = points;
        _navigationIndex = -1;
        _map = [self generateMap];
    }
    return self;
}

- (void)releaseNavigation {
    _allPaths = nil;
    _allNodes = nil;
    _map = nil;
}

-(void) navigateFrom:(InWalkInnerPoint *) startPoint to:(InWalkInnerPoint *) endPoint{
    _startPoint = startPoint;
    _endPoint = endPoint;
    _navigationIndex = 0;
    _completeNavigationPath = [[NSMutableArray alloc] init];
    _navigationPath = [self generateNavigationPathFrom:startPoint to:endPoint];
}

/**
 生成两个场景点之间的导航路径
 
 @param startPoint 起始场景点
 @param endPoint 结束场景点
 @return 导航路径
 */
-(NSArray<InWalkNavigationPathPoint *> *)generateNavigationPathFrom:(InWalkInnerPoint *)startPoint to:(InWalkInnerPoint *)endPoint{
    // 起点和终点在同一条路径上
    if([startPoint.pathID isEqualToString:endPoint.pathID]){
        NSArray<InWalkNavigationPathPoint *> *path = [self generateNavPathWithPathId:startPoint.pathID from:startPoint.offset.intValue to:endPoint.offset.intValue lastLength:0 headIsCorner:NO tailIsCorner:NO tailIsStair:YES remainLength:nil prePoint:nil];
        path.lastObject.isStair = NO;
//        [self printTurns:path];
        return path;
    }
    
    // 计算经过的路径
    NSArray<NSString *> *pathList = [self generateMapPathFrom:startPoint to:endPoint];
    
    NSMutableArray<InWalkNavigationPathPoint *> *path = [[NSMutableArray alloc] init];
    _paths = pathList;
    NSNumber *remainLength = [[NSNumber alloc] init];
    BOOL headIsCorner = NO;
    float headCorner = 0;
    
    // 从每条路径上抽取路径点
    for (int i = 0; i < pathList.count; i++) {
        NSArray<InWalkNavigationPathPoint *> *navigationPathPoint;
        
        // 最后一条路径
        if(i == (int)(pathList.count - 1)){
            NSString * currentPathId = pathList[i];
            NSString * previousPathId = pathList[i - 1];
            InWalkPath *currentPath = [_allPaths objectForKey:currentPathId];
            InWalkNode *headNode = currentPath.headNodeID ? [_allNodes objectForKey:currentPath.headNodeID]:nil;
            InWalkNode *tailNode = currentPath.tailNodeID ? [_allNodes objectForKey:currentPath.tailNodeID]:nil;
            
            // 正序从路径上抽取点
            if(headNode && [headNode.pathIDs containsObject:previousPathId]){
                // generateNavigationPathWithVideoId
                navigationPathPoint = [self generateNavPathWithPathId:currentPathId
                                                                 from:0
                                                                   to:endPoint.offset.intValue
                                                           lastLength:remainLength.intValue
                                                         headIsCorner:headIsCorner
                                                         tailIsCorner:YES
                                                          tailIsStair:YES
                                                         remainLength:nil
                                                             prePoint:[path lastObject]];
                
                navigationPathPoint.lastObject.isCorner = NO;
                navigationPathPoint.lastObject.isStair = NO;
                navigationPathPoint.firstObject.corner = headCorner;
            }
            // 逆序从路径上抽取点
            else if(tailNode && [tailNode.pathIDs containsObject:previousPathId]){
                // generateNavigationPathWithVideoId
                navigationPathPoint = [self generateNavPathWithPathId:currentPathId
                                                                 //from:endPoint.offset.intValue to:100
                                                                 from:100 to:endPoint.offset.intValue
                                                           lastLength:remainLength.intValue
                                                         headIsCorner:headIsCorner
                                                         tailIsCorner:YES
                                                          tailIsStair:YES
                                                          remainLength:nil
                                                             prePoint:[path lastObject]];
                navigationPathPoint.lastObject.isCorner = NO;
                navigationPathPoint.lastObject.isStair = NO;
                navigationPathPoint.firstObject.corner = headCorner;
            }
            
            if(headIsCorner && navigationPathPoint != nil && navigationPathPoint.count > 0){
                InWalkNavigationPathPoint * firstPathPoint = navigationPathPoint.firstObject;
                float angle = firstPathPoint.angle.floatValue + firstPathPoint.corner + 180;
                
                // 计算拐角角度
                float corner = formatAngle(-firstPathPoint.corner -180);
                firstPathPoint.angle = [NSNumber numberWithFloat:angle];
                firstPathPoint.corner = corner;
            }
        }
        // 第一条路径 ～ 倒数第二条路径
        else{
            NSString * currentPathId = pathList[i];
            NSString * nextPathId = pathList[i + 1];
            InWalkPath *currentPath = [_allPaths objectForKey:currentPathId];
            InWalkNode *headNode = currentPath.headNodeID ? [_allNodes objectForKey:currentPath.headNodeID]:nil;
            InWalkNode *taiNode = currentPath.tailNodeID ? [_allNodes objectForKey:currentPath.tailNodeID]:nil;
            
            BOOL tailIsStair = NO;   // 路径的最后一个点是否在楼梯处
            float tailCorner = 0;    // 路径的最后一个点若是拐角，角度值
            BOOL tailIsCorner = YES; // 路径的最后一个点是否在拐角处
            
            // 逆序从路径上抽取点
            if(headNode && [headNode.pathIDs containsObject:nextPathId] ){
                //float startTime = i==0 ? startPoint.offset.floatValue : currentPath.duration.floatValue;
                int startTime = i==0 ? startPoint.offset.intValue : 100;
                int endTime = 0;
                NSUInteger currentIndex = [headNode.pathIDs indexOfObject:currentPathId];
                NSUInteger nextIndex = [headNode.pathIDs indexOfObject:nextPathId];
                
                
                // 关于拐角角度：(angle2 - angle1 + 360) % 360 的值 30-150表示右转，210-330表示左转
                // 计算两段路径连接处的拐角角度
                tailCorner = formatAngle(headNode.directions[currentIndex].floatValue -headNode.directions[nextIndex].floatValue-180) ;
                if(tailCorner > -45 && tailCorner < 45){
                    tailCorner =0;
                    tailIsCorner = NO;
                }
                
                // 抽取路径点
                navigationPathPoint = [self generateNavPathWithPathId:currentPathId from:startTime to:endTime lastLength:remainLength.intValue headIsCorner:headIsCorner tailIsCorner:tailIsCorner tailIsStair:tailIsStair remainLength:&remainLength prePoint:[path lastObject]];
                
                navigationPathPoint.firstObject.corner = headCorner;
                if(headIsCorner && navigationPathPoint != nil && navigationPathPoint.count > 0){
                    InWalkNavigationPathPoint * firstPathPoint = navigationPathPoint.firstObject;
                    float angle = firstPathPoint.angle.floatValue + firstPathPoint.corner + 180;
                    float corner = formatAngle(- firstPathPoint.corner -180);
                    firstPathPoint.angle = [NSNumber numberWithFloat:angle];
                    firstPathPoint.corner = corner;
                }
                
                headIsCorner = tailIsCorner;
                headCorner = tailCorner;
            }
            // 正序从路径上抽取点
            else if(taiNode && [taiNode.pathIDs containsObject:nextPathId]){
                float startTime = i == 0 ? [startPoint.offset floatValue] : 0;//i==0 ? startPoint.offset.floatValue : 0;
                float endTime = 100; //currentPath.duration.floatValue;
                NSUInteger currentIndex = [taiNode.pathIDs indexOfObject:currentPathId];
                NSUInteger nextIndex = [taiNode.pathIDs indexOfObject:nextPathId];
                
                // 判断是否拐角
                tailCorner = formatAngle(taiNode.directions[currentIndex].floatValue -taiNode.directions[nextIndex].floatValue -180);
                if(tailCorner > -45 && tailCorner < 45){
                    tailCorner =0;
                    tailIsCorner = NO;
                }
                
                // generateNavigationPathWithVideoId
                navigationPathPoint = [self generateNavPathWithPathId:currentPathId from:startTime to:endTime lastLength:remainLength.intValue headIsCorner: headIsCorner tailIsCorner:tailIsCorner tailIsStair:tailIsStair remainLength:&remainLength prePoint:[path lastObject]];
                navigationPathPoint.firstObject.corner = headCorner;
                if(headIsCorner && navigationPathPoint != nil && navigationPathPoint.count > 0){
                    InWalkNavigationPathPoint * firstPathPoint = navigationPathPoint.firstObject;
                    float angle = firstPathPoint.angle.floatValue + firstPathPoint.corner + 180;
                    float corner = formatAngle(-firstPathPoint.corner - 180);
                    firstPathPoint.angle = [NSNumber numberWithFloat:angle];
                    firstPathPoint.corner = corner;
                }
                
                
                
                headIsCorner = tailIsCorner;
                headCorner = tailCorner;
            } // else {}
            
            if(tailIsStair && tailIsCorner && navigationPathPoint != nil && navigationPathPoint.count > 0){
                navigationPathPoint.lastObject.isCorner = YES;
                navigationPathPoint.lastObject.corner = tailCorner;
            }
        } // end of else
        
        if(navigationPathPoint && navigationPathPoint.count > 0){
            [path addObjectsFromArray:navigationPathPoint];
        }
    } // end of for
    
//    [self printTurns:path];
    return path;
}

- (NSString *)toDistanceDesc:(float)distance{
    if (distance > 1000) {
        return [NSString stringWithFormat:@"%.2f公里", distance / 1000.];
    }
    if (distance > 1) {
        return [NSString stringWithFormat:@"%d米", (int)distance];
    }
    return [NSString stringWithFormat:@"%.2f米", distance];
}

- (NSArray<NavigationModel *> *)getNavDetails{
    int len = _navigationPath ? (int)_navigationPath.count : 0;
    if (len < 2) {
        //NSLog(@" there is no route.");
        return nil;
    }
    
    NSMutableArray<NavigationModel *> *result = [[NSMutableArray alloc] init];
    if (len == 2) {
        InWalkNavigationPathPoint * first = [_navigationPath objectAtIndex:0];
        InWalkNavigationPathPoint * second = [_navigationPath objectAtIndex:1];
        float dx = second.pathPosition[0] - first.pathPosition[0];
        float dy = second.pathPosition[1] - first.pathPosition[1];
        float length = sqrt(dx*dx+dy*dy);
        //NSLog(@" walk %f meters and arrive destination.", length);
        [result addObject:[[NavigationModel alloc] initWithDistanceToTurn:[self toDistanceDesc:length] tip:NavigationTipEnd]];
        return [result copy];
    }
    
    int lastTurnPointIdx = 0;
    int i;
    float sum = 0;
    InWalkNavigationPathPoint *first;
    InWalkNavigationPathPoint *second;
    InWalkNavigationPathPoint *third;
    for (i = 0; i < len - 3; i++) {
        first = [_navigationPath objectAtIndex:i];
        second = [_navigationPath objectAtIndex:i + 1];
        third = [_navigationPath objectAtIndex:i + 2];
        float delta = third.angleToNext - first.angleToNext;
        BOOL isTurnPoint = NO;
        NSString *turnDirection;
        BOOL isTurnLeft = NO;
        float length = 0;
        if ((delta > 45 && delta < 135) || (delta > -315 && delta < -225)) {
            // 左转
            //NSLog(@" turn left >>> %d", (i + 1));
            isTurnPoint = YES;
            turnDirection = @"Left";
            third.turnFlag = 1;
            isTurnLeft = YES;
        } else if ((delta < -45 && delta > -135) || (delta > 225 && delta < 315)) {
            // 右转
            //NSLog(@" turn right >>> %d", (i + 1));
            isTurnPoint = YES;
            turnDirection = @"Right";
            third.turnFlag = 2;
            isTurnLeft = NO;
        }
        if (isTurnPoint) {
            // 计算前行距离
            for (int j = lastTurnPointIdx + 1; j <= i + 1; j++) {
                first = [_navigationPath objectAtIndex:j-1];
                second = [_navigationPath objectAtIndex:j];
                float dx = second.pathPosition[0] - first.pathPosition[0];
                float dy = second.pathPosition[1] - first.pathPosition[1];
                length += sqrt(dx*dx+dy*dy);
            }
            lastTurnPointIdx = i + 1;
            //second.isTurnPoint = YES;
            i++; // 跳到下一个点继续
            //NSLog(@" walk %f meters and turn %@.", length, turnDirection);
            [result addObject:[[NavigationModel alloc] initWithDistanceToTurn:[self toDistanceDesc:length]
                                                                  tip:isTurnLeft ? NavigationTipTurnLeft:NavigationTipTurnRight]];
            sum += length;
            
            //[self calcRealtimeDistanceAtIndex:(i-2) onPath:path];
        }
    }
    // walk to end.
    float length = 0;
    for (int j = lastTurnPointIdx + 1; j < len; j++) {
        first = [_navigationPath objectAtIndex:j-1];
        second = [_navigationPath objectAtIndex:j];
        float dx = second.pathPosition[0] - first.pathPosition[0];
        float dy = second.pathPosition[1] - first.pathPosition[1];
        length += sqrt(dx*dx+dy*dy);
    }
    sum += length;
    _totalLength = sum;
    //NSLog(@" walk %f meters and arrive destination.", length);
    [result addObject:[[NavigationModel alloc] initWithDistanceToTurn:[self toDistanceDesc:length] tip:NavigationTipEnd]];
    //NSLog(@"total %f meters(%d)", sum, len);
    _navigationPath.lastObject.turnFlag = 3;
    
    //[self calcRealtimeDistanceAtIndex:(len-2) onPath:path];
    //NSLog(@"end ...");
    return [result copy];
}

//- (NavigationModel *)calcRealtimeDistanceAtIndex:(int)index onPath:(NSArray<InWalkNavigationPathPoint *> *)path{
- (NavigationModel *)calcRealtimeDistanceAtIndex:(int)index{
    // 计算实时位置(index表示)到下一个拐点(或目标点)的距离
    InWalkNavigationPathPoint *pt, *prePt;
    float distanceToTurn = 0;
    float distanceToEnd = 0;
    int i = 0;
    int turnFlag = 0;
    NavigationModel *result = [[NavigationModel alloc] init];
    
    prePt = [_navigationPath objectAtIndex: index];
    for (i = index + 1; i < _navigationPath.count; i++) {
        pt = [_navigationPath objectAtIndex:i];
        float dx = pt.pathPosition[0] - prePt.pathPosition[0];
        float dy = pt.pathPosition[1] - prePt.pathPosition[1];
        if (distanceToEnd == 0) {
            distanceToTurn += sqrt(dx*dx+dy*dy);
            if (pt.turnFlag > 0) {
                distanceToEnd = distanceToTurn;
                //break;
                turnFlag = pt.turnFlag;
            }
        } else {
            distanceToEnd += sqrt(dx*dx+dy*dy);
        }
        prePt = pt;
    }
    if (index + 2 >= _navigationPath.count) {
        turnFlag = 3;
    }
    
    NSString *tip;
    if (i == _navigationPath.count) {
        tip = [NSString stringWithFormat:@"(realtime) walk %f meters and arrive destination.", distanceToTurn];
    } else {
        tip = [NSString stringWithFormat:@"(realtime) walk %f meters and turn %@.", distanceToTurn, pt.turnFlag == 1 ? @"Left" : @"Right"];
    }
    
    //NSLog(@"%@", tip);
    switch (turnFlag) {
        case 0:
            result.tip = NavigationTipStraight;
            break;
        case 1:
            result.tip = NavigationTipTurnLeft;
            break;
        case 2:
            result.tip = NavigationTipTurnRight;
            break;
        default:
            result.tip = NavigationTipEnd;
            break;
    }
    result.distanceToTurn = distanceToTurn;
    result.distanceToEnd = distanceToEnd;
    result.distanceToTurnDesc = [self toDistanceDesc:distanceToTurn];
    result.distanceToEndDesc = [self toDistanceDesc:distanceToEnd];
    return result;
}

/**
 生成视频路径上开始时间到结束时间的导航路径
 由于需要每隔_stepLength取一个路径点，当前后两条路径在一条直线上时需要将两条路径联合起来考虑
 
 @param pathID 视频路径Id
 @param startOffset 开始时间
 @param endOffset 结束时间
 @param lastLength 起始点偏移
 @param tailIsCorner 路径重点是否是转弯点
 @param remainLength 下一个路径点所需起始偏移
 @return 导航路径
 */
-(NSArray<InWalkNavigationPathPoint *> *) generateNavPathWithPathId:(NSString *) pathID from:(int) startOffset to:(int)endOffset lastLength:(int)lastLength headIsCorner:(BOOL)headIsCorner tailIsCorner:(BOOL)tailIsCorner tailIsStair:(BOOL)tailIsStair remainLength:(NSNumber **) remainLength prePoint:(InWalkNavigationPathPoint *)previousPoint{
    
    InWalkPath *path = [_allPaths objectForKey:pathID];
    int pointsCount = (path != nil && path.data != nil) ? (int)path.data.count / 2 : 0;
    if(pointsCount == 0){
        _completeNavigationPath = nil;
        return nil;
    }
    
    NSMutableArray<InWalkNavigationPathPoint *> *pathList = [[NSMutableArray alloc] init];
    BOOL isReverse = startOffset > endOffset ? YES : NO;
    NSNumber * angle = isReverse ? @180 : @0;
    lastLength = isReverse ? -lastLength : lastLength;
    float stepLength = isReverse ? -_stepLength : _stepLength; // 每多少个点取一个点
    float skipLength = _stepLength / 2;
    // startIndex
    int startSampleIndex = (int)(pointsCount * startOffset / 100);
    if (startSampleIndex > 0) {
        startSampleIndex--; // offset是百分比，但pointIndex应该从0开始计算
    }
    startSampleIndex *= 2; // 每个point(x,y)占用2个数组元素，这里x2表示startPoint.x的位置
    // endIndex
    int endSampleIndex = (int)(pointsCount * endOffset / 100);
    if (endSampleIndex > 0) {
        endSampleIndex--; // offset是百分比，但pointIndex应该从0开始计算
    }
    endSampleIndex *= 2; // 每个point(x,y)占用2个数组元素，这里x2表示endPoint.x的位置
    // currentIndex
    int currentIndex = startSampleIndex;
    InWalkNavigationPathPoint *prePoint = previousPoint;
    
    // 第一个点
    if(headIsCorner){
        InWalkNavigationPathPoint * startPoint = [[InWalkNavigationPathPoint alloc] init];
        startPoint.isCorner = YES;
        startPoint.pathID = pathID;
        startPoint.angle = angle;
        startPoint.pointIndex = currentIndex;
        
        startPoint.pathPosition = simd_make_float3([[path.data objectAtIndex:currentIndex] floatValue],
                                                   [[path.data objectAtIndex:(currentIndex + 1)] floatValue],
                                                   0);
        //[pathList addObject:startPoint];
        // 计算角度
        if (prePoint) {
            prePoint.angleToNext = [self calcAngleFrom:prePoint.pathPosition to:startPoint.pathPosition];
        }
        prePoint = startPoint;
        lastLength = stepLength;
    }
    
    // 中间的点
    while ((isReverse && currentIndex > endSampleIndex) || (!isReverse && currentIndex < endSampleIndex)) {
        InWalkNavigationPathPoint * point = [[InWalkNavigationPathPoint alloc] init];
        point.pathID = pathID;
        point.angle = angle;
        point.pointIndex = currentIndex;
        
        point.pathPosition = simd_make_float3([[path.data objectAtIndex:currentIndex] floatValue],
                                              [[path.data objectAtIndex:(currentIndex + 1)] floatValue],
                                              0);
        // 计算角度
        if (prePoint) {
            prePoint.angleToNext = [self calcAngleFrom:prePoint.pathPosition to:point.pathPosition];
        }
        prePoint = point;
        
        [pathList addObject:point];
        currentIndex += stepLength;
    }
    
    // 最后一个点
    if(tailIsCorner || tailIsStair){
        if(_stepLength - fabs(currentIndex - endSampleIndex) < skipLength && pathList.count > 1){
            [pathList removeLastObject];
        }
        if(remainLength){
            *remainLength = @0;
        }
        if(tailIsStair){
            InWalkNavigationPathPoint * endPoint = [[InWalkNavigationPathPoint alloc ] init];
            endPoint.isCorner = YES;
            endPoint.pathID = pathID;
            endPoint.angle = angle;
            endPoint.pointIndex = endOffset;
            if (currentIndex > endSampleIndex) {
                currentIndex = endSampleIndex;
            }
            endPoint.pathPosition = simd_make_float3([[path.data objectAtIndex:currentIndex] floatValue],
                                                     [[path.data objectAtIndex:(currentIndex + 1)] floatValue],
                                                     0);
            // 计算角度
            if (prePoint) {
                prePoint.angleToNext = [self calcAngleFrom:prePoint.pathPosition to:endPoint.pathPosition];
            }
            prePoint = endPoint;
            
            endPoint.isStair = YES;
            [pathList addObject:endPoint];
        }
    }else if(remainLength){
        *remainLength = [NSNumber numberWithInt: fabs(currentIndex - endSampleIndex) / 2];
    }
    
    // 储存所有point的数据，用于纠偏
    NSMutableArray<InWalkNavigationPathPoint *> *tmpCompleteList = [[NSMutableArray alloc] init];
    currentIndex = startSampleIndex;
    stepLength = isReverse ? -2 : 2;
    while ((isReverse && currentIndex > endSampleIndex) || (!isReverse && currentIndex < endSampleIndex)) {
        InWalkNavigationPathPoint *point = [[InWalkNavigationPathPoint alloc] init];
        point.pathPosition = simd_make_float3([[path.data objectAtIndex:currentIndex] floatValue],
                                              [[path.data objectAtIndex:(currentIndex + 1)] floatValue],
                                              0);
        point.x = [path.data objectAtIndex:currentIndex];
        point.y = [path.data objectAtIndex:currentIndex + 1];
        currentIndex += stepLength;
        [tmpCompleteList addObject:point];
    }
    [_completeNavigationPath addObjectsFromArray: tmpCompleteList];
    ////NSLog(@"  complete path points: %zd", _completeNavigationPath.count);
    
    return pathList;
}



// 计算从 +y轴单位向量(0,1) 到 目标向量(从fromPoint指向toPoint) 的夹角(逆时针)
- (float)calcAngleFrom:(simd_float3)fromPoint to:(simd_float3)toPoint{
    // 先求出两个向量的模，再求出两个向量的向量积
    // cos<a,b>=a*b/[|a|*|b|]=(x1x2+y1y2)/[√[x1^2+y1^2]*√[x2^2+y2^2]]
    float x1 = 0;
    float y1 = 1;
    float x2 = toPoint[0] - fromPoint[0];
    float y2 = toPoint[1] - fromPoint[1];
    double cosab = (x1*x2+y1*y2) / (sqrt(x1*x1+y1*y1)*sqrt(x2*x2+y2*y2));
    float angle = toDegrees(acos(cosab));
    
    double crossab = x1*y2-y1*x2; // +y向量与ab向量的叉乘，为正数说明+y到ab是顺时针(360-angle)，否则是逆时针(angle)
    if (crossab > 0) {
        return 360 - angle;
    } else {
        return angle;
    }
}

/**
 生成两场景点之间的最短路径（Dijkstra）
 
 @param startPoint 起始场景点
 @param endPoint 结尾场景点
 @return 最短路径所经过的节点
 */
-(NSArray *)generateMapPathFrom:(InWalkInnerPoint *)startPoint to:(InWalkInnerPoint *)endPoint{
    NSArray *nodeShorstPath;
    
    // 遍历所有连通的路径
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    InWalkPath *startPath = nil;
    InWalkPath *endPath = nil;
    NSString *startPointHeadNodeId = nil;//[_allPaths objectForKey:startPoint.pathID].headNodeID;
    NSString *startPointTailNodeId = nil;//[_allPaths objectForKey:startPoint.pathID].tailNodeID;
    NSString *endPointHeadNodeId = nil;//[_allPaths objectForKey:endPoint.pathID].headNodeID;
    NSString *endPointTailNodeId = nil;//[_allPaths objectForKey:endPoint.pathID].tailNodeID;
    if (startPoint.pathID) {
        startPath = [_allPaths objectForKey:startPoint.pathID];
        startPointHeadNodeId = startPath.headNodeID;
        startPointTailNodeId = startPath.tailNodeID;
    }
    if (endPoint.pathID) {
        endPath = [_allPaths objectForKey:endPoint.pathID];
        endPointHeadNodeId = endPath.headNodeID;
        endPointTailNodeId = endPath.tailNodeID;
    }
    
    float shorstWeight = NSIntegerMax;
    if(startPointHeadNodeId && endPointHeadNodeId){
        [paths addObject:InWalkShortestPath(_map, startPointHeadNodeId, endPointHeadNodeId)];
    }
    if(startPointHeadNodeId && endPointTailNodeId){
        [paths addObject:InWalkShortestPath(_map, startPointHeadNodeId, endPointTailNodeId)];
    }
    if(startPointTailNodeId && endPointHeadNodeId){
        [paths addObject:InWalkShortestPath(_map, startPointTailNodeId, endPointHeadNodeId)];
    }
    if(startPointTailNodeId && endPointTailNodeId){
        [paths addObject:InWalkShortestPath(_map, startPointTailNodeId, endPointTailNodeId)];
    }
    
    // 选择最短路径
    for (NSArray * path in paths) {
        if (path == nil) continue;
        
        float tmpWeight = [self calculateWeightFromPath:path];
        
        if (path.count > 0) {
            // 起点到第一个Node的距离
            if (startPointHeadNodeId && [startPointHeadNodeId isEqualToString:path.firstObject]) {
                tmpWeight = tmpWeight + [startPoint.distanceToHead floatValue];
            } else if (startPointTailNodeId && [startPointTailNodeId isEqualToString:path.firstObject]) {
                tmpWeight = tmpWeight + [startPath.length floatValue] - [startPoint.distanceToHead floatValue];
            }
            
            // 终点到最后一个Node的距离
            if (endPointHeadNodeId && [endPointHeadNodeId isEqualToString:path.lastObject]) {
                tmpWeight = tmpWeight + [endPoint.distanceToHead floatValue];
            } else if (endPointTailNodeId && [endPointTailNodeId isEqualToString:path.lastObject]) {
                tmpWeight = tmpWeight + [endPath.length floatValue] - [endPoint.distanceToHead floatValue];
            }
        }
        
        if(shorstWeight > tmpWeight){
            shorstWeight = tmpWeight;
            nodeShorstPath = path;
        }
    }
    
    // 记录最短路径经过的路径ID
    NSMutableArray<NSString *> *shortestPathList = [[NSMutableArray alloc] initWithCapacity:nodeShorstPath.count+1];
    [shortestPathList addObject:startPoint.pathID];
    for (int i=0; i<nodeShorstPath.count -1; i++) {
        InWalkNode *tmpNode =  [_allNodes objectForKey:nodeShorstPath[i]];
        NSUInteger index = [tmpNode.nodeIDs indexOfObject:nodeShorstPath[i+1]];
        [shortestPathList addObject:tmpNode.pathIDs[index]];
    }
    [shortestPathList addObject:endPoint.pathID];
    
    return shortestPathList;
}

/**
 生成路线图
 @return 路线图
 */
-(NSDictionary *) generateMap{
    NSMutableDictionary<NSString *, NSMutableDictionary*> * map = [[NSMutableDictionary alloc] init];
    
    for (InWalkPath * path in _allPaths.allValues) {
        InWalkNode * headNode = path.headNodeID ? [_allNodes objectForKey: path.headNodeID] : nil;
        InWalkNode * tailNode = path.tailNodeID ? [_allNodes objectForKey: path.tailNodeID] : nil;
        if(headNode != nil && tailNode != nil){
            NSMutableDictionary *headNodeEdge = [map objectForKey:headNode.nodeID];
            NSMutableDictionary *tailNodeEdge = [map objectForKey:tailNode.nodeID];
            NSNumber * weight = path.weight ? path.weight : @1000000;
            if(headNodeEdge == nil){
                headNodeEdge = [[NSMutableDictionary alloc] init];
                [map setObject:headNodeEdge forKey:headNode.nodeID];
            }
            if(tailNodeEdge == nil){
                tailNodeEdge = [[NSMutableDictionary alloc] init];
                [map setObject:tailNodeEdge forKey:tailNode.nodeID];
            }
            [headNodeEdge setObject:weight forKey:tailNode.nodeID];
            [tailNodeEdge setObject:weight forKey:headNode.nodeID];
        }
    }
    
    return map;
}

-(float) calculateVectorDirectionFrom:(NSArray<NSNumber *> *) from to:(NSArray<NSNumber *> *) to{
    float angle1 = atan2f(to[1].floatValue, to[0].floatValue);
    float angle2 = atan2f(from[1].floatValue, from[0].floatValue);
    return formatAngle(toDegrees(angle1 - angle2));
}

-(InWalkNavigationPathPoint *) currentNavigationPathPoint{
    if(_navigationPath != nil && _navigationIndex >= 0 && _navigationIndex < _navigationPath.count){
        return _navigationPath[_navigationIndex];
    }
    return nil;
}

-(InWalkNavigationPathPoint *) nextNavigationPathPoint{
    if(_navigationPath != nil && _navigationIndex >= 0 && _navigationIndex < _navigationPath.count -1){
        return _navigationPath[_navigationIndex +1];
    }
    return nil;
}

-(InWalkNavigationPathPoint *) previousNavigationPathPoint{
    if(_navigationPath != nil && _navigationIndex >= 1 && _navigationIndex < _navigationPath.count){
        return _navigationPath[_navigationIndex-1];
    }
    return nil;
}

-(BOOL) isReachDestination{
    return _navigationIndex == _navigationPath.count -1;
}

-(BOOL) isReachStart{
    return _navigationIndex == 0;
}

#pragma mark --导航路径相关



/**
 计算导航路径的总权重
 
 @param path 导航路径
 @return 权重
 */
-(float) calculateWeightFromPath:(NSArray *) path{
    float weight =0;
    for (int i =0 ; i < path.count - 1; i++) {
        weight += [self calculateWeightFrom:path[i] to:path[i+1]];
    }
    return weight;
}

/**
 计算两相邻节点之间的权重
 
 @param fromNodeId 起始节点ID
 @param toNodeId 结尾节点ID
 @return 权重值
 */
-(float) calculateWeightFrom:(NSString *) fromNodeId to:(NSString *) toNodeId{
    float weight = 1000000;
    InWalkNode *fromNode = [_allNodes objectForKey:fromNodeId];
    if (fromNode.nodeIDs != nil){
        NSUInteger index = [fromNode.nodeIDs indexOfObject:toNodeId];
        if(index != NSNotFound){
            weight = [_allPaths objectForKey:fromNode.pathIDs[index]].weight.floatValue;
        }
    }
    return weight;
}


-(NSMutableArray<InWalkNavigationPathPoint *> *)beaconNavigationPath{
    NSMutableArray * beaconNavPaths = [NSMutableArray array];
    int i = 0;
    for (InWalkNavigationPathPoint * point in self.completeNavigationPath) {
        //根据x y 值判断当前所有定位点中的位置点
        for (InWalkInnerPoint * p in _allPoints.allValues) {
            if (p.x.floatValue == point.x.floatValue && p.y.floatValue == point.y.floatValue) {
                p.pointIndex = i;
                [beaconNavPaths addObject:p];
                i++;
                break;
            }
        }
    }
    
    return beaconNavPaths;
}




@end
