//
//  ProjectListViewController.m
//  InWalkDemo
//
//  Created by limu on 2019/4/18.
//  Copyright © 2019 InReal Co., Ltd. All rights reserved.
//

#import "ProjectListViewController.h"
#import "Global.h"

@interface ProjectListViewController()<UITableViewDelegate,UITableViewDataSource,UISearchControllerDelegate,UISearchResultsUpdating>

//tableView
@property (strong, nonatomic)  UITableView *tableView;

//searchController
@property (strong, nonatomic)  UISearchController *searchController;

//数据源
@property (strong,nonatomic) NSMutableDictionary<NSString *, NSObject *> *dataList;

@property (strong,nonatomic) NSMutableDictionary<NSString *, NSObject *> *searchList;

@property (strong, nonatomic) NSString *selected;
@property (nonatomic) CGFloat width;

@end

@implementation ProjectListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataList = [NSMutableDictionary dictionary];
    _searchList = [NSMutableDictionary dictionary];
    
    //[self setRandomData];
    [self.dataList addEntriesFromDictionary:[Global sharedInstance].projectList];
    
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, screenBounds.size.width, screenBounds.size.height)];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    //_tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.rowHeight = 56; // 行高
    
    //创建UISearchController
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    _searchController.searchBar.placeholder = @"在此处搜索您所在的停车场";
    [_searchController.searchBar setValue:@"取消" forKey:@"_cancelButtonText"];
    //_searchController.searchBar.layer.cornerRadius = _searchController.searchBar.frame.size.height / 2;
    
    // placeholder居中显示
    if(@available(iOS 11.0, *)){
        UITextField *textField = [_searchController.searchBar valueForKey:@"searchField"];
        [textField sizeToFit];
        
        //记录一下这个时候的宽度
        _width = textField.frame.size.width;
        
        CGFloat w = (_searchController.searchBar.frame.size.width - _width) / 2.0;
        [_searchController.searchBar setPositionAdjustment:UIOffsetMake(w, 0)
                                          forSearchBarIcon:UISearchBarIconSearch];
        
        // 圆角
        textField.layer.cornerRadius  = 18.0;
        textField.clipsToBounds       = YES;
    }
    
    
    //设置代理
    _searchController.delegate = self;
    _searchController.searchResultsUpdater= self;
    
    //设置UISearchController的显示属性，以下3个属性默认为YES
    //搜索时，背景变暗色
    _searchController.dimsBackgroundDuringPresentation = NO;
    if (@available(iOS 9.1, *)) {
        //搜索时，背景变模糊
        _searchController.obscuresBackgroundDuringPresentation = NO;
        //隐藏导航栏
        _searchController.hidesNavigationBarDuringPresentation = NO;
    }
    
    //self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
    //    // 修改状态栏颜色（全局）
    //    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    //    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
    //        statusBar.backgroundColor = [UIColor redColor];//set whatever color you like
    //    }
    
    
    // 44.0
    _searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 56.0);
    
    // 添加 searchbar 到 headerview
    self.tableView.tableHeaderView = _searchController.searchBar;
    
    [self.view addSubview:_tableView];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)setRandomData {
    self.dataList = [NSMutableDictionary dictionaryWithCapacity:100];
    
    //产生100个“数字+三个随机字母”
    for (NSInteger i=0; i<100; i++) {
        [self.dataList setObject:[NSString stringWithFormat:@"%ld%@",(long)i,[self shuffledAlphabet]] forKey:[NSString stringWithFormat:@"%zd", i]];
    }
}

//产生3个随机字母
- (NSString *)shuffledAlphabet {
    NSMutableArray * shuffledAlphabet = [NSMutableArray arrayWithArray:@[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"]];
    
    NSString *strTest = [[NSString alloc]init];
    for (int i=0; i<3; i++) {
        int x = arc4random() % 25;
        strTest = [NSString stringWithFormat:@"%@%@",strTest,shuffledAlphabet[x]];
    }
    
    return strTest;
}


//设置区域的行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.searchController.active) {
        return [self.searchList count];
    }else{
        return [self.dataList count];
    }
}


