//
//  GW_FileVC.m
//  GW_ChatMessage
//
//  Created by gw on 2018/5/10.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_FileVC.h"
#import "GW_FileManager.h"
#import "GW_DocumentCell.h"
#import "GW_FIleScanVC.h"
@interface GW_FileVC ()<UITableViewDelegate,UITableViewDataSource,GW_DocumentCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, copy) NSString *name;
@end

@implementation GW_FileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNav];
    [self loadData];
    
}

- (void)setupNav
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"本机文件";
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 25)];
    [rightButton setTitle:@"发送" forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [rightButton addTarget:self action:@selector(rightBarButtonClicked)forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    [rightButton setTitleColor:ColorRGBHas(0x018eb0) forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.rightBtn = rightButton;
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 25)];
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftBarButtonClicked)forControlEvents:UIControlEventTouchUpInside];
    [leftButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:17];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    
    [self.view addSubview:self.tableView];
}

- (void)rightBarButtonClicked{
    if (!self.name){
        return;
    }
    if ([self.delegate respondsToSelector:@selector(selectedFileName:)]) {
        [self.delegate selectedFileName:self.name];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)leftBarButtonClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadData{
    NSDirectoryEnumerator * enumer = [[NSFileManager defaultManager] enumeratorAtPath:[GW_FileManager fileMainPath]];
    NSString *name;
    while (name = [enumer nextObject]) {
        if ([name isEqualToString:@".DS_Store"]) continue;
        if (![[name pathExtension] isEqualToString:@"DS_Store"]&&[name length]>0) {
            [self.dataArr addObject:name];
        }
    }
    [self.tableView reloadData];
    //    ICLog(@"===%@",[ICFileTool fileMainPath]);
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GW_DocumentCell *cell = [GW_DocumentCell cellWithTableView:tableView];
    cell.delegate = self;
    cell.name = self.dataArr[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GW_DocumentCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    GW_FIleScanVC *scanVC = [[GW_FIleScanVC alloc] init];
    scanVC.filePath              = cell.filePath;
    scanVC.orgName               = cell.name;
    [self.navigationController pushViewController:scanVC animated:YES];
}

#pragma mark - ICDocumentCellDelegate

- (void)selectBtnClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    GW_DocumentCell *cell = (GW_DocumentCell *)[[button superview] superview];
    NSIndexPath *curIndexPath = [self.tableView indexPathForCell:cell];
    
    for (int row = 0; row < self.dataArr.count; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        if (curIndexPath != indexPath) {
            GW_DocumentCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.selectBtn.selected = NO;
        }
    }
    
    self.name = cell.name;
    button.selected = !button.selected;
    if (button.selected) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.rightBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    }else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self.rightBtn setTitleColor:ColorRGBHas(0x018eb0) forState:UIControlStateNormal];
    }
}

#pragma mark - Getter

- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
