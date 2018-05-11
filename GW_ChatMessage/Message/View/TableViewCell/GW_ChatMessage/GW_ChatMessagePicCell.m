//
//  GW_ChatMessagePicCell.m
//  GW_ChatMessage
//
//  Created by gw on 2018/5/8.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_ChatMessagePicCell.h"
#import "GW_CameraManager.h"
#import "GW_FileManager.h"
#import "GW_MessageManager.h"
#import "GW_PhotoBrowserVC.h"
@interface GW_ChatMessagePicCell()
@property (strong, nonatomic) UIButton *imageBtn;
@end
@implementation GW_ChatMessagePicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        self.backgroundColor = [UIColor yellowColor];
        [self.contentView addSubview:self.imageBtn];
    }
    return self;
}



#pragma mark - Private Method

- (void)setModelFrame:(GW_ChatMessageFrameModel *)modelFrame
{
    [super setModelFrame:modelFrame];
    
    GW_CameraManager *manager = [GW_CameraManager shareManager];
    UIImage *image;
    if (modelFrame.model.message.isPicEmotion) {
        image = [UIImage imageWithContentsOfFile:modelFrame.model.mediaPath];
    }else{
        image = [manager imageWithLocalPath:[manager imagePathWithName:modelFrame.model.mediaPath.lastPathComponent]];
    }
    
    self.imageBtn.frame = modelFrame.picViewF;
    
    self.bubbleView.userInteractionEnabled = _imageBtn.imageView.image != nil;
    self.bubbleView.image = nil;
    if (modelFrame.model.isSender) {    // 发送者
        if (modelFrame.model.message.isPicEmotion) {
            [self.imageBtn setBackgroundImage:image forState:UIControlStateNormal];
            return;
        }
        UIImage *arrowImage = [manager arrowMeImage:image size:modelFrame.picViewF.size mediaPath:modelFrame.model.mediaPath isSender:modelFrame.model.isSender];
        [self.imageBtn setBackgroundImage:arrowImage forState:UIControlStateNormal];
    } else {
        if (modelFrame.model.message.isPicEmotion) {
            [self.imageBtn setBackgroundImage:image forState:UIControlStateNormal];
            return;
        }
        NSString *orgImgPath = [manager originImgPath:modelFrame];
        if ([GW_FileManager fileExistsAtPath:orgImgPath]) {
            UIImage *orgImg = [manager imageWithLocalPath:orgImgPath];
            UIImage *arrowImage = [manager arrowMeImage:orgImg size:modelFrame.picViewF.size mediaPath:orgImgPath isSender:modelFrame.model.isSender];
            [self.imageBtn setBackgroundImage:arrowImage forState:UIControlStateNormal];
        } else {
            UIImage *arrowImage = [manager arrowMeImage:image size:modelFrame.picViewF.size mediaPath:modelFrame.model.mediaPath isSender:modelFrame.model.isSender];
            [self.imageBtn setBackgroundImage:arrowImage forState:UIControlStateNormal];
        }
    }
}

- (void)imageBtnClick:(UIButton *)btn
{
    if (btn.currentBackgroundImage == nil) {
        return;
    }
    CGRect smallRect = [GW_MessageManager photoFramInWindow:btn];
    CGRect bigRect   = [GW_MessageManager photoLargerInWindow:btn];
    NSValue *smallValue = [NSValue valueWithCGRect:smallRect];
    NSValue *bigValue   = [NSValue valueWithCGRect:bigRect];
    NSString *imgPath      = self.modelFrame.model.mediaPath;
    NSString *orgImgPath = [[GW_CameraManager shareManager] originImgPath:self.modelFrame];
    if ([GW_FileManager fileExistsAtPath:orgImgPath]) {
        self.modelFrame.model.mediaPath = orgImgPath;
        imgPath = orgImgPath;
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:imgPath forKey:GW_PicSeleceClictPathKey];
    [dict setValue:self.modelFrame forKey:GW_PicMessageFrameModelKey];
    [dict setValue:smallValue forKey:GW_PicSelectSmallValueKey];
    [dict setValue:bigValue forKey:GW_PicSelectBigValueKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:GW_PicSeleceClictNotification object:nil userInfo:dict];
}



#pragma mark - Getter

- (UIButton *)imageBtn
{
    if (!_imageBtn) {
        _imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_imageBtn addTarget:self action:@selector(imageBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _imageBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        _imageBtn.layer.masksToBounds = YES;
        _imageBtn.layer.cornerRadius = 5;
        _imageBtn.clipsToBounds = YES;
    }
    return _imageBtn;
}

@end
