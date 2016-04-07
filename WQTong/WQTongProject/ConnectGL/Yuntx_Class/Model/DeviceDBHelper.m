//
//  DeviceDBHelper.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/15.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "DeviceDBHelper.h"
#import "ECSession.h"

@implementation DeviceDBHelper

+(DeviceDBHelper*)sharedInstance {
    
    static dispatch_once_t DeviceDBHelperonce;
    static DeviceDBHelper * DeviceDBHelperstatic;
    dispatch_once(&DeviceDBHelperonce, ^{
        DeviceDBHelperstatic = [[DeviceDBHelper alloc] init];
    });
    return DeviceDBHelperstatic;
}

-(instancetype)init {
    if (self = [super init]) {
        self.joinGroupArray = [NSMutableArray array];
    }
    return self;
}

-(void)openDataBasePath:(NSString*)userName {
    [[IMMsgDBAccess sharedInstance] openDatabaseWithUserName:userName];
    self.sessionDic = nil;
    [self getMyCustomSession];
}

- (NSArray *)getAllMessagesOfSessionId:(NSString *)sessionId
{
   return [[IMMsgDBAccess sharedInstance] getAllMessageOfSessionId:sessionId];
}

- (NSArray *)getAllTypeMessageLocalPathOfSessionId:(NSString *)sessionId type:(MessageBodyType)type
{
    return [[IMMsgDBAccess sharedInstance] getAllLocalPathMessageOfSessionId:sessionId type:type];
}

-(NSArray*)getLatestHundredMessageOfSessionId:(NSString*)sessionId andSize:(NSInteger)pageSize {
    return [[IMMsgDBAccess sharedInstance] getLatestSomeMessagesCount:pageSize OfSession:sessionId];
}

-(NSArray*)getMessageOfSessionId:(NSString *)sessionId beforeTime:(NSString*)timetamp andPageSize:(NSInteger)pageSize {
    return [[IMMsgDBAccess sharedInstance] getSomeMessagesCount:pageSize OfSession:sessionId beforeTime:timetamp.longLongValue];
}

-(void)deleteAllMessageOfSession:(NSString*)sessionId {
#if 0
    //删除会话的数据,保留会话
    ECSession *session = [self.sessionDic objectForKey:sessionId];
    session.text = @"";
    session.type = MessageBodyType_Text;
    [[IMMsgDBAccess sharedInstance] updateSession:session];
    [[IMMsgDBAccess sharedInstance] deleteMessageOfSession:sessionId];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_DeleteLocalSessionMessage object:sessionId];
#else
    //删除会话的数据，删除会话
    [self.sessionDic removeObjectForKey:sessionId];
    [[IMMsgDBAccess sharedInstance] deleteSession:sessionId];
    [[IMMsgDBAccess sharedInstance] deleteMessageOfSession:sessionId];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_DeleteLocalSessionMessage object:sessionId];
#endif
}

-(void)deleteAllMessageSaveSessionOfSession:(NSString*)sessionId {
    //删除会话的数据,保留会话
    ECSession *session = [self.sessionDic objectForKey:sessionId];
    session.text = @"";
    session.type = MessageBodyType_Text;
    [[IMMsgDBAccess sharedInstance] updateSession:session];
    [[IMMsgDBAccess sharedInstance] deleteMessageOfSession:sessionId];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_DeleteLocalSessionMessage object:sessionId];
}

-(NSArray*)getLatestHundredGroupNotice {
    return [[IMMsgDBAccess sharedInstance] getSomeGroupMessagesCount:100];
}


-(ECGroupNoticeMessage*)getLatestGroupMessage {
    NSArray *messageArray = [[IMMsgDBAccess sharedInstance] getSomeGroupMessagesCount:1];
    if (messageArray && messageArray.count > 0) {
        return [messageArray objectAtIndex:0];
    }
    return nil;
}

-(void)clearGroupMessageTable {
    [self.sessionDic removeObjectForKey:@"系统通知"];
    [[IMMsgDBAccess sharedInstance] clearGroupMessageTable];
}

-(void)markGroupMessagesAsRead {
    ECSession *sessoin = [self.sessionDic objectForKey:@"系统通知"];
    if (sessoin) {
        sessoin.unreadCount = 0;
    }
    [[IMMsgDBAccess sharedInstance] markGroupMessagesAsRead];
}

-(void)updateMessageId:(ECMessage*)msgNewId andTime:(long long)time ofMessageId:(NSString*)msgOldId {
    ECSession *session = [self.sessionDic objectForKey:msgNewId.sessionId];
    if (session) {
        session.dateTime = time;
    }
    [[IMMsgDBAccess sharedInstance] updateSession:session];
    [[IMMsgDBAccess sharedInstance] updateMessageId:msgNewId.messageId andTime:time ofMessageId:msgOldId andSession:msgNewId.sessionId];
}

