//
//  GW_ChatBoxTextView.h
//  GW_ChatMessage
//
//  Created by gw on 2018/4/23.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GW_ChatBoxTextView : UIView
/** 输入框 */
@property (nonatomic, strong) UITextView *textView;

@property (copy, nonatomic) void (^getText)(NSString *text);

@property (copy, nonatomic) void (^getStatus)(GW_ChatBoxStatus status);


@end
