//
//  GW_MessageCell.h
//  GW_ChatMessage
//
//  Created by gw on 2018/4/19.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_BaseCell.h"
#import "GW_MessageModel.h"
@interface GW_MessageCell : GW_BaseCell

@property (nonatomic, strong) GW_MessageModel *group;

@property (nonatomic, weak) UIImageView *avatarImageView;
@property (nonatomic, weak) UILabel *usernameLabel;
@property (nonatomic, weak) UILabel *dateLabel;
@property (nonatomic, weak) UILabel *messageLabel;
@property (nonatomic, weak) UIButton *unreadLabel;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
