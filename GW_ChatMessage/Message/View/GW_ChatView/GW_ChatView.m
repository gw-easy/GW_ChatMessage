//
//  GW_ChatBoxView.m
//  GW_ChatMessage
//
//  Created by gw on 2018/4/20.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_ChatView.h"
#import "GW_FaceModel.h"
#import "GW_ChatMessageFrameModel.h"
#import "GW_ChatBoxTextView.h"
#import "GW_MessageManager.h"
#import "GW_FaceManager.h"
#import "GW_ChatBoxTalkView.h"
#import "GW_ChatBoxMoreView.h"
#import "GW_MoreItemModel.h"
#import "GW_ChatVideoView.h"
#import "GW_VideoManager.h"
#import "GW_FileManager.h"
#import "NSDictionary+Extension.h"

static const CGFloat CHATBOX_BUTTON_WIDTH = 37;
static const CGFloat VIEW_MARGIC = 5;//view之间的间距
static const CGFloat TEXT_VIEW_HEIGHT = 40;

#define videwViewH SCREENHEIGHT * 0.64 // 录制视频视图高度
#define videwViewX SCREENHEIGHT * 0.36 // 录制视频视图X
@interface GW_ChatBoxView : UIView<UITextViewDelegate>
/** chotBox的顶部边线 */
@property (nonatomic, strong) UIView *topLine;

@property (strong, nonatomic) UIView *boxView;

@property (copy, nonatomic) void (^changeChatBoxState)(GW_ChatBoxStatus fromState,GW_ChatBoxStatus toState);

/** 录音按钮 */
@property (nonatomic, strong) UIButton *voiceButton;
/** 表情按钮 */
@property (nonatomic, strong) UIButton *faceButton;
/** (+)按钮 */
@property (nonatomic, strong) UIButton *moreButton;
/** 按住说话 */
@property (nonatomic, strong) GW_ChatBoxTalkView *talkView;
/** 输入框 */
@property (nonatomic, strong) GW_ChatBoxTextView *boxTextView;

@property (strong, nonatomic) GW_ChatBoxFaceView *chatFaceView;

@property (strong, nonatomic) GW_ChatBoxMoreView *chatMoreView;

@property (copy, nonatomic) NSString *pushText;

/** 保存状态 */
@property (nonatomic, assign) GW_ChatBoxStatus status;

//是否禁止键盘隐藏
@property (assign, nonatomic) BOOL isStopHideKeyboard;

@end
@implementation GW_ChatBoxView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:ColorRGB(241, 241, 248)];
        self.status = GW_ChatBoxStatusNothing; // 起始状态
        [self addSubview:self.boxView];
        [self addSubview:self.topLine];
        [self addSubview:self.voiceButton];
        [self addSubview:self.moreButton];
        [self.boxView addSubview:self.faceButton];
        [self.boxView addSubview:self.boxTextView];
        
        
        [self addSubview:self.talkView];
        
        [self addSubview:self.chatFaceView];
        [self addSubview:self.chatMoreView];
    }
    return self;
}

-(UIView *)boxView{
    if (!_boxView) {
        _boxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, HEIGHT_CHATBOXVIEW)];
        [_boxView setBackgroundColor:ColorRGB(241, 241, 248)];
    }
    return _boxView;
}

- (UIView *)topLine{
    if (!_topLine) {
        _topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0.5)];
        [_topLine setBackgroundColor:ColorRGB(165, 165, 165)];
    }
    return _topLine;
}

