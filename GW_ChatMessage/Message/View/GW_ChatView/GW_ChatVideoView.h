//
//  GW_ChatVideoView.h
//  GW_ChatMessage
//
//  Created by gw on 2018/5/7.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface GW_ChatVideoView : UIView
@property (strong, nonatomic) UIView *videoLayerView;

@property (strong, nonatomic) UILabel *recordBtnLabel;

// 提示label:上移取消
@property (strong, nonatomic) UILabel *promptLabel;

@property (strong, nonatomic) UIView *timeLine;
// 时钟
@property (strong, nonatomic) NSTimer *recordTimer;

@property (strong, nonatomic) NSString *videoName;

@property (strong, nonatomic) NSDate *startDate;

@property (strong, nonatomic) NSDate *endDate;

@property (copy, nonatomic) void (^sendVideoMessage)(NSString *path);

@property (copy, nonatomic) void (^resign_First_Responder)(void);

@end
