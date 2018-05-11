//
//  GW_ChatVideoView.m
//  GW_ChatMessage
//
//  Created by gw on 2018/5/7.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_ChatVideoView.h"
#import "GW_VideoManager.h"
static const float durationTime = 10.0;
@interface GW_ChatVideoView()

@end
@implementation GW_ChatVideoView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.videoLayerView];
        [self addSubview:self.recordBtnLabel];
        [self addSubview:self.timeLine];
        [self addSubview:self.promptLabel];
        [self setupUIwithFrame:frame];
    }
    return self;
}

- (void)setupUIwithFrame:(CGRect)frame
{
    
    //    self.recordBtn.frame = CGRectMake(0, self.height-20-70, 70, 70);
    self.recordBtnLabel.centerX = self.centerX;

    UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:exitBtn];
    exitBtn.width = exitBtn.height = 40;
    exitBtn.left = self.width - 50 - exitBtn.width;
    exitBtn.centerY = self.recordBtnLabel.centerY;
    [exitBtn setTitle:@"取消" forState:UIControlStateNormal];
    [exitBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [exitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [exitBtn addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
    
    self.videoLayerView.frame = CGRectMake(0, 0, SCREENWIDTH,self.height);

    // 占位图片,现写成label
    UILabel *label = [[UILabel alloc] init];
    label.tag = 1001;
    [self.videoLayerView addSubview:label];
    [self addTapGestureRecognizer];
    label.text = @"正在加载...";
    label.centerX = self.videoLayerView.centerX;
    label.centerY = self.videoLayerView.centerY;
    label.textColor = [UIColor whiteColor];
}

- (void)addTapGestureRecognizer{
    UITapGestureRecognizer *tapTecoginzer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
    tapTecoginzer.numberOfTapsRequired = 1;
    tapTecoginzer.delaysTouchesBegan = YES;
    [self.videoLayerView addGestureRecognizer:tapTecoginzer];
}

- (void)singleTap{
    
}



// 结束录制
- (void)stopRecordingVideo{
    [[GW_VideoManager shareManager] stopRecordingVideo:^(NSString *path) {
        if (self.resign_First_Responder) {
            self.resign_First_Responder();
        }
        if (self.sendVideoMessage) {
            self.sendVideoMessage(path);
        }
        //            ICMessageFrame *messageFrame = [ICMessageHelper createMessageFrame:TypeVideo content:@"[视频]" path:videoPath from:@"gxz" to:self.group.gId fileKey:nil isSender:YES receivedSenderByYourself:NO]; // 创建本地消息
        //            [self addObject:messageFrame isSender:YES];
        //            [self messageSendSucced:messageFrame];
    }];
}

- (void)exit{
    [self destroyTimer];
    [[GW_VideoManager shareManager] exit]; // 防止内存泄露
    if (self.resign_First_Responder) {
        self.resign_First_Responder();
    }
}


// 手指相对位置
- (BOOL)touchInButtonWithPoint:(CGPoint)point{
    CGFloat x = point.x;
    CGFloat y = point.y;
    return (x>=self.recordBtnLabel.left-80&&x<=self.recordBtnLabel.right+50)&&(y<=self.recordBtnLabel.bottom&&y>=self.recordBtnLabel.top);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint  point = [touch locationInView:self];
    BOOL touchResult = [self touchInButtonWithPoint:point];
    if (touchResult) {
        [self recordVideoStarted]; // 开始录制
        [self setTimeLineAndPromptView];
        [self promptStatuesChanged:touchResult];
    }
}

- (void)recordVideoStarted{
    self.recordBtnLabel.hidden = YES;
    self.timeLine.frame = CGRectMake(0,self.recordBtnLabel.top-20 , SCREENWIDTH, 1);
    _startDate = [NSDate date];
    self.timeLine.hidden = NO;
    self.promptLabel.hidden = NO;
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(recordTimeOver) userInfo:nil repeats:NO];
    self.videoName = [NSString currentName];
    [[GW_VideoManager shareManager] startRecordingVideoWithFileName:self.videoName];
    [UIView animateWithDuration:durationTime animations:^{
        _timeLine.frame = CGRectMake(_timeLine.centerX, _timeLine.top, 0, 1);
    } completion:^(BOOL finished) {
        
    }];
}

// time is over
- (void)recordTimeOver{
    self.promptLabel.hidden = YES;
    [self destroyTimer];
    // 结束录制
    [self stopRecordingVideo];
}

// 提示信息
- (void)setTimeLineAndPromptView{
    self.promptLabel.text = @"↑上移取消";
    self.promptLabel.bottom = self.timeLine.bottom-40;
    [self.promptLabel sizeToFit];
    self.promptLabel.center = CGPointMake(self.width*0.5, _promptLabel.centerY);
    self.promptLabel.textColor = [UIColor greenColor];
    self.promptLabel.backgroundColor = [UIColor clearColor];
}

- (void)promptStatuesChanged:(BOOL)status{
    if (status) {
        self.promptLabel.text = @"↑上移取消";
        self.promptLabel.textColor = [UIColor greenColor];
    } else {
        self.promptLabel.text = @"松开取消录制";
        self.promptLabel.textColor = [UIColor redColor];
    }
    [self.promptLabel sizeToFit];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch   = [touches anyObject];
    CGPoint  point   = [touch locationInView:self];
    BOOL isTopStatus = [self isMoveToTop:point];
    [self promptStatuesChanged:!isTopStatus];
    if (isTopStatus) {
        
    }
}

- (BOOL)isMoveToTop:(CGPoint)point{
    CGFloat y = point.y;
    return y<self.recordBtnLabel.top-10;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint  point = [touch locationInView:self];
    BOOL isTopStatus = [self isMoveToTop:point];
    if (isTopStatus) { // 取消录制
        [self recordVideoCanceled];
    } else { // 结束录制
        [self recordVideoFinished];
    }
}

- (void)recordVideoFinished{
    _endDate = [NSDate date];
    [self destroyTimer];
    self.promptLabel.hidden = YES;
    NSTimeInterval timeInterval = [_endDate timeIntervalSinceDate:_startDate];
    if ((double)timeInterval <= durationTime) { //小于或等于规定时间
        self.recordBtnLabel.hidden = YES; // 录制完了就隐藏,录制页面直接下去
        self.timeLine.hidden = YES;
        [self stopRecordingVideo];
        
    } else {
        return;
    }
}

- (void)recordVideoCanceled{
    // 这里如果以后出问题，就直接让videoView下去
    [self destroyTimer];
    self.timeLine.hidden = YES;
    self.recordBtnLabel.hidden = YES;
    self.promptLabel.hidden = YES;
    [[GW_VideoManager shareManager] stopRecordingVideo:^(NSString *path) {
        self.recordBtnLabel.hidden = NO;
        // 删除已经录制的文件
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[GW_VideoManager shareManager] cancelRecordingVideoWithFileName:_videoName];
        });
    }];
}

