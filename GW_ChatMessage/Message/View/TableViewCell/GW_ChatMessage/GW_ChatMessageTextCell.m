//
//  GW_ChatMessageTextCell.m
//  GW_ChatMessage
//
//  Created by gw on 2018/4/20.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_ChatMessageTextCell.h"
#import "GW_FaceManager.h"
@implementation GW_ChatMessageTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.chatLabel];
        __weak typeof(self) weadSelf = self;
        _chatLabel.urlLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
            [weadSelf urlSkip:[NSURL URLWithString:string]];
        };
    }
    return self;
}

- (void)setModelFrame:(GW_ChatMessageFrameModel *)modelFrame{
    [super setModelFrame:modelFrame];
    self.chatLabel.frame = modelFrame.chatLabelF;
    [self.chatLabel setAttributedText:[GW_FaceManager transferMessageString:modelFrame.model.message.content font:self.chatLabel.font lineHeight:self.chatLabel.font.lineHeight]];
    //    self.chatLabel.text = modelFrame.model.content;
}


- (void)attemptOpenURL:(NSURL *)url
{
    BOOL safariCompatible = [url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"];
    if (safariCompatible && [[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警示" message:@"您的链接无效" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

//从字符串拿出的url
- (void)urlSkip:(NSURL *)url
{
//    [self routerEventWithName:GXRouterEventURLSkip userInfo:@{@"url"   : url}];
}


- (KILabel *)chatLabel
{
    if (nil == _chatLabel) {
        _chatLabel = [[KILabel alloc] init];
        _chatLabel.numberOfLines = 0;
        _chatLabel.font = MessageFont;
        _chatLabel.textColor = ColorRGBHas(0x282724);
    }
    return _chatLabel;
}

@end
