//
//  MMExampleCenterTableViewController.m
//  InWalkDemo
//
//  Created by limu on 2019/4/18.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import "MMExampleCenterTableViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "ProjectListViewController.h"
#import <InWalkAR/InWalkAR.h>
#import "ARNavigationViewController.h"
#import "Global.h"

typedef NS_ENUM(NSInteger, MMCenterViewControllerSection){
    MMCenterViewControllerSectionLeftViewState,
    MMCenterViewControllerSectionLeftDrawerAnimation,
    MMCenterViewControllerSectionRightViewState,
    MMCenterViewControllerSectionRightDrawerAnimation,
};

@interface MMExampleCenterTableViewController()<InWalkManagerDelegate>
@property(nonatomic) InWalkManager * manager;
@property(nonatomic) NSString *projectId;
@end

@implementation MMExampleCenterTableViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self setRestorationIdentifier:@"MMExampleCenterControllerRestorationKey"];
    }
    [self.view setBackgroundColor:[UIColor whiteColor]];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // add view.
    [self.navigationItem setTitleView:nil];
        
    [self setupLeftMenuButton];
    
    // 1. 加载数据
//    [self loadData];
    [self loadLocalData];
    
    //[self.navigationItem setTitleView: [self pageTitleViewWithTitle:@"松日鼎盛大厦 "]];
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    // image
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_1.png"]];
    iv.frame = CGRectMake(0, screenBounds.size.height / 2.0 - 200, screenBounds.size.width, 350);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:iv];
    
    // label
    UILabel *lb = [[UILabel alloc] init];
    CGFloat w2 = 240;
    lb.frame = CGRectMake((screenBounds.size.width - w2) / 2.0, screenBounds.size.height / 2.0, w2, 50);
    lb.text = @"帮助您寻找爱车";
    lb.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lb];
    
    // button
    UIButton *btn = [[UIButton alloc] init];
    CGFloat w1 = 160;
    btn.frame = CGRectMake((screenBounds.size.width - w1) / 2.0, screenBounds.size.height / 2.0 + 64, w1, 44);
    [btn setTitle:@"开启AR寻车" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor colorWithRed:70.0/255.0 green:126.0/255.0 blue:247.0/255.0 alpha:1.0];
    [btn setTintColor:[UIColor redColor]];
    btn.layer.cornerRadius = 6.0;
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)loadLocalData {
    NSMutableDictionary<NSString *, NSString *> *idList = [[NSMutableDictionary alloc] init];
    [idList setObject:@"益友车城" forKey:@"id_xxxxx"];
    [idList setObject:@"卓越城" forKey:@"id_xxxxx22"];    
    
    [Global sharedInstance].projectList = idList;
    
    self.projectId = [[idList allKeys] objectAtIndex: 0];
    [Global sharedInstance].val = self.projectId;
    
    [self refreshTitleView];
}

- (void)loadData {
    // 登录、加载项目列表
    __weak typeof(self) weakSelf = self;
    NSURL *url = [NSURL URLWithString:@"http://47.112.14.122:3010/api/v1/pb/login/local"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    //"username=test&password=123123"
    //NSString *keyValueBody = [NSString stringWithFormat:@"username=%@&password=%@", _INWALKAR_TEST_ACC, _INWALKAR_TEST_PWD];
    request.HTTPBody = [@"username=test&password=123123" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{@"Content-Type":@"application/x-www-form-urlencoded;charset=utf-8"};
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    //NSURLSession *session = NSURLSession.sharedSession;
    
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            if(strongSelf == nil){
                return ;
            }
            
            if(error){
                // 加载数据失败，弹出提示消息
                NSLog(@"加载数据失败");
            }else{
                NSDictionary * dir = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                // load project list.
                [strongSelf loadProjectList: [dir objectForKey:@"accessToken"]];
            }
        });
    }];
    [task resume];
}