// 销毁定时器
- (void)destroyTimer{
    [self.recordTimer invalidate];
    self.recordTimer = nil;
}

- (UIView *)timeLine{
    if (!_timeLine) {
        _timeLine = [[UIView alloc] init];
        _timeLine.backgroundColor = [UIColor greenColor];
    }
    return _timeLine;
}

- (UILabel *)promptLabel
{
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.font = [UIFont systemFontOfSize:15];
    }
    return _promptLabel;
}

- (UIView *)videoLayerView
{
    if (!_videoLayerView) {
        _videoLayerView = [[UIView alloc] init];
        _videoLayerView.backgroundColor = [UIColor blackColor];
        _videoLayerView.tag = 1000;

    }
    return _videoLayerView;
}

- (UILabel *)recordBtnLabel{
    if (!_recordBtnLabel) {
        _recordBtnLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.height-20-70-64, 70, 70)];
        _recordBtnLabel.layer.cornerRadius = 70/2.0;
        _recordBtnLabel.layer.masksToBounds = YES;
        _recordBtnLabel.layer.borderWidth = 2;
        _recordBtnLabel.layer.borderColor = [UIColor greenColor].CGColor;
    }
    return _recordBtnLabel;
}

- (void)dealloc{
    [self destroyTimer];
}
@end