-(void)markMessagesAsReadOfSession:(NSString*)sessionId {
    ECSession *session = [self.sessionDic objectForKey:sessionId];
    if (session) {
        session.unreadCount = 0;
        [[IMMsgDBAccess sharedInstance] updateSession:session];
    }
}

-(void)deleteMessage:(ECMessage*)message andPre:(ECMessage*)premessage {
    if (premessage) {
        long long int time = [premessage.timestamp longLongValue];
        ECSession * session = [self messageConvertToSession:premessage];
        session.dateTime = time;
        [[IMMsgDBAccess sharedInstance] updateSession:session];
    } else {
        [self.sessionDic removeObjectForKey:message.sessionId];
        [[IMMsgDBAccess sharedInstance] deleteSession:message.sessionId];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mainviewdidappear" object:nil];
    [[IMMsgDBAccess sharedInstance] deleteMessage:message.messageId andSession:message.sessionId];
}

-(void)addNewMessage:(ECMessage*)message andSessionId:(NSString*)sessionId {
    ECSession * session = [self messageConvertToSession:message];
    if ([message.sessionId isEqualToString:sessionId]) {
        session.unreadCount = 0;
    } else {
        session.unreadCount++;
    }
    [[IMMsgDBAccess sharedInstance] updateSession:session];
    [[IMMsgDBAccess sharedInstance] addMessage:message];
}

-(void)addNewGroupMessage:(ECGroupNoticeMessage*)message {
    if (message && message.sender.length>0) {
        [self noticeConvertToSession:message];
    }
    [[IMMsgDBAccess sharedInstance] addGroupMessage:message];
}

-(NSArray*)getMyCustomSession {
    if (!self.sessionDic) {
        self.sessionDic = [[IMMsgDBAccess sharedInstance] loadAllSessions];
        
        NSArray *notice = [[IMMsgDBAccess sharedInstance] getGroupSessionArray];
        for (ECGroupNoticeMessage * msg in notice) {
            if (msg && msg.sender.length>0) {
                ECSession* session = [self noticeConvertToSession:msg];
                session.unreadCount = [[IMMsgDBAccess sharedInstance] getUnreadGroupMessageCount];
            }
        }
    }
    
    return  [self.sessionDic.allValues sortedArrayUsingComparator:
                                     ^(ECSession *obj1, ECSession* obj2) {
                                         if(obj1.dateTime > obj2.dateTime) {
                                             return(NSComparisonResult)NSOrderedAscending;
                                         } else {
                                             return(NSComparisonResult)NSOrderedDescending;
                                         }
                                     }];
}

-(ECSession *)messageConvertToSession:(ECMessage*)message {
    long long int time = [message.timestamp longLongValue];
    
    ECSession *session = [self.sessionDic objectForKey:message.sessionId];
    if (session) {
        if (session.dateTime>time) {
            time = session.dateTime+1;
            message.timestamp = [NSString stringWithFormat:@"%lld",time];
        }
    } else {
        session = [[ECSession alloc] init];
    }
    
    session.sessionId = message.sessionId;
    session.dateTime = time;
    session.type = message.messageBody.messageBodyType;
    switch (message.messageBody.messageBodyType) {
            
        case MessageBodyType_Text: {
            ECTextMessageBody * msg = (ECTextMessageBody*)message.messageBody;
            session.text = msg.text;
        }
            break;
        case MessageBodyType_Image:
            session.text = @"[图片]";
            break;
        case MessageBodyType_Video:
            session.text = @"[视频]";
            break;
        case MessageBodyType_Voice:
            session.text = @"[语音]";
            break;
        case MessageBodyType_Call: {
            ECCallMessageBody * msg = (ECCallMessageBody*)message.messageBody;
            session.text = msg.callText;
        }
            break;
        case MessageBodyType_Location:{
            session.text = @"[位置]";
        }
            break;
        default:
            session.text = @"[文件]";
            break;
    }
    [self.sessionDic setObject:session forKey:message.sessionId];
    return session;
}

-(ECSession *)noticeConvertToSession:(ECGroupNoticeMessage*)msg {
    ECSession *session = [self.sessionDic objectForKey:@"系统通知"];
    if (session) {
        session.unreadCount++;
    } else {
        session = [[ECSession alloc] init];
        session.sessionId = @"系统通知";
        [self.sessionDic setObject:session forKey:session.sessionId];
        session.unreadCount = 1;
    }
    
    session.dateTime = [msg.dateCreated longLongValue];
    session.type = 100;
    
    NSString* groupName = [self getGroupName:msg.groupId andGroupName:msg.groupName];
    NSString *name = @"";
    if (msg.isDiscuss) {
        name = @"讨论组";
    } else {
        name = @"群组";
    }
    
    if (msg.messageType == ECGroupMessageType_Dissmiss) {

        session.text = [NSString stringWithFormat:@"%@%@被解散",name,groupName];
        
    } else if (msg.messageType == ECGroupMessageType_Invite) {
        
        ECInviterMsg * message = (ECInviterMsg *)msg;
        session.text = [NSString stringWithFormat:@"\"%@\"邀请您加入\"%@\"%@",[self getMemberName:message.admin andNickName:message.nickName],groupName,name];
        
    } else if (msg.messageType == ECGroupMessageType_Propose) {
        
        ECProposerMsg * message = (ECProposerMsg *)msg;
        session.text = [NSString stringWithFormat:@"\"%@\"申请加入%@\"%@\"",[self getMemberName:message.proposer andNickName:message.nickName],name,groupName];
        
    } else if (msg.messageType == ECGroupMessageType_Join) {
        
        ECJoinGroupMsg *message = (ECJoinGroupMsg *)msg;
        session.text = [NSString stringWithFormat:@"\"%@\"加入%@\"%@\"",[self getMemberName:message.member andNickName:message.nickName],name,groupName];
        
    } else if (msg.messageType == ECGroupMessageType_Quit) {
        
        ECQuitGroupMsg *message = (ECQuitGroupMsg *)msg;
        session.text = [NSString stringWithFormat:@"\"%@\"退出%@\"%@\"",[self getMemberName:message.member andNickName:message.nickName],name,groupName];
        
    } else if (msg.messageType == ECGroupMessageType_RemoveMember) {
        
        ECRemoveMemberMsg *message = (ECRemoveMemberMsg *)msg;
        session.text = [NSString stringWithFormat:@"\"%@\"被移除%@\"%@\"",[self getMemberName:message.member andNickName:message.nickName],name,groupName];
        
    } else if (msg.messageType == ECGroupMessageType_ReplyJoin) {
        
        ECReplyJoinGroupMsg *message = (ECReplyJoinGroupMsg *)msg;
        [[DemoGlobalClass sharedInstance]getOtherNameWithPhone:message.member];
        session.text = [NSString stringWithFormat:@"%@\"%@\"%@\"%@\"的加入申请",groupName,message.confirm==2?@"同意":@"拒绝",name,[self getMemberName:message.member andNickName:message.nickName]];
        
    } else if (msg.messageType == ECGroupMessageType_ReplyInvite) {
        
        ECReplyInviteGroupMsg *message = (ECReplyInviteGroupMsg *)msg;
        session.text = [NSString stringWithFormat:@"\"%@\"%@\"%@\"的邀请加入%@\"%@\"",[self getMemberName:message.member andNickName:message.nickName],message.confirm==2?@"同意":@"拒绝",message.admin,name,groupName];
        
    } else if (msg.messageType == ECGroupMessageType_ModifyGroup) {
        
        ECModifyGroupMsg *message = (ECModifyGroupMsg *)msg;
        NSString * jsonString = @"";
        if (message.modifyDic) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message.modifyDic options:NSJSONWritingPrettyPrinted error:nil];
            if (jsonData) {
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
        }
        session.text = [NSString stringWithFormat:@"\"%@\"修改%@\"%@\"信息:%@",[self getMemberName:message.member andNickName:nil],name, groupName, jsonString];
        
    } else if (msg.messageType == ECGroupMessageType_ChangeAdmin) {
        
        ECChangeAdminMsg *message = (ECChangeAdminMsg *)msg;
        session.text = [NSString stringWithFormat:@"\"%@\"成为\"%@%@的管理员\"",message.nickName, groupName,name];
        
    } else if (msg.messageType == ECGroupMessageType_ChangeMemberRole) {
        ECChangeMemberRoleMsg *message = (ECChangeMemberRoleMsg *)msg;
        ECMemberRole role = (ECMemberRole)[[message.roleDic objectForKey:@"role"] integerValue];
        NSString *roleText = nil;
        if (role == ECMemberRole_Member) {
            roleText = @"取消管理员";
        } else if (role == ECMemberRole_Admin) {
            roleText = @"设置为管理员";
        }
        session.text = [NSString stringWithFormat:@"\"%@\"被\"%@%@\"",message.nickName, message.sender,roleText];
    }

    return session;
}

-(NSString*)getMemberName:(NSString*)phone andNickName:(NSString*)nickName {
    NSString *name = [[DemoGlobalClass sharedInstance] getOtherNameWithPhone:phone];
    if ([name isEqualToString:phone] || name.length==0) {
        name = (nickName.length==0?phone:nickName);
    }
    return name;
}

-(NSString*)getGroupName:(NSString*)groupId andGroupName:(NSString*)groupName {
    NSString * name = [[IMMsgDBAccess sharedInstance] getGroupNameOfId:groupId];
    if (name.length > 0) {
        return name;
    }
    
    if (groupName.length>0) {
        return groupName;
    }
    return groupId;
}
@end
