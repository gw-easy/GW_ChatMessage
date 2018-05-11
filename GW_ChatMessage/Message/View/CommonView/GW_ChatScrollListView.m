
//  GW_ChatScrollListView.m
//  GW_ChatMessage
//
//  Created by gw on 2018/5/3.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_ChatScrollListView.h"
#import "GW_FaceModel.h"
#import "GW_MoreItemModel.h"
#import "GW_FaceManager.h"
static const int maxRows = 3;
static const int maxCols = 7;
static const int picMaxRows = 2;
static const int picMaxCols = 4;
static const CGFloat pageHeight = 10;
static const CGFloat moreBtnMargic = 5;
static const CGFloat moreBtnTitleHeight = 30;
#define GW_EmotionPageSize(x,y) ((x * y) - 1)
#pragma mark --GW_EmotionBtn--
@interface GW_EmotionBtn:UIButton
@property (nonatomic, strong) GW_FaceModel *emotion;
@end
@implementation GW_EmotionBtn
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.titleLabel.font = [UIFont systemFontOfSize:32.0];
    self.adjustsImageWhenHighlighted = NO;
}

- (void)setEmotion:(GW_FaceModel *)emotion
{
    if (emotion.code) {
        [self setTitle:emotion.code.emoji forState:UIControlStateNormal];
    } else if (emotion.face_name) {
        NSString *path = @"";
        if ([emotion.face_name rangeOfString:@"ajmd"].location != NSNotFound) {
            path = [GW_FaceManager getAJMD_Face:emotion.face_name];
            [self setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
        }else if([emotion.face_name rangeOfString:@"lt"].location != NSNotFound){
            path = [GW_FaceManager getLT_Face:emotion.face_name];
            [self setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
        }else if([emotion.face_name rangeOfString:@"xxy"].location != NSNotFound){
            path = [GW_FaceManager getXXY_Face:emotion.face_name];
            [self setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
        }else{
            path = [GW_FaceManager getNormal_Face:emotion.face_name];
            [self setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
        }
        emotion.face_path = path;
    }
    _emotion = emotion;
}

@end

#pragma mark --GW_MoreViewItem--
@interface GW_MoreViewItem : UIButton
@property (strong, nonatomic) GW_MoreItemModel *itemModel;

@end
@implementation GW_MoreViewItem

- (void)setItemModel:(GW_MoreItemModel *)itemModel{
    _itemModel = itemModel;
    self.tag = itemModel.status;
    [self setTitle:itemModel.titleName forState:UIControlStateNormal];
    [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:itemModel.imageName] forState:UIControlStateNormal];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:15];
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(0, contentRect.size.height-moreBtnTitleHeight, contentRect.size.width,  moreBtnTitleHeight);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    return CGRectMake(moreBtnMargic, moreBtnMargic, contentRect.size.width-moreBtnMargic*2, contentRect.size.width-moreBtnMargic*2);
}

@end

#pragma mark --GW_ChatBoxFaceSingalPageView--
@interface GW_ChatBoxFaceSingalPageView:UIView
@property (strong, nonatomic) UIButton *deleteBtn;
@property (strong, nonatomic) NSArray *emotions;
@property (strong, nonatomic) NSArray *picEmotions;
@property (strong, nonatomic) NSArray *moreItem;
@property (assign, nonatomic) BOOL isPicPage;
@end
@implementation GW_ChatBoxFaceSingalPageView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.deleteBtn];
    }
    return self;
}

