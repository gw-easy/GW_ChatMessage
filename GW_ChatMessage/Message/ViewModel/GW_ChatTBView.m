//
//  GW_ChatTBView.m
//  GW_ChatMessage
//
//  Created by gw on 2018/4/20.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_ChatTBView.h"
#import "GW_ChatMessageTextCell.h"
#import "GW_MessageManager.h"
#import "GW_ChatMessageSystemCell.h"
#import "GW_ChatMessageAudioCell.h"
#import "GW_ChatMessageVideoCell.h"
#import "GW_ChatMessagePicCell.h"
#import "GW_ChatMessageFileCell.h"
#import "GW_CameraManager.h"
@interface GW_ChatTBView()<UITableViewDelegate,UITableViewDataSource,GW_ChatMessageBaseCellDelegate>

@property (strong, nonatomic) UIMenuItem *menuItemCopy;
@property (strong, nonatomic) UIMenuItem *delete_MenuItem;
@property (strong, nonatomic) UIMenuItem *forward_MenuItem;
@property (strong, nonatomic) UIMenuItem *recall_MenuItem;
@property (strong, nonatomic) NSIndexPath *longIndexPath;
@end

@implementation GW_ChatTBView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.tableView];
        [self registerCell];
    }
    return self;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = self.backgroundColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        if (@available(iOS 11.0, *)) {
//            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [_tableView addGestureRecognizer:tap];
    }
    return _tableView;
}

- (void)registerCell
{
    [self.tableView registerClass:[GW_ChatMessageTextCell class] forCellReuseIdentifier:CellText];
    [self.tableView registerClass:[GW_ChatMessagePicCell class] forCellReuseIdentifier:CellPic];
    [self.tableView registerClass:[GW_ChatMessageVideoCell class] forCellReuseIdentifier:CellVideo];
    [self.tableView registerClass:[GW_ChatMessageAudioCell class] forCellReuseIdentifier:CellAudio];
    [self.tableView registerClass:[GW_ChatMessageFileCell class] forCellReuseIdentifier:CellFile];
    [self.tableView registerClass:[GW_ChatMessageSystemCell class] forCellReuseIdentifier:CellSystem];
}

- (void)setTBheight:(CGFloat)TBheight{
    self.height = TBheight;
    self.tableView.height = TBheight;
    _TBheight = TBheight;
}

#pragma mark - Tableview data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id obj = self.dataSource[indexPath.row];
    if ([obj isKindOfClass:[NSString class]]){
        return nil;
    } else {
        GW_ChatMessageFrameModel *modelFrame = (GW_ChatMessageFrameModel *)obj;
        NSString *CellID = modelFrame.model.message.type;
        if ([CellID isEqualToString:CellSystem]) {
            GW_ChatMessageSystemCell *cell = [GW_ChatMessageSystemCell cellWithTableView:tableView reusableId:CellSystem];
            cell.messageF              = modelFrame;
            return cell;
        }
        __kindof GW_ChatMessageBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        cell.delegate = self;
        [[GW_CameraManager shareManager] clearReuseImageMessage:cell.modelFrame.model];
        cell.modelFrame = modelFrame;
        return cell;
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)longRecognizer{
    if (longRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [longRecognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        _longIndexPath = indexPath;
        id object = [self.dataSource objectAtIndex:indexPath.row];
        if (![object isKindOfClass:[GW_ChatMessageFrameModel class]]) return;
        GW_ChatMessageBaseCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self showMenuView:cell.bubbleView andIndexPath:indexPath message:cell.modelFrame.model];
    }
}

- (void)showMenuView:(UIView *)showInView andIndexPath:(NSIndexPath *)indexPath message:(GW_ChatMessageModel *)messageModel
{
    [self becomeFirstResponder];
    if (_menuItemCopy == nil) {
        _menuItemCopy = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMessage:)];
    }
    if (_delete_MenuItem == nil) {
        _delete_MenuItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMessage:)];
    }
    if (_forward_MenuItem == nil) {
        _forward_MenuItem = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(forwardMessage:)];
    }
    NSInteger currentTime = [GW_MessageManager currentMessageTime];
    NSInteger interval    = currentTime - messageModel.message.date;
    if (messageModel.isSender) {
        if ((interval/1000) < 5*60 && !(messageModel.message.deliveryState == GW_MessageDeliveryState_Failure)) {
            if (_recall_MenuItem == nil) {
                _recall_MenuItem = [[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(recallMessage:)];
            }
            [[UIMenuController sharedMenuController] setMenuItems:@[_menuItemCopy,_delete_MenuItem,_recall_MenuItem,_forward_MenuItem]];
        } else {
            [[UIMenuController sharedMenuController] setMenuItems:@[_menuItemCopy,_delete_MenuItem,_forward_MenuItem]];
        }
    } else {
        [[UIMenuController sharedMenuController] setMenuItems:@[_menuItemCopy,_delete_MenuItem,_forward_MenuItem]];
    }
    [[UIMenuController sharedMenuController] setTargetRect:showInView.frame inView:showInView.superview ];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
}

// 用于UIMenuController显示，缺一不可
-(BOOL)canBecomeFirstResponder{
    return YES;
}


- (void)copyMessage:(UIMenuItem *)copyMenuItem
{
    UIPasteboard *pasteboard  = [UIPasteboard generalPasteboard];
    GW_ChatMessageFrameModel *messageF = [self.dataSource objectAtIndex:_longIndexPath.row];
    pasteboard.string = messageF.model.message.content;
}

- (void)deleteMessage:(UIMenuItem *)deleteMenuItem
{
    // 这里还应该把本地的消息附件删除
    GW_ChatMessageFrameModel * messageF = [self.dataSource objectAtIndex:_longIndexPath.row];
    [self statusChanged:messageF];
}

- (void)recallMessage:(UIMenuItem *)recallMenuItem
{
    // 这里应该发送消息撤回的网络请求
    GW_ChatMessageFrameModel * messageF = [self.dataSource objectAtIndex:_longIndexPath.row];
    [self.dataSource removeObject:messageF];
    
    if (self.sendRecell) {
        messageF = self.sendRecell();
    }
    
    [self.dataSource insertObject:messageF atIndex:_longIndexPath.row];
    [self.tableView reloadData];
}

- (void)forwardMessage:(UIMenuItem *)forwardItem{
    GWLog(@"需要用到的数据库，等添加了数据库再做转发...");
}

- (void)statusChanged:(GW_ChatMessageFrameModel *)messageF
{
    [self.dataSource removeObject:messageF];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[_longIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GW_ChatMessageFrameModel *messageF = [self.dataSource objectAtIndex:indexPath.row];
    return messageF.cellHight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.resignFirstResponder) {
        self.resignFirstResponder();
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.resignFirstResponder) {
        self.resignFirstResponder();
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    if ([cell isKindOfClass:[GW_ChatMessageVideoCell class]] && self) {
        GW_ChatMessageVideoCell *videoCell = (GW_ChatMessageVideoCell *)cell;
        [videoCell stopVideo];
    }
}

- (void) scrollToBottom{
    if (self.dataSource.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)reloadData{
    [self.tableView reloadData];
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (void)tapAction:(UITapGestureRecognizer *)tap{
    if (self.resignFirstResponder) {
        self.resignFirstResponder();
    }
}

@end
