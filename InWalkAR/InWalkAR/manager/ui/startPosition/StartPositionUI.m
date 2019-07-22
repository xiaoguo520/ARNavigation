//
//  StartPositionUI.m
//  ARKitDemoUI
//
//  Created by limu on 2019/1/2.
//  Copyright © 2019年 example. All rights reserved.
//

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width

#import "StartPositionUI.h"
#import "ZXSSpuTableViewCell.h"
#import "StartPositionModel.h"
#import "PopView.h"
#import "InWalkIbeaconManager.h"

@interface StartPositionUI()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>{
    PopView *_popView;
    UIView *_superView;
    UISearchBar *search;
    UISearchBar *search2;
    UIView *_listView;
    UITableView *tableView;
    NSMutableArray<StartPositionModel *> *_filterData;
    NSArray<StartPositionModel *> *_rawData;
    NSString *_destNum;
    BOOL isTouchingPopView;
    UIPanGestureRecognizer *pan;
    BOOL isDestConfirmed; // 是否终点位置已确定(支持反向寻车的停车场，该值应该是YES；其他，NO)
}
@end

@implementation StartPositionUI

- (void)setSuperView:(UIView *)view{
    _superView = view;
}

//- (void)setItems:(NSArray<StartPositionModel *> *)items{
//    _rawData = items;
//    _filterData = [[NSMutableArray alloc] init];
//    [_filterData addObjectsFromArray:_rawData];
//}

- (void)refreshDest:(NSString *)destNum items:(NSArray<StartPositionModel *> *)items {
    _destNum = destNum;
    _rawData = items;
    _filterData = [[NSMutableArray alloc] init];
    [_filterData addObjectsFromArray:_rawData];
    
    [search setText:@""];
    [search2 setText:_destNum];
    
    [tableView reloadData];
}

