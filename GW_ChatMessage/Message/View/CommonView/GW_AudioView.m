//
//  GW_AudioView.m
//  GW_ChatMessage
//
//  Created by gw on 2018/5/10.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_AudioView.h"
#import <AVFoundation/AVFoundation.h>
#import "GW_TalkManager.h"
#import "GW_MessageManager.h"
@interface GW_AudioView()<AVAudioPlayerDelegate,GW_TalkManagerDelegate>
@property (strong, nonatomic) UIImageView *imageV;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *endTimeLabel;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIProgressView *progressV;
@property (strong, nonatomic) UIButton *playBtn;
@end
@implementation GW_AudioView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imageV];
        [self addSubview:self.nameLabel];
        [self addSubview:self.playBtn];
        [self addSubview:self.progressV];
        [self addSubview:self.endTimeLabel];
    }
    return self;
}

- (void)setAudioName:(NSString *)audioName{
    _audioName = audioName;
    _nameLabel.text = audioName;
}

- (void)setAudioPath:(NSString *)audioPath{
    _audioPath = audioPath;
    NSUInteger durataion = [[GW_TalkManager shareManager] durationWithVideo:[NSURL fileURLWithPath:audioPath]];
    _endTimeLabel.text = [GW_MessageManager timeDurationFormatter:durataion];
}

- (void)beginPlay:(UIButton *)playBtn
{
    GW_TalkManager *manager = [GW_TalkManager shareManager];
    if (manager.player == nil) {
        [playBtn setBackgroundImage:[UIImage imageNamed:@"iconfont-zhanting"] forState:UIControlStateNormal];
        manager.delegate = self;
        [manager startPlayRecorder:_audioPath];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                                selector:@selector(playProgress)
                                                userInfo:nil repeats:YES];
    } else if ([manager.player isPlaying]) {
        [playBtn setBackgroundImage:[UIImage imageNamed:@"iconfont-kaishianniu"] forState:UIControlStateNormal];
        [manager pause];
        [_timer setFireDate:[NSDate distantFuture]];
    } else {
        [playBtn setBackgroundImage:[UIImage imageNamed:@"iconfont-zhanting"] forState:UIControlStateNormal];
        [manager.player play];
        [_timer setFireDate:[NSDate date]];
    }
    
}

- (void)playProgress{
    GW_TalkManager *manager = [GW_TalkManager shareManager];
    _progressV.progress = [[manager player] currentTime]/[[manager player] duration];
}

- (void)timerInvalid{
    [_timer invalidate];
    _timer = nil;
}

// 释放
- (void)voiceDidPlayFinished
{
    [self timerInvalid];
    GW_TalkManager *manager = [GW_TalkManager shareManager];
    [manager stopPlayRecorder:_audioPath];
    manager.delegate = nil;
    [_playBtn setBackgroundImage:[UIImage imageNamed:@"iconfont-kaishianniu"] forState:UIControlStateNormal];
}

- (void)releaseTimer{
    [self timerInvalid];
}

- (void)dealloc{
    GW_TalkManager *manager = [GW_TalkManager shareManager];
    [manager stopPlayRecorder:_audioPath];
    manager.delegate = nil;
    [self timerInvalid];
}

- (UIImageView *)imageV{
    if (!_imageV) {
        _imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconfont-luyin"]];
        _imageV.frame = CGRectMake(150, 105, 99, 143);
        _imageV.centerX = self.width*0.5;
    }
    return _imageV;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, self.imageV.bottom+27, 250, 20)];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _nameLabel.centerX = self.width*0.5;
        _nameLabel.font    = [UIFont systemFontOfSize:15.0];
        _nameLabel.textColor = ColorRGBHas(0x535f62);
        _nameLabel.text    = _audioName;
    }
    return _nameLabel;
}

- (UIButton *)playBtn{
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"iconfont-kaishianniu"] forState:UIControlStateNormal];
        _playBtn.frame = CGRectMake(25,self.nameLabel.bottom+200, 50, 50);
        [_playBtn addTarget:self action:@selector(beginPlay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIProgressView *)progressV{
    if (!_progressV) {
        _progressV = [[UIProgressView alloc] initWithFrame:CGRectMake(self.playBtn.right+16, self.playBtn.top, self.width-self.playBtn.right-16-25, 10)];
        _progressV.centerY = self.playBtn.centerY;
        _progressV.progressTintColor =  ColorRGB(13, 103, 135);
    }
    return _progressV;
}

- (UILabel *)endTimeLabel{
    if (!_endTimeLabel) {
        _endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.progressV.right-100, self.progressV.bottom+14, 100, 20)];
        _endTimeLabel.textAlignment = NSTextAlignmentRight;
        _endTimeLabel.font = [UIFont systemFontOfSize:14.0];
        _endTimeLabel.textColor = ColorRGBHas(0x535f62);
    }
    return _endTimeLabel;
}
@end
