//
//  GW_ChatMesssageBaseCell.m
//  GW_ChatMessage
//
//  Created by gw on 2018/4/20.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_ChatMessageBaseCell.h"

@implementation GW_ChatMessageBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILongPressGestureRecognizer *longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognizer:)];
        longRecognizer.minimumPressDuration = 0.5;
        [self addGestureRecognizer:longRecognizer];
    }
    return self;
}

- (void)setupUI {
    [self.contentView addSubview:self.bubbleView];
    [self.contentView addSubview:self.headImageView];
    [self.contentView addSubview:self.activityView];
    [self.contentView addSubview:self.retryButton];
}

- (UIImageView *)headImageView {
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _headImageView.layer.cornerRadius = _headImageView.width/2;
        [_headImageView clipsToBounds];
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headClicked)];
        [_headImageView addGestureRecognizer:tapGes];
    }
    return _headImageView;
}

- (UIImageView *)bubbleView {
    if (!_bubbleView) {
        _bubbleView = [[UIImageView alloc] init];
    }
    return _bubbleView;
}

- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _activityView;
}

- (UIButton *)retryButton {
    if (!_retryButton) {
        _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_retryButton setImage:[UIImage imageNamed:@"button_retry_comment"] forState:UIControlStateNormal];
        [_retryButton addTarget:self action:@selector(retryButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _retryButton;
}

- (void)retryButtonClick:(UIButton *)btn {
    if (_delegate && [_delegate respondsToSelector:@selector(reSendMessage:)]) {
        [self.delegate reSendMessage:self];
    }
}

- (void)setModelFrame:(GW_ChatMessageFrameModel *)modelFrame{
    _modelFrame = modelFrame;
    
    GW_ChatMessageModel *messageModel = modelFrame.model;
    self.headImageView.frame     = modelFrame.headImageViewF;
    self.bubbleView.frame        = modelFrame.bubbleViewF;
    if (messageModel.isSender) {    // 发送者
        self.activityView.frame  = modelFrame.activityF;
        self.retryButton.frame   = modelFrame.retryButtonF;
        switch (modelFrame.model.message.deliveryState) { // 发送状态
            case GW_MessageDeliveryState_Delivering:
            {
                [self.retryButton setHidden:YES];
                [self avtivityStartAnimating:YES];
            }
                break;
            case GW_MessageDeliveryState_Delivered:
            {
                [self avtivityStartAnimating:NO];
                [self.retryButton setHidden:YES];
            }
                break;
            case GW_MessageDeliveryState_Failure:
            {
                [self avtivityStartAnimating:NO];
                [self.retryButton setHidden:NO];
            }
                break;
            default:
                break;
        }
        if ([modelFrame.model.message.type isEqualToString:CellFile] ||[modelFrame.model.message.type isEqualToString:CellPicText]){
            self.bubbleView.image = [UIImage imageNamed:@"liaotianfile"];
        }else{
            self.bubbleView.image = [UIImage imageNamed:@"liaotianbeijing2"];
        }
        [self.headImageView setImage:[UIImage imageNamed:@"mayun.jpg"]];
    } else {    // 接收者
        self.retryButton.hidden  = YES;
        self.bubbleView.image    = [UIImage imageNamed:@"liaotianbeijing1"];
        [self.headImageView setImage:[UIImage imageNamed:@"mahuateng.jpeg"]];
    }
}

- (void)avtivityStartAnimating:(BOOL)ani{
    if (ani) {
        [self.activityView setHidden:NO];
        [self.activityView startAnimating];
    }else{
        [self.activityView stopAnimating];
        [self.activityView setHidden:YES];
    }
}

- (void)headClicked{
    if (_delegate && [_delegate respondsToSelector:@selector(headImageClicked:)]) {
        [_delegate headImageClicked:_modelFrame.model.message.from];
    }
}

- (void)longPressRecognizer:(UILongPressGestureRecognizer *)recognizer{
    if (_delegate && [_delegate respondsToSelector:@selector(longPress:)]) {
        [_delegate longPress:recognizer];
    }
}

@end