- (void)showDest:(NSString *)destNum items:(NSArray<StartPositionModel *> *)items{
    _destNum = destNum;
    _rawData = items;
    _filterData = [[NSMutableArray alloc] init];
    [_filterData addObjectsFromArray:_rawData];
    
    float viewWidth = kScreenWidth;
    float viewHeight = 139 + 248;
    
    CGRect rect = CGRectMake(0, kScreenHeight - viewHeight, viewWidth, viewHeight);
    _popView = [[PopView alloc] initWithFrame:rect];
    [_popView setBackgroundColor:[UIColor whiteColor]];
    // 阴影效果
    _popView.layer.shadowOpacity = 0.5;
    _popView.layer.shadowRadius = 5;
    _popView.layer.shadowColor = [UIColor grayColor].CGColor;
    _popView.layer.shadowOffset = CGSizeMake(0, -1);
    //
    [_superView addSubview:_popView];
    // add header view.
    {
        float w = 32;
        float h = 4;
        CGRect headerFrame = CGRectMake((viewWidth - w) / 2, (24 - h) / 2, w, h);
        UIView *header = [[UIView alloc] initWithFrame:headerFrame];
        [header setBackgroundColor:[UIColor lightGrayColor]];
        [header.layer setCornerRadius:2];
        [_popView addSubview:header];
    }
    // add close button(height:32+12=44).
    //if (_destNum && _destNum.length > 0) // 若该页面之前没有其他页面时，是不需要展示关闭按钮的
    {
        float padding = 6;
        float w = 32;
        CGRect closeFrame = CGRectMake(viewWidth - w - padding, padding, w, w);
        UIImageView *img = [[UIImageView alloc] initWithFrame:closeFrame];
        [img setImage:[UIImage imageNamed:@"close_48.png"
                                 inBundle:[NSBundle bundleForClass:[self class]]
            compatibleWithTraitCollection:nil]];
        // add tap event.
        UITapGestureRecognizer *tapGesturePop = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
        img.userInteractionEnabled = YES;
        [img addGestureRecognizer:tapGesturePop];
        [_popView addSubview:img];
    }
    // add view.
    {
        float y = 44;
        float h0 = 40;
        CGRect rect = CGRectMake(16, y, viewWidth - 32, 81);
        UIView *view = [[UIView alloc] initWithFrame:rect];
        //[view setBackgroundColor:[UIColor cyanColor]];
        view.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1]; // #f6f6f6
        // set corner radius.
        view.layer.cornerRadius = 6;
        view.layer.masksToBounds = true;
        
        // add label 1.
        CGRect rect1 = CGRectMake(16, 0, 60, h0);
        UILabel *label1 = [[UILabel alloc] initWithFrame:rect1];
        //[label1 setBackgroundColor:[UIColor lightGrayColor]];
        [label1 setTextAlignment:NSTextAlignmentCenter];
        [label1 setText:@"起点："];
        [view addSubview:label1];
        // add textField 1.
        CGRect rect11 = CGRectMake(76, 0, viewWidth - 100, h0);
        search = [[UISearchBar alloc] initWithFrame:rect11];
        [search setPlaceholder:@"输入起点位置"];
        // clear out background.
        [search setBackgroundImage:[UIImage new]];
        // hide clear icon on the right.
        UITextField *textField = [search valueForKey:@"_searchField"];
        textField.clearButtonMode = UITextFieldViewModeNever;
        //search.tintColor = [UIColor colorWithRed:192.0/255 green:192.0/255 blue:192.0/255 alpha:1]; // #c0c0c0
        search.tintColor = [UIColor blueColor];
        textField.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1]; // #f6f6f6
        // hide search icon on the left.
        [search setImage:[UIImage new] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
        // set text's display offset.
        [search setSearchFieldBackgroundPositionAdjustment:UIOffsetMake(-7.5, 0)];
        [search setSearchTextPositionAdjustment:UIOffsetMake(-30, 0)];
        // delegate.
        search.delegate = self;
        [view addSubview:search];
        
        // add line separator.
        CGRect rectLine = CGRectMake(16, h0, viewWidth - 64, 1);
        UIView *line = [[UIView alloc] initWithFrame:rectLine];
        [line setBackgroundColor:[UIColor colorWithRed:227/255.0 green:227/255.0 blue:227/255.0 alpha:1.0]];
        [view addSubview:line];
        
        // add label 2.
        CGRect rect2 = CGRectMake(16, h0 + 1, 60, h0);
        UILabel *label2 = [[UILabel alloc] initWithFrame:rect2];
        //[label2 setBackgroundColor:[UIColor greenColor]];
        [label2 setTextAlignment:NSTextAlignmentCenter];
        [label2 setText:@"终点："];
        [view addSubview:label2];
        // add textField 2.
        CGRect rect12 = CGRectMake(76, h0 + 1, viewWidth - 76, h0);
//        UILabel *label22 = [[UILabel alloc] initWithFrame:rect12];
//        //[label22 setText:@"tf2"];
//        [label22 setText:destNum];
//        [view addSubview:label22];
        search2 = [[UISearchBar alloc] initWithFrame:rect12];
        [search2 setPlaceholder:@"输入终点位置"];
        // clear out background.
        [search2 setBackgroundImage:[UIImage new]];
        // hide clear icon on the right.
        UITextField *textField2 = [search2 valueForKey:@"_searchField"];
        textField2.clearButtonMode = UITextFieldViewModeNever;
        //search.tintColor = [UIColor colorWithRed:192.0/255 green:192.0/255 blue:192.0/255 alpha:1]; // #c0c0c0
        search2.tintColor = [UIColor blueColor];
        textField2.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1]; // #f6f6f6
        // hide search icon on the left.
        [search2 setImage:[UIImage new] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
        // set text's display offset.
        [search2 setSearchFieldBackgroundPositionAdjustment:UIOffsetMake(-7.5, 0)];
        [search2 setSearchTextPositionAdjustment:UIOffsetMake(-30, 0)];
        if (destNum != nil && destNum.length > 0) {
            [search2 setText:destNum];
            textField2.enabled = NO;
            isDestConfirmed = YES;
        } else {
            // delegate.
            search2.delegate = self;
            isDestConfirmed = NO;
        }
        [view addSubview:search2];
        
        [_popView addSubview:view];
        
        // 注册观察键盘的变化
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transformView:) name:UIKeyboardWillChangeFrameNotification object:nil];
        // 输入时的事件
        search.delegate = self;
        // 展示键盘DONE键
        search.returnKeyType = UIReturnKeyDone;
    }
    // add navigation button.
    {
        float y = 139; // 44 + 81 + 14
        CGRect btnFrame = CGRectMake(16, y, viewWidth - 32, 46);
        UIButton *btn = [[UIButton alloc] initWithFrame:btnFrame];
        [btn setTitle:@"开始AR导航" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //[btn setBackgroundColor:[UIColor blueColor]];
        [btn setBackgroundColor:[UIColor colorWithRed:39.0/255 green:137.0/255 blue:252.0/255 alpha:1.0]]; // #0x2789fc
        [btn.layer setCornerRadius:4];
        // 点击事件
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_popView addSubview:btn];
    }
    // add list view(UITableView).
    {
        // add gap(gray rect).
        CGRect rect = CGRectMake(0, 139, kScreenWidth, 14);
        _listView = [[UIView alloc] initWithFrame:rect];
        [_listView setBackgroundColor:[UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0]]; // #0xe0e0e0
        _listView.layer.shadowColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0].CGColor;
        _listView.layer.shadowOffset = CGSizeMake(0,2);
        _listView.layer.shadowOpacity = 1;
        _listView.layer.shadowRadius = 3;
        [_popView addSubview:_listView];
        
        // add list(UITableView).
        tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 153, kScreenWidth, 240)];//240
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[ZXSSpuTableViewCell class] forCellReuseIdentifier:@"ZXSSpuTableViewCell"];
        [_popView addSubview:tableView];
    }
    
    // 先展示按钮（把列表移除，但列表需要先占位，否则滚动/点击等交互存在问题）
    viewHeight = 139 + 40 + 14;
    CGRect rect3 = CGRectMake(0, kScreenHeight - viewHeight, kScreenWidth, viewHeight);
    [_popView setFrame:rect3];
    [_listView removeFromSuperview];
    [tableView removeFromSuperview];
    
    // add tap event.
    UITapGestureRecognizer *tapGesturePop = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popTouchUpInside:)];
    tapGesturePop.delegate = self;
    tapGesturePop.numberOfTouchesRequired = 1;
    _popView.userInteractionEnabled = YES;
    [_popView addGestureRecognizer:tapGesturePop];
    // 解决手势与UITableViewCell点击事件的冲突
    [tapGesturePop setCancelsTouchesInView:NO];
    
    [self addPanGesture];
}


