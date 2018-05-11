//
//  GW_FaceManager.m
//  GW_ChatMessage
//
//  Created by gw on 2018/4/20.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_FaceManager.h"
#import "GW_FaceModel.h"
#define GW_FaceManagerShare [GW_FaceManager shareManager]
static NSString *const gw_demoListBundle = @"GW_DemoChartlet.bundle";
static NSString *const gw_normalListBundle = @"GW_Normal_face.bundle";

@interface GW_FaceManager()
@property (strong, nonatomic) NSArray *emojiEmotions;
@property (strong, nonatomic) NSArray *custumEmotions;
@property (strong, nonatomic) NSArray *gifEmotions;
@property (strong, nonatomic) NSArray *AJMDEmotions;
@property (strong, nonatomic) NSArray *LTEmotions;
@property (strong, nonatomic) NSArray *XXYEmotions;
@property (assign, nonatomic) CGFloat faceListViewWidth;
@end
@implementation GW_FaceManager
+ (void)load{
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [GW_FaceManager shareManager];
    }];
}

static GW_FaceManager *face = nil;
+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       face = [[super allocWithZone:NULL] init];
    });
    return face;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return GW_FaceManagerShare;
}

- (instancetype)init{
    if (self = [super init]) {
        self.faceListViewWidth = SCREENWIDTH;
        [self emojiListView];
        [self custumListView];
        [self ajmdListView];
        [self ltListView];
        [self xxyListView];
    }
    return self;
}

+ (NSString *)getNormal_Face:(NSString *)faceName{
    return [self getPathImage:[NSString stringWithFormat:@"%@@2x.png",faceName] dir:@"face_image"];
}

+ (NSString *)getAJMD_Face:(NSString *)faceName{
    return [self getPathImage:[NSString stringWithFormat:@"%@@2x.png",faceName] dir:@"ajmd"];
}

+ (NSString *)getLT_Face:(NSString *)faceName{
    return [self getPathImage:[NSString stringWithFormat:@"%@@2x.png",faceName] dir:@"lt"];
}

+ (NSString *)getXXY_Face:(NSString *)faceName{
    return [self getPathImage:[NSString stringWithFormat:@"%@@2x.png",faceName] dir:@"xxy"];
}


+ (NSString *)getPathImage:(NSString *)faceName dir:(NSString *)dir{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"GW_DemoChartlet.bundle" ofType:nil];
    NSBundle *normalBundle = [NSBundle bundleWithPath:path];
    path = [normalBundle pathForResource:faceName ofType:nil inDirectory:[NSString stringWithFormat:@"%@/content",dir]];
    return path;
}

- (GW_ChatScrollListView *)emojiListView{
    if (!_emojiListView) {
        _emojiListView = [[GW_ChatScrollListView alloc] initWithFrame:CGRectMake(0, 0, self.faceListViewWidth, HEIGHT_CHATBOXVIEWSHOW-menuHeight)];
        _emojiListView.emotions = self.emojiEmotions;
    }
    return _emojiListView;
}

- (GW_ChatScrollListView *)custumListView{
    if (!_custumListView) {
        _custumListView = [[GW_ChatScrollListView alloc] initWithFrame:CGRectMake(0, 0, self.faceListViewWidth, HEIGHT_CHATBOXVIEWSHOW-menuHeight)];
        _custumListView.emotions = self.custumEmotions;
        _custumListView.hidden = YES;
    }
    return _custumListView;
}

- (GW_ChatScrollListView *)ajmdListView{
    if (!_ajmdListView) {
        _ajmdListView = [[GW_ChatScrollListView alloc] initWithFrame:CGRectMake(0, 0, self.faceListViewWidth, HEIGHT_CHATBOXVIEWSHOW-menuHeight)];
        _ajmdListView.picEmotions = self.AJMDEmotions;
        _ajmdListView.hidden = YES;
    }
    return _ajmdListView;
}

- (GW_ChatScrollListView *)ltListView{
    if (!_ltListView) {
        _ltListView = [[GW_ChatScrollListView alloc] initWithFrame:CGRectMake(0, 0, self.faceListViewWidth, HEIGHT_CHATBOXVIEWSHOW-menuHeight)];
        _ltListView.picEmotions = self.LTEmotions;
        _ltListView.hidden = YES;
    }
    return _ltListView;
}
- (GW_ChatScrollListView *)xxyListView{
    if (!_xxyListView) {
        _xxyListView = [[GW_ChatScrollListView alloc] initWithFrame:CGRectMake(0, 0, self.faceListViewWidth, HEIGHT_CHATBOXVIEWSHOW-menuHeight)];
        _xxyListView.picEmotions = self.XXYEmotions;
        _xxyListView.hidden = YES;
    }
    return _xxyListView;
}

