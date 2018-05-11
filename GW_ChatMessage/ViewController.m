//
//  ViewController.m
//  GW_ChatMessage
//
//  Created by gw on 2018/3/29.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "ViewController.h"
#import "GW_SearchResultController.h"
#import "GW_MessageModel.h"
#import "GW_MessageCell.h"
#import "GW_ChatVC.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchController *scVC;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    [self loadDataSource];
}

- (void)setUI{
    self.view.backgroundColor = [UIColor whiteColor];
    
    //防止和按住说话冲突，延迟性高的问题
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan=NO;
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    GW_SearchResultController *searchVC    = [[GW_SearchResultController alloc] init];
    
    _scVC = [[UISearchController alloc] initWithSearchResultsController:searchVC];
    [_scVC.searchBar sizeToFit];
    self.tableView.tableHeaderView = _scVC.searchBar;
    
    [_scVC.searchBar setBarTintColor:[UIColor redColor]];
    [_scVC.searchBar.layer setBorderWidth:0.5];
    [_scVC.searchBar.layer setBorderColor:[UIColor greenColor].CGColor];
    _scVC.dimsBackgroundDuringPresentation = YES;
    self.definesPresentationContext = YES;
    _scVC.view.backgroundColor = [UIColor whiteColor];
    _scVC.hidesNavigationBarDuringPresentation = YES;
    self.tableView.frame  = CGRectMake(0,64, self.view.width, SCREENHEIGHT-64);
}

- (void)loadDataSource
{
    GW_MessageModel *group = [[GW_MessageModel alloc] init];
    group.unReadCount = 2;
    group.gName = @"马云";
    group.lastMsgString = @"马化腾你等着!";
    [self.dataArray addObject:group];
    [self.dataArray addObject:group];
    [self.dataArray addObject:group];
    [self.dataArray addObject:group];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GW_MessageCell *cell = [GW_MessageCell cellWithTableView:tableView];
//    if (indexPath.row == self.dataArray.count - 1) {
//        [cell setBottomLineStyle:CellLineStyleNone];
//    }
//    else {
//        [cell setBottomLineStyle:CellLineStyleDefault];
//    }
    cell.group = self.dataArray[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 67.0;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    GW_MessageModel *group  = self.dataArray[indexPath.row];
    NSString* topTitle  = group.isTop ? @"取消置顶" : @"置顶";
    NSString* readTitle = group.unReadCount ? @"标为已读" : @"标为未读";
    UITableViewRowAction *deleRow = [UITableViewRowAction rowActionWithStyle:0 title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
    }];
    UITableViewRowAction *topRow = [UITableViewRowAction rowActionWithStyle:0 title:topTitle handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
    }];
    UITableViewRowAction *readRow = [UITableViewRowAction rowActionWithStyle:0 title:readTitle handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
    }];
    topRow.backgroundColor = [UIColor grayColor];
    readRow.backgroundColor     = [UIColor orangeColor];
    return @[deleRow,topRow,readRow];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GW_MessageModel *group = self.dataArray[indexPath.row];
    GW_ChatVC *chatVc = [[GW_ChatVC alloc] init];
    chatVc.group = group;
    [self.navigationController pushViewController:chatVc animated:YES];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        [self.view addSubview:tableView];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView = tableView;
    }
    return _tableView;
}

- (NSMutableArray *)dataArray
{
    if (nil == _dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return  _dataArray;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
