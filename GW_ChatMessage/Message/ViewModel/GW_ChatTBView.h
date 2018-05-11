//
//  GW_ChatTBView.h
//  GW_ChatMessage
//
//  Created by gw on 2018/4/20.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GW_ChatMessageFrameModel.h"
@interface GW_ChatTBView : UIView
/** 数据源 */
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UITableView *tableView;
@property (assign, nonatomic) CGFloat TBheight;
@property (copy, nonatomic) void (^resignFirstResponder)(void);
@property (copy, nonatomic) GW_ChatMessageFrameModel* (^sendRecell)(void);
- (void)reloadData;
- (void) scrollToBottom;
@end
