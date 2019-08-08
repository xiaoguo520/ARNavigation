//
//  MathUtil.h
//  InRealVR
//
//  Created by 王凡 on 2017/4/28.
//  Copyright © 2017年 InReal Co., Ltd. All rights reserved.
//

#ifndef MathUtil_h
#define MathUtil_h


#endif /* MathUtil_h */

static inline float toRadians(float ang) {
    return ang * M_PI / 180.0f;
}
static inline float toDegrees(float ang){
    return ang * 180.0f / M_PI;
}

static inline float formatAngle(float angle){
    float result = fmodf(angle, 360);
    result = result < 0 ? result + 360 :result;
    result = result > 180 ? result -360 : result;
    return result;
}