//
- (UIButton *) voiceButton
{
    if (!_voiceButton) {
        _voiceButton = [[UIButton alloc] initWithFrame:CGRectMake(0, (HEIGHT_CHATBOXVIEW - CHATBOX_BUTTON_WIDTH) / 2, CHATBOX_BUTTON_WIDTH, CHATBOX_BUTTON_WIDTH)];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoiceHL"] forState:UIControlStateHighlighted];
        [_voiceButton addTarget:self action:@selector(voiceButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceButton;
}
// 录音按钮点击事件
- (void) voiceButtonDown:(UIButton *)sender
{
    GW_ChatBoxStatus lastStatus = self.status;
    if (lastStatus == GW_ChatBoxStatusShowVoice) {//正在显示talkButton，改为键盘状态
        self.status = GW_ChatBoxStatusShowKeyboard;
        [self.talkView setHidden:YES];
        [self.boxTextView setHidden:NO];
        [self.boxTextView.textView becomeFirstResponder];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
    } else {    // 变成talkButton的状态
        self.status = GW_ChatBoxStatusShowVoice;
        [self resignFirstResponder];
        [self.boxTextView setHidden:YES];
        [self.talkView setHidden:NO];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:UIControlStateNormal];
    }
    if (self.changeChatBoxState) {
        self.changeChatBoxState(lastStatus, self.status);
    }
    
}

- (GW_ChatBoxTalkView *)talkView{
    if (!_talkView) {
        _talkView = [[GW_ChatBoxTalkView alloc] initWithFrame:self.boxTextView.frame];
        _talkView.hidden = YES;
    }
    return _talkView;
}
//
- (UIButton *)moreButton{
    if (!_moreButton) {
        _moreButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - VIEW_MARGIC-CHATBOX_BUTTON_WIDTH, (self.height - CHATBOX_BUTTON_WIDTH) / 2, CHATBOX_BUTTON_WIDTH, CHATBOX_BUTTON_WIDTH)];
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
        [_moreButton addTarget:self action:@selector(moreButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}
//
- (UIButton *)faceButton{
    if (!_faceButton) {
        _faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _faceButton.frame = CGRectMake(self.width - VIEW_MARGIC*2-CHATBOX_BUTTON_WIDTH*2, (HEIGHT_CHATBOXVIEW - CHATBOX_BUTTON_WIDTH) / 2, CHATBOX_BUTTON_WIDTH, CHATBOX_BUTTON_WIDTH);
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        [_faceButton addTarget:self action:@selector(faceButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _faceButton;
}

- (GW_ChatBoxFaceView *)chatFaceView{
    if (!_chatFaceView) {
        _chatFaceView = [[GW_ChatBoxFaceView alloc] initWithFrame:CGRectMake(0, self.bottom, self.width, HEIGHT_CHATBOXVIEWSHOW)];
        _chatFaceView.hidden = YES;
    }
    return _chatFaceView;
}
//
- (GW_ChatBoxTextView *)boxTextView{
    if (!_boxTextView) {
        _boxTextView = [[GW_ChatBoxTextView alloc] initWithFrame:CGRectMake(self.voiceButton.right+VIEW_MARGIC,0,self.faceButton.left-self.voiceButton.right-VIEW_MARGIC*2,TEXT_VIEW_HEIGHT)];
        _boxTextView.centerY = self.height/2;
    }
    return _boxTextView;
}
//
- (GW_ChatBoxMoreView *)chatMoreView{
    if (!_chatMoreView) {
        _chatMoreView = [[GW_ChatBoxMoreView alloc] initWithFrame:self.chatFaceView.frame];
        _chatMoreView.hidden = YES;
    }
    return _chatMoreView;
}


- (void)faceButtonDown:(UIButton *)btn{
    GW_ChatBoxStatus lastStatus = self.status;
    if (lastStatus == GW_ChatBoxStatusShowFace) {
        self.status = GW_ChatBoxStatusShowKeyboard;
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [self.boxTextView.textView becomeFirstResponder];
    }else{
        [self.talkView setHidden:YES];
        [self.boxTextView setHidden:NO];
        [self.voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        self.status = GW_ChatBoxStatusShowFace;
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:UIControlStateNormal];
        if (lastStatus == GW_ChatBoxStatusShowMore) {
        } else if (lastStatus == GW_ChatBoxStatusShowVoice) {
            [self.voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
            [self.talkView setHidden:YES];
            [self.boxTextView setHidden:NO];
        }  else if (lastStatus == GW_ChatBoxStatusShowKeyboard) {
            self.isStopHideKeyboard = YES;
            [self resignFirstResponder];
            self.status = GW_ChatBoxStatusShowFace;
        } else if (lastStatus == GW_ChatBoxStatusShowVoice) {
            [self.talkView setHidden:YES];
            [self.boxTextView setHidden:NO];
            [self.voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
            self.status = GW_ChatBoxStatusShowFace;
        }
    }
    
    if (self.changeChatBoxState) {
        self.changeChatBoxState(lastStatus, self.status);
    }
}

// 更多（+）按钮
- (void) moreButtonDown:(UIButton *)sender
{
    GW_ChatBoxStatus lastStatus = self.status;
    if (lastStatus == GW_ChatBoxStatusShowMore) { // 当前显示的就是more页面
        self.status = GW_ChatBoxStatusShowKeyboard;
        [self.boxTextView.textView becomeFirstResponder];
    } else {
        [self.talkView setHidden:YES];
        [self.boxTextView setHidden:NO];
        [self.voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        self.chatMoreView.hidden = NO;
        self.status = GW_ChatBoxStatusShowMore;
        if (lastStatus == GW_ChatBoxStatusShowFace) {  // 改变按钮样式
            [self.faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        } else if (lastStatus == GW_ChatBoxStatusShowVoice) {
            [self.talkView setHidden:YES];
            [self.boxTextView setHidden:NO];
            [self.voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        } else if (lastStatus == GW_ChatBoxStatusShowKeyboard) {
            self.isStopHideKeyboard = YES;
            [self resignFirstResponder];
            self.status = GW_ChatBoxStatusShowMore;
        }
    }
    if (self.changeChatBoxState) {
        self.changeChatBoxState(lastStatus, self.status);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"GW_ChatBoxView");
}



#pragma mark - Public Methods

- (BOOL)resignFirstResponder{
    [self.boxTextView.textView resignFirstResponder];
    [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
    [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];

    return [super resignFirstResponder];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end


#pragma mark --GW_ChatView--
@interface GW_ChatView()

@property (assign, nonatomic) CGRect keyboardFrame;
@property (copy, nonatomic) NSString *text;
/** 数据源 */
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (assign, nonatomic) BOOL isKeyBoardAppear;

@property (strong, nonatomic) GW_ChatVideoView *videoView;
@end
@implementation GW_ChatView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.tbView];
        [self addSubview:self.chatBoxView];
        if (self.chatBoxView.talkView.talkHudView) {
            [self addSubview:self.chatBoxView.talkView.talkHudView];
        }
        [self addNotification];
        
        [self blockAction];
    }
    return self;
}

- (void)blockAction{

    WS(weakSelf)
#pragma mark tbview-block
    self.tbView.sendRecell = ^{
        
        GW_ChatMessageFrameModel *msgF = [GW_MessageManager createMessageFrame:CellSystem content:@"你撤回了一条消息" path:nil from:@"gxz" to:weakSelf.group.gId fileKey:nil isSender:YES receivedSenderByYourself:NO];
        return msgF;
    };
    self.tbView.resignFirstResponder = ^{
        [weakSelf resignRespinder];
    };
    
    
#pragma mark -boxTalkView-block
    self.chatBoxView.talkView.talkStopRecording = ^(NSString *audioPath) {
        GW_ChatMessageFrameModel *messageF = [GW_MessageManager createMessageFrame:CellAudio content:@"[语音]" path:audioPath from:@"gxz" to:weakSelf.group.gId fileKey:nil isSender:YES receivedSenderByYourself:NO];
        [weakSelf addObject:messageF isSender:YES];
        [weakSelf messageSendSucced:messageF];
        
        GW_ChatMessageFrameModel *messageL = [GW_MessageManager createMessageFrame:CellAudio content:@"[语音]" path:audioPath from:@"gxz" to:weakSelf.group.gId fileKey:nil isSender:NO receivedSenderByYourself:NO];
        [weakSelf addObject:messageL isSender:YES];
        [weakSelf messageSendSucced:messageL];
    };

#pragma mark chatboxview-boxTextView-block
    self.chatBoxView.boxTextView.getText = ^(NSString *text) {
        [weakSelf chatBox:weakSelf.chatBoxView sendTextMessage:text];
    };
    
    self.chatBoxView.boxTextView.getStatus = ^(GW_ChatBoxStatus status) {
        weakSelf.chatBoxView.changeChatBoxState(weakSelf.chatBoxView.status, status);
        weakSelf.chatBoxView.status = status;
    };
    
    self.chatBoxView.changeChatBoxState = ^(GW_ChatBoxStatus fromState, GW_ChatBoxStatus toState) {
        if (toState == GW_ChatBoxStatusShowKeyboard) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.chatBoxView.chatFaceView.hidden = YES;
                weakSelf.chatBoxView.chatMoreView.hidden = YES;
            });
            return;
        }else if (toState == GW_ChatBoxStatusShowVoice){
            
            [UIView animateWithDuration:0.3 animations:^{
                [weakSelf chatBoxChangeChatBoxHeight:HEIGHT_CHATBOXVIEW];
            } completion:^(BOOL finished) {
                weakSelf.chatBoxView.chatFaceView.hidden = YES;
                weakSelf.chatBoxView.chatMoreView.hidden = YES;
            }];
        }else if (toState == GW_ChatBoxStatusShowFace){
            if (fromState == GW_ChatBoxStatusShowVoice || fromState == GW_ChatBoxStatusNothing) {
                weakSelf.chatBoxView.chatFaceView.top = HEIGHT_CHATBOXVIEW;
                weakSelf.chatBoxView.chatFaceView.hidden = NO;
                [UIView animateWithDuration:0.3 animations:^{
                    [weakSelf chatBoxChangeChatBoxHeight:HEIGHT_CHATBOXVIEWSHOW+HEIGHT_CHATBOXVIEW];
                }];
            } else {  // 表情高度变化
                weakSelf.chatBoxView.chatFaceView.top = HEIGHT_CHATBOXVIEW + HEIGHT_CHATBOXVIEWSHOW;
                weakSelf.chatBoxView.chatFaceView.hidden = NO;
                [UIView animateWithDuration:0.3 animations:^{
                    weakSelf.chatBoxView.chatFaceView.top = HEIGHT_CHATBOXVIEW;
                } completion:^(BOOL finished) {
                    weakSelf.chatBoxView.chatMoreView.hidden = YES;
                }];
                if (fromState != GW_ChatBoxStatusShowMore) {
                    [UIView animateWithDuration:0.2 animations:^{
                        [weakSelf chatBoxChangeChatBoxHeight:HEIGHT_CHATBOXVIEWSHOW+HEIGHT_CHATBOXVIEW];
                    }];
                }
            }
        }else if (toState == GW_ChatBoxStatusShowMore) {
            if (fromState == GW_ChatBoxStatusShowVoice || fromState == GW_ChatBoxStatusNothing) {
                weakSelf.chatBoxView.chatMoreView.top = HEIGHT_CHATBOXVIEW;
                weakSelf.chatBoxView.chatMoreView.hidden = NO;
                [UIView animateWithDuration:0.3 animations:^{
                    [weakSelf chatBoxChangeChatBoxHeight:HEIGHT_CHATBOXVIEWSHOW+HEIGHT_CHATBOXVIEW];
                }];
            } else {
                weakSelf.chatBoxView.chatMoreView.top = HEIGHT_CHATBOXVIEW+HEIGHT_CHATBOXVIEWSHOW;
                weakSelf.chatBoxView.chatMoreView.hidden = NO;
                [UIView animateWithDuration:0.3 animations:^{
                weakSelf.chatBoxView.chatMoreView.top = HEIGHT_CHATBOXVIEW;
                } completion:^(BOOL finished) {
                    weakSelf.chatBoxView.chatFaceView.hidden = YES;
                }];

                [UIView animateWithDuration:0.2 animations:^{
                    [weakSelf chatBoxChangeChatBoxHeight:HEIGHT_CHATBOXVIEWSHOW+HEIGHT_CHATBOXVIEW];
                }];
            }
        }
    };

#pragma mark --moreView--image
    self.chatBoxView.chatMoreView.sendPicMessage = ^(NSString *path, UIImage *pic) {
        GW_ChatMessageFrameModel *messageF = [GW_MessageManager createMessageFrame:CellPic content:@"[图片]" path:path from:@"gxz" to:weakSelf.group.gId fileKey:nil isSender:YES receivedSenderByYourself:NO];
        [weakSelf addObject:messageF isSender:YES];
        [weakSelf messageSendSucced:messageF];
        
        GW_ChatMessageFrameModel *messageL = [GW_MessageManager createMessageFrame:CellPic content:@"[图片]" path:path from:@"gxz" to:weakSelf.group.gId fileKey:nil isSender:NO receivedSenderByYourself:NO];
        [weakSelf addObject:messageL isSender:YES];
        [weakSelf messageSendSucced:messageL];
    };
    
    self.chatBoxView.chatMoreView.sendFileMessage = ^(NSString *fileName) {
        NSString *lastName = [fileName originName];
        NSString*fileKey   = [fileName firstStringSeparatedByString:@"_"];
        NSString *content = [NSString stringWithFormat:@"[文件]%@",lastName];
        GW_ChatMessageFrameModel *messageFrame = [GW_MessageManager createMessageFrame:CellFile content:content path:fileName from:@"gxz" to:weakSelf.group.gId fileKey:nil isSender:YES receivedSenderByYourself:NO];
        NSString *path = [[GW_FileManager fileMainPath] stringByAppendingPathComponent:fileName];
        double s = [GW_FileManager fileSizeWithPath:path];
        NSNumber *x = [GW_MessageManager fileType:[fileName pathExtension]];
        if (!x) {
            x = @0;
        }
        NSDictionary *lnk = @{@"s":@((long)s),@"x":x,@"n":lastName};
        messageFrame.model.message.lnk = [lnk jsonString];
        messageFrame.model.message.fileKey = fileKey;
        [weakSelf addObject:messageFrame isSender:YES];
        [weakSelf messageSendSucced:messageFrame];
    };
    
}

- (void)resignRespinder{
    if (self.chatBoxView.status == GW_ChatBoxStatusShowVideo) { // 录制视频状态
        
        [UIView animateWithDuration:0.3 animations:^{
            self.videoView.top = self.height;
            [self chatBoxChangeChatBoxHeight:HEIGHT_CHATBOXVIEW];
        } completion:^(BOOL finished) {
            [self.videoView removeFromSuperview]; // 移除video视图
            self.chatBoxView.status = GW_ChatBoxStatusNothing;//同时改变状态
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                  [[GW_VideoManager shareManager] exit];  // 防止内存泄露
            });
        }];
    }
    
    if (self.chatBoxView.status != GW_ChatBoxStatusNothing && self.chatBoxView.status != GW_ChatBoxStatusShowVoice) {
        [self.chatBoxView resignFirstResponder];
        
        [UIView animateWithDuration:0.3 animations:^{
            [self chatBoxChangeChatBoxHeight:HEIGHT_CHATBOXVIEW];
        } completion:^(BOOL finished) {
            self.chatBoxView.chatFaceView.hidden = YES;
            self.chatBoxView.chatMoreView.hidden = YES;
            // 状态改变
            self.chatBoxView.status = GW_ChatBoxStatusNothing;
        }];
    }
}

- (GW_ChatBoxView *)chatBoxView{
    if (!_chatBoxView) {
        _chatBoxView = [[GW_ChatBoxView alloc] initWithFrame:CGRectMake(0, self.height-HEIGHT_CHATBOXVIEW, self.width, HEIGHT_CHATBOXVIEW)];
        
    }
    return _chatBoxView;
}

- (GW_ChatTBView *)tbView{
    if (!_tbView) {
        _tbView = [[GW_ChatTBView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height-HEIGHT_CHATBOXVIEW)];
        _tbView.backgroundColor = ColorRGB(240, 237, 237);
    }
    return _tbView;
}

- (void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectVideoAction:) name:GW_MoreViewVideoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picSendMessage:) name:GW_PicEmotionDidSelectNotification object:nil];
}

- (void)picSendMessage:(NSNotification *)noti{
    GW_FaceModel *fModel = noti.userInfo[GW_SelectEmotionKey];
    GW_ChatMessageFrameModel *messageF = [GW_MessageManager createMessageFrame:CellPicEmotion content:@"[图片]" path:fModel.face_path from:@"gxz" to:self.group.gId fileKey:nil isSender:YES receivedSenderByYourself:NO];
    [self addObject:messageF isSender:YES];
    [self messageSendSucced:messageF];
    
    GW_ChatMessageFrameModel *messageL = [GW_MessageManager createMessageFrame:CellPicEmotion content:@"[图片]" path:fModel.face_path from:@"gxz" to:self.group.gId fileKey:nil isSender:NO receivedSenderByYourself:NO];
    [self addObject:messageL isSender:YES];
    [self messageSendSucced:messageL];
}

- (void)selectVideoAction:(NSNotification *)noti{
    [self resignRespinder];
    if (![[GW_VideoManager shareManager] canRecordViedo]) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请在iPhone的“设置-隐私”选项中，允许WeChat访问你的摄像头和麦克风。" message:nil preferredStyle:0];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:0 handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVC addAction:alertAction];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC animated:YES completion:^{
        }];
    } else {
        [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(videoViewWillAppear) userInfo:nil repeats:NO]; // 待动画完成
    }
}