//返回单元格内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *flag=@"cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:flag];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:flag];
    }
    if (self.searchController.active) {
        // [indexPath.row]
        [cell.textLabel setText: [NSString stringWithFormat: @"%@", [self.searchList objectForKey: [[self.searchList allKeys] objectAtIndex:indexPath.row]]]];
    }
    else{
        [cell.textLabel setText: [NSString stringWithFormat: @"%@", [self.self.dataList objectForKey: [[self.self.dataList allKeys] objectAtIndex:indexPath.row]]]];
        //[cell.textLabel setText:self.dataList[indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selected = [NSString stringWithFormat:@"%zd", indexPath.row];
    //[Global sharedInstance].val = [[Global sharedInstance].idList objectAtIndex:indexPath.row];
    if (self.searchController.active) {
        //[Global sharedInstance].val = [NSString stringWithFormat:@"%@", [self.searchList objectForKey: [[self.searchList allKeys] objectAtIndex:indexPath.row]]];
        [Global sharedInstance].val = [[self.searchList allKeys] objectAtIndex:indexPath.row];
    } else {
        //[Global sharedInstance].val = [NSString stringWithFormat:@"%@", [self.dataList objectForKey: [[self.dataList allKeys] objectAtIndex:indexPath.row]]];
        [Global sharedInstance].val = [[self.dataList allKeys] objectAtIndex:indexPath.row];
    }
    
    //NSLog(@"select ... %zd", indexPath.row);
    NSLog(@"select ... %@", self.selected);
    NSLog(@"select ... %@", [Global sharedInstance].val);
    
    [self dismissSearchPage];
}

- (void)dismissSearchPage {
    //[self dismissViewControllerAnimated:YES completion:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchController setActive:NO];
        //self.navigationController.navigationBar.topItem.title = @"MYTITLE".uppercaseString;
        //self.navigationItem.titleView = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}



#pragma mark - UISearchControllerDelegate代理

//测试UISearchController的执行过程

- (void)willPresentSearchController:(UISearchController *)searchController
{
    //NSLog(@"willPresentSearchController");
    if (@available(iOS 11.0, *)) {
        if(!_searchController.searchBar.text.length) {
            [_searchController.searchBar setPositionAdjustment:UIOffsetMake(0,0)forSearchBarIcon:UISearchBarIconSearch];
        }
        
        // 圆角
        UITextField *textField = [_searchController.searchBar valueForKey:@"searchField"];
        if (textField) {
            textField.layer.cornerRadius  = textField.frame.size.height / 2.0;
            textField.clipsToBounds       = YES;
        }
    }
    NSLog(@"... // %f %f", _searchController.searchBar.frame.size.height, _searchController.searchBar.frame.origin.y);
}

- (void)didPresentSearchController:(UISearchController *)searchController
{
    NSLog(@"didPresentSearchController");
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
    NSLog(@"willDismissSearchController");
    
}

- (void)didDismissSearchController:(UISearchController *)searchController
{
    NSLog(@"didDismissSearchController");
    if (@available(iOS 11.0, *)) {
        if(!_searchController.searchBar.text.length) {
            [_searchController.searchBar setPositionAdjustment:UIOffsetMake((_searchController.searchBar.frame.size.width-self.width)/2.0,0) forSearchBarIcon:UISearchBarIconSearch];
        }
    }
    NSLog(@"... // %f %f", _searchController.searchBar.frame.size.height, _searchController.searchBar.frame.origin.y);
    
    [self dismissSearchPage];
}

- (void)presentSearchController:(UISearchController *)searchController
{
    NSLog(@"presentSearchController");
}


-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (self.selected) {
        return;
    }
    
    NSLog(@"updateSearchResultsForSearchController");
    if (self.searchList!= nil) {
        [self.searchList removeAllObjects];
    }
    //过滤数据
    NSString *searchString = [self.searchController.searchBar text];
    //NSPredicate *preicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", searchString];
    //self.searchList= [NSMutableArray arrayWithArray:[_dataList filteredArrayUsingPredicate:preicate]];
    if (self.dataList && self.dataList.count > 0) {
        if (!self.searchList) {
            self.searchList = [NSMutableDictionary dictionary];
        }
        NSString *val;
        for (NSString *k in self.dataList.allKeys) {
            val = [NSString stringWithFormat:@"%@", [self.dataList objectForKey:k]];
            if ([val containsString:searchString]) {
                [self.searchList setObject:val forKey:k];
            }
        }
    }
    
    //刷新表格
    [self.tableView reloadData];
}

@end
