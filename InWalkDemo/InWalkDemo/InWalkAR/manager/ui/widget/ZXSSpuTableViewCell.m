//
//  ZXSSpuTableViewCell.m
//  ARKitDemoUI
//
//  Created by limu on 2019/1/3.
//  Copyright © 2019年 example. All rights reserved.
//

#import "ZXSSpuTableViewCell.h"

@implementation ZXSSpuTableViewCell

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
        self.lb1 = [[UILabel alloc]initWithFrame:CGRectMake(40, 10, 300, 20)];
        self.lb2 = [[UILabel alloc]initWithFrame:CGRectMake(40, 30, 300, 20)];
        self.img = [[UIImageView alloc]initWithFrame:CGRectMake(16, 22, 14, 16)];
        
        [self.lb1 setFont:[UIFont systemFontOfSize:18]];
        [self.lb2 setFont:[UIFont systemFontOfSize:16]];
        [self.lb2 setTextColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]];
        
        [self.contentView addSubview:self.img];
        [self.contentView addSubview:self.lb1];
        [self.contentView addSubview:self.lb2];
        //[self.contentView setUserInteractionEnabled:YES];        
    }
    return self;
}

@end
