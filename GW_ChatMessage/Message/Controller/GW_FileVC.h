//
//  GW_FileVC.h
//  GW_ChatMessage
//
//  Created by gw on 2018/5/10.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GW_FileVCDelegate <NSObject>

- (void)selectedFileName:(NSString *)fileName;

@end
@interface GW_FileVC : UIViewController
@property (weak, nonatomic) id <GW_FileVCDelegate>delegate;
@end
