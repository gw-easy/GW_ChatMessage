//
//  GW_MoreManager.m
//  GW_ChatMessage
//
//  Created by gw on 2018/5/4.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_CameraManager.h"
#import "GW_MoreItemModel.h"
#import "GW_FileManager.h"
static NSString *const videoPic = @"Chat/VideoPic";
static NSString *const arrowME = @"arrowME";
static NSString *const myPic = @"Chat/MyPic";
static NSString *const Deliver = @"Deliver";
@interface GW_CameraManager()
@property (nonatomic, strong) NSCache *videoImageCache;
@property (nonatomic, strong) NSCache *imageChacheMe;
@property (nonatomic, strong) NSCache *imageChacheYou;
@property (nonatomic, strong) NSCache *photoCache;
@property (strong, nonatomic) UIImage *failedImage;
@end
@implementation GW_CameraManager
+ (void)load{
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [GW_CameraManager shareManager];
    }];
}
static GW_CameraManager *base = nil;
+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        base = [[super allocWithZone:NULL] init];
    });
    return base;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [GW_CameraManager shareManager];
}

- (instancetype)init{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCaches) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        self.failedImage  = [UIImage imageNamed:@"icon_album_picture_fail_big"];
    }
    return self;
}

- (void)clearCaches{
    [self.videoImageCache removeAllObjects];
    [self.imageChacheMe removeAllObjects];
    [self.imageChacheYou removeAllObjects];
    [self.photoCache removeAllObjects];
}

// 使用文件名为key
- (UIImage *)imageWithLocalPath:(NSString *)localPath{
    if ([self.photoCache objectForKey:localPath.lastPathComponent]) {
        return [self.photoCache objectForKey:localPath.lastPathComponent];
    } else if (![localPath hasSuffix:@".png"]) {
        return nil;
    }
    UIImage *image = [UIImage imageWithContentsOfFile:localPath];
    if (image) {
        [self.photoCache setObject:image forKey:localPath.lastPathComponent];
    } else {
        image = _failedImage;
        [self.photoCache setObject:image forKey:localPath.lastPathComponent];
    }
    return image;
}

- (void)clearReuseImageMessage:(GW_ChatMessageModel *)message{
    NSString *path = message.mediaPath;
    NSString *videoPath = message.mediaPath;// 这是整个路径
    [self.photoCache removeObjectForKey:path.lastPathComponent];
    [self.imageChacheMe removeObjectForKey:path.lastPathComponent];
    [self.imageChacheYou removeObjectForKey:path.lastPathComponent];
    [self.videoImageCache removeObjectForKey:[[[videoPath stringByDeletingPathExtension] stringByAppendingPathExtension:videoPic] lastPathComponent]];
}

// get and save arrow image
- (UIImage *)arrowMeImage:(UIImage *)image
                     size:(CGSize)imageSize
                mediaPath:(NSString *)mediaPath
                 isSender:(BOOL)isSender{
    NSString *arrowPath = [self arrowMeImagePathWithOriginImagePath:mediaPath];
    if (!arrowPath) {
        return _failedImage;
    }
    if ([self.imageChacheMe objectForKey:arrowPath.lastPathComponent]) {
        return [self.imageChacheMe objectForKey:arrowPath.lastPathComponent];
    }
    UIImage *arrowImage = [UIImage imageWithContentsOfFile:arrowPath];
    if (arrowImage) {
        return arrowImage;
    }
    if ([image isEqual:_failedImage]) {
        return _failedImage;
    }
    arrowImage = [UIImage makeArrowImageWithSize:imageSize image:image isSender:isSender];
    [self.imageChacheMe setObject:arrowImage forKey:arrowPath.lastPathComponent];
    [self saveArrowMeImage:arrowImage withMediaPath:arrowPath.lastPathComponent];
    return arrowImage;
}

// me to you
- (NSString *)arrowMeImagePathWithOriginImagePath:(NSString  *)orgImgPath
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:arrowME];
    [self fileManagerWithPath:path];
    NSString *arrowPath = [path stringByAppendingPathComponent:orgImgPath.lastPathComponent];
    return arrowPath;
}

- (void)fileManagerWithPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirExist = [fileManager fileExistsAtPath:path];
    if (!isDirExist) {
        BOOL isCreateDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isCreateDir) {
            GWLog(@"create folder failed");
            return ;
        }
    }
}

- (void)saveArrowMeImage:(UIImage *)image
           withMediaPath:(NSString *)mediPath{
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:mediPath atomically:NO];
}

// 路径cache/MyPic
- (NSString *)createFolderPahtWithMainFolder:(NSString *)mainFolder
                                 childFolder:(NSString *)childFolder{
    NSString *path = [mainFolder stringByAppendingPathComponent:childFolder];
    [self fileManagerWithPath:path];
    return path;
}

