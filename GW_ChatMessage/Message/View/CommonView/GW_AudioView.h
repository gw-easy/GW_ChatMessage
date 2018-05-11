//
//  GW_AudioView.h
//  GW_ChatMessage
//
//  Created by gw on 2018/5/10.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GW_AudioView : UIView
@property (nonatomic, copy) NSString *audioName;

@property (nonatomic, copy) NSString *audioPath;

- (void)releaseTimer;
@end
