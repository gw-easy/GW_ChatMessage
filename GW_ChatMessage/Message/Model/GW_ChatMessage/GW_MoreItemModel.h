//
//  GW_MoreItemModel.h
//  GW_ChatMessage
//
//  Created by gw on 2018/5/3.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface GW_MoreItemModel : NSObject
@property (copy, nonatomic) NSString *imageName;
@property (copy, nonatomic) NSString *titleName;
@property (assign, nonatomic) GW_ChatBoxStatus status;
@property (copy, nonatomic) NSString *statusStr;

@end
