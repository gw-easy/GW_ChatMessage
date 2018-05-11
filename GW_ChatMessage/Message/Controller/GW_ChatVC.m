//
//  GW_ChatVC.m
//  GW_ChatMessage
//
//  Created by gw on 2018/4/20.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_ChatVC.h"
#import "GW_MessageManager.h"
#import "GW_ChatView.h"
#import "GW_ChatTBView.h"
#import "GW_ChatMessageFrameModel.h"
#import "GW_MessageManager.h"
#import "GW_CameraManager.h"
#import "GW_PhotoBrowserVC.h"

@interface GW_ChatVC ()<GW_ChatViewDelegate,UIViewControllerTransitioningDelegate,UIViewControllerAnimatedTransitioning>
@property (nonatomic, strong) GW_ChatView *chatBox;
/** 数据源 */
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UITextView *textView;
@property (assign, nonatomic) bool isKeyBoardAppear; // 键盘是否弹出来了
@property (nonatomic, assign)  BOOL presentFlag;  // 是否model出控制器
@property (nonatomic, strong) UIImageView *presentImageView;
@property (strong, nonatomic) NSDictionary *userInfoDict;//通知信息
@end

@implementation GW_ChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.group.gName;
    [self setupUI];

//    self.navigationController.navigationBarHidden = YES;
    [self addNotification];
}

- (void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPic:) name:GW_PicSeleceClictNotification object:nil];
}

- (void)setupUI{
    self.view.backgroundColor = ColorRGB(240, 237, 237);
    // 注意添加顺序
    [self.view addSubview:self.chatBox];
}





- (void)selectPic:(NSNotification *)noti{
    self.userInfoDict = noti.userInfo;
    
    [self showLargeImageWithPath:self.userInfoDict[GW_PicSeleceClictPathKey] withMessageF:self.userInfoDict[GW_PicMessageFrameModelKey]];
}

// tap image
- (void)showLargeImageWithPath:(NSString *)imgPath
                  withMessageF:(GW_ChatMessageFrameModel *)messageF
{
    UIImage *image = [[GW_CameraManager shareManager] imageWithLocalPath:imgPath];
    if (image == nil) {
        GWLog(@"image is not existed");
        return;
    }
    GW_PhotoBrowserVC *photoVC = [[GW_PhotoBrowserVC alloc] initWithImage:image];
    self.presentImageView.image       = image;
    photoVC.transitioningDelegate     = self;
    photoVC.modalPresentationStyle    = UIModalPresentationCustom;
    [self presentViewController:photoVC animated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    self.presentFlag = YES;
    return self;
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.presentFlag = NO;
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (self.presentFlag) {
        UIView *toView              = [transitionContext viewForKey:UITransitionContextToViewKey];
        self.presentImageView.frame = [self.userInfoDict[GW_PicSelectSmallValueKey] CGRectValue];
        [[transitionContext containerView] addSubview:self.presentImageView];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            self.presentImageView.frame = [self.userInfoDict[GW_PicSelectBigValueKey] CGRectValue];
        } completion:^(BOOL finished) {
            if (finished) {
                [self.presentImageView removeFromSuperview];
                [[transitionContext containerView] addSubview:toView];
                [transitionContext completeTransition:YES];
            }
        }];
    } else {
        GW_PhotoBrowserVC *photoVC = (GW_PhotoBrowserVC *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIImageView *iv     = photoVC.imageView;
        UIView *fromView    = [transitionContext viewForKey:UITransitionContextFromViewKey];
        iv.center = fromView.center;
        [fromView removeFromSuperview];
        [[transitionContext containerView] addSubview:iv];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            iv.frame = [self.userInfoDict[GW_PicSelectSmallValueKey] CGRectValue];
        } completion:^(BOOL finished) {
            if (finished) {
                [iv removeFromSuperview];
                [transitionContext completeTransition:YES];
            }
        }];
    }
}

- (UIImageView *)presentImageView{
    if (!_presentImageView) {
        _presentImageView = [[UIImageView alloc] init];
    }
    return _presentImageView;
}

- (GW_ChatView *)chatBox
{
    if (_chatBox == nil) {
        _chatBox = [[GW_ChatView alloc] initWithFrame:CGRectMake(0, HEIGHT_NAVBAR+HEIGHT_STATUSBAR, SCREENWIDTH, SCREENHEIGHT-HEIGHT_NAVBAR-HEIGHT_STATUSBAR)];
        _chatBox.backgroundColor = [UIColor greenColor];
        _chatBox.delegate = self;
    }
    return _chatBox;
}


- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
