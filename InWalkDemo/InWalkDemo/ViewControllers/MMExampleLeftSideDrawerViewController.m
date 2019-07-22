//
//  MMExampleLeftSideDrawerViewController.m
//  InWalkDemo
//
//  Created by limu on 2019/4/18.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import "MMExampleLeftSideDrawerViewController.h"
#import "MMExampleCenterTableViewController.h"
#import "MMNavigationController.h"
#import "UIView+Toast.h"

@interface MMExampleLeftSideDrawerViewController() {
    UIButton *btn0;
    UIButton *btn1;
    UIButton *btn2;
    UIButton *btn3;
    UIButton *btn4;
}
@end

@implementation MMExampleLeftSideDrawerViewController

-(id)init{
    self = [super init];
    if(self){
        [self setRestorationIdentifier:@"MMExampleLeftSideDrawerController"];
    }
    //[self.view setBackgroundColor:[UIColor brownColor]];
    [self.view setBackgroundColor:[UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0]];
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"Left will appear");
    
    if (btn0 != nil) {
        return;
    }
    
    btn0 = [self itemAtIndex:0 imageName:@"icon_car.png" itemName:@" AR寻车"];
    btn1 = [self itemAtIndex:1 imageName:@"icon_shopping.png" itemName:@" AR导购"];
    btn2 = [self itemAtIndex:2 imageName:@"icon_food.png" itemName:@" AR美食"];
    btn3 = [self itemAtIndex:3 imageName:@"icon_car_manage.png" itemName:@" 车辆管理"];
    btn4 = [self itemAtIndex:4 imageName:@"icon_msg.png" itemName:@" 消息通知"];
    
    [self.view addSubview:btn0];
    [self.view addSubview:btn1];
    [self.view addSubview:btn2];
    [self.view addSubview:btn3];
    [self.view addSubview:btn4];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"Left did appear");
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"Left will disappear");
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"Left did disappear");
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    // 侧滑页面标题
    self.navigationItem.titleView = [self pageTitleView];
    //[self setTitle:@"智现实AR"];
}

// 列表项目
- (UIButton *)itemAtIndex:(int)index imageName:(NSString *)imageName itemName:(NSString *)itemName {
    CGFloat height = 50;
    CGFloat y = UIApplication.sharedApplication.statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height + 20 + index * (height + 10);
    
    UIButton *btn = [[UIButton alloc] init];
    btn.frame = CGRectMake(0, y, 280, height);
    //btn.backgroundColor = [UIColor redColor];
    //[btn setTitle:@"AR寻车" forState:UIControlStateNormal];
    [btn setAttributedTitle:[self richTextWithImage:[UIImage imageNamed:imageName]
                                        imageHeight:26
                                             string:itemName
                                           baseline:6.0]
                   forState:UIControlStateNormal];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    // 文本居左
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    btn.tag = index;
    
    //[btn setBackgroundColor: [UIColor whiteColor]];
    
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)btnClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (btn == nil) {
        return;
    }
    
    NSLog(@"click .. %zd", btn.tag);
    if (btn.tag == 0) {
        MMExampleCenterTableViewController * center = [[MMExampleCenterTableViewController alloc] init];
        
        UINavigationController * nav = [[MMNavigationController alloc] initWithRootViewController:center];
        
        [self.mm_drawerController setCenterViewController:nav
                                       withCloseAnimation:YES
                                               completion:nil];
        
        return;
    } else {
        [self.view.window makeToast:@"正在开发中"];
    }
}

// 页面标题
- (UIView *)pageTitleView {
    // 设置标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.attributedText = [self richTextWithImage:[UIImage imageNamed:@"icon_app.png"]
                                            imageHeight:28
                                                 string:@" 智现实AR"
                                               baseline:6.0];
    //titleLabel.frame = CGRectMake(0, 0, 240, 40);
    //titleLabel.backgroundColor = [UIColor redColor];
    return titleLabel;
}

// 创建富文本字符串
- (NSMutableAttributedString *)richTextWithImage:(UIImage *)image imageHeight:(CGFloat)h string:(NSString *)string baseline:(CGFloat)baseline {
    // 创建一个富文本
    NSMutableAttributedString *richText = [[NSMutableAttributedString alloc] initWithString:@""];
    // 添加图片
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    attch.image = image;
    attch.bounds = CGRectMake(0, 0, h, h);
    // 创建带有图片的富文本
    [richText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attch]];
    [richText appendAttributedString: [[NSAttributedString alloc] initWithString:string]];
    // 垂直居中设置
    [richText addAttribute:NSBaselineOffsetAttributeName
                     value:@(baseline)
                     range:NSMakeRange(2, richText.length - 2)];
    
    return richText;
}

@end
