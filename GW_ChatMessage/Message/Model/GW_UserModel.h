//
//  GW_UserModel.h
//  GW_ChatMessage
//
//  Created by gw on 2018/4/19.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GW_UserModel : NSObject
// 用户ID
@property (nonatomic, copy) NSString *eId;

// 用户名
@property (nonatomic, copy) NSString *eName;

// 新增 用户的头像photoid
@property (nonatomic, copy) NSString *photoId;

// 昵称
@property (nonatomic, copy) NSString *nName;

// 头像URL
//@property (nonatomic, copy) NSString *headURL;

// 性别
//@property (nonatomic, copy) NSString *sex;

// 手机号
@property (nonatomic, copy) NSString *phone;

// 办公手机号
@property (nonatomic, copy) NSString *mobile;

// 邮箱
@property (nonatomic, copy) NSString *email;

// 职务
@property (nonatomic, copy) NSString *jobTitle;

// 组织ID
@property (nonatomic, copy) NSString *oId;

// 部门名称
@property (nonatomic, copy) NSString *oName;

// 账号
@property (nonatomic, copy) NSString *account;


// 人员状态，其实不应该加到这里的，后台强制定的
@property (nonatomic, assign) BOOL valid;
@end
