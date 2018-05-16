//
//  GW_ChatMessageVideoCell.m
//  GW_ChatMessage
//
//  Created by gw on 2018/5/7.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_ChatMessageVideoCell.h"
#import "GW_VideoManager.h"
#import "GW_CameraManager.h"
#import "GW_AVPlayer.h"
#import "GW_FileManager.h"
#import "GW_AVPlayerManager.h"
@interface GW_ChatMessageVideoCell()
@property (nonatomic, strong) UIView *backImageView;

@property (nonatomic, strong) UIButton *topBtn;
@end
@implementation GW_ChatMessageVideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.backImageView];
        [self.backImageView addSubview:self.topBtn];
    }
    return self;
}

- (void)setModelFrame:(GW_ChatMessageFrameModel *)modelFrame{
    [super setModelFrame:modelFrame];
    GW_CameraManager *manager = [GW_CameraManager shareManager];
    NSString *path = [[GW_VideoManager shareManager] receiveVideoPathWithFileKey:[modelFrame.model.mediaPath.lastPathComponent stringByDeletingPathExtension]];
    UIImage *videoArrowImage = [manager videoConverPhotoWithVideoPath:path size:modelFrame.picViewF.size isSender:modelFrame.model.isSender];
    self.backImageView.frame = modelFrame.picViewF;
    
    self.bubbleView.userInteractionEnabled = (videoArrowImage != nil);
    self.bubbleView.image = nil;
    self.backImageView.layer.contents = (__bridge id _Nullable)(videoArrowImage.CGImage);
    self.topBtn.frame = CGRectMake(0, 0, self.backImageView.width, self.backImageView.height);
    
    self.backImageView.layer.mask = [UIImage shapeBezierPath:modelFrame.model.isSender imageSize:modelFrame.picViewF.size];
}

- (UIView *)backImageView{
    if (!_backImageView) {
        _backImageView = [[UIView alloc] init];
        _backImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageBtnClick:)];
        [_backImageView addGestureRecognizer:tap];
    }
    return _backImageView;
}


- (void)imageBtnClick:(UITapGestureRecognizer *)btn{
    __block NSString *path = [[GW_VideoManager shareManager] videoPathForMP4:self.modelFrame.model.mediaPath];
    [self videoPlay:path];
}

- (void)videoPlay:(NSString *)path{
    GW_AVPlayer *player = [[GW_AVPlayer alloc] initWithPlayerURL:[NSURL fileURLWithPath:path]];
    [player presentFromVideoView:self.backImageView toContainer:nil animated:YES completion:nil];
}


- (UIButton *)topBtn{
    if (!_topBtn) {
        _topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_topBtn addTarget:self action:@selector(firstPlay) forControlEvents:UIControlEventTouchUpInside];
        _topBtn.layer.masksToBounds = YES;
        _topBtn.layer.cornerRadius = 5;
    }
    return _topBtn;
}

- (void)firstPlay{
    __block NSString *path = [[GW_VideoManager shareManager] videoPathForMP4:self.modelFrame.model.mediaPath];
    if ([GW_FileManager fileExistsAtPath:path]) {
        [self reloadStart];
        _topBtn.hidden = YES;
    }
}

-(void)reloadStart {
    __weak typeof(self) weakSelf=self;
    NSString *path = [[GW_VideoManager shareManager] videoPathForMP4:self.modelFrame.model.mediaPath];
    [[GW_AVPlayerManager sharedManager] startPlayVideo:path withVideoDecode:^(NSString *filePath,UIImage *ref) {
        if ([filePath isEqualToString:path]) {
            if (ref) {
                weakSelf.backImageView.layer.contents = (__bridge id _Nullable)ref.CGImage;
            }
        }
    }];
    
    [[GW_AVPlayerManager sharedManager] reloadVideoPlay:^(NSString *filePath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([filePath isEqualToString:path]) {
                [weakSelf reloadStart];
            }
        });
    } withFilePath:path];
}




-(void)stopVideo {
    _topBtn.hidden = NO;
    [[GW_AVPlayerManager sharedManager] cancelVideo:[[GW_VideoManager shareManager] videoPathForMP4:self.modelFrame.model.mediaPath]];
}

-(void)dealloc {
    [[GW_AVPlayerManager sharedManager] cancelAllVideo];
}

@end
