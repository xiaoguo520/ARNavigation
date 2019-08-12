//
//  UILabel+Extend.m
//  patient
//
//  Created by 新开元 iOS on 2016/11/29.
//  Copyright © 2016年 com.xky.app. All rights reserved.
//

#import "UILabel+Extend.h"

@implementation UILabel (Extend)

+(UILabel *)initWithColor:(UIColor *)color font:(UIFont *)font{
    UILabel * label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = color;
    return label;
}

-(void)setNullText:(NSString *)text{
    if ([text isEqualToString:@""]) {
        self.text = @"暂无";
        
    }else if([text hasPrefix:@""]){
        [text stringByAppendingString:@"暂无"];
        self.text = text;
    }else{
        self.text = text;
    }
    
}



- (void)alignTop {
    CGSize fontSize = [self.text sizeWithFont:self.font];
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;    //expected width of label
    CGSize theStringSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    for(int i=0; i<newLinesToPad; i++){
        self.text = [self.text stringByAppendingString:@"\n "];
        
    }
}

- (void)alignBottom {
    CGSize fontSize = [self.text sizeWithFont:self.font];
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;    //expected width of label
    CGSize theStringSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    for(int i=0; i<newLinesToPad; i++){
        self.text = [NSString stringWithFormat:@" \n%@",self.text];
    }
}

- (void)changeLineSpaceWithSpace:(float)space {
    
    NSString *labelText = self.text;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:space];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    self.attributedText = attributedString;
    [self sizeToFit];
    
}

- (void)changeWordSpaceWithSpace:(float)space {
    
    NSString *labelText = self.text;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText attributes:@{NSKernAttributeName:@(space)}];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    self.attributedText = attributedString;
    [self sizeToFit];
    
}


-(void)changeSpacewithLineSpace:(float)lineSpace WordSpace:(float)wordSpace{
    NSString *labelText = self.text;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText attributes:@{NSKernAttributeName:@(wordSpace)}];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpace];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    self.attributedText = attributedString;
    [self sizeToFit];
    
}

-(void)setSingleFont:(CGFloat)singleFont{
    self.font = [UIFont systemFontOfSize:singleFont];
}

-(CGFloat)singleFont{
    return self.jk_height;
}


//自适应
+ (CGFloat) adaptLabel_Width:(UILabel *)label {
    label.lineBreakMode = NSLineBreakByWordWrapping;
//    label.numberOfLines = 0;
    [label sizeToFit];
    CGSize currentLabelSize = [label sizeThatFits:CGSizeMake(MAXFLOAT, label.jk_height)];
    
    return currentLabelSize.width;
}

+ (CGFloat )adaptLabel_height:(UILabel *)label width:(CGFloat) width{
    
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    CGSize currentLabelSize = [label sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return currentLabelSize.height;
}


@end
