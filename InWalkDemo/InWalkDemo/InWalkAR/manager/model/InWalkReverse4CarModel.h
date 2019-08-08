//
//  InWalkReverse4CarModel.h
//  InWalkAR
//
//  Created by limu on 2019/4/24.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface InWalkReverse4CarModel : NSObject

@property (nonatomic, nullable,strong) NSString *spaceCode;    // 泊位号
@property (nonatomic, nullable,strong) NSString *parkingPlace; // 泊位详情
@property (nonatomic, nullable,strong) NSString *parkingPhoto; // 泊位照片

@end

NS_ASSUME_NONNULL_END