// 将要弹出视频视图
- (void)videoViewWillAppear{
    self.videoView = [[GW_ChatVideoView alloc] initWithFrame:CGRectMake(0, self.height, SCREENWIDTH, SCREENHEIGHT)];
    [[UIApplication sharedApplication].keyWindow addSubview:self.videoView];
    [UIView animateWithDuration:0.5 animations:^{
//        self.tbView.tableView.height = self.height - videwViewH;
        self.videoView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
        self.chatBoxView.frame = CGRectMake(0, self.height-HEIGHT_CHATBOXVIEW, SCREENWIDTH, HEIGHT_CHATBOXVIEW);
        [self.tbView scrollToBottom];
    } completion:^(BOOL finished) { // 状态改变
        self.chatBoxView.status = GW_ChatBoxStatusShowVideo;
        // 在这里创建视频设配
        UIView *videoLayerView = [self.videoView viewWithTag:1000];
        UIView *placeholderView = [self.videoView viewWithTag:1001];
        [[GW_VideoManager shareManager] setVideoPreviewLayer:videoLayerView];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(videoPreviewLayerWillAppear:) userInfo:placeholderView repeats:NO];
        
    }];
    
    
#pragma mark --videoView--
    WS(weakSelf)
    self.videoView.sendVideoMessage = ^(NSString *path) {
//        GW_ChatMessageFrameModel *messageFrame = [GW_MessageManager createMessageFrame:CellVideo content:@"[视频]" path:path from:@"gxz" to:weakSelf.group.gId fileKey:nil isSender:YES receivedSenderByYourself:NO]; // 创建本地消息
//        [weakSelf addObject:messageFrame isSender:YES];
//        [weakSelf messageSendSucced:messageFrame];
        
        GW_ChatMessageFrameModel *messageFrameL = [GW_MessageManager createMessageFrame:CellVideo content:@"[视频]" path:path from:@"gxz" to:weakSelf.group.gId fileKey:nil isSender:NO receivedSenderByYourself:NO]; // 创建本地消息
        [weakSelf addObject:messageFrameL isSender:NO];
        [weakSelf messageSendSucced:messageFrameL];
    };
    
    self.videoView.resign_First_Responder = ^{
        [weakSelf resignRespinder];
    };
}

