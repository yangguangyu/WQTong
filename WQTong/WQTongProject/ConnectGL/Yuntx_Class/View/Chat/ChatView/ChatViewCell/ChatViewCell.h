//
//  ChatViewCell.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/8.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIResponder+Custom.h"
#import "ECMessage.h"

extern NSString *const KResponderCustomChatViewCellBubbleViewEvent;
extern NSString *const KResponderCustomECMessageKey;

extern NSString *const KResponderCustomChatViewCellResendEvent;
extern NSString *const KResponderCustomTableCellKey;
extern NSString *const KResponderCustomECMessagePortraitImgKey;

extern const char KTimeIsShowKey;

@interface ChatViewCell : UITableViewCell
@property (nonatomic, assign) BOOL isSender;
@property (nonatomic, strong) UIImageView *portraitImg;
@property (nonatomic, strong) UILabel *fromId;
@property (nonatomic, strong) UIView *bubbleView;

@property (nonatomic, strong) ECMessage *displayMessage;

/**
 *@brief 创建cell
 */
-(instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier;

//设置cell的数据
-(void)bubbleViewWithData:(ECMessage*) message;

/**
 *@brief 根据消息内容获取占用的高度
 */
+(CGFloat)getHightOfCellViewWith:(ECMessageBody *)message;

/**
 *@brief 更新消息发送状态
 */
-(void)updateMessageSendStatus:(ECMessageState)state;

/**
 *@brief bubleView点击事件
 */
-(void)bubbleViewTapGesture:(id)sender;

@end
