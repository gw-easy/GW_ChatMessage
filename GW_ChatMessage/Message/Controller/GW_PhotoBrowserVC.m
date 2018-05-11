//
//  GW_PhotoBrowserVC.m
//  GW_ChatMessage
//
//  Created by gw on 2018/5/8.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_PhotoBrowserVC.h"

@interface GW_PhotoBrowserVC ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;

// 缩放比例
@property (nonatomic, assign) int scale;
@end

@implementation GW_PhotoBrowserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scale = 2;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureTapAction:)];
    tap.numberOfTapsRequired    = 1;
    [self.imageView addGestureRecognizer:tap];
    
    UITapGestureRecognizer *twiceTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureTwiceAction:)];
    twiceTap.numberOfTapsRequired    = 2;
    [self.imageView addGestureRecognizer:twiceTap];
    
    // 如果确认双击手势失败后才执行单击手势
    [tap requireGestureRecognizerToFail:twiceTap];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureLongAction:)];
    [self.imageView addGestureRecognizer:longGesture];
}

- (void)gestureTapAction:(UITapGestureRecognizer *)gesture{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)gestureTwiceAction:(UITapGestureRecognizer *)gesture{
    [UIView animateWithDuration:0.5 animations:^{
        self.imageView.transform = CGAffineTransformMakeScale(self.scale, self.scale);
    }];
    self.scale = self.scale == 1 ? 2:1;
    UIEdgeInsets insets = self.scrollView.contentInset;
    CGFloat appHeight   = [UIScreen mainScreen].bounds.size.height;
    if (self.imageView.height > appHeight) {
        CGFloat margin = (self.imageView.height - appHeight)*0.5;
        self.scrollView.contentInset = UIEdgeInsetsMake(margin, self.imageView.width/4.0, margin, self.imageView.width/4.0);
    } else {
        self.scrollView.contentInset = UIEdgeInsetsMake(insets.top, self.imageView.width/4.0, insets.bottom, self.imageView.width/4.0);
    }
}

- (void)gestureLongAction:(UILongPressGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UIAlertController *alVC = [UIAlertController alertControllerWithTitle:@"您是要保存图片吗" message:nil preferredStyle:0];
        UIAlertAction *alAction = [UIAlertAction actionWithTitle:@"保存" style:0 handler:^(UIAlertAction * _Nonnull action) {
            UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }];
        UIAlertAction *cancelAc = [UIAlertAction actionWithTitle:@"取消" style:0 handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alVC addAction:alAction];
        [alVC addAction:cancelAc];
        [self presentViewController:alVC animated:YES completion:^{
            
        }];
    }
}

- (void)viewTap{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (instancetype)initWithImage:(UIImage *)image{
    if (self = [super init]) {
        [self setupUI];
        self.image  = image;
        self.view.backgroundColor = [UIColor blackColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTap)];
        tap.numberOfTapsRequired = 1;
        [self.view addGestureRecognizer:tap];
    }
    return self;
}

- (void)setupUI{
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    
    self.scrollView.frame = self.view.bounds;
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 2.0;
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    CGFloat offsetX = (scrollView.width - view.width) * 0.5;
    CGFloat offsetY = (scrollView.height - view.height) * 0.5;
    
    offsetX = offsetX > 0 ? offsetX : 0;
    offsetY = offsetY > 0 ? offsetY : 0;
    view.left = 0;
    view.top = 0;
    scrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, offsetY, offsetX);
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.width - self.imageView.width) * 0.5;
    CGFloat offsetY = (scrollView.height - self.imageView.height) * 0.5;
    
    offsetX = offsetX > 0 ? offsetX : 0;
    offsetY = offsetY > 0 ? offsetY : 0;
    scrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, offsetY, offsetX);
}

#pragma mark - UIimageDelegate

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"保存图片失败");
    } else {
        NSLog(@"保存图片成功");
    }
}

- (void)setImage:(UIImage *)image{
    _image = image;
    self.imageView.image = image;
    
    // 设置图片位置
    CGFloat height       = self.scrollView.bounds.size.width * image.size.height / image.size.width;
    self.imageView.frame = CGRectMake(0, 0, self.scrollView.bounds.size.width, height);
    if (height < self.scrollView.bounds.size.height) {
        CGFloat margin   = (self.scrollView.bounds.size.height - height) * 0.5;
        self.scrollView.contentInset = UIEdgeInsetsMake(margin, 0, margin, 0);
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, height);
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        
    }
    return _scrollView;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
