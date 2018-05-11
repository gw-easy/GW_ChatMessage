//
//  GW_ChatBoxView.h
//  GW_ChatMessage
//
//  Created by gw on 2018/4/20.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GW_ChatTBView.h"
#import "GW_MessageModel.h"
#import "GW_ChatBoxFaceView.h"
@class GW_ChatBoxView;
@protocol GW_ChatViewDelegate <NSObject>
@optional
/**
 *  输入框状态(位置)改变
 *
 *  @param chatBox    chatBox
 *  @param fromStatus 起始状态
 *  @param toStatus   目的状态
 */
- (void)chatBox:(GW_ChatBoxView *)chatBox changeStatusForm:(GW_ChatBoxStatus)fromStatus to:(GW_ChatBoxStatus)toStatus;

/**
 *  发送消息
 *
 *  @param chatBox     chatBox
 *  @param textMessage 消息
 */
- (void)chatBox:(GW_ChatBoxView *)chatBox sendTextMessage:(NSString *)textMessage;

/**
 *  输入框高度改变
 *
 *  @param chatBox chatBox
 *  @param height  height
 */
- (void)chatBox:(GW_ChatBoxView *)chatBox changeChatBoxHeight:(CGFloat)height;

/**
 *  开始录音
 *
 *  @param chatBox chatBox
 */
- (void)chatBoxDidStartRecordingVoice:(GW_ChatBoxView *)chatBox;
- (void)chatBoxDidStopRecordingVoice:(GW_ChatBoxView *)chatBox;
- (void)chatBoxDidCancelRecordingVoice:(GW_ChatBoxView *)chatBox;
- (void)chatBoxDidDrag:(BOOL)inside;


@end

@interface GW_ChatView : UIView
@property (strong, nonatomic) GW_ChatTBView *tbView;
@property (strong, nonatomic) GW_ChatBoxView *chatBoxView;
@property (strong, nonatomic) GW_MessageModel *group;
@property (nonatomic, weak) id<GW_ChatViewDelegate>delegate;
@end


