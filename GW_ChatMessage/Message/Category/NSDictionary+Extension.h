//  GW_ChatMessage
//
//  Created by gw on 2018/4/20.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Extension)


+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonStr;

- (NSString*)jsonString;

@end
