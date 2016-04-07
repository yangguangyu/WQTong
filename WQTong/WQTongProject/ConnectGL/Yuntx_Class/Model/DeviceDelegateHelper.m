//
//  DeviceDelegateHelper.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "DeviceDelegateHelper.h"
#import "EmojiConvertor.h"
#import "UIImageView+WebCache.h"
#import "ECMultiDeviceState.h"

#define LOG_OPEN 0

@interface DeviceDelegateHelper()
@property(atomic, assign) NSUInteger offlineCount;
@end

@implementation DeviceDelegateHelper{
    SystemSoundID receiveSound;
}

+(DeviceDelegateHelper*)sharedInstance{
    static DeviceDelegateHelper *devicedelegatehelper;
    static dispatch_once_t devicedelegatehelperonce;
    dispatch_once(&devicedelegatehelperonce, ^{
        devicedelegatehelper = [[DeviceDelegateHelper alloc] init];
    });
    return devicedelegatehelper;
}

-(instancetype)init{
    if (self = [super init]) {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"receive_msg"
                                                              ofType:@"caf"];
        NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
        OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL,
                                                        &receiveSound);
        if (err != kAudioServicesNoError)
            NSLog(@"Could not load %@, error code: %d", soundURL, (int)err);
    }
    return self;
}
- (void)dealloc
{
    AudioServicesDisposeSystemSoundID(receiveSound);
}
#if LOG_OPEN
-(void)onLogInfo:(NSString*)log {
    NSLog(@"ECDeviceSDK LOG:%@",log);
}
#endif

-(void)playRecMsgSound:(NSString*)sessionId{
    
//后台切前台接收消息判断
    if (self.preDate==nil) {
        self.preDate = [NSDate date];
    }
    
    if (self.isB2F && self.preDate != nil && [self.preDate timeIntervalSinceNow]>-1) {
        self.preDate = [NSDate date];
        return;
    }
    
    self.isB2F = NO;
    
//是否在会话里接收消息
    BOOL isChat = NO;
    if (self.sessionId.length>0 && sessionId.length>0 && [self.sessionId isEqualToString:sessionId]) {
        isChat = YES;
    }
    
    if (![[IMMsgDBAccess sharedInstance] isNoticeOfGroupId:sessionId]) {
        return;
    }
//查看设置
    if ([DemoGlobalClass sharedInstance].isMessageSound && !isChat) {
        //播放声音
        AudioServicesPlaySystemSound(receiveSound);
    }
    
    if ([DemoGlobalClass sharedInstance].isMessageShake){
        //震动
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
}

/**
 @brief 网络改变后调用的代理方法
 @param status 网络状态值
 */
- (void)onReachbilityChanged:(ECNetworkType)status{
    [DemoGlobalClass sharedInstance].netType = status;
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onNetworkChanged object:@(status)];
}

/**
 @brief 系统事件通知
 @param CCPEvents 包含的系统事件
 */
- (void)onSystemEvents:(CCPEvents)events{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onSystemEvent object:@(events)];
}

#if 0

/**
 @brief 连接状态接口
 @discussion 监听与服务器的连接状态 V4.0版本接口
 @param error 连接的状态
 */
-(void)onConnected:(ECError *)error{
    NSLog(@"\r==========\ronConnected errorcode=%d\r============", (int)error.errorCode);
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onConnected object:error];
}

#else

/**
 @brief 连接状态接口
 @discussion 监听与服务器的连接状态 V5.0版本接口
 @param state 连接的状态
 @param error 错误原因值
 */
-(void)onConnectState:(ECConnectState)state failed:(ECError*)error {
    switch (state) {
        case State_ConnectSuccess:
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onConnected object:[ECError errorWithCode:ECErrorType_NoError]];
            break;
        case State_Connecting:
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onConnected object:[ECError errorWithCode:ECErrorType_Connecting]];
            break;
        case State_ConnectFailed:
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onConnected object:error];
            break;
        default:
            break;
    }
}

#endif

/**
 @brief 个人信息版本号
 @param version 服务器上的个人信息版本号
 */
