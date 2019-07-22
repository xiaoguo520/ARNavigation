//
//  ZXSNuTableViewCell.m
//  ARKitDemoUI
//
//  Created by limu on 2019/1/4.
//  Copyright © 2019年 example. All rights reserved.
//

#import "ZXSNuTableViewCell.h"

@implementation ZXSNuTableViewCell

//- (void)awakeFromNib {
//    [super awakeFromNib];
//    // Initialization code
//}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // height: 60
        self.img = [[UIImageView alloc]initWithFrame:CGRectMake(36, 18, 24, 24)];
        self.lb = [[UILabel alloc]initWithFrame:CGRectMake(64, 18, 300, 24)];
        
        [self.contentView addSubview:self.img];
        [self.contentView addSubview:self.lb];
        //[self.contentView setUserInteractionEnabled:YES];
    }
    return self;
}

@end
