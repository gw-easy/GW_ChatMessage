//
//  GW_ChatMessageSystemCell.h
//  GW_ChatMessage
//
//  Created by gw on 2018/4/28.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GW_ChatMessageFrameModel.h"
@interface GW_ChatMessageSystemCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView
                       reusableId:(NSString *)ID;

@property (nonatomic, strong) GW_ChatMessageFrameModel *messageF;
@end
