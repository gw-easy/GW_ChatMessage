//
//  GW_ChatMessageFrameModel.h
//  GW_ChatMessage
//
//  Created by gw on 2018/4/20.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GW_ChatMessageModel.h"

@interface GW_ChatMessageFrameModel : NSObject
//聊天信息的背景图
@property (nonatomic, assign, readonly) CGRect bubbleViewF;

//聊天信息label
@property (nonatomic, assign, readonly) CGRect chatLabelF;

//发送的菊花视图
@property (nonatomic, assign, readonly) CGRect activityF;

//重新发送按钮
@property (nonatomic, assign, readonly) CGRect retryButtonF;

// 头像
@property (nonatomic, assign, readonly) CGRect headImageViewF;

// topView   /***第一版***/
@property (nonatomic, assign, readonly) CGRect topViewF;

//计算总的高度
@property (nonatomic, assign) CGFloat cellHight;

/// 消息模型
@property (nonatomic, strong) GW_ChatMessageModel *model;

/// 图片
@property (nonatomic, assign, readonly) CGRect picViewF;

/// 语音图标
@property (nonatomic, assign) CGRect voiceIconF;

/// 语音时长数字
@property (nonatomic, assign) CGRect durationLabelF;

/// 语音未读红点
@property (nonatomic, assign) CGRect redViewF;
@end
