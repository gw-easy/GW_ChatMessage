//
//  GW_BaseCell.h
//  GW_ChatMessage
//
//  Created by gw on 2018/4/19.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,CellLineStyle) {
    CellLineStyleDefault, //默认cell 左边缩进
    CellLineStyleFill, //同cell等宽
    CellLineStyleSpace, //左右同时缩进
    CellLineStyleNone //没有线
};
@interface GW_BaseCell : UITableViewCell
@property (nonatomic, assign) CellLineStyle bottomLineStyle;
@property (nonatomic, assign) CellLineStyle topLineStyle;

@property (nonatomic, assign) CGFloat leftFreeSpace; // 低线的左边距

@property (nonatomic, assign) CGFloat rightFreeSpace;

@property (nonatomic, weak) UIView *bottomLine;

@property (nonatomic, weak) UIView *topLine;
@end
