//
//  GW_BaseCell.m
//  GW_ChatMessage
//
//  Created by gw on 2018/4/19.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_BaseCell.h"
@interface GW_BaseCell()

@end
@implementation GW_BaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self topLine];
        [self bottomLine];
        
        _topLineStyle = CellLineStyleNone;
        _bottomLineStyle = CellLineStyleDefault;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.topLine.top = 0;
    self.bottomLine.top = self.height - self.bottomLine.height;
    [self setBottomLineStyle:_bottomLineStyle];
    [self setTopLineStyle:_topLineStyle];
    
}

- (void)setTopLineStyle:(CellLineStyle)topLineStyle
{
    _topLineStyle = topLineStyle;
    if (topLineStyle == CellLineStyleDefault) {
        self.topLine.left = _leftFreeSpace;
        self.topLine.width = self.width - _leftFreeSpace;
        [self.topLine setHidden:NO];
    } else if (topLineStyle == CellLineStyleFill){
        self.topLine.left = 0;
        self.topLine.width = self.width;
        self.topLine.hidden = NO;
    }else if (topLineStyle == CellLineStyleSpace){
        self.topLine.left = _leftFreeSpace;
        self.topLine.width = self.width-_leftFreeSpace-_rightFreeSpace;
        [self.topLine setHidden:NO];
    }else if (topLineStyle == CellLineStyleNone){
        self.topLine.hidden = YES;
    }
}

- (void)setBottomLineStyle:(CellLineStyle)bottomLineStyle
{
    _bottomLineStyle = bottomLineStyle;
    if (bottomLineStyle == CellLineStyleDefault) {
        self.bottomLine.left = _leftFreeSpace;
        self.bottomLine.width = self.width - _leftFreeSpace - _rightFreeSpace;
        self.bottomLine.hidden = NO;
    }else if (bottomLineStyle == CellLineStyleFill) {
        self.bottomLine.left = 0;
        self.bottomLine.width = self.width;
        self.bottomLine.hidden = NO;
    }else if (bottomLineStyle == CellLineStyleSpace){
        self.bottomLine.left = _leftFreeSpace;
        self.bottomLine.width = self.width-_leftFreeSpace-_rightFreeSpace;
        [self.bottomLine setHidden:NO];
    }else if (bottomLineStyle == CellLineStyleNone) {
        self.bottomLine.hidden = YES;
    }
}

- (UIView *)bottomLine
{
    if (!_bottomLine) {
        UIView *line = [[UIView alloc] init];
        line.height = 0.5f;
        line.backgroundColor = [UIColor grayColor];
        line.alpha = 0.4;
        [self.contentView addSubview:line];
        _bottomLine = line;
    }
    return _bottomLine;
}

- (UIView *)topLine
{
    if (!_topLine) {
        UIView *line = [[UIView alloc] init];
        line.height = 0.5f;
        line.backgroundColor = [UIColor grayColor];
        line.alpha = 0.4;
        [self.contentView addSubview:line];
        _topLine = line;
    }
    return _topLine;
}


@end
