//
//  RZCarPlateNoKeyBoardCellModel.h
//  InWalkAR
//
//  Created by limu on 2019/4/18.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RZCarPlateNoKeyBoardCellModel : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIImage *image;


@property (nonatomic, assign) BOOL rz_isChangedKeyBoardBtnType;
@property (nonatomic, assign) BOOL rz_isDeleteBtnType;

@end

NS_ASSUME_NONNULL_END
