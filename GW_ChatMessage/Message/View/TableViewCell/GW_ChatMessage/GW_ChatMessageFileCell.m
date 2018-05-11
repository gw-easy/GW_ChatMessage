//
//  GW_ChatMessageFileCell.m
//  GW_ChatMessage
//
//  Created by gw on 2018/5/10.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_ChatMessageFileCell.h"
#import "GW_FileButton.h"
#import "NSDictionary+Extension.h"
#import "GW_FileManager.h"
@interface GW_ChatMessageFileCell()
@property (nonatomic, strong) GW_FileButton *fileButton;
@end
@implementation GW_ChatMessageFileCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.fileButton];
    }
    return self;
}

- (void)setModelFrame:(GW_ChatMessageFrameModel *)modelFrame
{
    [super setModelFrame:modelFrame];
    
    self.fileButton.frame = modelFrame.picViewF;
    self.fileButton.messageModel = modelFrame.model;
    
    if ([GW_FileManager fileExistsAtPath:[self localFilePath]]) {
        if (modelFrame.model.isSender) {
            if (modelFrame.model.message.deliveryState == GW_MessageDeliveryState_Delivered) {
                self.fileButton.identLabel.text = @"已发送";
            } else {
                self.fileButton.identLabel.text = @"未发送";
            }
        } else {
            self.fileButton.identLabel.text = @"已下载";
        }
    } else {
        if (modelFrame.model.isSender) {
            if (modelFrame.model.message.deliveryState == GW_MessageDeliveryState_Delivered) {
                self.fileButton.identLabel.text = @"已发送";
            } else {
                self.fileButton.identLabel.text = @"未发送";
            }
        } else {
            self.fileButton.identLabel.text = @"未下载";
        }
    }
}

- (void)fileBtnClicked:(UIButton *)fileBtn
{
    // 如果文件存在就直接打开，否者下载
    __block NSString *path = [self localFilePath];
    if ([GW_FileManager fileExistsAtPath:path]) {
//        [self routerEventWithName:GXRouterEventScanFile
//                         userInfo:@{
//                                    MessageKey   : self.modelFrame,
//                                    @"filePath"  : path,
//                                    @"fileBtn"   : fileBtn
//                                    }
//         ];
//        return;
    }
    NSString *fileKey = self.modelFrame.model.message.fileKey;
    if (!fileKey){
        return;
    }
    self.fileButton.progressView.hidden = NO;
}


- (NSString *)localFilePath{
    NSString *lnk = self.modelFrame.model.message.lnk;
    NSDictionary *dicLnk = [NSDictionary dictionaryWithJsonString:lnk];
    NSString *orgName  = [dicLnk objectForKey:@"n"];
    NSString *key      = self.modelFrame.model.message.fileKey;
    NSString *path = [GW_FileManager filePathWithName:key orgName:[orgName stringByDeletingPathExtension] type:[orgName pathExtension]];
    
    return path;
}

- (GW_FileButton *)fileButton{
    if (!_fileButton) {
        _fileButton = [GW_FileButton buttonWithType:UIButtonTypeCustom];
        [_fileButton addTarget:self action:@selector(fileBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fileButton;
}
@end
