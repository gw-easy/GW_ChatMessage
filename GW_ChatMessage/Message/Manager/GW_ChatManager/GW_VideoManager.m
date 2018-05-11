//
//  GW_VideoManager.m
//  GW_ChatMessage
//
//  Created by gw on 2018/5/4.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_VideoManager.h"
#import "GW_FileManager.h"
@interface GW_VideoManager()<AVCaptureFileOutputRecordingDelegate>{
    AVCaptureVideoPreviewLayer *_preLayer;
}
//字节流
@property (nonatomic, strong) AVCaptureSession *session;
//文件输出
@property (nonatomic, strong) AVCaptureMovieFileOutput *captureMovieOutput;

@property (copy, nonatomic) recordingFinish finished;

@end
@implementation GW_VideoManager
static GW_VideoManager *base = nil;
+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        base = [[super allocWithZone:NULL] init];
    });
    return base;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [GW_VideoManager shareManager];
}

- (void)setVideoPreviewLayer:(UIView *)videoLayerView
{
    // 创建会话
    [self session];
    // 创建视频设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *inputVideo = [AVCaptureDeviceInput deviceInputWithDevice:[devices firstObject] error:nil];
    if (!inputVideo) {
        GWLog(@"deviceInput wrong!");
        return;
    }
    // 创建麦克风设备
    AVCaptureDevice *deviceAudio = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    // 摄像头输入输出流
    AVCaptureDeviceInput *inputAudio = [AVCaptureDeviceInput deviceInputWithDevice:deviceAudio error:nil];
    _session.sessionPreset = AVCaptureSessionPreset640x480;
    // 将输入输出设备添加到会话中
    if ([_session canAddInput:inputVideo]) {
        [_session addInput:inputVideo];
    }
    if ([_session canAddInput:inputAudio]) {
        [_session addInput:inputAudio];
    }
    if ([_session canAddOutput:self.captureMovieOutput]) {
        [_session addOutput:self.captureMovieOutput];
    }
    AVCaptureVideoPreviewLayer *preLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    preLayer.videoGravity = AVLayerVideoGravityResizeAspectFill; // 填充
    //    preLayer.videoGravity = AVLayerVideoGravityResize; // 按可见区域大小录制视频
    preLayer.frame = videoLayerView.bounds;
    
    videoLayerView.layer.masksToBounds = YES;
    [videoLayerView layoutIfNeeded];
    [videoLayerView.layer addSublayer:preLayer];
    _preLayer = preLayer;
    [_session startRunning];
}

// begin recording
- (void)startRecordingVideoWithFileName:(NSString *)videoName{
    AVCaptureConnection *connection = [self.captureMovieOutput connectionWithMediaType:AVMediaTypeVideo];
    
//    connection.videoOrientation=[_preLayer connection].videoOrientation;
    if (!connection) {
        GWLog(@"capture connection wrong!");
        return;
    }
    // 预览图层和视频方向保持一致
    if ([connection isVideoOrientationSupported]) {
        connection.videoOrientation = [self getCaptureVideoOrientation];
    }
    NSString *videoPath = [self videoPathWithFileName:videoName];
    NSURL *urlPath = [NSURL fileURLWithPath:videoPath];
    [_captureMovieOutput startRecordingToOutputFileURL:urlPath recordingDelegate:self];
}

- (AVCaptureVideoOrientation)getCaptureVideoOrientation {
    AVCaptureVideoOrientation result;
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            result = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            //如果这里设置成AVCaptureVideoOrientationPortraitUpsideDown，则视频方向和拍摄时的方向是相反的。
            result = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeLeft:
            result = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            result = AVCaptureVideoOrientationLandscapeLeft;
            break;
        default:
            result = AVCaptureVideoOrientationPortrait;
            break;
    }
    
    return result;
}

- (BOOL)canRecordViedo
{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        return NO;
    } else {
        return YES;
    }
}

// stop recording
- (void)stopRecordingVideo:(recordingFinish)finished{
    _finished = finished;
    [_captureMovieOutput stopRecording];
}

