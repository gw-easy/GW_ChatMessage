//
//  GW_AVPlayOpertion.h
//  GW_ChatMessage
//
//  Created by gw on 2018/5/7.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 视频文件解析回调
 @param ref 视频每帧截图的CGImageRef图像信息
 @param filePath 视频路径地址
 */
typedef void(^videoEveryImageRef)(NSString *filePath,UIImage *ref);
/**
 视频停止播放
 @param filePath 视频路径地址
 */
typedef void(^videoStop)(NSString *filePath);
@interface GW_AVPlayOpertion : NSBlockOperation

@property (copy, nonatomic) videoEveryImageRef refBlock;
@property (copy, nonatomic) videoStop stopBlock;


/**
 开始获取视频每一帧图像

 @param filePath 视频路径
 */
-(void)videoPlayTask:(NSString *)filePath;
@end
