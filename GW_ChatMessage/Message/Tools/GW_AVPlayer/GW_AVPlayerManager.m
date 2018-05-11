//
//  GW_AVPlayerManager.m
//  GW_ChatMessage
//
//  Created by gw on 2018/5/7.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_AVPlayerManager.h"

@interface GW_AVPlayerManager()

@end
@implementation GW_AVPlayerManager
static GW_AVPlayerManager *base = nil;
+ (instancetype)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        base = [[super allocWithZone:NULL] init];
    });
    return base;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [GW_AVPlayerManager sharedManager];
}

- (instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)startPlayVideo:(NSString *)filePath withVideoDecode:(videoEveryImageRef)videoDecode{
    [self checkVideoPath:filePath withBlock:videoDecode];
}

- (GW_AVPlayOpertion *)checkVideoPath:(NSString *)filePath withBlock:(videoEveryImageRef)videoBlock{
    //初始化了一个自定义的NSBlockOperation对象，它是用一个Block来封装需要执行的操作
    GW_AVPlayOpertion *videoOpertion;
    //如果这个视频已经在播放，就先取消它，再次进行播放
    [self cancelVideo:filePath];
    
    videoOpertion = [[GW_AVPlayOpertion alloc] init];
    __weak GW_AVPlayOpertion *weakVideoOpertion = videoOpertion;
    videoOpertion.refBlock = videoBlock;
    //并发执行一个视频操作任务
    [videoOpertion addExecutionBlock:^{
        [weakVideoOpertion videoPlayTask:filePath];
    }];
    //执行完毕后停止操作
    [videoOpertion setCompletionBlock:^{
        //从视频操作字典里面异常这个Operation
        [self.videoOperationDict removeObjectForKey:filePath];
        //属性停止回调
        if (weakVideoOpertion.stopBlock) {
            weakVideoOpertion.stopBlock(filePath);
        }
    }];
    //将这个Operation操作加入到视频操作字典内
    [self.videoOperationDict setObject:videoOpertion forKey:filePath];
    //add之后就执行操作
    [self.videoOperationQueue addOperation:videoOpertion];
    return videoOpertion;
}

- (void)reloadVideoPlay:(videoStop)videoStop withFilePath:(NSString *)filePath{
    GW_AVPlayOpertion *videoOperation;
    if (self.videoOperationDict[filePath]) {
        videoOperation = self.videoOperationDict[filePath];
        videoOperation.stopBlock = videoStop;
    }
}

- (void)cancelVideo:(NSString *)filePath{
    GW_AVPlayOpertion *videoOperation;
    //如果所有视频操作字典内存在这个视频操作，取出这个操作
    if (self.videoOperationDict[filePath]) {
        videoOperation = self.videoOperationDict[filePath];
        if (videoOperation.isCancelled) {
            return;
        }
        //操作完不做任何事
        [videoOperation setCompletionBlock:nil];
        videoOperation.stopBlock = nil;
        videoOperation.refBlock = nil;
        [videoOperation cancel];
        if (videoOperation.isCancelled) {
            //从视频操作字典里面异常这个Operation
            [self.videoOperationDict removeObjectForKey:filePath];
        }
    }
}

-(void)cancelAllVideo
{
    if (self.videoOperationQueue) {
        //根据视频地址这个key来取消所有Operation
        NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:self.videoOperationDict];
        for (NSString *key in tempDict) {
            [self cancelVideo:key];
        }
        [self.videoOperationDict removeAllObjects];
        [self.videoOperationQueue cancelAllOperations];
    }
}

- (NSMutableDictionary *)videoOperationDict{
    if (!_videoOperationDict) {
        _videoOperationDict = [[NSMutableDictionary alloc] init];
    }
    return _videoOperationDict;
}

- (NSOperationQueue *)videoOperationQueue{
    if (!_videoOperationQueue) {
        _videoOperationQueue = [[NSOperationQueue alloc] init];
        _videoOperationQueue.maxConcurrentOperationCount = 1000;
    }
    return _videoOperationQueue;
}

@end
