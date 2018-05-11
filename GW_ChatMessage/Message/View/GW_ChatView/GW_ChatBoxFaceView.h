//
//  GW_ChatBoxFaceView.h
//  GW_ChatMessage
//
//  Created by gw on 2018/4/24.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,GW_EmotionMenuButtonType) {
    GW_EmotionMenuButtonTypeEmoji = 100,
    GW_EmotionMenuButtonTypeCuston,
    GW_EmotionMenuButtonTypeAJMD,
    GW_EmotionMenuButtonTypeLT,
    GW_EmotionMenuButtonTypeXXY,
    GW_EmotionMenuButtonTypeGif,
    GW_EmotionMenuButtonTypeNothing
};

@interface GW_ChatBoxFaceView : UIView

@end
