//
//  GW_MessageCell.m
//  GW_ChatMessage
//
//  Created by gw on 2018/4/19.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_MessageCell.h"
static const CGFloat topPadding = 8;
static const CGFloat leftPadding = 9;

static NSString *cellID = @"cellID";
@interface GW_MessageCell()

@end
@implementation GW_MessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self avatarImageView];
        [self usernameLabel];
        [self dateLabel];
        [self messageLabel];
        [self unreadLabel];
        
        self.bottomLineStyle = CellLineStyleFill;
    }
    return self;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    
    GW_MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[GW_MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)setGroup:(GW_MessageModel *)group
{
    _group   = group;
    if (group.isTop == 1) {
        self.backgroundColor = [UIColor blueColor];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
    if (group.unReadCount > 0) {
        [self.unreadLabel setTitle:[NSString stringWithFormat:@"%d",group.unReadCount] forState:UIControlStateNormal];
        self.unreadLabel.backgroundColor     = [UIColor redColor];
    } else {
        [self.unreadLabel setTitle:@" " forState:UIControlStateNormal];
        self.unreadLabel.backgroundColor = self.backgroundColor;
    }
    _avatarImageView.image = [UIImage imageNamed:@"mayun.jpg"];
    [_messageLabel setText:group.lastMsgString];
    [_usernameLabel setText:group.gName];
    
    _dateLabel.text = @"11:20";
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat top = 13;
    CGFloat imageWidth = self.height - topPadding*2;
    
    [_avatarImageView setFrame:CGRectMake(leftPadding, topPadding, imageWidth, imageWidth)];
    
    _dateLabel.top = top;
    _dateLabel.width = 70;
    _dateLabel.height = _dateLabel.font.pointSize+2;
    _dateLabel.right = self.width - 9;
    
    _usernameLabel.top = top;
    _usernameLabel.left = _avatarImageView.right + 8;
    _usernameLabel.width = self.width-_usernameLabel.left-5;
    _usernameLabel.height = _usernameLabel.font.pointSize+2;

    _messageLabel.top = _usernameLabel.bottom+4;
    _messageLabel.left = _usernameLabel.left;
    _messageLabel.width = _usernameLabel.width;
    _messageLabel.height = _messageLabel.font.pointSize+2;

    _unreadLabel.width = _messageLabel.height;
    _unreadLabel.height = _messageLabel.height;
     _unreadLabel.right = _dateLabel.right;
    _unreadLabel.centerY = _messageLabel.centerY;
}

- (UIView *) avatarImageView
{
    if (_avatarImageView == nil) {
        UIImageView *imageV = [[UIImageView alloc] init];
        [self.contentView addSubview:imageV];
        _avatarImageView = imageV;
    }
    return _avatarImageView;
}

- (UILabel *) usernameLabel
{
    if (_usernameLabel == nil) {
        UILabel *label = [[UILabel alloc] init];
        [self.contentView addSubview:label];
        _usernameLabel.font = [UIFont systemFontOfSize:17.0];
        _usernameLabel = label;
    }
    return _usernameLabel;
}

- (UILabel *) dateLabel
{
    if (_dateLabel == nil) {
        UILabel *label = [[UILabel alloc] init];
//        label.backgroundColor = [UIColor redColor];
        [label setTextAlignment:NSTextAlignmentRight];
        [label setTextColor:[UIColor lightGrayColor]];
        label.font = [UIFont systemFontOfSize:12.0];
        [self.contentView addSubview:label];
        _dateLabel = label;
    }
    return _dateLabel;
}

- (UILabel *) messageLabel
{
    if (_messageLabel == nil) {
        UILabel *label = [[UILabel alloc] init];
        [label setTextColor:[UIColor lightGrayColor]];
        label.font = [UIFont systemFontOfSize:14.0];
        [self.contentView addSubview:label];
        _messageLabel = label;
    }
    return _messageLabel;
}

- (UIButton *)unreadLabel
{
    if (_unreadLabel == nil) {
        UIButton *button = [[UIButton alloc] init];
        [self.contentView addSubview:button];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius  = 8;
        button.contentEdgeInsets   = UIEdgeInsetsMake(1, 5, 1, 5);
        button.backgroundColor     = [UIColor redColor];
        button.titleLabel.font     = [UIFont systemFontOfSize:12.0];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _unreadLabel   = button;
    }
    return _unreadLabel;
}

@end
