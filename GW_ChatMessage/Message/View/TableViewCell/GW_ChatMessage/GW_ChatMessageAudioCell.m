//
//  GW_ChatMessageAudioCell.m
//  GW_ChatMessage
//
//  Created by gw on 2018/5/3.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_ChatMessageAudioCell.h"
#import "GW_TalkManager.h"
#import "VoiceConverter.h"
@interface GW_ChatMessageAudioCell()<GW_TalkManagerDelegate>
@property (nonatomic, strong) UIButton    *voiceButton;
@property (nonatomic, strong) UILabel     *durationLabel;
@property (nonatomic, strong) UIImageView *voiceIcon;
@property (nonatomic, strong) UIView      *redView;
/** voice path */
@property (nonatomic, copy) NSString *voicePath;
@end

@implementation GW_ChatMessageAudioCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.voiceIcon];
        [self.contentView addSubview:self.durationLabel];
        [self.contentView addSubview:self.voiceButton];
        [self.contentView addSubview:self.redView];
        
    }
    return self;
}


- (void)setModelFrame:(GW_ChatMessageFrameModel *)modelFrame
{
    [super setModelFrame:modelFrame];
    
    NSString *voicePath = [self mediaPath:modelFrame.model.mediaPath];
    self.durationLabel.text  = [NSString stringWithFormat:@"%ld''",[[GW_TalkManager shareManager] durationWithVideo:[NSURL fileURLWithPath:voicePath]]];
    if (modelFrame.model.isSender) {  // sender
        self.voiceIcon.image = [UIImage imageNamed:@"right-3"];
        UIImage *image1 = [UIImage imageNamed:@"right-1"];
        UIImage *image2 = [UIImage imageNamed:@"right-2"];
        UIImage *image3 = [UIImage imageNamed:@"right-3"];
        self.voiceIcon.animationImages = @[image1, image2, image3];
        self.durationLabel.textAlignment = NSTextAlignmentLeft;
    } else {                          // receive
        self.voiceIcon.image = [UIImage imageNamed:@"left-3"];
        UIImage *image1 = [UIImage imageNamed:@"left-1"];
        UIImage *image2 = [UIImage imageNamed:@"left-2"];
        UIImage *image3 = [UIImage imageNamed:@"left-3"];
        self.voiceIcon.animationImages = @[image1, image2, image3];
        self.durationLabel.textAlignment = NSTextAlignmentRight;
    }
    self.voiceIcon.animationDuration = 0.8;
    if (modelFrame.model.message.status == GW_MessageStatus_read) {
        self.redView.hidden  = YES;
    } else if (modelFrame.model.message.status == GW_MessageStatus_unRead) {
        self.redView.hidden  = NO;
    }
    self.durationLabel.frame = modelFrame.durationLabelF;
    self.voiceIcon.frame     = modelFrame.voiceIconF;
    self.voiceButton.frame   = modelFrame.bubbleViewF;
    self.redView.frame       = modelFrame.redViewF;
    
}

// 文件路径
- (NSString *)mediaPath:(NSString *)originPath
{
    // 这里文件路径重新给，根据文件名字来拼接
    NSString *name = [[originPath lastPathComponent] stringByDeletingPathExtension];
    return [[GW_TalkManager shareManager] receiveVoicePathWithFileKey:name];
}


#pragma mark - respond Method

- (void)voiceButtonClicked:(UIButton *)voiceBtn{
    voiceBtn.selected = !voiceBtn.selected;
    [self chatVoiceTaped:self.modelFrame];
}

// play voice
- (void)chatVoiceTaped:(GW_ChatMessageFrameModel *)messageFrame{
    GW_TalkManager *recordManager = [GW_TalkManager shareManager];
    recordManager.delegate = self;
    // 文件路径
    NSString *voicePath = [self mediaPath:messageFrame.model.mediaPath];
    NSString *amrPath   = [[voicePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"amr"];
    [VoiceConverter ConvertAmrToWav:amrPath wavSavePath:voicePath];
    if (messageFrame.model.message.status == 0){
        messageFrame.model.message.status = 1;
        self.redView.hidden = YES;
    }
    if (self.voicePath) {
        if ([self.voicePath isEqualToString:voicePath]) { // the same recoder
            self.voicePath = nil;
            [[GW_TalkManager shareManager] stopPlayRecorder:voicePath];
            [self.voiceIcon stopAnimating];
            self.voiceIcon.hidden = YES;
            return;
        } else {
            [self.voiceIcon stopAnimating];
            self.voiceIcon.hidden = YES;
        }
    }
    [[GW_TalkManager shareManager] startPlayRecorder:voicePath];
    [self.voiceIcon startAnimating];
    self.voicePath = voicePath;
    self.voiceIcon.hidden = NO;
}

- (void)voiceDidPlayFinished{
    self.voicePath = nil;
    GW_TalkManager *manager = [GW_TalkManager shareManager];
    manager.delegate = nil;
    [self.voiceIcon stopAnimating];
    self.voiceIcon.hidden = YES;
}
#pragma mark - Getter

- (UIButton *)voiceButton
{
    if (!_voiceButton) {
        _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_voiceButton addTarget:self action:@selector(voiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceButton;
}

- (UILabel *)durationLabel
{
    if (!_durationLabel ) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.font = MessageFont;
    }
    return _durationLabel;
}

- (UIImageView *)voiceIcon
{
    if (!_voiceIcon) {
        _voiceIcon = [[UIImageView alloc] init];
    }
    return _voiceIcon;
}

- (UIView *)redView
{
    if (!_redView) {
        _redView = [[UIView alloc] init];
        _redView.layer.masksToBounds = YES;
        _redView.layer.cornerRadius = 4;
        _redView.backgroundColor = ColorRGBHas(0xf05e4b);
    }
    return _redView;
}

@end
