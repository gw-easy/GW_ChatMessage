//
//  GW_PhotoBrowserVC.h
//  GW_ChatMessage
//
//  Created by gw on 2018/5/8.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GW_PhotoBrowserVC : UIViewController
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong,) UIImageView *imageView;


- (instancetype)initWithImage:(UIImage *)image;
@end
