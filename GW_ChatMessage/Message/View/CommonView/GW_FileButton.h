//
//  GW_FileButton.h
//  GW_ChatMessage
//
//  Created by gw on 2018/5/10.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GW_ChatMessageModel;
@interface GW_FileButton : UIButton
@property (nonatomic, strong) GW_ChatMessageModel *messageModel;

@property (nonatomic, strong) UILabel *identLabel;

@property (nonatomic, strong) UIProgressView *progressView;
@end
