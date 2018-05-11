//
//  GW_FaceManager.h
//  GW_ChatMessage
//
//  Created by gw on 2018/4/20.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GW_ChatScrollListView.h"
@interface GW_FaceManager : NSObject

//提前加载数据
@property (strong, nonatomic) GW_ChatScrollListView *emojiListView;
@property (strong, nonatomic) GW_ChatScrollListView *custumListView;
@property (strong, nonatomic) GW_ChatScrollListView *gifListView;
@property (strong, nonatomic) GW_ChatScrollListView *ajmdListView;
@property (strong, nonatomic) GW_ChatScrollListView *ltListView;
@property (strong, nonatomic) GW_ChatScrollListView *xxyListView;

+ (instancetype)shareManager;

+ (NSString *)getNormal_Face:(NSString *)faceName;

+ (NSString *)getAJMD_Face:(NSString *)faceName;

+ (NSString *)getLT_Face:(NSString *)faceName;

+ (NSString *)getXXY_Face:(NSString *)faceName;

+ (NSMutableAttributedString *)transferMessageString:(NSString *)message
                                                font:(UIFont *)font
                                          lineHeight:(CGFloat)lineHeight;
@end
