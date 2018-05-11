//
//  GW_ChatBoxTalkView.m
//  GW_ChatMessage
//
//  Created by gw on 2018/5/2.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_ChatBoxTalkView.h"
#import "GW_TalkManager.h"
@interface GW_TalkHudView()
@property (assign, nonatomic) CGFloat progress;
@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation GW_TalkHudView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.animationDuration    = 0.5;
        self.animationRepeatCount = -1;
    }
    return self;
}

- (NSArray *)images{
    if (!_images) {
        _images                     = @[
                                      [UIImage imageNamed:@"voice_1"],
                                      [UIImage imageNamed:@"voice_2"],
                                      [UIImage imageNamed:@"voice_3"],
                                      [UIImage imageNamed:@"voice_4"],
                                      [UIImage imageNamed:@"voice_5"],
                                      [UIImage imageNamed:@"voice_6"]
                                      ];
    }
    return _images;
}

- (NSTimer *)timer{
    if (!_timer) {
        _timer =[NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(progressChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (void)progressChange{
    AVAudioRecorder *recorder = [[GW_TalkManager shareManager] recorder] ;
    [recorder updateMeters];
    float power= [recorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0,声音越大power绝对值越小
    self.progress = (1.0/160)*(power + 160);
}

- (void)setProgress:(CGFloat)progress{
    _progress = MIN(MAX(progress, 0.f),1.f);
    [self updateImages];
}

- (void)updateImages{
    if (self.progress == 0) {
        self.animationImages = nil;
        [self stopAnimating];
        return;
    }
    if (self.progress >= 0.8 ) {
        self.animationImages = @[self.images[3],self.images[4],self.images[5],self.images[4],self.images[3]];
    } else {
        self.animationImages = @[self.images[0],self.images[1],self.images[2],self.images[1]];
    }
    [self startAnimating];
}
@end

@interface GW_ChatBoxTalkView()
/** 按住说话 */
@property (nonatomic, strong) UIButton *talkButton;
@property (copy, nonatomic) NSString *fileName;

@end

@implementation GW_ChatBoxTalkView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.talkButton];
//        [self talkHudView];
    }
    return self;
}

- (GW_TalkHudView *)talkHudView{
    if (!_talkHudView) {
        _talkHudView = [[GW_TalkHudView alloc] initWithFrame:CGRectMake(0, 0, 155, 155)];
        _talkHudView.hidden = YES;
        _talkHudView.center = CGPointMake(SCREENWIDTH/2, (SCREENHEIGHT-64)/2);
    }
    return _talkHudView;
}

- (UIButton *)talkButton{
    if (!_talkButton) {
        _talkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _talkButton.frame = CGRectMake(0,0,self.width,self.height);
        [_talkButton setTitle:@"按住 说话" forState:UIControlStateNormal];
        [_talkButton setTitle:@"松开 结束" forState:UIControlStateHighlighted];
        [_talkButton setTitleColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0] forState:UIControlStateNormal];
        [_talkButton setBackgroundImage:[UIImage draw_imageWithColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.5]] forState:UIControlStateHighlighted];
        [_talkButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [_talkButton.layer setMasksToBounds:YES];
        [_talkButton.layer setCornerRadius:4.0f];
        [_talkButton.layer setBorderWidth:0.5f];
        [_talkButton.layer setBorderColor:ColorRGB(165, 165, 165).CGColor];

        [_talkButton addTarget:self action:@selector(talkButtonDown:) forControlEvents:UIControlEventTouchDown];
        [_talkButton addTarget:self action:@selector(talkButtonUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_talkButton addTarget:self action:@selector(talkButtonUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
//        [_talkButton addTarget:self action:@selector(talkButtonTouchCancel:) forControlEvents:UIControlEventTouchCancel];
        [_talkButton addTarget:self action:@selector(talkButtonDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
        [_talkButton addTarget:self action:@selector(talkButtonDragInside:) forControlEvents:UIControlEventTouchDragInside];
    }
    return _talkButton;
}

// 说话按钮
- (void)talkButtonDown:(UIButton *)sender{
    self.fileName = [self currentRecordFileName];
    [[GW_TalkManager shareManager] startRecordingWithFileName:self.fileName completion:^(NSError *error) {
        if (error) {
            
        }else{
            [self timerFree];
            self.talkHudView.hidden = NO;
            self.talkHudView.image =[UIImage imageNamed:@"voice_1"];
            [self.talkHudView timer];
        }
    }];
    
}

- (void)talkButtonUpInside:(UIButton *)sender{
    WS(weakSelf)
    [[GW_TalkManager shareManager] stopRecordingWithCompletion:^(NSString *recordPath) {
        if ([recordPath isEqualToString:GW_ShortRecording]) {
            [weakSelf voiceRecordSoShort];
            [weakSelf removeRecordFile];
        } else {    // send voice message
            [weakSelf timerFree]; // 销毁定时器
            weakSelf.talkHudView.hidden = YES;
            if (recordPath) {
                if (weakSelf.talkStopRecording) {
                    weakSelf.talkStopRecording(recordPath);
                }
//                ICMessageFrame *messageF = [ICMessageHelper createMessageFrame:TypeVoice content:@"[语音]" path:voicePath from:@"gxz" to:self.group.gId fileKey:nil isSender:YES receivedSenderByYourself:NO];
//                [self addObject:messageF isSender:YES];
//                [self messageSendSucced:messageF];
            }
        }
    }];

}

- (void)talkButtonUpOutside:(UIButton *)sender{
    [self timerFree];
    self.talkHudView.hidden = YES;
    [[GW_TalkManager shareManager] removeCurrentRecordFile:self.fileName];
}

- (void)talkButtonDragOutside:(UIButton *)sender{
    [self.talkHudView.timer setFireDate:[NSDate distantFuture]];
    self.talkHudView.animationImages  = nil;
    self.talkHudView.image = [UIImage imageNamed:@"cancelVoice"];
}

- (void)talkButtonDragInside:(UIButton *)sender{
    [self.talkHudView.timer setFireDate:[NSDate distantPast]];
    self.talkHudView.image  = [UIImage imageNamed:@"voice_1"];
}

//- (void)talkButtonTouchCancel:(UIButton *)sender{
//}

- (void)voiceRecordSoShort{
    [self timerFree];
    self.talkHudView.animationImages = nil;
    self.talkHudView.image = [UIImage imageNamed:@"voiceShort"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.talkHudView.hidden = YES;
    });
}

- (void)removeRecordFile{
    [[GW_TalkManager shareManager] removeCurrentRecordFile:self.fileName];
}

- (void)timerFree{
    [self.talkHudView.timer invalidate];
    self.talkHudView.timer  = nil;
}

- (NSString *)currentRecordFileName{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%ld",(long)timeInterval];
    return fileName;
}
@end