// cancel recording
- (void)cancelRecordingVideoWithFileName:(NSString *)videoName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *videoPath = [self videoPathWithFileName:videoName];
    if (!videoPath) return;
    BOOL isRemoveSucceed = [fileManager removeItemAtPath:videoPath error:nil];
    if (isRemoveSucceed) {
        GWLog(@"remove succeed!");
    }
}

- (void)exit{
    [_session stopRunning];
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if ([self getFileSize:[outputFileURL path]] == 0.0) {
        return;
    }
    // 转换
    NSURL *mp4Url = [self convertMp4:outputFileURL];
    [self getFileSize:[mp4Url path]];
    WS(weakSelf)
    
    [self compressVideo:[mp4Url path] finished:^(NSString *path) {
        if (path && weakSelf.finished) {
            weakSelf.finished(path);
        }
        // 删除原录制的文件
        if ([GW_FileManager fileExistsAtPath:outputFileURL.path]) {
            [GW_FileManager removeFileAtPath:outputFileURL.path];
        }
    }];
    // 直接转大小不会改变
    //    [self getFileSize:filePath];
    //    _finished([mp4Url path]);
}

// file size
- (CGFloat)getFileSize:(NSString *)path{
    NSDictionary *outputFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    GWLog(@"file size : %f",[outputFileAttributes fileSize]/1024.0/1024.0);
    return [outputFileAttributes fileSize]/1024.0/1024.0;
}

//转成mp4格式
- (NSURL *)convertMp4:(NSURL *)movUrl {
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        mp4Url = [movUrl copy];
        mp4Url = [mp4Url URLByDeletingPathExtension];
        mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            wait = nil;
        }
    }
    
    return mp4Url;
}

// compress video 文件压缩-高质量->中质量
- (NSString *)compressVideo:(NSString *)path finished:(recordingFinish)finish{
    NSURL *url = [NSURL fileURLWithPath:path];
    // 获取文件资源
    AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
    // 导出资源属性
    NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    // 是否包含中分辨率，如果是低分辨率AVAssetExportPresetLowQuality则不清晰
    if ([presets containsObject:AVAssetExportPresetMediumQuality]) {
        // 重定义资源属性
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        // 压缩后的文件路径
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
        NSString *videoName = [formatter stringFromDate:[NSDate date]];
        NSString *outPutPath = [self videoPathWithFileName:videoName];
        exportSession.outputURL = [NSURL fileURLWithPath:outPutPath];
        exportSession.shouldOptimizeForNetworkUse = YES;// 是否对网络进行优化
        exportSession.outputFileType = AVFileTypeMPEG4; // 转成MP4
        // 导出
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self getFileSize:outPutPath];
                    // 这里完成了压缩
                    if (finish){
                       finish(outPutPath);
                    }
                    
                });
            }
        }];
        return outPutPath;
    }
    return nil;
}

// video的路径
- (NSString *)videoPathWithFileName:(NSString *)videoName{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:GW_VideoChildPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirExist = [fileManager fileExistsAtPath:path];
    if (!isDirExist) {
        BOOL isCreatDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isCreatDir) {
            GWLog(@"create folder failed");
            return nil;
        }
    }
    return [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",videoName,GW_VideoType]];
}

- (NSString *)videoPathForMP4:(NSString *)namePath
{
    NSString *videoPath   = [self videoPathWithFileName:[[namePath lastPathComponent] stringByDeletingPathExtension]];
    NSString *mp4Path     = [[videoPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp4"];
    return mp4Path;
}

// 接收到的视频保存路径(文件以fileKey为名字)
- (NSString *)receiveVideoPathWithFileKey:(NSString *)fileKey{
    return [self videoPathWithFileName:fileKey];
}

- (NSString *)videoPathWithFileName:(NSString *)videoName fileDir:(NSString *)fileDir {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirExist = [fileManager fileExistsAtPath:path];
    if (!isDirExist) {
        BOOL isCreatDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isCreatDir) {
            GWLog(@"create folder failed");
            return nil;
        }
    }
    return [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",videoName,GW_VideoType]];
}



- (AVCaptureSession *)session
{
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureMovieFileOutput *)captureMovieOutput{
    if (!_captureMovieOutput) {
        _captureMovieOutput = [[AVCaptureMovieFileOutput alloc] init];
    }
    return _captureMovieOutput;
}
@end
