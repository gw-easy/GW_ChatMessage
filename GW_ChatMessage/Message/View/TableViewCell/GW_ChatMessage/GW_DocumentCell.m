//
//  GW_DocumentCell.m
//  GW_ChatMessage
//
//  Created by gw on 2018/5/10.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_DocumentCell.h"
#import "GW_FileManager.h"
#import "GW_MessageManager.h"
@interface GW_DocumentCell()
@property (strong, nonatomic) UIImageView *imageV;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *sizeLabel;
@end
@implementation GW_DocumentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.leftFreeSpace = 115;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.selectBtn];
        [self.contentView addSubview:self.imageV];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.sizeLabel];
    }
    return self;
}


+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"docCell";
    GW_DocumentCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[GW_DocumentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (void)setName:(NSString *)name{
    _name = name;
    NSString *type = [name pathExtension];
    NSString *path = [[GW_FileManager fileMainPath] stringByAppendingPathComponent:name];
    self.filePath = path;
    self.nameLabel.text = [name originName];
    self.sizeLabel.text = [GW_FileManager filesize:path];
    NSNumber *num = [GW_MessageManager fileType:type];
    if (num == nil) {
        self.imageV.image = [UIImage imageNamed:@"iconfont-wenjian"];
    } else {
        self.imageV.image = [GW_MessageManager allocationImage:[num intValue]];
    }
}

- (void)selectBtnClicked:(id)sender{
    if ([self.delegate respondsToSelector:@selector(selectBtnClicked:)]) {
        [self.delegate selectBtnClicked:sender];
    }
}

- (UIButton *)selectBtn{
    if (!_selectBtn) {
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectBtn.frame = CGRectMake(15, 30, 20, 20);
        [_selectBtn setImage:[UIImage imageNamed:@"App_select_dis"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"App_select"] forState:UIControlStateSelected];
        [_selectBtn addTarget:self action:@selector(selectBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectBtn;
}

- (UIImageView *)imageV{
    if (!_imageV) {
        _imageV = [[UIImageView alloc] initWithFrame:CGRectMake(55, 15, 50, 50)];
    }
    return _imageV;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imageV.right+10, 15, SCREENWIDTH-_imageV.right-10-40, 16)];
        _nameLabel.font = [UIFont systemFontOfSize:15.0];
        _nameLabel.numberOfLines = 2;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _nameLabel.textColor = ColorRGBHas(0x000000);
//        [_nameLabel sizeToFit];
    }
    return _nameLabel;
}

- (UILabel *)sizeLabel{
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imageV.right+10,_imageV.bottom-15 , 100, 15)];
        _sizeLabel.font = [UIFont systemFontOfSize:11.0];
        _sizeLabel.textColor = ColorRGBHas(0x7e7e7e);
//        [_sizeLabel sizeToFit];
    }
    return _sizeLabel;
}
@end
