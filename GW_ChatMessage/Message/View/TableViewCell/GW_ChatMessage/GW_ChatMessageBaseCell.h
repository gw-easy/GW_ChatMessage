//
//  GW_ChatMesssageBaseCell.h
//  GW_ChatMessage
//
//  Created by gw on 2018/4/20.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GW_ChatMessageFrameModel.h"

@class GW_ChatMessageBaseCell;
@protocol GW_ChatMessageBaseCellDelegate <NSObject>

- (void)longPress:(UILongPressGestureRecognizer *)longRecognizer;

@optional
- (void)headImageClicked:(NSString *)eId;
- (void)reSendMessage:(GW_ChatMessageBaseCell *)baseCell;

@end
@interface GW_ChatMessageBaseCell : UITableViewCell
@property (nonatomic, weak) id<GW_ChatMessageBaseCellDelegate> delegate;

// 消息模型
@property (nonatomic, strong) GW_ChatMessageFrameModel *modelFrame;
// 头像
@property (nonatomic, strong) UIImageView *headImageView;
// 内容气泡视图
@property (nonatomic, strong) UIImageView *bubbleView;
// 菊花视图所在的view
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
// 重新发送
@property (nonatomic, strong) UIButton *retryButton;
@end
