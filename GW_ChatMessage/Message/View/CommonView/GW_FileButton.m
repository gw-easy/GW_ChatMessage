//
//  GW_FileButton.m
//  GW_ChatMessage
//
//  Created by gw on 2018/5/10.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_FileButton.h"
#import "GW_ChatMessageModel.h"
#import "NSDictionary+Extension.h"
#import "GW_MessageManager.h"
@interface GW_FileButton()
@property (nonatomic, strong) UIImageView *imageV;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *sizeLabel;
@end
@implementation GW_FileButton

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imageV];
        [self addSubview:self.nameLabel];
        [self addSubview:self.sizeLabel];
        [self addSubview:self.progressView];
        [self addSubview:self.identLabel];
    }
    return self;
}

- (void)setMessageModel:(GW_ChatMessageModel *)messageModel
{
    NSString *lnk = messageModel.message.lnk;
    NSDictionary *dicLnk = [NSDictionary dictionaryWithJsonString:lnk];
    NSInteger size  = [[dicLnk objectForKey:@"s"] integerValue];
    NSString *sizeStr;
    if (size/1000.0 > 1000) {
        sizeStr = [NSString stringWithFormat:@"%.1fMB",size/1024.0/1000.0];
    } else {
        sizeStr = [NSString stringWithFormat:@"%.1fKB",size/1000.0];
    }
    GW_FileType type = [[dicLnk objectForKey:@"x"] intValue];
    NSString *name  = [dicLnk objectForKey:@"n"];
    self.imageV.image = [GW_MessageManager allocationImage:type];
    //    self.nameLabel.text = [name lastStringSeparatedByString:@"_"];
    self.nameLabel.text   = name;
    self.sizeLabel.text = sizeStr;
    
    self.imageV.frame = CGRectMake(15, 13, 68, 68);
    self.nameLabel.frame = CGRectMake(_imageV.right+10, _imageV.top+3, 150.0, 18.0);
    [_nameLabel sizeToFit];
    self.sizeLabel.frame = CGRectMake(_imageV.right+10, _imageV.bottom-3-12, 50, 12);
    [_sizeLabel sizeToFit];
    
    self.identLabel.frame = CGRectMake(self.width-12-50, _imageV.bottom-3-12, 40, 12);
    
    self.progressView.frame = CGRectMake(15,_imageV.bottom+10, self.width-30, 8);
    self.progressView.centerY = _imageV.bottom + (self.height-_imageV.bottom)*0.5;
}


- (UIImageView *)imageV{
    if (!_imageV) {
        _imageV = [[UIImageView alloc] init];
    }
    return _imageV;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.numberOfLines = 2;
        _nameLabel.font = [UIFont systemFontOfSize:16.0];
        _nameLabel.textColor = ColorRGBHas(0x262626);
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _nameLabel;
}

- (UILabel *)sizeLabel{
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] init];
        _sizeLabel.font = [UIFont systemFontOfSize:11.0];
        _sizeLabel.textColor = ColorRGBHas(0x707070);
    }
    return _sizeLabel;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.hidden = YES;
        _progressView.progressTintColor = [UIColor greenColor];
    }
    return _progressView;
}

- (UILabel *)identLabel{
    if (!_identLabel) {
        _identLabel = [[UILabel alloc] init];
        _identLabel.font = [UIFont systemFontOfSize:11.0];
        _identLabel.textColor = ColorRGBHas(0x707070);
        _identLabel.textAlignment = NSTextAlignmentRight;
    }
    return _identLabel;
}

@end
