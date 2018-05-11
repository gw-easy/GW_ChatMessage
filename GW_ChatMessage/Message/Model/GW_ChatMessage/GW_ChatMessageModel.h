//
//  GW_ChatMessageModel.h
//  GW_ChatMessage
//
//  Created by gw on 2018/4/20.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GW_MessageContentModel.h"
@interface GW_ChatMessageModel : NSObject
// 后期重构把这个类可能要去掉--by:gxz

// 是否是发送者
@property (nonatomic, assign) BOOL isSender;
// 是否是群聊
//@property (nonatomic, assign) BOOL isChatGroup;




@property (nonatomic, strong) GW_MessageContentModel *message;

// 包含voice，picture，video的路径;有大图时就是大图路径
// 不用这些路径了，只用里面的名字重新组成路径
@property (nonatomic, copy) NSString *mediaPath;
@end
