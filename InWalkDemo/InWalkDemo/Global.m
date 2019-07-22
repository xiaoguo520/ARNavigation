//
//  Global.m
//  InWalkDemo
//
//  Created by limu on 2019/4/20.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import "Global.h"

@interface Global() {

}
@end

@implementation Global

+ (instancetype)sharedInstance {
    static Global * globalVar;
    @synchronized(self){//线程锁,防止数据呗多线程操作
        if (!globalVar) {
            globalVar=[[Global alloc] init];
        }
        return globalVar;
    }
}

@end