-(void)onServicePersonVersion:(unsigned long long)version {
    if ([DemoGlobalClass sharedInstance].dataVersion==0 && version==0) {
        [DemoGlobalClass sharedInstance].isNeedSetData = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_needInputName object:nil];
    } else if (version>[DemoGlobalClass sharedInstance].dataVersion) {
        [[ECDevice sharedInstance] getPersonInfo:^(ECError *error, ECPersonInfo *person) {
            if (error.errorCode == ECErrorType_NoError) {
                [DemoGlobalClass sharedInstance].dataVersion = person.version;
                [DemoGlobalClass sharedInstance].birth = person.birth;
                [DemoGlobalClass sharedInstance].nickName = person.nickName;
                [DemoGlobalClass sharedInstance].sex = person.sex;
                [DemoGlobalClass sharedInstance].sign = person.sign;
            }
        }];
    }
}

/**
 @brief 最新软件版本号
 @param version 软件版本号
 @param mode 更新模式  1：手动更新 2：强制更新
 */
-(void)onSoftVersion:(NSString*)version andUpdateMode:(NSInteger)mode andUpdateDesc:(NSString*)desc{
    
    NSLog(@"SoftVersion=%@ mode=%ld",version, (long)mode);
    NSComparisonResult result = [version compare:kSofeVer];
    if (result == 1) {
        [DemoGlobalClass sharedInstance].isNeedUpdate=YES;
        [[AppDelegate shareInstance] updateSoftAlertViewShow:(desc.length>0?desc:@"有新版本发布啦！") isForceUpdate:(mode==2)];
    }
}

-(void)onReceiveDeskMessage:(ECMessage*)message{
    if (message.from.length==0) {
        return;
    }
    
    if (message.messageBody.messageBodyType == MessageBodyType_Text) {
        ECTextMessageBody * textmsg = (ECTextMessageBody *)message.messageBody;
        textmsg.text = [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:textmsg.text];
    }
    
#warning 时间全部转换成本地时间
    if (message.timestamp) {
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
        message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    }
    
    [[DeviceDBHelper sharedInstance] addNewMessage:message andSessionId:self.sessionId];
    
    [self playRecMsgSound:message.sessionId];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
    
    if(message.messageBody.messageBodyType > MessageBodyType_Text){
        ECFileMessageBody *body = (ECFileMessageBody*)message.messageBody;
        body.displayName = body.remotePath.lastPathComponent;
        [[DeviceChatHelper sharedInstance] downloadMediaMessage:message andCompletion:nil];
    }
}

/**
 @brief 接收即时消息代理函数
 @param message 接收的消息
 */
-(void)onReceiveMessage:(ECMessage*)message{
    
    if (message.from.length==0 || message.messageBody.messageBodyType==MessageBodyType_Call) {
        return;
    }
    
    if (message.messageBody.messageBodyType == MessageBodyType_Text) {
        ECTextMessageBody * textmsg = (ECTextMessageBody *)message.messageBody;
        textmsg.text = [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:textmsg.text];
    }
    
#warning 时间全部转换成本地时间
    if (message.timestamp) {
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
        message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    }
    
    [[DeviceDBHelper sharedInstance] addNewMessage:message andSessionId:self.sessionId];
    
    //同步过来的发送消息不播放提示音
    if (message.messageState == ECMessageState_Receive) {
        [self playRecMsgSound:message.sessionId];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
    
    MessageBodyType bodyType = message.messageBody.messageBodyType;
    if( bodyType == MessageBodyType_Voice || bodyType == MessageBodyType_Video || bodyType == MessageBodyType_File || bodyType == MessageBodyType_Image){
        ECFileMessageBody *body = (ECFileMessageBody*)message.messageBody;
        body.displayName = body.remotePath.lastPathComponent;
        
        if (message.messageBody.messageBodyType == MessageBodyType_Video) {
            
            ECVideoMessageBody *videoBody = (ECVideoMessageBody *)message.messageBody;
            
            if (videoBody.thumbnailRemotePath == nil) {
                videoBody.displayName = videoBody.remotePath.lastPathComponent;
                [[DeviceChatHelper sharedInstance] downloadMediaMessage:message andCompletion:nil];
            }
            
        } else {
            [[DeviceChatHelper sharedInstance] downloadMediaMessage:message andCompletion:nil];
        }
    }
}

- (void)onReceiveMessageNotify:(ECMessageNotifyMsg *)message {
    NSLog(@"onReceiveMessageNotify:--%@",message);
    ECMessageDeleteNotifyMsg *msg = (ECMessageDeleteNotifyMsg*)message;
    
    [[IMMsgDBAccess sharedInstance] updateMessageLocalPath:msg.messageId withPath:@"" withDownloadState:ECMediaDownloadSuccessed andSession:msg.sender];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_ReceiveMessageDelete object:nil userInfo:@{@"msgid":msg.messageId, @"sessionid":msg.sender}];
}
/**
 @brief 离线消息数
 @param count 消息数
 */
