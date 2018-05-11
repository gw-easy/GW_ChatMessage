//
//  GW_ChatBoxTextView.m
//  GW_ChatMessage
//
//  Created by gw on 2018/4/23.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_ChatBoxTextView.h"
#import "GW_FaceModel.h"
@interface GW_ChatBoxTextView()<UITextViewDelegate>

@end;

@implementation GW_ChatBoxTextView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.textView];
        [self addNotification];
    }
    return self;
}

- (UITextView *) textView
{
    if (_textView == nil) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0,0,self.width,self.height)];
        [_textView setFont:[UIFont systemFontOfSize:16.0f]];
        [_textView.layer setMasksToBounds:YES];
        [_textView.layer setCornerRadius:4.0f];
        [_textView.layer setBorderWidth:0.5f];
        [_textView.layer setBorderColor:ColorRGB(165, 165, 165).CGColor];
        [_textView setScrollsToTop:NO];
        [_textView setReturnKeyType:UIReturnKeySend];
        [_textView setDelegate:self];
    }
    return _textView;
}

- (void)textInsertText:(NSString *)text{
    [self.textView insertText:text];
}


// 监听通知
- (void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emotionDidSelected:) name:GW_EmotionDidSelectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteBtnClicked) name:GW_EmotionDidDeleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessage) name:GW_EmotionDidSendNotification object:nil];
}


- (void)emotionDidSelected:(NSNotification *)notifi{
    GW_FaceModel *emotion = notifi.userInfo[GW_SelectEmotionKey];
    if (emotion.code) {
        [self.textView insertText:emotion.code.emoji];
    } else if (emotion.face_name) {
        [self.textView insertText:emotion.face_name];
    }
    [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length, 0)];
}

// 删除
- (void)deleteBtnClicked
{
    [self.textView deleteBackward];
}

- (void)sendMessage
{
    if (self.textView.text.length > 0) {     // send Text
        if (self.getText) {
            self.getText(self.textView.text);
        }
    }
    [self.textView setText:@""];
}

#pragma mark - UITextViewDelegate

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    //    ICChatBoxStatus lastStatus = self.status;
    if (self.getStatus) {
        self.getStatus(GW_ChatBoxStatusShowKeyboard);
    }
}

- (void) textViewDidChange:(UITextView *)textView
{
    //    CGFloat height = [textView sizeThatFits:CGSizeMake(self.textView.width, MAXFLOAT)].height;
    if (textView.text.length > 5000) { // 限制5000字内
        textView.text = [textView.text substringToIndex:5000];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        if (self.textView.text.length > 0) {     // send Text
            if (self.getText) {
                self.getText(self.textView.text);
            }
        }
        [self.textView setText:@""];
        return NO;
    }
    return YES;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
