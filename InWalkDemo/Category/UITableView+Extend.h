//
//  UITableView+Extend.h
//  New_Patient
//
//  Created by 新开元 iOS on 2018/12/22.
//  Copyright © 2018年 新开元 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (Extend)


/**
 设置分区圆角，cell内侧需向内偏移12个点

 @param cell cell description
 @param indexPath indexPath description
 */
-(void)setTableViewSectionRefWithCell:(UITableViewCell *)cell indexpath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
