//
//  GW_ChatMessageFrameModel.m
//  GW_ChatMessage
//
//  Created by gw on 2018/4/20.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_ChatMessageFrameModel.h"
#import "GW_CameraManager.h"
#import "GW_VideoManager.h"
@implementation GW_ChatMessageFrameModel
- (void)setModel:(GW_ChatMessageModel *)model{
    _model = model;
    CGFloat headToView    = 10; //头像距离屏幕边框距离
    CGFloat headToBubble  = 3;  //头像到文本背景距离
    CGFloat headWidth     = 45; //头像宽度
    CGFloat cellMargin    = 10; //头像距离cell的上边距
    CGFloat bubblePadding = 10;
    CGFloat chatLabelMax  = SCREENWIDTH - headWidth - 100;
    CGFloat arrowWidth    = 7;      // 气泡箭头
    CGFloat topViewH      = 10;     //文本框顶端距离头像顶端距离
    CGFloat cellMinW      = 60;     // cell的最小宽度值,针对文本
    CGSize timeSize  = CGSizeMake(0, 0);
    if (model.isSender) {
        cellMinW = timeSize.width + arrowWidth + bubblePadding*2;
        CGFloat headX = SCREENWIDTH - headToView - headWidth;
        _headImageViewF = CGRectMake(headX, cellMargin, headWidth, headWidth);
        if ([model.message.type isEqualToString:CellText]) {
            CGSize chateLabelSize = [model.message.content sizeWithMaxWidth:chatLabelMax andFont:MessageFont];
            CGSize bubbleSize = CGSizeMake(chateLabelSize.width + bubblePadding * 2 + arrowWidth, chateLabelSize.height + bubblePadding * 2);
            CGSize topViewSize = CGSizeMake(cellMinW+bubblePadding*2, topViewH);
            _bubbleViewF = CGRectMake(CGRectGetMinX(_headImageViewF) - headToBubble - bubbleSize.width, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGFloat x = CGRectGetMinX(_bubbleViewF)+bubblePadding;
            _topViewF = CGRectMake(CGRectGetMinX(_headImageViewF) - headToBubble - topViewSize.width-headToBubble-5, cellMargin,topViewSize.width,topViewSize.height);
            _chatLabelF = CGRectMake(x, topViewH + cellMargin + bubblePadding, chateLabelSize.width, chateLabelSize.height);
        }else if ([model.message.type isEqualToString:CellPic]){
            CGSize imageSize = CGSizeMake(40, 40);
            UIImage *image;
            if (model.message.isPicEmotion) {
                image = [UIImage imageWithContentsOfFile:model.mediaPath];
                imageSize = image.size;
            }else{
                image = [UIImage imageWithContentsOfFile:[[GW_CameraManager shareManager] imagePathWithName:model.mediaPath.lastPathComponent]];
                if (image) {
                    imageSize          = [self handleImage:image.size];
                }
            }

            imageSize.width        = imageSize.width > timeSize.width ? imageSize.width : timeSize.width;
            CGSize topViewSize     = CGSizeMake(imageSize.width-arrowWidth, topViewH);
            CGSize bubbleSize      = CGSizeMake(imageSize.width, imageSize.height);
            CGFloat bubbleX        = CGRectGetMinX(_headImageViewF)-headToBubble-bubbleSize.width;
            _bubbleViewF           = CGRectMake(bubbleX, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGFloat x              = CGRectGetMinX(_bubbleViewF);
            _topViewF             = CGRectMake(x, cellMargin,topViewSize.width,topViewSize.height);
            _picViewF              = CGRectMake(x, cellMargin+topViewH, imageSize.width, imageSize.height);
        }else if ([model.message.type isEqualToString:CellAudio]){
            CGFloat bubbleViewW = 100;
            _bubbleViewF = CGRectMake(CGRectGetMinX(_headImageViewF) - headToBubble - bubbleViewW, cellMargin+topViewH, bubbleViewW, 40);
            _topViewF = CGRectMake(CGRectGetMinX(_bubbleViewF), cellMargin, bubbleViewW - arrowWidth, topViewH);
            _durationLabelF = CGRectMake(CGRectGetMinX(_bubbleViewF)+ bubblePadding , cellMargin + 10+topViewH, 50, 20);
            _voiceIconF = CGRectMake(CGRectGetMaxX(_bubbleViewF) - 22, cellMargin + 10 + topViewH, 11, 16.5);// - 20
        }else if ([model.message.type isEqualToString:CellVideo]){
            CGSize imageSize       = CGSizeMake(150, 150);
            UIImage *videoImage = [[GW_CameraManager shareManager] videoImageWithFileName:model.mediaPath.lastPathComponent];
            if (!videoImage) {
                NSString *path          = [[GW_VideoManager shareManager] receiveVideoPathWithFileKey:[model.mediaPath.lastPathComponent stringByDeletingPathExtension]];
                videoImage    = [UIImage videoFramerateWithPath:path];
            }
            if (videoImage) {
                float scale        = videoImage.size.height/videoImage.size.width;
                imageSize = CGSizeMake(150, 140*scale);
            }
            CGSize bubbleSize = CGSizeMake(imageSize.width, imageSize.height);
            _bubbleViewF = CGRectMake(CGRectGetMinX(_headImageViewF)-headToBubble-bubbleSize.width, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGSize topViewSize     = CGSizeMake(imageSize.width-arrowWidth, topViewH);
            CGFloat x              = CGRectGetMinX(_bubbleViewF);
            _topViewF              = CGRectMake(x, cellMargin, topViewSize.width, topViewSize.height);
            _picViewF              = CGRectMake(x, cellMargin+topViewH, imageSize.width, imageSize.height);
        }else if ([model.message.type isEqualToString:CellFile]){
            CGSize bubbleSize = CGSizeMake(253, 95.0);
            _bubbleViewF = CGRectMake(CGRectGetMinX(_headImageViewF)-headToBubble-bubbleSize.width, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGSize topViewSize     = CGSizeMake(bubbleSize.width-arrowWidth, topViewH);
            CGFloat x              = CGRectGetMinX(_bubbleViewF);
            _topViewF              = CGRectMake(x, cellMargin, topViewSize.width, topViewSize.height);
            _picViewF              = CGRectMake(x, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
        }else if ([model.message.type isEqualToString:CellPicText]) {
            CGSize bubbleSize = CGSizeMake(253, 120.0);
            _bubbleViewF = CGRectMake(CGRectGetMinX(_headImageViewF)-headToBubble-bubbleSize.width, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGSize topViewSize     = CGSizeMake(bubbleSize.width-arrowWidth, topViewH);
            CGFloat x              = CGRectGetMinX(_bubbleViewF);
            _topViewF              = CGRectMake(x, cellMargin, topViewSize.width, topViewSize.height);
            _picViewF              = CGRectMake(x, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
        }
        CGFloat activityX = _bubbleViewF.origin.x-40;
        CGFloat activityY = (_bubbleViewF.origin.y + _bubbleViewF.size.height)/2 - 5;
        CGFloat activityW = 40;
        CGFloat activityH = 40;
        _activityF = CGRectMake(activityX, activityY, activityW, activityH);
        _retryButtonF = _activityF;
    }else{

        _headImageViewF = CGRectMake(headToView, cellMargin, headWidth, headWidth);
        CGSize nameSize       = CGSizeMake(0, 0);
        cellMinW = nameSize.width + 6 + timeSize.width; // 最小宽度
        if ([model.message.type isEqualToString:CellText]) {
            CGSize chateLabelSize = [model.message.content sizeWithMaxWidth:chatLabelMax andFont:MessageFont];
            CGSize bubbleSize = CGSizeMake(chateLabelSize.width + bubblePadding * 2 + arrowWidth, chateLabelSize.height + bubblePadding * 2);
            CGSize topViewSize = CGSizeMake(cellMinW+bubblePadding*2, topViewH);
            _bubbleViewF = CGRectMake(CGRectGetMaxX(_headImageViewF) + headToBubble, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGFloat x = CGRectGetMinX(_bubbleViewF) + bubblePadding + arrowWidth;
             _topViewF = CGRectMake(CGRectGetMinX(_bubbleViewF)+arrowWidth, cellMargin, topViewSize.width, topViewSize.height);
            _chatLabelF   = CGRectMake(x, cellMargin + bubblePadding + topViewH, chateLabelSize.width, chateLabelSize.height);
        }else if ([model.message.type isEqualToString:CellPic]){
            CGSize imageSize = CGSizeMake(40, 40);
            UIImage *image;
            if (model.message.isPicEmotion) {
                image = [UIImage imageWithContentsOfFile:model.mediaPath];
                imageSize = image.size;
            }else{
                image = [UIImage imageWithContentsOfFile:[[GW_CameraManager shareManager] imagePathWithName:model.mediaPath.lastPathComponent]];
                if (image) {
                    imageSize          = [self handleImage:image.size];
                }
            }
            imageSize.width        = imageSize.width > cellMinW ? imageSize.width : cellMinW;
            CGSize topViewSize     = CGSizeMake(imageSize.width-arrowWidth, topViewH);
            CGSize bubbleSize      = CGSizeMake(imageSize.width, imageSize.height);
            CGFloat bubbleX        = CGRectGetMaxX(_headImageViewF)+headToBubble;
            _bubbleViewF           = CGRectMake(bubbleX, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGFloat x              = CGRectGetMinX(_bubbleViewF);
            _topViewF              = CGRectMake(x+arrowWidth, cellMargin, topViewSize.width, topViewSize.height);
            _picViewF              = CGRectMake(x, cellMargin+topViewH, imageSize.width, imageSize.height);
        }else if ([model.message.type isEqualToString:CellAudio]){
            CGFloat bubbleViewW = 100; // 加上一个红点的宽度
            
            _bubbleViewF = CGRectMake(CGRectGetMaxX(_headImageViewF) + headToBubble, cellMargin+topViewH, bubbleViewW, 40);
            _topViewF = CGRectMake(CGRectGetMinX(_bubbleViewF)+arrowWidth, cellMargin, bubbleViewW-arrowWidth, topViewH);
            _voiceIconF = CGRectMake(CGRectGetMinX(_bubbleViewF)+arrowWidth+bubblePadding, cellMargin + 10 + topViewH, 11, 16.5);
            _durationLabelF = CGRectMake(CGRectGetMaxX(_voiceIconF) +bubblePadding, cellMargin + 10 + topViewH, 50, 20);
            _redViewF = CGRectMake(CGRectGetMaxX(_bubbleViewF) + 6, CGRectGetMinY(_bubbleViewF) + _bubbleViewF.size.height*0.5-4, 8, 8);
        }else if ([model.message.type isEqualToString:CellVideo]){
            CGSize imageSize       = CGSizeMake(150, 150);
            UIImage *videoImage = [[GW_CameraManager shareManager] videoImageWithFileName:[NSString stringWithFormat:@"%@.png",model.message.fileKey]];
            if (!videoImage) {
                //接收到的路径
                NSString *path          = [[GW_VideoManager shareManager] receiveVideoPathWithFileKey:model.message.fileKey];
                videoImage    = [UIImage videoFramerateWithPath:path];
            }
            if (videoImage) {
                float scale        = videoImage.size.height/videoImage.size.width;
                imageSize = CGSizeMake(150, 140*scale);
            }
            CGSize bubbleSize = CGSizeMake(imageSize.width, imageSize.height);
            _bubbleViewF = CGRectMake(CGRectGetMaxX(_headImageViewF)+headToBubble, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGSize topViewSize     = CGSizeMake(imageSize.width-arrowWidth, topViewH);
            CGFloat x              = CGRectGetMinX(_bubbleViewF);
            _topViewF              = CGRectMake(x+arrowWidth, cellMargin, topViewSize.width, topViewSize.height);
            _picViewF              = CGRectMake(x, cellMargin+topViewH, imageSize.width, imageSize.height);
        }else if ([model.message.type isEqualToString:CellFile]){
            CGSize bubbleSize = CGSizeMake(253, 95.0);
            _bubbleViewF = CGRectMake(CGRectGetMaxX(_headImageViewF)+headToBubble, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGSize topViewSize     = CGSizeMake(bubbleSize.width-arrowWidth, topViewH);
            CGFloat x              = CGRectGetMinX(_bubbleViewF);
            _topViewF              = CGRectMake(x+arrowWidth, cellMargin, topViewSize.width, topViewSize.height);
            _picViewF              = CGRectMake(x, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
        }else if ([model.message.type isEqualToString:CellPicText]) {
            CGSize bubbleSize = CGSizeMake(253, 120.0);
            _bubbleViewF = CGRectMake(CGRectGetMaxX(_headImageViewF)+headToBubble, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
            CGSize topViewSize     = CGSizeMake(bubbleSize.width-arrowWidth, topViewH);
            CGFloat x              = CGRectGetMinX(_bubbleViewF);
            _topViewF              = CGRectMake(x+arrowWidth, cellMargin, topViewSize.width, topViewSize.height);
            _picViewF              = CGRectMake(x, cellMargin+topViewH, bubbleSize.width, bubbleSize.height);
        }
    }
    
    _cellHight = MAX(CGRectGetMaxY(_bubbleViewF), CGRectGetMaxY(_headImageViewF)) + cellMargin;
    if ([model.message.type isEqualToString:CellSystem]) {
        CGSize size = [model.message.content sizeWithMaxWidth:[UIScreen mainScreen].bounds.size.width-40 andFont:[UIFont systemFontOfSize:11.0]];
        _cellHight = size.height+10;
    }
}

// 缩放，临时的方法
- (CGSize)handleImage:(CGSize)retSize{
    CGFloat scaleH = 0.22;
    CGFloat scaleW = 0.38;
    CGFloat height = 0;
    CGFloat width = 0;
    if (retSize.height / SCREENHEIGHT + 0.16 > retSize.width / SCREENWIDTH) {
        height = SCREENHEIGHT * scaleH;
        width = retSize.width / retSize.height * height;
    } else {
        width = SCREENWIDTH * scaleW;
        height = retSize.height / retSize.width * width;
    }
    return CGSizeMake(width, height);
}
@end