#pragma mark - popView展开时(键盘可见)，向下滑动popView将键盘隐藏，并将popView重置为收缩状态
- (void)addPanGesture {
    if (!pan) {
        pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    }
    [_popView addGestureRecognizer:pan];
}

- (void)removePanGesture {
    if (pan) {
        [_popView removeGestureRecognizer:pan];
    }
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    CGPoint tp = [pan translationInView:_popView];
    // 向上滑动时 tp.y 为负，向下滑动时 tp.y 为正
    //NSLog(@"pan ... %f", tp.y);
    if (tp.y > 50) {
        // 收起键盘
        [self removePanGesture];
        [self collapsePopView];
    }
}

- (void)collapsePopView {
    // 收起键盘：隐藏可选项
    [_listView removeFromSuperview];
    [tableView removeFromSuperview];
    
    //在0.25s内完成self.view的Frame的变化，等于是给self.view添加一个向上移动deltaY的动画
    [UIView animateWithDuration:0.5f animations:^{
        
        float vh = 139 + 6 + 40 + 14;
        
        CGRect rect = CGRectMake(0, kScreenHeight - vh, kScreenWidth, vh);
        [_popView setFrame:rect];
        
        [self addPanGesture];
        
        // 收起键盘
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        
    }];
}


// 点击popWindow
-(void) popTouchUpInside:(UITapGestureRecognizer *)recognizer{
    //NSLog(@"clicked pop(spu)...");
    isTouchingPopView = YES;
}


// 键盘的DONE键点击事件
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    // 收起键盘
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

// 输入发生变化
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (_rawData) {
        [_filterData removeAllObjects];
        if (searchText != nil && searchText.length > 0) {
            for (StartPositionModel *item in _rawData) {
                if ([item.name containsString:searchText]) {
                    [_filterData addObject:item];
                }
            }
        } else {
            [_filterData addObjectsFromArray:_rawData];
        }
        [tableView reloadData];
        [tableView scrollsToTop];
    }
}

