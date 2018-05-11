//
//  GW_Header.h
//  GW_ChatMessage
//
//  Created by gw on 2018/4/19.
//  Copyright © 2018年 gw. All rights reserved.
//

#ifndef GW_Header_h
#define GW_Header_h

#ifdef DEBUG
#define GWLog(fmt, ...) NSLog((@"[文件名:%s]\n" "[方法名:%s]\n" "[行号:%d]\n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define GWLog(...)
#endif

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

#define ColorRGB(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define ColorRGBA(r, g, b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]

#define ColorRGBHas(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]

#define ROOT_VC_KEY_WINDOW [UIApplication sharedApplication].keyWindow.rootViewController


#endif /* GW_Header_h */