// 移除录视频时的占位图片
- (void)videoPreviewLayerWillAppear:(NSTimer *)timer{
    UIView *placeholderView = (UIView *)[timer userInfo];
    [placeholderView removeFromSuperview];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    self.keyboardFrame = CGRectZero;
    _isKeyBoardAppear  = NO;
    self.chatBoxView.status = GW_ChatBoxStatusNothing;
    if (self.chatBoxView.isStopHideKeyboard) {
        self.chatBoxView.isStopHideKeyboard = NO;
        return;
    }
    CGFloat height = HEIGHT_CHATBOXVIEW;
    [self chatBoxChangeChatBoxHeight:height];

}

- (void)keyboardFrameWillChange:(NSNotification *)notification{
    self.keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (self.chatBoxView.status == GW_ChatBoxStatusShowKeyboard && self.keyboardFrame.size.height <= HEIGHT_CHATBOXVIEWSHOW) {
        return;
    }else if ((self.chatBoxView.status == GW_ChatBoxStatusShowFace || self.chatBoxView.status == GW_ChatBoxStatusShowMore) && self.keyboardFrame.size.height <= HEIGHT_CHATBOXVIEWSHOW) {
        return;
    }
    CGFloat height = self.keyboardFrame.size.height + HEIGHT_CHATBOXVIEW;
    [self chatBoxChangeChatBoxHeight:height];
    self.chatBoxView.status = GW_ChatBoxStatusShowKeyboard;
}

