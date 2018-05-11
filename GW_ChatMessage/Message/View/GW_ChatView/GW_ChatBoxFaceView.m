//
//  GW_ChatBoxFaceView.m
//  GW_ChatMessage
//
//  Created by gw on 2018/4/24.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_ChatBoxFaceView.h"
#import "GW_FaceManager.h"
#import "GW_FaceModel.h"
#import "GW_ChatScrollListView.h"
static const CGFloat BtnWight = 60;

#pragma mark --GW_ChatBoxFaceMenuView--
@interface GW_ChatBoxFaceMenuView:UIView
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIButton *sendBtn;

@property (strong, nonatomic) UIButton *selectedBtn;
@property (copy, nonatomic) void (^getBtnTag)(NSInteger tag);


@end
@implementation GW_ChatBoxFaceMenuView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.scrollView];
        [self addSubview:self.sendBtn];
        [self setupBtn:[@"0x1f603" emoji] buttonType:GW_EmotionMenuButtonTypeEmoji isTitle:YES];
        [self setupBtn:@"" buttonType:GW_EmotionMenuButtonTypeCuston isTitle:NO];
        [self setupBtn:@"" buttonType:GW_EmotionMenuButtonTypeAJMD isTitle:NO];
        [self setupBtn:@"" buttonType:GW_EmotionMenuButtonTypeLT isTitle:NO];
        [self setupBtn:@"" buttonType:GW_EmotionMenuButtonTypeXXY isTitle:NO];
        //        [self setupBtn:@"Gif" buttonType:ICEmotionMenuButtonTypeGif];
        for (int i = 0; i < self.scrollView.subviews.count; i ++) {
            UIButton *btn = self.scrollView.subviews[i];
            btn.frame = CGRectMake(BtnWight*i, 0, BtnWight, self.height);
        }
        self.scrollView.contentSize = CGSizeMake(self.scrollView.subviews.count*BtnWight, self.height);
    }
    return self;
}

- (UIButton *)setupBtn:(NSString *)title
            buttonType:(GW_EmotionMenuButtonType)buttonType isTitle:(BOOL)isTitle{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchDown];
    btn.tag = buttonType; // 不要把0作为tag值

    if (isTitle) {
        [btn setTitle:title forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:26.5];
    }else{
        [btn setImage:[self getMenuImage:buttonType] forState:UIControlStateNormal];
    }

    [self.scrollView addSubview:btn];
    [btn setBackgroundImage:[UIImage draw_imageWithColor:[UIColor whiteColor]]forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage draw_imageWithColor:ColorRGB(241, 241, 244)] forState:UIControlStateSelected];
    if (buttonType == GW_EmotionMenuButtonTypeEmoji) {
        [self btnClicked:btn];
    }
    return btn;
}

- (UIImage *)getMenuImage:(GW_EmotionMenuButtonType)type{
    switch (type) {
        case GW_EmotionMenuButtonTypeCuston:
            return [UIImage imageWithContentsOfFile:[GW_FaceManager getNormal_Face:@"[吓～]"]];
            break;
        case GW_EmotionMenuButtonTypeAJMD:
            return [UIImage imageWithContentsOfFile:[GW_FaceManager getAJMD_Face:@"ajmd_s_highlighted"]];
            break;
        case GW_EmotionMenuButtonTypeLT:
            return [UIImage imageWithContentsOfFile:[GW_FaceManager getLT_Face:@"lt_s_highlighted"]];
            break;
        case GW_EmotionMenuButtonTypeXXY:
            return [UIImage imageWithContentsOfFile:[GW_FaceManager getXXY_Face:@"xxy_s_highlighted"]];
            break;
        case GW_EmotionMenuButtonTypeGif:
            
            break;
        case GW_EmotionMenuButtonTypeNothing:
            
            break;
        case GW_EmotionMenuButtonTypeEmoji:
            
            break;
    }
    return nil;
}

- (void)sendBtnClicked:(UIButton *)sendBtn{
    [[NSNotificationCenter defaultCenter] postNotificationName:GW_EmotionDidSendNotification object:nil];
}

- (void)btnClicked:(UIButton *)button{
    self.selectedBtn.selected = NO;
    button.selected           = YES;
    self.selectedBtn         = button;
    if (self.getBtnTag) {
        self.getBtnTag(button.tag);
    }
}



- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width-BtnWight, self.height)];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setScrollsToTop:NO];
        [_scrollView setBackgroundColor:[UIColor whiteColor]];
    }
    return _scrollView;
}