-(void)onOfflineMessageCount:(NSUInteger)count{
    NSLog(@"onOfflineMessageCount=%lu",(unsigned long)count);
    self.offlineCount = count;
}

/**
 @brief 需要获取的消息数
 @return 消息数 -1:全部获取 0:不获取
 */
-(NSInteger)onGetOfflineMessage{
    NSInteger retCount = -1;
    if (self.offlineCount!=0) {
        /*
        if (self.offlineCount>100) {
            retCount = 100;
        }
        */
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_haveHistoryMessage object:nil];
        });
    }
    return retCount;
}

/**
 @brief 接收离线消息代理函数
 @param message 接收的消息
 */
-(void)onReceiveOfflineMessage:(ECMessage*)message{
    if (message.from.length==0 || message.messageBody.messageBodyType==MessageBodyType_Call) {
        if (message.messageBody.messageBodyType==MessageBodyType_Call) {
            [[DeviceDBHelper sharedInstance] addNewMessage:message andSessionId:self.sessionId];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
        }
        return;
    }
    
    if (message.messageBody.messageBodyType == MessageBodyType_Text) {
        ECTextMessageBody * textmsg = (ECTextMessageBody *)message.messageBody;
        textmsg.text = [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:textmsg.text];
    }
    
#warning 时间全部转换成本地时间
    if (!message.timestamp) {
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
        message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    }
    
    [[DeviceDBHelper sharedInstance] addNewMessage:message andSessionId:self.sessionId];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
    
    MessageBodyType bodyType = message.messageBody.messageBodyType;
    if( bodyType == MessageBodyType_Voice || bodyType == MessageBodyType_Video || bodyType == MessageBodyType_File || bodyType == MessageBodyType_Image){
        ECFileMessageBody *body = (ECFileMessageBody*)message.messageBody;
        body.displayName = body.remotePath.lastPathComponent;
        
        if (message.messageBody.messageBodyType == MessageBodyType_Video) {
            ECVideoMessageBody *videoBody = (ECVideoMessageBody *)message.messageBody;
            if (videoBody.thumbnailRemotePath == nil) {
                videoBody.displayName = videoBody.remotePath.lastPathComponent;
                [[DeviceChatHelper sharedInstance] downloadMediaMessage:message andCompletion:nil];
            }
        } else {
            [[DeviceChatHelper sharedInstance] downloadMediaMessage:message andCompletion:nil];
        }
    }
}

/**
 @brief 离线消息接收是否完成
 @param isCompletion YES:拉取完成 NO:拉取未完成(拉取消息失败)
 */
-(void)onReceiveOfflineCompletion:(BOOL)isCompletion {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_HistoryMessageCompletion object:nil];
    });
    [self playRecMsgSound:nil];
}

/**
 @brief 客户端录音振幅代理函数
 @param amplitude 录音振幅
 */
-(void)onRecordingAmplitude:(double) amplitude{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onRecordingAmplitude object:@(amplitude)];
}

/**
 @brief 接收群组相关消息
 @discussion 参数要根据消息的类型，转成相关的消息类；
 解散群组、收到邀请、申请加入、退出群组、有人加入、移除成员等消息
 @param groupMsg 群组消息
 */
-(void)onReceiveGroupNoticeMessage:(ECGroupNoticeMessage *)groupMsg{
    
#warning 时间全部转换成本地时间
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    groupMsg.dateCreated = [NSString stringWithFormat:@"%lld", (long long)tmp];
    
    [[DeviceDBHelper sharedInstance] addNewGroupMessage:groupMsg];
    if (groupMsg.messageType ==ECGroupMessageType_Dissmiss) {
        
        [[DeviceDBHelper sharedInstance] deleteAllMessageOfSession:groupMsg.groupId];
        
    } else if (groupMsg.messageType == ECGroupMessageType_RemoveMember) {
        
        ECRemoveMemberMsg *message = (ECRemoveMemberMsg *)groupMsg;
        if ([message.member isEqualToString:[DemoGlobalClass sharedInstance].userName]) {
            [[DeviceDBHelper sharedInstance] deleteAllMessageOfSession:groupMsg.groupId];
        }
    }
    [self playRecMsgSound:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onReceivedGroupNotice object:groupMsg];
}

@end
