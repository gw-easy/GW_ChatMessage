//
//  GW_TalkManager.m
//  GW_ChatMessage
//
//  Created by gw on 2018/5/2.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_TalkManager.h"
#import "GW_FileManager.h"
#import "VoiceConverter.h"
static const float recordDuration = 1.0;

@interface GW_TalkManager()<AVAudioPlayerDelegate,AVAudioRecorderDelegate>
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (nonatomic, strong) NSDictionary *recordSetting;
@property (copy, nonatomic) void (^recordFinish)(NSString *recordPath);
@end
@implementation GW_TalkManager
static GW_TalkManager *base = nil;
+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        base = [[super allocWithZone:NULL] init];
    });
    return base;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [GW_TalkManager shareManager];
}

// here also need to limit recording time
- (void)startRecordingWithFileName:(NSString *)fileName completion:(void(^)(NSError *error))completion{
    NSError *error = nil;
    if (![[GW_TalkManager shareManager] canRecord]) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"无法录音" message:@"请在iPhone的“设置-隐私-麦克风”选项中，允许iCom访问你的手机麦克风。" preferredStyle:0];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:0 handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVC addAction:sureAction];
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"无法录音" message:@"请在iPhone的“设置-隐私-麦克风”选项中，允许iCom访问你的手机麦克风。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
        [ROOT_VC_KEY_WINDOW presentViewController:alertVC animated:YES completion:^{
            
        }];
        if (completion) {
            error = [NSError errorWithDomain:NSLocalizedString(@"error", @"没权限") code:122 userInfo:nil];
            completion(error);
        }
        return;
    }
    if ([_recorder isRecording]) {
        [_recorder stop];
        [self cancelCurrentRecording];
        return;
    } else {
        NSString *wavFilePath = [self recorderPathWithFileName:fileName];
        NSURL *wavUrl = [[NSURL alloc] initFileURLWithPath:wavFilePath];
        // 在实例化AVAudioRecorder之前，先开启会话,否则真机上录制失败
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *setCategoryError = nil;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&setCategoryError];
        if(setCategoryError){
            NSLog(@"%@", [setCategoryError description]);
        }
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:wavUrl settings:self.recordSetting error:&error];
        if (!_recorder || error) {
            _recorder = nil;
            if (completion) {
                error = [NSError errorWithDomain:NSLocalizedString(@"error.initRecorderFail", @"Failed to initialize AVAudioRecorder") code:123 userInfo:nil];
                completion(error);
            }
            return;
        }
        _startDate = [NSDate date];
        _recorder.meteringEnabled = YES;
        _recorder.delegate = self;
        [_recorder record];
        if (completion) {
            completion(error);
        }
    }
}


// here also need format conversion
- (void)stopRecordingWithCompletion:(void(^)(NSString *recordPath))completion
{
    
    //    [self.recorder stop];
    _endDate = [NSDate date];
    if ([_recorder isRecording]) {
        if ([_endDate timeIntervalSinceDate:_startDate] < recordDuration) {
            if (completion) {
                completion(GW_ShortRecording);
            }
            [self.recorder stop];
            [self cancelCurrentRecording];
            sleep(1.0);//a temporary method，let it sheep a minute,because recorder generated need time，to prevented clicked quickly situation
            GWLog(@"record time duration is too short");
            return;
        }
        self.recordFinish = completion;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.recorder stop];
            GWLog(@"record time duration :%f",[_endDate timeIntervalSinceDate:_startDate]);
        });
    }
}

- (NSString *)recorderPathWithFileName:(NSString *)fileName
{
    NSString *path = [self recorderMainPath];
    return [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",fileName,GW_RecorderType]];
}

// 录音文件主路径
- (NSString *)recorderMainPath
{
    return [GW_FileManager createPathWithChildPath:GW_ChildPath];
}

// 移除音频
- (void)removeCurrentRecordFile:(NSString *)fileName{
    [self cancelCurrentRecording];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self recorderPathWithFileName:fileName];
    BOOL isDirExist = [fileManager fileExistsAtPath:path];
    if (isDirExist) {
        [fileManager removeItemAtPath:path error:nil];
    }
}

- (void)cancelCurrentRecording{
    self.recorder.delegate = nil;
    if (self.recorder.recording) {
        [self.recorder stop];
    }
    self.recorder = nil;
    self.recordFinish = nil;
}

- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    return bCanRecord;
}

- (NSDictionary *)recordSetting{
    if (!_recordSetting) {
        _recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithFloat:8000.0],AVSampleRateKey,
                          [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                          [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                          [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                          nil];
        //初始化
        /**
         //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM 采用线性PCM编码来存储音乐信号，为非压缩方式
         AVNumberOfChannelsKey:声道数 通常为双声道 值2
         AVSampleRateKey：采样率 单位是HZ 通常设置成44100 44.1k
         AVLinearPCMBitDepthKey：比特率  8 16 32
         AVEncoderAudioQualityKey：声音质量 需要的参数是一个枚举 ：
         AVAudioQualityMin    最小的质量
         AVAudioQualityLow    比较低的质量
         AVAudioQualityMedium 中间的质量
         AVAudioQualityHigh   高的质量
         AVAudioQualityMax    最好的质量
         AVEncoderBitRateKey：音频的编码比特率 BPS传输速率 一般为128000bps
         */
    }
    return _recordSetting;
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                           successfully:(BOOL)flag
{
    NSString *recordPath = [[_recorder url] path];
    // 音频转换
    NSString *amrPath = [[recordPath stringByDeletingPathExtension] stringByAppendingPathExtension:GW_AmrType];
    //格式转换需要和安卓端商定
    [VoiceConverter ConvertWavToAmr:recordPath amrSavePath:amrPath];
    if (self.recordFinish) {
        if (!flag) {
            recordPath = nil;
        }
        self.recordFinish(recordPath);
    }
    self.recorder = nil;
    self.recordFinish = nil;
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
                                   error:(NSError *)error{
    GWLog(@"audioRecorderEncodeErrorDidOccur");
}


#pragma mark - Player

- (void)startPlayRecorder:(NSString *)recorderPath
{
    //    [self.player stop];
    //    self.player = nil;  // clear previous player
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;  // 加上这两句，否则声音会很小
    [audioSession setCategory :AVAudioSessionCategoryPlayback error:&err];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:recorderPath] error:nil];
    self.player.numberOfLoops = 0;
    [self.player prepareToPlay];
    self.player.delegate = self;
    [self.player play];
}

- (void)stopPlayRecorder:(NSString *)recorderPath
{
    [self.player stop];
    self.player = nil;
    self.player.delegate = nil;
}

- (void)pause
{
    [self.player pause];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag
{
    [self.player stop];
    self.player = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(voiceDidPlayFinished)]) {
        [self.delegate voiceDidPlayFinished];
    }
}





// 接收到的语音保存路径(文件以fileKey为名字)
- (NSString *)receiveVoicePathWithFileKey:(NSString *)fileKey
{
    return [self recorderPathWithFileName:fileKey];
}



// 获取语音时长
- (NSUInteger)durationWithVideo:(NSURL *)voiceUrl{
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:voiceUrl options:opts]; // 初始化视频媒体文件
    NSUInteger second = 0;
    second = urlAsset.duration.value / urlAsset.duration.timescale; // 获取视频总时长,单位秒
    return second;
}

@end
