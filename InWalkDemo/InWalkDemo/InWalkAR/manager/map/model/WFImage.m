//
//  WFImage.m
//  InWalkAR
//
//  Created by wangfan on 2018/7/20.
//  Copyright © 2018年 InReal Co., Ltd. All rights reserved.
//

#import "WFImage.h"
#import "MathUtil.h"
@implementation WFImage
-(instancetype) init{
    if(self = [super init]){
        _scale = CGSizeMake(1, 1);
        _rotateAngle = 0;
    }
    return  self;
}
-(void) drawSelf{
    [super drawSelf];
    if(_image){
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGSize size = CGSizeMake(_image.size.width, _image.size.height);
        CGRect rect = CGRectMake(0 , 0 , size.width, size.height);
        CGContextTranslateCTM(context, _position.x, _position.y);
        //NSLog(@" rotateAngle : %f  ", _rotateAngle);
        CGContextRotateCTM(context, toRadians(_rotateAngle)); // 注意：旋转是以点(_position.x, _position.y)为基准进行的，可以理解为图片是围绕{平移后的图片左上角的点}进行旋转的(顺时针)
        CGContextScaleCTM(context, _scale.width, _scale.height); // 注意：缩放是以点(_position.x, _position.y)为基准进行的
        [_image drawInRect:rect];
        CGContextRestoreGState(context);
    }
}
@end
