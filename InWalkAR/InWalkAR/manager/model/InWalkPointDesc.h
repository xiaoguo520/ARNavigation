//
//  InWalkPointDesc.h
//  InWalkAR
//
//  Created by limu on 2019/6/4.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 展示终点店铺的海报
@interface InWalkPointDesc : NSObject

@property(nonatomic,strong,nullable) NSString *imgSlogan;
@property(nonatomic,strong,nullable) NSString *imgType;
@property(nonatomic,strong,nullable) NSString *imgAd;
@property(nonatomic,strong,nullable) NSString *imgDesc;

@property(nonatomic) NSString *name; // 店铺名
@property(nonatomic) NSString *imgSmall; // 小图标
@property(nonatomic) NSString *imgExpand; // 展开的海报
@property(nonatomic) float scaleSmall;   // 宽
@property(nonatomic) float scaleExpand;  // 高

-(instancetype) initWithSlogan:(NSString*)sloganImg type:(NSString*)typeImg ad:(NSString*)adImg desc:(NSString*)desc;
- (instancetype)initWithShopName:(NSString*)shopName smallImage:(NSString*)smallImg scale:(float)scale1 expandImage:(NSString*)expandImg scale:(float)scale2;

@end

NS_ASSUME_NONNULL_END
