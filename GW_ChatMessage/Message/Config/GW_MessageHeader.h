//
//  GW_MessageHeader.h
//  GW_ChatMessage
//
//  Created by gw on 2018/4/20.
//  Copyright © 2018年 gw. All rights reserved.
//

#ifndef GW_MessageHeader_h
#define GW_MessageHeader_h
static NSString *const CellText = @"CellText_GW";
static NSString *const CellPic = @"CellPic_GW";
static NSString *const CellPicEmotion = @"CellPicEmotion_GW";
static NSString *const CellAudio = @"CellAudio_GW";
static NSString *const CellVideo = @"CellVideo_GW";
static NSString *const CellFile = @"CellFile_GW";
static NSString *const CellSystem = @"CellSystem_GW";
static NSString *const CellPicText = @"CellPicText_GW";

#pragma mark --notification--
//emotions通知
static NSString *const GW_EmotionDidSelectNotification =
@"GXEmotionDidSelectNotification";
static NSString *const GW_EmotionDidDeleteNotification =
@"GXEmotionDidDeleteNotification";
static NSString *const GW_EmotionDidSendNotification =
@"GXEmotionDidSendNotification";
static NSString *const GW_SelectEmotionKey = @"GW_SelectEmotionKey";
static NSString *const GW_PicEmotionDidSelectNotification = @"GW_PicEmotionDidSelectNotification";
//moreView通知
static NSString *const GW_SelectMoreItemKey = @"GW_SelectMoreItemKey";
static NSString *const GW_MoreViewPhotoNotification = @"GW_MoreViewPhotoNotification";
static NSString *const GW_MoreViewCameraNotification = @"GW_MoreViewCameraNotification";
static NSString *const GW_MoreViewVideoNotification = @"GW_MoreViewVideoNotification";
static NSString *const GW_MoreViewDocNotification = @"GW_MoreViewDocNotification";
static NSString *const GW_MoreViewVideoFinishNotification = @"GW_MoreViewVideoFinishNotification";

static NSString *const GW_PicSeleceClictNotification = @"GW_PicSeleceClictNotification";
static NSString *const GW_PicSeleceClictPathKey = @"GW_PicSeleceClictPathKey";
static NSString *const GW_PicMessageFrameModelKey = @"GW_PicMessageFrameModelKey";
static NSString *const GW_PicSelectSmallValueKey = @"GW_PicSelectSmallValueKey";
static NSString *const GW_PicSelectBigValueKey = @"GW_PicSelectBigValueKey";

static const CGFloat HEIGHT_STATUSBAR = 20;
static const CGFloat HEIGHT_NAVBAR = 44;
static const CGFloat HEIGHT_CHATBOXVIEW = 49; //chatbox默认
static const CGFloat HEIGHT_CHATBOXVIEWSHOW = 215; //chatbox展开
static const CGFloat TOP_LINE_HEIGHT = 0.5; //顶部线高度
static const CGFloat menuHeight = 36;//表情menu高度


static NSString *const GW_ChildPath = @"Chat/File";
static NSString *const GW_VideoChildPath = @"Chat/Video";
static NSString *const GW_DiscverVideoPath = @"Download/Video";
static NSString *const GW_RecorderType = @".wav";
static NSString *const GW_VideoType = @".mp4";
static NSString *const GW_AmrType = @"amr";
static NSString *const GW_PngType = @"png";

static NSString *const GW_ShortRecording = @"GW_ShortRecording";
#endif /* GW_MessageHeader_h */