- (UIButton *)deleteBtn{
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setImage:[UIImage imageNamed:@"emotion_delete"] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

- (void)deleteBtnClicked:(UIButton *)btn{
    [[NSNotificationCenter defaultCenter] postNotificationName:GW_EmotionDidDeleteNotification object:nil];// 通知出去
}

- (void)setMoreItem:(NSArray *)moreItem{
    _moreItem = moreItem;
    NSUInteger count = moreItem.count;
    CGFloat inset = 15;
    CGFloat btnW = (self.width - 2*inset)/picMaxCols;
    CGFloat btnH = (self.height - 2*inset)/picMaxRows;
    for (int i = 0; i < count; i ++) {
        GW_MoreViewItem *button = [GW_MoreViewItem buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(inset + (i % picMaxCols)*btnW, inset + (i / picMaxCols)*btnH, btnW, btnH);
        [self addSubview:button];
        button.itemModel = moreItem[i];
        
        [button addTarget:self action:@selector(selectMoreItem:) forControlEvents:UIControlEventTouchUpInside];
        
    }
}

- (void)setEmotions:(NSArray *)emotions{
    _emotions = emotions;
    [self setEmotionBtnframe:emotions row:maxRows col:maxCols isDelete:YES];
}

- (void)setPicEmotions:(NSArray *)picEmotions{
    _picEmotions = picEmotions;
    [self setEmotionBtnframe:picEmotions row:picMaxRows col:picMaxCols isDelete:NO];
}

- (void)setEmotionBtnframe:(NSArray *)arr row:(int)row col:(int)col isDelete:(BOOL)isDelete{
    NSUInteger count = arr.count;
    CGFloat inset = 15;
    CGFloat btnW = (self.width - 2*inset)/col;
    CGFloat btnH = (self.height - 2*inset)/row;
    for (int i = 0; i < count; i ++) {
        GW_EmotionBtn *button = [[GW_EmotionBtn alloc] init];
        button.frame = CGRectMake(inset + (i % col)*btnW, inset + (i / col)*btnH, btnW, btnH);
        [self addSubview:button];
        button.emotion = arr[i];
        if (isDelete) {
            [button addTarget:self action:@selector(emotionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [button addTarget:self action:@selector(picEmotionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    if (!isDelete) {
        return;
    }
    self.deleteBtn.width = btnW;
    self.deleteBtn.height = btnH;
    self.deleteBtn.left = inset + (count%col)*btnW;
    self.deleteBtn.top = inset + (count/col)*btnH;
}

- (void)emotionBtnClicked:(GW_EmotionBtn *)button{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:button.emotion forKey:GW_SelectEmotionKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:GW_EmotionDidSelectNotification object:nil userInfo:userInfo];
}

- (void)picEmotionBtnClicked:(GW_EmotionBtn *)button{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:button.emotion forKey:GW_SelectEmotionKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:GW_PicEmotionDidSelectNotification object:nil userInfo:userInfo];
}

- (void)selectMoreItem:(GW_MoreViewItem *)item{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[GW_SelectMoreItemKey]  = item.itemModel;
    if (item.tag == GW_ChatBoxItemPhoto) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GW_MoreViewPhotoNotification object:nil userInfo:userInfo];
        GWLog(@"GW_ChatBoxItemAlbum");
    }else if (item.tag == GW_ChatBoxItemCamera){
        [[NSNotificationCenter defaultCenter] postNotificationName:GW_MoreViewCameraNotification object:nil userInfo:userInfo];
        GWLog(@"GW_ChatBoxItemCamera");
    }else if (item.tag == GW_ChatBoxItemVideo){
        [[NSNotificationCenter defaultCenter] postNotificationName:GW_MoreViewVideoNotification object:nil userInfo:userInfo];
        GWLog(@"GW_ChatBoxItemVideo");
    }else if (item.tag == GW_ChatBoxItemDoc){
        [[NSNotificationCenter defaultCenter] postNotificationName:GW_MoreViewDocNotification object:nil userInfo:userInfo];
        GWLog(@"GW_ChatBoxItemDoc");
    }
}

@end

@interface GW_ChatScrollListView()<UIScrollViewDelegate>

@end

@implementation GW_ChatScrollListView

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = ColorRGB(237, 237, 246);
        [self addSubview:self.topLine];
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
    }
    return self;
}

- (void)setMoreItem:(NSArray *)moreItem{
    _moreItem = moreItem;
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    CGFloat pageSize = GW_EmotionPageSize(picMaxRows, picMaxCols);
    NSUInteger count = (moreItem.count + pageSize - 1)/ pageSize;
    self.pageControl.numberOfPages  = count;
    for (int i = 0; i < count; i ++) {
        GW_ChatBoxFaceSingalPageView *pageView = [[GW_ChatBoxFaceSingalPageView alloc] initWithFrame:CGRectMake(i*self.scrollView.width, 0, self.scrollView.width, self.scrollView.height)];
        NSRange range;
        range.location = i * pageSize;
        NSUInteger left = moreItem.count - range.location;//剩余
        if (left >= pageSize) {
            range.length = pageSize;
        } else {
            range.length = left;
        }

        pageView.moreItem = [moreItem subarrayWithRange:range];

        [self.scrollView addSubview:pageView];
    }
    self.scrollView.contentSize = CGSizeMake(count*self.scrollView.width, self.scrollView.height);
}

- (void)setEmotions:(NSArray *)emotions{
    _emotions = emotions;
    [self setSingalPageframeArr:emotions row:maxRows col:maxCols isDelete:YES];
}

- (void)setPicEmotions:(NSArray *)picEmotions{
    _picEmotions = picEmotions;
    [self setSingalPageframeArr:picEmotions row:picMaxRows col:picMaxCols isDelete:NO];
}

- (void)setSingalPageframeArr:(NSArray *)arr row:(int)row col:(int)col isDelete:(BOOL)isDelete{
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    CGFloat pageSize = GW_EmotionPageSize(row, col);
    if (!isDelete) {
        pageSize = pageSize+1;
    }
    NSUInteger count = (arr.count + pageSize - 1)/ pageSize;
    self.pageControl.numberOfPages  = count;
    for (int i = 0; i < count; i ++) {
        GW_ChatBoxFaceSingalPageView *pageView = [[GW_ChatBoxFaceSingalPageView alloc] initWithFrame:CGRectMake(i*self.scrollView.width, 0, self.scrollView.width, self.scrollView.height)];
        NSRange range;
        range.location = i * pageSize;
        NSUInteger left = arr.count - range.location;//剩余
        if (left >= pageSize) {
            range.length = pageSize;
        } else {
            range.length = left;
        }
        if (isDelete) {
            pageView.emotions = [arr subarrayWithRange:range];
        }else{
            pageView.picEmotions = [arr subarrayWithRange:range];
        }
        
        [self.scrollView addSubview:pageView];
    }
    self.scrollView.contentSize = CGSizeMake(count*self.scrollView.width, self.scrollView.height);
}

- (void)scrollToTopAcrion{
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    self.pageControl.currentPage = 0;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height-pageHeight)];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setPagingEnabled:YES];
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.height-pageHeight, self.width, pageHeight)];
        _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}

- (UIView *)topLine
{
    if (!_topLine) {
        _topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width,TOP_LINE_HEIGHT)];
        _topLine.backgroundColor = ColorRGB(188.0, 188.0, 188.0);
    }
    return _topLine;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    double pageNum = scrollView.contentOffset.x/scrollView.width;
    self.pageControl.currentPage  = (int)(pageNum+0.5);
}

@end
