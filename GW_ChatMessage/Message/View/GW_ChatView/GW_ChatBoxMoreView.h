//
//  GW_ChatBoxMoreView.h
//  GW_ChatMessage
//
//  Created by gw on 2018/5/3.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GW_ChatBoxMoreView : UIView
@property (copy, nonatomic) void (^sendPicMessage)(NSString *path,UIImage *pic);
@property (copy, nonatomic) void (^sendFileMessage)(NSString *fileName);
@end
