//
//  GW_VideoManager.h
//  GW_ChatMessage
//
//  Created by gw on 2018/5/4.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
typedef void(^recordingFinish)(NSString *path);
@interface GW_VideoManager : NSObject
@property (copy, nonatomic) void (^videoFinished)(NSString *path);
+ (instancetype)shareManager;

- (void)setVideoPreviewLayer:(UIView *)videoLayerView;

- (void)startRecordingVideoWithFileName:(NSString *)videoName;

// 录制权限
- (BOOL)canRecordViedo;

// stop recording
- (void)stopRecordingVideo:(recordingFinish)finished;

- (void)cancelRecordingVideoWithFileName:(NSString *)videoName;

// 退出
- (void)exit;
// 接收到的视频保存路径(文件以fileKey为名字)
- (NSString *)receiveVideoPathWithFileKey:(NSString *)fileKey;

- (NSString *)videoPathWithFileName:(NSString *)videoName;

- (NSString *)videoPathForMP4:(NSString *)namePath;
// 自定义路径
- (NSString *)videoPathWithFileName:(NSString *)videoName fileDir:(NSString *)fileDir;

@end
