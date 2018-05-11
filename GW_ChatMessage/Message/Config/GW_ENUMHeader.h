//
//  GW_ENUMHeader.h
//  GW_ChatMessage
//
//  Created by gw on 2018/4/20.
//  Copyright © 2018年 gw. All rights reserved.
//

#ifndef GW_ENUMHeader_h
#define GW_ENUMHeader_h
// 消息发送状态
typedef enum {
    GW_MessageDeliveryState_Pending = 0,  // 待发送
    GW_MessageDeliveryState_Delivering,   // 正在发送
    GW_MessageDeliveryState_Delivered,    // 已发送，成功
    GW_MessageDeliveryState_Failure,      // 发送失败
    GW_MessageDeliveryState_ServiceFaid   // 发送服务器失败(可能其它错,待扩展)
}GW_MessageDeliveryState;


// 消息类型
typedef enum {
    GW_MessageType_Text  = 1,             // 文本
    GW_MessageType_Voice,                 // 短录音
    GW_MessageType_Image,                 // 图片
    GW_MessageType_Video,                 // 短视频
    GW_MessageType_File,                  //文件
    GW_MessageType_System,                //系统消息
    GW_MessageType_Doc,                   // 文档
    GW_MessageType_TextURL,               // 文本＋链接
    GW_MessageType_PicText,                //文本+图片
    GW_MessageType_ImageURL,              // 图片＋链接
    GW_MessageType_URL,                   // 纯链接
    GW_MessageType_DrtNews,               // 送达号
    GW_MessageType_NTF   = 12,            // 通知
    
    GW_MessageType_DTxt  = 21,            // 纯文本
    GW_MessageType_DPic  = 22,            // 文本＋单图
    GW_MessageType_DMPic = 23,            // 文本＋多图
    GW_MessageType_DVideo= 24,            // 文本＋视频
    GW_MessageType_PGW_URL= 25             // 动态图文链接
    
}GW_MessageType;

typedef enum {
    GW_Group_SELF = 0,                    // 自己
    GW_Group_DOUBLE,                      // 双人组
    GW_Group_MULTI,                       // 多人组
    GW_Group_TODO,                        // 待办
    GW_Group_QING,                        // 轻应用
    GW_Group_NATIVE,                      // 原生应用
    GW_Group_DISCOVERY,                   // 发现
    GW_Group_DIRECT,                      // 送达号
    GW_Group_NOTIFY,                      // 通知
    GW_Group_BOOK                         // 通讯录
}GW_GroupType;

// 消息状态
typedef enum {
    GW_MessageStatus_unRead = 0,          // 消息未读
    GW_MessageStatus_read,                // 消息已读
    GW_MessageStatus_back                 // 消息撤回
}GW_MessageStatus;

typedef enum {
    GW_ActionType_READ = 1,               // 语音已读
    GW_ActionType_BACK,                   // 消息撤回
    GW_ActionType_UPTO,                   // 消息读数
    GW_ActionType_KGW_K,                   // 请出会话
    GW_ActionType_OPOK,                   // 待办已办
    GW_ActionType_BDRT,                   // 送达号消息撤回
    GW_ActionType_GUPD,                   // 群信息修改
    GW_ActionType_UUPD,                   // 群成员信息修改
    GW_ActionType_DUPD,                   // 送达号信息修改
    GW_ActionType_OFFL = 10,              // 请您下线
    GW_ActionType_STOP = 11,              // 清除所有缓存
    GW_ActionType_UUPN                    // 改昵称
    
}GW_ActionType;

typedef NS_ENUM(NSInteger, GW_ChatBoxStatus) {
    GW_ChatBoxStatusNothing,     // 默认状态
    GW_ChatBoxStatusShowVoice,   // 录音状态
    GW_ChatBoxStatusShowFace,    // 输入表情状态
    GW_ChatBoxStatusShowMore,    // 显示“更多”页面状态
    GW_ChatBoxStatusShowKeyboard,// 正常键盘
    GW_ChatBoxStatusShowVideo    // 录制视频
};

typedef enum {
    GW_DeliverSubStatus_Can        = 0,   // 可订阅
    GW_DeliverSubStatus_Already,
    GW_DeliverSubStatus_System
}GW_DeliverSubStatus;

typedef enum {
    GW_DeliverTopStatus_NO         = 0, // 非置顶
    GW_DeliverTopStatus_YES             // 置顶
}GW_DeliverTopStatus;


typedef enum {
    GW_FileType_Other = 0,                // 其它类型
    GW_FileType_Audio,                    //
    GW_FileType_Video,                    //
    GW_FileType_Html,
    GW_FileType_Pdf,
    GW_FileType_Doc,
    GW_FileType_Xls,
    GW_FileType_Ppt,
    GW_FileType_Img,
    GW_FileType_Txt
}GW_FileType;

//moreItem类型
typedef NS_ENUM(NSInteger, GW_ChatBoxItem){
    GW_ChatBoxItemPhoto = 66,   // Photo
    GW_ChatBoxItemCamera,      // Camera
    GW_ChatBoxItemVideo,       // Video
    GW_ChatBoxItemDoc          // pdf
};

#endif /* GW_ENUMHeader_h */
