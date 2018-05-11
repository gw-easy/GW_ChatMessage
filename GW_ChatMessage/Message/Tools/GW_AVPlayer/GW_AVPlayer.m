//
//  GW_AVPlayer.m
//  GW_ChatMessage
//
//  Created by gw on 2018/5/7.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_AVPlayer.h"
@interface GW_AVPlayer ()
@property (nonatomic, weak) UIView *fromView;
@property (nonatomic, weak) UIView *toContainerView;
@property (nonatomic, assign) BOOL fromNavigationBarHidden;
@end
@implementation GW_AVPlayer

- (instancetype)initWithPlayerURL:(NSURL *)URL {
    self = [super init];
    if (self){
        self.backgroundColor = [UIColor blackColor];
        
        //设置player的参数
        self.currentItem = [AVPlayerItem playerItemWithURL:URL];
        self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
        self.player.usesExternalPlaybackWhileExternalScreenIsActive=YES;
        //AVPlayerLayer
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.videoGravity = AVLayerVideoGravityResize;
        [self.layer addSublayer:self.playerLayer];
        [self.player play];
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
//            [self dismissAnimated:YES completion:nil];
//        }];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
        
        // 循环播放
        _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(playerItemDidPlayToEndTimeNotification:)
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
    }
    return self;
}

-(void)tapAction:(UITapGestureRecognizer *)tap{
    [self dismissAnimated:YES completion:nil];
}

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [UIView setAnimationsEnabled:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:_fromNavigationBarHidden withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
    if ([self.delegate respondsToSelector:@selector(closePlayerViewAction)]) {
        [self.delegate closePlayerViewAction];
    }
    float oneTime = animated ? 0.5 : 0;
    
    [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self releasePlayer];
        if (completion) completion();
    }];
    
}

- (void)presentFromVideoView:(UIView *)fromView
                 toContainer:(UIView *)toContainer
                    animated:(BOOL)animated
                  completion:(void (^)(void))completion{
    _toContainerView = toContainer == nil ? ROOT_VC_KEY_WINDOW.view : toContainer;
    
    _fromView = fromView;
    
    [_toContainerView addSubview:self];
    
    CGFloat height = fromView.size.height * SCREENWIDTH / fromView.size.width;
    
    self.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    
    self.alpha = 0;
    
    float oneTime = animated ? 0.5 : 0;
    
    [UIView animateWithDuration:oneTime animations:^{
        self.playerLayer.frame = CGRectMake(0, SCREENHEIGHT / 2 - height / 2, SCREENWIDTH, height);
        self.alpha = 1;
    }];
    _fromNavigationBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
    if (completion) completion();
}

- (void)playerItemDidPlayToEndTimeNotification:(NSNotification *)sender {
//    播放完自动从头开始播
    [self.player seekToTime:kCMTimeZero]; // seek to zero
}

- (void)releasePlayer {
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self.player pause];
    [self removeFromSuperview];
    [self.playerLayer removeFromSuperlayer];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
    self.currentItem = nil;
    self.playerLayer = nil;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self releasePlayer];
}
@end
