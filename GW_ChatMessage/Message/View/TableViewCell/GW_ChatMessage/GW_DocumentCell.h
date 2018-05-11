//
//  GW_DocumentCell.h
//  GW_ChatMessage
//
//  Created by gw on 2018/5/10.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_BaseCell.h"
@protocol GW_DocumentCellDelegate <NSObject>

- (void)selectBtnClicked:(id)sender;

@end
@interface GW_DocumentCell : GW_BaseCell
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, weak) id<GW_DocumentCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (strong, nonatomic) UIButton *selectBtn;

@end
