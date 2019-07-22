//
//  RZCarPlateNoKeyBoardCell.h
//  InWalkAR
//
//  Created by limu on 2019/4/18.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZCarPlateNoKeyBoardCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RZCarPlateNoKeyBoardCell : UICollectionViewCell

@property (nonatomic, strong) RZCarPlateNoKeyBoardCellModel *model;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) void(^rz_clicked)(NSIndexPath *indexPath);

@end

NS_ASSUME_NONNULL_END