- (UIButton *)sendBtn
{
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.frame = CGRectMake(self.width-BtnWight, 0, BtnWight, self.height);
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_sendBtn setBackgroundColor:[UIColor colorWithRed:0.1 green:0.4 blue:0.8 alpha:1.0]];
        [_sendBtn addTarget:self action:@selector(sendBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"GW_ChatBoxFaceMenuView");
}
@end

#pragma mark --GW_ChatBoxFaceView--
@interface GW_ChatBoxFaceView()
@property (assign, nonatomic) GW_EmotionMenuButtonType oldType;
@property (strong, nonatomic) GW_ChatScrollListView *emojiListView;
@property (strong, nonatomic) GW_ChatScrollListView *custumListView;
@property (strong, nonatomic) GW_ChatScrollListView *gifListView;
@property (strong, nonatomic) GW_ChatScrollListView *ajmdListView;
@property (strong, nonatomic) GW_ChatScrollListView *ltListView;
@property (strong, nonatomic) GW_ChatScrollListView *xxyListView;
@property (strong, nonatomic) GW_ChatBoxFaceMenuView *menuView;
@end

@implementation GW_ChatBoxFaceView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.oldType = GW_EmotionMenuButtonTypeNothing;
        GW_FaceManager *faceM = [GW_FaceManager shareManager];
        self.emojiListView = faceM.emojiListView;
        self.custumListView = faceM.custumListView;
        self.ajmdListView = faceM.ajmdListView;
        self.ltListView = faceM.ltListView;
        self.xxyListView = faceM.xxyListView;
        
        [self addSubview:self.emojiListView];
        [self addSubview:self.custumListView];
        [self addSubview:self.ajmdListView];
        [self addSubview:self.ltListView];
        [self addSubview:self.xxyListView];
        [self addSubview:self.menuView];
        [self blockAction];
        // 如果表情选中的时候需要动画或者其它操作,则在这里监听通知
        
    }
    return self;
}

- (GW_ChatBoxFaceMenuView *)menuView{
    if (!_menuView) {
        _menuView = [[GW_ChatBoxFaceMenuView alloc] initWithFrame:CGRectMake(0, self.height-menuHeight, self.width, menuHeight)];
    }
    return _menuView;
}

- (void)blockAction{
    WS(weakSelf)
    self.menuView.getBtnTag = ^(NSInteger tag) {
        if (weakSelf.oldType == GW_EmotionMenuButtonTypeNothing) {
            weakSelf.oldType = tag;
        }
        switch (tag) {
            case GW_EmotionMenuButtonTypeEmoji:{
                [weakSelf showListView:weakSelf.emojiListView tag:weakSelf.oldType];
            }
                break;
            case GW_EmotionMenuButtonTypeCuston:{
                [weakSelf showListView:weakSelf.custumListView tag:weakSelf.oldType];
            }
                break;
            case GW_EmotionMenuButtonTypeGif:{
                
            }
                break;
            case GW_EmotionMenuButtonTypeAJMD:{
                [weakSelf showListView:weakSelf.ajmdListView tag:weakSelf.oldType];
            }
                break;
            case GW_EmotionMenuButtonTypeLT:{
                [weakSelf showListView:weakSelf.ltListView tag:weakSelf.oldType];
            }
                break;
            case GW_EmotionMenuButtonTypeXXY:{
                [weakSelf showListView:weakSelf.xxyListView tag:weakSelf.oldType];
            }
                break;
                
            default:
                break;
        }
        weakSelf.oldType = tag;
    };
}


- (void)showListView:(GW_ChatScrollListView *)listView tag:(GW_EmotionMenuButtonType)tag{
    switch (tag) {
        case GW_EmotionMenuButtonTypeEmoji:{
            self.emojiListView.hidden = YES;
            [self.emojiListView scrollToTopAcrion];
        }
            break;
        case GW_EmotionMenuButtonTypeCuston:{
            self.custumListView.hidden = YES;
            [self.custumListView scrollToTopAcrion];
        }
            break;
        case GW_EmotionMenuButtonTypeGif:{
            
        }
            break;
        case GW_EmotionMenuButtonTypeAJMD:{
            self.ajmdListView.hidden = YES;
            [self.ajmdListView scrollToTopAcrion];
        }
            break;
        case GW_EmotionMenuButtonTypeLT:{
            self.ltListView.hidden = YES;
            [self.ltListView scrollToTopAcrion];
        }
            break;
        case GW_EmotionMenuButtonTypeXXY:{
            self.xxyListView.hidden = YES;
            [self.xxyListView scrollToTopAcrion];
        }
            break;
        default:
            break;
    }
    listView.hidden = NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"GW_ChatFaceView");
}

- (void)dealloc{
    GWLog(@"GW_ChatBoxFaceView");
}
@end