// 使用文件名作为key
- (UIImage *)videoConverPhotoWithVideoPath:(NSString *)videoPath
                                      size:(CGSize)imageSize
                                  isSender:(BOOL)isSender{
    if (!videoPath){
        return nil;
    }
    NSString *trueFileName = [[[videoPath stringByDeletingPathExtension] stringByAppendingPathExtension:GW_PngType] lastPathComponent];
    if ([self.videoImageCache objectForKey:trueFileName]) {
        return [self.videoImageCache objectForKey:trueFileName];
    }
    UIImage *videoImg = [self videoImageWithFileName:trueFileName];
    if (videoImg) {
        UIImage *addImage = [UIImage addImage2:[UIImage imageNamed:@"App_video_play_btn_bg"] toImage:videoImg];
        [self.videoImageCache setObject:addImage forKey:trueFileName];
        return addImage;
    }
//    视频第一帧
    UIImage *thumbnailImage = [UIImage videoFramerateWithPath:videoPath];
//    绘制带有三角的图框
    UIImage *videoArrowImage = [UIImage makeArrowImageWithSize:imageSize image:thumbnailImage isSender:isSender];
//    将两个图片合并
    UIImage *resultImg = [UIImage addImage2:[UIImage imageNamed:@"App_video_play_btn_bg"] toImage:videoArrowImage];
    if (resultImg) {
        [self.videoImageCache setObject:resultImg forKey:trueFileName];
        [self saveVideoImage:resultImg fileName:trueFileName];
    }
    return resultImg;
}

- (NSString *)saveImage:(UIImage *)image{
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *chachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    // 图片名称
    NSString *fileName = [NSString stringWithFormat:@"%@%@",[NSString currentName],@".png"];
    NSString *mainFilePath = [self createFolderPahtWithMainFolder:chachePath childFolder:myPic];
    NSString *filePath = [mainFilePath stringByAppendingPathComponent:fileName];
    [imageData writeToFile:filePath atomically:NO];
    return filePath;
}

// 发送图片的地址
- (NSString *)sendImagePath:(NSString *)imgName{
    NSString *chachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [NSString stringWithFormat:@"%@",imgName];
    NSString *mainFilePath = [self createFolderPahtWithMainFolder:chachePath childFolder:myPic];
    NSString *filePath = [mainFilePath stringByAppendingPathComponent:fileName];
    return filePath;
    
}

/// 保存 video image 到沙盒
- (void)saveVideoImage:(UIImage *)image
              fileName:(NSString *)fileName{
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *chachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *mainFilePath = [self createFolderPahtWithMainFolder:chachePath childFolder:videoPic];
    NSString *filePath = [mainFilePath stringByAppendingPathComponent:fileName];
    [imageData writeToFile:filePath atomically:NO];
}

// 获取 videoImage 从沙盒
- (UIImage *)videoImageWithFileName:(NSString *)fileName{
    return [UIImage imageWithContentsOfFile:[self videoImagePath:fileName]];
}

- (NSString *)videoImagePath:(NSString *)fileName{
    NSString *path = [[GW_FileManager cacheDirectory] stringByAppendingPathComponent:videoPic];
    [self fileManagerWithPath:path];
    NSString *fullPath = [path stringByAppendingPathComponent:fileName];
    return fullPath;
}

// 保存接收到图片   fileKey-small.png
- (NSString *)receiveImagePathWithFileKey:(NSString *)fileKey
                                     type:(NSString *)type
{
    // 目前是png，以后说不定要改
    NSString *fileName = [NSString stringWithFormat:@"%@-%@%@",fileKey,type,@".png"];
    NSString *mainFilePath = [self createFolderPahtWithMainFolder:[GW_FileManager cacheDirectory] childFolder:myPic];
    return [mainFilePath stringByAppendingPathComponent:fileName];
}

// 通过名称获取我的图片路径
- (NSString *)imagePathWithName:(NSString *)imageName{
    return [[[GW_FileManager cacheDirectory] stringByAppendingPathComponent:myPic] stringByAppendingPathComponent:imageName];
}

// origin image 路径
- (NSString *)originImgPath:(GW_ChatMessageFrameModel *)messageF{
    return [self receiveImagePathWithFileKey:messageF.model.message.fileKey type:@"origin"];
}

// small image 路径
- (NSString *)smallImgPath:(NSString *)fileKey{
    return [self receiveImagePathWithFileKey:fileKey type:@"small"];
}

- (NSString *)delieveImagePath:(NSString *)fileKey{
    NSString *fileName = [NSString stringWithFormat:@"%@%@",fileKey,@".png"];
    NSString *mainFilePath = [self createFolderPahtWithMainFolder:[GW_FileManager cacheDirectory] childFolder:Deliver];
    return [mainFilePath stringByAppendingPathComponent:fileName];
}

- (NSString *)deliverFilePath:(NSString *)name
                         type:(NSString *)type{
    NSString *fileName = [NSString stringWithFormat:@"%@.%@",name,type];
    NSString *mainFilePath = [self createFolderPahtWithMainFolder:[GW_FileManager cacheDirectory] childFolder:Deliver];
    return [mainFilePath stringByAppendingPathComponent:fileName];
}

- (NSCache *)videoImageCache
{
    if (nil == _videoImageCache) {
        _videoImageCache = [[NSCache alloc] init];
    }
    return _videoImageCache;
}

- (NSCache *)imageChacheMe
{
    if (nil == _imageChacheMe) {
        _imageChacheMe = [[NSCache alloc] init];
    }
    return _imageChacheMe;
}

- (NSCache *)imageChacheYou
{
    if (nil == _imageChacheYou) {
        _imageChacheYou = [[NSCache alloc] init];
    }
    return _imageChacheYou;
}

- (NSCache *)photoCache
{
    if (nil == _photoCache) {
        _photoCache = [[NSCache alloc] init];
    }
    return _photoCache;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
