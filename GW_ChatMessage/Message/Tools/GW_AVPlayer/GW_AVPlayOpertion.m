//
//  GW_AVPlayOpertion.m
//  GW_ChatMessage
//
//  Created by gw on 2018/5/7.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_AVPlayOpertion.h"

@implementation GW_AVPlayOpertion

- (void)videoPlayTask:(NSString *)filePath{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:filePath] options:nil];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    //如果AVAssetTrack信息为空，直接返回
    if (!tracks || tracks.count==0) {
        GWLog(@"没有视频信息");
        return;
    }
    AVAssetTrack *track = [tracks objectAtIndex:0];
    NSError *error;
    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:asset error:&error];
    UIImageOrientation orientation = [self orientationFromAVAssetTrack:track];
    int m_pixelFormatType = kCVPixelFormatType_32BGRA;
    NSDictionary *option = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt: (int)m_pixelFormatType] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    //获取输出端口AVAssetReaderTrackOutput
    AVAssetReaderTrackOutput *trackOut = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:option];
    //添加输出端口
    [reader addOutput:trackOut];
    //    开启阅读器
    [reader startReading];
    //确保nominalFrameRate帧速率 > 0，碰到过坑爹的安卓拍出来0帧的视频
    //同时确保当前Operation操作没有取消,reader状态为读取
    while (reader.status == AVAssetReaderStatusReading && !self.isCancelled && track.nominalFrameRate>0 && self.refBlock) {
        CMSampleBufferRef bufferRef = [trackOut copyNextSampleBuffer];
        if (!bufferRef) {
            GWLog(@"没有视频帧信息");
            return;
        }
        

        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.refBlock) {
                self.refBlock(filePath, [self imageRefFormSampleBuffer:bufferRef orientation:orientation]);
            }
            if (bufferRef) {
                CFRelease(bufferRef);
            }
            
        });
        [NSThread sleepForTimeInterval:CMTimeGetSeconds(track.minFrameDuration)];
    }
    [reader cancelReading];
}

- (UIImageOrientation)orientationFromAVAssetTrack:(AVAssetTrack *)videoTrack
{
    UIImageOrientation orientation = UIImageOrientationUp;
    
    CGAffineTransform t = videoTrack.preferredTransform;
    if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
        // Portrait
        //        degress = 90;
        orientation = UIImageOrientationRight;
    }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
        // PortraitUpsideDown
        //        degress = 270;
        orientation = UIImageOrientationLeft;
    }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
        // LandscapeRight
        //        degress = 0;
        orientation = UIImageOrientationUp;
    }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
        // LandscapeLeft
        //        degress = 180;
        orientation = UIImageOrientationDown;
    }
    
    return orientation;
}

- (UIImage *)imageRefFormSampleBuffer:(CMSampleBufferRef)sampleBufferRef orientation:(UIImageOrientation)orientation{
    CVImageBufferRef imageBufRef = CMSampleBufferGetImageBuffer(sampleBufferRef);
//    锁住imageRef的地址
    CVPixelBufferLockBaseAddress(imageBufRef, 0);
    size_t perRow = CVPixelBufferGetBytesPerRow(imageBufRef);
    size_t width = CVPixelBufferGetWidth(imageBufRef);
    size_t height = CVPixelBufferGetHeight(imageBufRef);
    //获取imageRef的地址
    unsigned char *pixelAddr =  (unsigned char *)CVPixelBufferGetBaseAddress(imageBufRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //data: 创建BitmapContext所需的内存空间，由malloc创建
//    　width: 图片的宽度
//    　height: 图片的高度
//    　bitsPerComponent: data中的每个数据所占的字节数
//    　bytesPerRow: 图片每行的位数 = 图片列数＊4(因为每个点有4个通道)
//    　space: 颜色区间
//    　bitmapInfo: bitmap类型，一般选择PremultipliedFirst(ARGB)

    CGContextRef context = CGBitmapContextCreate(pixelAddr, width, height, 8, perRow, colorSpace, kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedFirst);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBufRef, 0);
    UIGraphicsEndImageContext();
    //设置图片位置信息
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:0 orientation:orientation];
    
    if (imageRef) {
        CGImageRelease(imageRef);
    }
    return image;
}

@end