- (NSArray *)emojiEmotions{
    if (!_emojiEmotions) {
        NSString *path  = [[NSBundle mainBundle] pathForResource:@"emoji.plist" ofType:nil];
        _emojiEmotions  = [GW_FaceModel GW_JsonToModel:[NSArray arrayWithContentsOfFile:path]];
    }
    return _emojiEmotions;
}



- (NSArray *)custumEmotions{
    if (!_custumEmotions) {
        NSString *path = [self emotionsPathBundle:gw_demoListBundle fileName:@"normal_face.plist" isdic:@"face_image"];
        _custumEmotions = [GW_FaceModel GW_JsonToModel:[NSArray arrayWithContentsOfFile:path]];
    }
    return _custumEmotions;
}



- (NSArray *)gifEmotion{
    if (!_gifEmotions) {
        
    }
    return _gifEmotions;
}

- (NSArray *)AJMDEmotions{
    if (!_AJMDEmotions) {
        NSString *path = [self emotionsPathBundle:gw_demoListBundle fileName:@"ajmd_list.plist" isdic:@"ajmd"];
        _AJMDEmotions = [GW_FaceModel GW_JsonToModel:[NSArray arrayWithContentsOfFile:path]];
    }
    return _AJMDEmotions;
}

- (NSArray *)LTEmotions{
    if (!_LTEmotions) {
        NSString *path = [self emotionsPathBundle:gw_demoListBundle fileName:@"lt_list.plist" isdic:@"lt"];
        _LTEmotions = [GW_FaceModel GW_JsonToModel:[NSArray arrayWithContentsOfFile:path]];
    }
    return _LTEmotions;
}


- (NSArray *)XXYEmotions{
    if (!_XXYEmotions) {
        NSString *path = [self emotionsPathBundle:gw_demoListBundle fileName:@"xxy_list.plist" isdic:@"xxy"];
        _XXYEmotions = [GW_FaceModel GW_JsonToModel:[NSArray arrayWithContentsOfFile:path]];
    }
    return _XXYEmotions;
}


- (NSString *)emotionsPathBundle:(NSString *)bundleName fileName:(NSString *)fileName isdic:(NSString *)isdic{
    NSString *path  = [[NSBundle mainBundle] pathForResource:bundleName ofType:nil];
    if (isdic && isdic.length>0) {
        path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/",isdic]];
    }
    path = [path stringByAppendingPathComponent:fileName];
//    NSBundle *normalBundle = [NSBundle bundleWithPath:path];
//    path = [normalBundle pathForResource:fileName ofType:nil];
    return path;
}

+ (NSMutableAttributedString *)transferMessageString:(NSString *)message
                                                font:(UIFont *)font
                                          lineHeight:(CGFloat)lineHeight
{
    NSMutableAttributedString *attributeStr
    = [[NSMutableAttributedString alloc] initWithString:message];
    NSString *regEmj  = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]";// [微笑]、［哭］等自定义表情处理
    NSError *error    = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regEmj options:NSRegularExpressionCaseInsensitive error:&error];
    if (!expression) {
        GWLog(@"%@",error);
        return attributeStr;
    }
    [attributeStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attributeStr.length)];
    NSArray *resultArray = [expression matchesInString:message options:0 range:NSMakeRange(0, message.length)];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    for (NSTextCheckingResult *match in resultArray) {
        NSRange range    = match.range;
        NSString *subStr = [message substringWithRange:range];
        NSArray *faceArr = GW_FaceManagerShare.custumEmotions;
        for (GW_FaceModel *face in faceArr) {
            if ([face.face_name isEqualToString:subStr]) {
                NSTextAttachment *attach  = [[NSTextAttachment alloc] init];
                attach.image = [UIImage imageWithContentsOfFile:[GW_FaceManager getNormal_Face:face.face_name]];
                // 位置调整Y值就行
                attach.bounds = CGRectMake(0, -4, lineHeight+2, lineHeight+2);
                NSAttributedString *imgStr = [NSAttributedString attributedStringWithAttachment:attach];
                NSMutableDictionary *imagDic   = [NSMutableDictionary dictionaryWithCapacity:2];
                [imagDic setObject:imgStr forKey:@"image"];
                [imagDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                [mutableArray addObject:imagDic];
            }
        }
    }
    for (int i =(int) mutableArray.count - 1; i >= 0; i --) {
        NSRange range;
        [mutableArray[i][@"range"] getValue:&range];
        [attributeStr replaceCharactersInRange:range withAttributedString:mutableArray[i][@"image"]];
    }
    return attributeStr;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
