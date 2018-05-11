//
//  GW_ChatBoxMoreView.m
//  GW_ChatMessage
//
//  Created by gw on 2018/5/3.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_ChatBoxMoreView.h"
#import "GW_ChatScrollListView.h"
#import "GW_CameraManager.h"
#import "GW_MoreItemModel.h"
#import "GW_VideoManager.h"
#import "GW_FileVC.h"
#import "GW_MessageManager.h"
@interface GW_ChatBoxMoreView()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,GW_FileVCDelegate>
@property (strong, nonatomic) GW_ChatScrollListView *listView;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) NSArray *moreArr;
@end
@implementation GW_ChatBoxMoreView
- (instancetype) initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = ColorRGB(237, 237, 246);
        [self addSubview:self.listView];
        [self addNotification];
        self.hidden = YES;
    }
    return self;
}

- (NSArray *)moreArr{
    if (!_moreArr) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"moreItemList.plist" ofType:nil];
        _moreArr = [GW_MoreItemModel GW_JsonToModel:[NSArray arrayWithContentsOfFile:path]];
    }
    return _moreArr;
}

- (GW_ChatScrollListView *)listView{
    if (!_listView) {
        _listView = [[GW_ChatScrollListView alloc] initWithFrame:CGRectMake(0, 0, self.width, HEIGHT_CHATBOXVIEWSHOW)];
        _listView.moreItem = self.moreArr;
    }
    return _listView;
}

- (void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPhotoAction:) name:GW_MoreViewPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectCameraAction:) name:GW_MoreViewCameraNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectDocAction:) name:GW_MoreViewDocNotification object:nil];
}

- (void)selectPhotoAction:(NSNotification *)noti{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self.imagePicker animated:YES completion:nil];
    } else {
        GWLog(@"photLibrary is not available!");
    }
}
- (void)selectCameraAction:(NSNotification *)noti{
    if (![self hasPermissionToGetCamera]) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请在iPhone的“设置-隐私”选项中，允许WeChat访问你的相机。" message:nil preferredStyle:0];
        UIAlertAction *ac = [UIAlertAction actionWithTitle:@"确定" style:0 handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVC addAction:ac];
        [ROOT_VC_KEY_WINDOW presentViewController:alertVC animated:YES completion:^{
            
        }];
    } else {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [ROOT_VC_KEY_WINDOW presentViewController:self.imagePicker animated:YES completion:nil];
        } else {
            GWLog(@"camera is no available!");
        }
    }
}

- (void)selectDocAction:(NSNotification *)noti{
    GW_FileVC *docVC = [[GW_FileVC alloc] init];
    docVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:docVC];
    [ROOT_VC_KEY_WINDOW presentViewController:nav animated:YES completion:nil];
}

- (void)selectedFileName:(NSString *)fileName{
    if (self.sendFileMessage) {
        self.sendFileMessage(fileName);
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (BOOL)hasPermissionToGetCamera
{
    BOOL hasPermission = YES;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        hasPermission = NO;
    }
    return hasPermission;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //    NSString *mediaType = info[UIImagePickerControllerMediaType];
    //    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
    //        ICLog(@"movie");
    //    } else {
    UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    // 图片压缩后再上传服务器
    // 保存路径
    UIImage *simpleImg = [UIImage simpleImage:orgImage];
    NSString *filePath = [[GW_CameraManager shareManager] saveImage:simpleImg];
    if (self.sendPicMessage) {
        self.sendPicMessage(filePath, simpleImg);
    }

}

- (UIImagePickerController *)imagePicker
{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.modalPresentationStyle = UIModalPresentationCustom;
        _imagePicker.view.backgroundColor = [UIColor whiteColor];
        [_imagePicker.navigationBar setBackgroundImage:[UIImage imageNamed:@"daohanglanbeijing"] forBarMetrics:UIBarMetricsDefault];
        _imagePicker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    }
    return _imagePicker;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