- (void)chatBoxChangeChatBoxHeight:(CGFloat)height{
    self.chatBoxView.top = self.height-height;
    self.chatBoxView.height = height;
    self.tbView.TBheight = self.chatBoxView.top;
    if (height == HEIGHT_CHATBOXVIEW) {
        [self.tbView reloadData];
        _isKeyBoardAppear  = NO;
    }else{
        [self.tbView scrollToBottom];
        _isKeyBoardAppear  = YES;
    }
}

- (void)chatBox:(GW_ChatBoxView *)chatBox sendTextMessage:(NSString *)textMessage{
    if (textMessage && textMessage.length > 0) {
        [self sendTextMessageWithContent:textMessage];
        [self otherSendTextMessageWithContent:textMessage];
    }
}

- (void)sendTextMessageWithContent:(NSString *)messageStr{
    GW_ChatMessageFrameModel *messageF = [GW_MessageManager createMessageFrame:CellText content:messageStr path:nil from:@"gxz" to:self.group.gId fileKey:nil isSender:YES receivedSenderByYourself:NO];
    [self addObject:messageF isSender:YES];
    
    [self messageSendSucced:messageF];
}

// 增加数据源并刷新
- (void)addObject:(GW_ChatMessageFrameModel *)messageF
         isSender:(BOOL)isSender{
    [self.dataSource addObject:messageF];
    self.tbView.dataSource = self.dataSource;
    [self.tbView reloadData];
    if (isSender || _isKeyBoardAppear) {
        [self.tbView scrollToBottom];
    }
}

- (void)messageSendSucced:(GW_ChatMessageFrameModel *)messageF{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        messageF.model.message.deliveryState = GW_MessageDeliveryState_Delivered;
        [self.tbView reloadData];
        [self.tbView scrollToBottom];
    });
}

- (void)otherSendTextMessageWithContent:(NSString *)messageStr{
    GW_ChatMessageFrameModel *messageF = [GW_MessageManager createMessageFrame:CellText content:messageStr path:nil from:@"gxz" to:self.group.gId fileKey:nil isSender:NO receivedSenderByYourself:NO];
    [self addObject:messageF isSender:YES];
    
    [self messageSendSucced:messageF];
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"GW_ChatView");
}
@end