// 弹出键盘，视图上移
-(void)transformView:(NSNotification *)aNSNotification{
    // 键盘弹出前的Rect
    NSValue *keyBoardBeginRect = [[aNSNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect beginRect = [keyBoardBeginRect CGRectValue];
    
    // 键盘弹出后的Rect
    NSValue *keyBoardEndRect = [[aNSNotification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect endRect = [keyBoardEndRect CGRectValue];
    
    // 获取键盘位置变化前后纵坐标Y的变化值
    CGFloat deltaY = endRect.origin.y - beginRect.origin.y; // -216
    if (deltaY < 0) {
        // 往上拉（弹出键盘）：展示可选项
        [_popView addSubview:_listView];
        [_popView addSubview:tableView];
        [_popView bringSubviewToFront:tableView];
        //收起键盘关闭定位
        [[InWalkIbeaconManager manager] stopRangingBeacons];
    } else {
        // 收起键盘：隐藏可选项
        [_listView removeFromSuperview];
        [tableView removeFromSuperview];
    }
    

    
    //在0.25s内完成self.view的Frame的变化，等于是给self.view添加一个向上移动deltaY的动画
    [UIView animateWithDuration:0.25f animations:^{
//        [_superView setFrame:CGRectMake(_superView.frame.origin.x,
//                                        _superView.frame.origin.y + deltaY,
//                                        _superView.frame.size.width,
//                                        _superView.frame.size.height)];
//
//        // 重新设置弹出窗口的frame
//        float viewHeight;
//        if (deltaY > 0) {
//            viewHeight = 139 + 6 + 40 + 14;
//        } else {
//            viewHeight = 139 + 6 + 248;
//        }
//        CGRect rect = CGRectMake(0, kScreenHeight - viewHeight, kScreenWidth, viewHeight);
//        [_popView setFrame:rect];
        
        float vh;
        if (deltaY > 0) {
            // 收起
            vh = 139 + 6 + 40 + 14;
        } else {
            // 向上拉
            vh = 139 + 6 + 248 - deltaY;
        }
        
        CGRect rect = CGRectMake(0, kScreenHeight - vh, kScreenWidth, vh);
        [_popView setFrame:rect];

    }];
}

- (void)btnClick:(UITapGestureRecognizer *)recognizer{
    ////NSLog(@"on click .. %@", search.text);
    if (_delegate) {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        //[self dismiss];
        
        [_delegate startNavigationFrom:search.text to:_destNum];
    }
}

// close.
- (void)close:(UITapGestureRecognizer *)recognizer{
    //NSLog(@"dismiss(close) ...");
    [self dismiss];
    if (_delegate) {        
        [_delegate onCloseStartPositionUI:isDestConfirmed];
    }
}

- (void)dismiss{
    if (_popView) {
        [_popView removeFromSuperview];
        
        if (_popView.subviews) {
            for (UIView *v in _popView.subviews) {
                [v removeFromSuperview];
            }
        }
    }
}



#pragma mark - UITableView 部分

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _filterData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //为Cell设置重用的ID
    ZXSSpuTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ZXSSpuTableViewCell" forIndexPath:indexPath];
    //如果cell没有才创建
    if (cell == nil) {
        cell = [[ZXSSpuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZXSSpuTableViewCell"];
    }
    
    StartPositionModel *item = [_filterData objectAtIndex:indexPath.row];
    
    cell.lb1.text = item ? item.name : [NSString stringWithFormat:@"A0%ld",(long)indexPath.row];
    cell.lb2.text = item ? item.detail : [NSString stringWithFormat:@"停车场 L3层 %ld",(long)indexPath.row];
    [cell.img setImage: [UIImage imageNamed: (item ? item.imgName :@"locate_3x.png")
                                   inBundle:[NSBundle bundleForClass:[self class]]
              compatibleWithTraitCollection:nil]];
    
    [cell.contentView setUserInteractionEnabled:YES];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 点击事件
    StartPositionModel *item = [_filterData objectAtIndex:indexPath.row];
    //NSLog(@"click ... %d %@", (int)indexPath.row, item.name);
    //[search setText:[NSString stringWithFormat:@"L3-A0%d", (int)indexPath.row]];
    if (search.isFirstResponder) {
        [search setText:item.name];
    } else if (search2.isFirstResponder) {
        [search2 setText:item.name];
        _destNum = item.name;
    }
    
    // 手抬起后清除灰色背景
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    // 收起键盘
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}


//根据定位更新起点
- (void)upDataOriginFormPosition:(StartPositionModel *)model{
    if (model == nil) {
        [search setText:@""];
    }else{
        [search setText:model.name];
    }
}

@end
