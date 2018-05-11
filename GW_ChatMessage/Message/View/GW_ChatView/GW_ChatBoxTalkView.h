//
//  GW_ChatBoxTalkView.h
//  GW_ChatMessage
//
//  Created by gw on 2018/5/2.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GW_TalkHudView : UIImageView

@end

@interface GW_ChatBoxTalkView : UIView
@property (strong, nonatomic) GW_TalkHudView *talkHudView;
@property (copy, nonatomic) void (^talkStopRecording)(NSString *audioPath);
@end