- (void)loadProjectList:(NSString *)accessToken {
    NSURLSession *session = NSURLSession.sharedSession;
    __weak typeof(self) weakSelf = self;
    //ar?size=10
    NSURL *url = [NSURL URLWithString:@"http://47.112.14.122:3010/api/v1/ar?size=1000"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    // add Header
    [request setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            if(strongSelf == nil){
                return ;
            }
            
            if(error){
                // 加载数据失败，弹出提示消息
            }else{
                
//                [InWalkModel inWalk_setupObjectClassInArray:^{
//                    return @{
//                             @"hotspots":@"InWalkInnerPoint",
//                             @"maps":@"InWalkMap"
//                             };
//                }];
//
//                [InWalkItem inWalk_setupObjectClassInArray:^{
//                    return @{
//                             @"overlays":@"InWalkInnerOverlay",
//                             @"nodes":@"InWalkNode"
//                             };
//                }];
                
                NSDictionary * dir =  [NSJSONSerialization JSONObjectWithData:data options:kNilOptions  error:nil];
                
                // NSString *errorInfo = dir[@"detail"][@"message"] ? dir[@"detail"][@"message"] : dir[@"detail"][@"details"][0][@"message"];
                
                // 解析数据、展示到Title
                
                // 创建Model
                if ([[dir allKeys] containsObject:@"count"]) {
                    NSNumber *count = dir[@"count"];
                    NSMutableDictionary<NSString *, NSString *> *idList = [[NSMutableDictionary alloc] init];
                    if (count.intValue > 0) {
                        for (int i = 0; i < count.intValue; i++) {
                            //[idList addObject: dir[@"rows"][i][@"_id"]];
                            [idList setObject:dir[@"rows"][i][@"name"] forKey:dir[@"rows"][i][@"_id"]];
                        }
                        
                        [Global sharedInstance].projectList = idList;
                        
                        self.projectId = [[idList allKeys] objectAtIndex: 0];
                        [Global sharedInstance].val = self.projectId;
                        
                        [self refreshTitleView];
                    }
                }
                
                //
                
                //
                
                //
                
                // todo - 项目列表数据：需要添加项目名称
                // todo - 展示提示(开始导航的提示)
                
            }
        });
    }];
    [task resume];
}

- (void)refreshTitleView {
    //if (self.projectId && [Global sharedInstance].projectList)
    NSString *name = [NSString stringWithFormat:@"%@", [[Global sharedInstance].projectList objectForKey: self.projectId]];
    [self.navigationItem setTitleView: [self pageTitleViewWithTitle: [NSString stringWithFormat:@"%@ ", name]]];
}

- (void)btnClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (btn == nil) {
        return;
    }
    
    NSLog(@"click .. %zd ... start", btn.tag);
    
    // 跳转到新页面
    ARNavigationViewController *twoVC = [[ARNavigationViewController alloc] init];
    [self presentViewController:twoVC animated:YES completion:^{
        //modal完成是调用
        NSLog(@" NavigationViewController ...");
    }];
    
}



#pragma mark - viewController 相关

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"Center will appear");
    
    // 判断ProjectID是否发生改变，如果是，需要刷新页面
    if ([Global sharedInstance].val != self.projectId) {
        self.projectId = [Global sharedInstance].val;
        [self refreshTitleView];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"Center did appear");
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"Center will disappear");
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"Center did disappear");
}

-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)doubleTap:(UITapGestureRecognizer*)gesture{
    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideLeft completion:nil];
}

-(void)twoFingerDoubleTap:(UITapGestureRecognizer*)gesture{
    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideRight completion:nil];
}

- (UIView *)pageTitleViewWithTitle:(NSString *)title {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.attributedText = [self richTextWithImage:[UIImage imageNamed:@"ic_drop.png"]
                                                 string:title //@"松日鼎盛大厦 "
                                               baseline:0.0];
    // 点击事件
    titleLabel.userInteractionEnabled = YES;
    [titleLabel addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTouchUpInside:)]];
    
    return titleLabel;
}

- (void)labelTouchUpInside:(UITapGestureRecognizer *)recognizer{
    NSLog(@"touch ...");
    
    ProjectListViewController *twoVC = [[ProjectListViewController alloc] init];
    //self.twoVC = twoVC;
    
    //modal出来的View添加在窗口上面,把之前的根控制器的View移除
    
    [self presentViewController:twoVC animated:YES completion:^{
        //modal完成是调用
        NSLog(@" ProjectListViewController ...");
    }];
}

// 创建富文本字符串
- (NSMutableAttributedString *)richTextWithImage:(UIImage *)image string:(NSString *)string baseline:(CGFloat)baseline {
    // 创建一个富文本
    NSMutableAttributedString *richText = [[NSMutableAttributedString alloc] initWithString:string];
    // 添加图片
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    attch.image = image;
    attch.bounds = CGRectMake(0, 0, 12, 12);
    // 创建带有图片的富文本
    [richText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attch]];
    //[richText appendAttributedString: [[NSAttributedString alloc] initWithString:string]];
    // 垂直居中设置
    [richText addAttribute:NSBaselineOffsetAttributeName
                     value:@(baseline)
                     range:NSMakeRange(0, richText.length)];
    
    return richText;
}

@end
