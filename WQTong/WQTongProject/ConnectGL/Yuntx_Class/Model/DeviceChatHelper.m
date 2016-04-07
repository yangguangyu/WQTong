//
//  DeviceChatHelper.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/15.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "DeviceChatHelper.h"
#import "EmojiConvertor.h"

@implementation DeviceChatHelper
{
    SystemSoundID sendSound;
}

+(DeviceChatHelper*)sharedInstance{
    static dispatch_once_t DeviceChatHelperOnce;
    static DeviceChatHelper *deviceChatHelper;
    dispatch_once(&DeviceChatHelperOnce, ^{
        deviceChatHelper = [[DeviceChatHelper alloc] init];
    });
    return deviceChatHelper;
}

-(instancetype)init{
    if (self = [super init]) {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"sendmsgsuc"
                                                              ofType:@"caf"];
        NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
        OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL,
                                                        &sendSound);
        if (err != kAudioServicesNoError)
            NSLog(@"Could not load %@, error code: %d", soundURL, (int)err);
    }
    return self;
}

-(void)playSendMsgSound{
    
    if ([DemoGlobalClass sharedInstance].isMessageSound){
        //播放声音
        AudioServicesPlaySystemSound(sendSound);
    }
}
- (void)dealloc{
    AudioServicesDisposeSystemSoundID(sendSound);
}
/**
 @brief 设置进度
 @discussion 用户需实现此接口用以支持进度显示
 @param progress 值域为0到1.0的浮点数
 @param message  某一条消息的progress
 @result
 */
- (void)setProgress:(float)progress forMessage:(ECMessage *)message{
    NSLog(@"DeviceChatHelper setprogress %f,messageId=%@,from=%@,to=%@,session=%@",progress,message.messageId,message.from,message.to,message.sessionId);
}

-(ECMessage*)sendLocationMessage:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)title to:(NSString*)to {
    ECLocationMessageBody *messageBody = [[ECLocationMessageBody alloc] initWithCoordinate:coordinate andTitle:title];
    
    ECMessage *message = [[ECMessage alloc] initWithReceiver:to body:messageBody];
    message.userData = nil;
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    
#warning 入库前设置本地时间，以本地时间排序和以本地时间戳获取本地数据库缓存数据
    message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    
    [[ECDevice sharedInstance].messageManager sendMessage:message progress:self completion:^(ECError *error, ECMessage *amessage) {
        
        if (error.errorCode == ECErrorType_NoError) {
            [self playSendMsgSound];
        } else if (error.errorCode == ECErrorType_Have_Forbid || error.errorCode == ECErrorType_File_Have_Forbid) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您已被禁言" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        } else if (error.errorCode == ECErrorType_ContentTooLong) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error.errorDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
        
        [[IMMsgDBAccess sharedInstance] updateState:message.messageState ofMessageId:message.messageId andSession:message.sessionId];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SendMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:amessage}];
    }];
    
    [[DeviceDBHelper sharedInstance] addNewMessage:message andSessionId:message.sessionId];
    
    return message;
}

-(ECMessage*)sendTextMessage:(NSString*)text to:(NSString*)to{
    
    return [self sendTextMessage:text to:to withUserData:nil];
}

-(ECMessage*)sendTextMessage:(NSString*)text to:(NSString*)to withUserData:(NSString*)userData {
    text = [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:text];
    
    ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] initWithText:text];
    ECMessage *message = [[ECMessage alloc] initWithReceiver:to body:messageBody];
    message.userData = userData;
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    
#warning 入库前设置本地时间，以本地时间排序和以本地时间戳获取本地数据库缓存数据
    message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    
    if ([KDeskNumber isEqualToString:to]) {
        [[ECDevice sharedInstance].messageManager sendToDeskMessage:message progress:self completion:^(ECError *error, ECMessage *amessage) {
            
            if (error.errorCode == ECErrorType_NoError) {
                [self playSendMsgSound];
            } else if (error.errorCode == ECErrorType_Have_Forbid || error.errorCode == ECErrorType_File_Have_Forbid) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您已被禁言" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            } else if (error.errorCode == ECErrorType_ContentTooLong) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error.errorDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
            
            [[IMMsgDBAccess sharedInstance] updateState:message.messageState ofMessageId:message.messageId andSession:message.sessionId];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SendMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:amessage}];
        }];
    } else {
        [[ECDevice sharedInstance].messageManager sendMessage:message progress:self completion:^(ECError *error, ECMessage *amessage) {
            
            if (error.errorCode == ECErrorType_NoError) {
                [self playSendMsgSound];
            } else if (error.errorCode == ECErrorType_Have_Forbid || error.errorCode == ECErrorType_File_Have_Forbid) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您已被禁言" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            } else if (error.errorCode == ECErrorType_ContentTooLong) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error.errorDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
            
            [[IMMsgDBAccess sharedInstance] updateState:message.messageState ofMessageId:message.messageId andSession:message.sessionId];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SendMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:amessage}];
        }];
    }
    
    [[DeviceDBHelper sharedInstance] addNewMessage:message andSessionId:message.sessionId];
    
    return message;
}

-(ECMessage*)sendMediaMessage:(ECFileMessageBody*)mediaBody to:(NSString*)to withUserData:(NSString*)userData {
    
    ECMessage *message = [[ECMessage alloc] initWithReceiver:to body:mediaBody];
    message.userData = userData;
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    
#warning 入库前设置本地时间，以本地时间排序和以本地时间戳获取本地数据库缓存数据
    message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    
    if (![KDeskNumber isEqualToString:to]) {
        
        [[ECDevice sharedInstance].messageManager sendMessage:message progress:self completion:^(ECError *error, ECMessage *message) {
            
            if (error.errorCode == ECErrorType_NoError) {
                [self playSendMsgSound];
            } else if (error.errorCode == ECErrorType_Have_Forbid || error.errorCode == ECErrorType_File_Have_Forbid) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您已被禁言" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            } else if (error.errorCode == ECErrorType_ContentTooLong) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error.errorDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
            
            [[IMMsgDBAccess sharedInstance] updateState:message.messageState ofMessageId:message.messageId andSession:message.sessionId];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SendMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:message}];
        }];
    }
    
    NSLog(@"DeviceChatHelper sendMediaMessage messageid=%@",message.messageId);
    
    [[DeviceDBHelper sharedInstance] addNewMessage:message andSessionId:message.sessionId];
    
    return message;

}

-(ECMessage*)sendMediaMessage:(ECFileMessageBody*)mediaBody to:(NSString*)to{
    
    ECMessage *message = [[ECMessage alloc] initWithReceiver:to body:mediaBody];
    message.userData = @"";
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    
#warning 入库前设置本地时间，以本地时间排序和以本地时间戳获取本地数据库缓存数据
    message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    
    if ([KDeskNumber isEqualToString:to]) {
        [[ECDevice sharedInstance].messageManager sendToDeskMessage:message progress:self completion:^(ECError *error, ECMessage *amessage) {
            
            if (error.errorCode == ECErrorType_NoError) {
                [self playSendMsgSound];
            } else if(error.errorCode == ECErrorType_Have_Forbid || error.errorCode == ECErrorType_File_Have_Forbid) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您已被禁言" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            } else if (error.errorCode == ECErrorType_ContentTooLong) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error.errorDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
            
            [[IMMsgDBAccess sharedInstance] updateState:message.messageState ofMessageId:message.messageId andSession:message.sessionId];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SendMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:amessage}];
        }];
    } else {
        [[ECDevice sharedInstance].messageManager sendMessage:message progress:self completion:^(ECError *error, ECMessage *amessage) {
            
            if (error.errorCode == ECErrorType_NoError) {
                [self playSendMsgSound];
            } else if (error.errorCode == ECErrorType_Have_Forbid || error.errorCode == ECErrorType_File_Have_Forbid) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您已被禁言" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            } else if (error.errorCode == ECErrorType_ContentTooLong) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error.errorDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
            
            [[IMMsgDBAccess sharedInstance] updateState:message.messageState ofMessageId:message.messageId andSession:message.sessionId];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SendMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:amessage}];
        }];
    }
    
    NSLog(@"DeviceChatHelper sendMediaMessage messageid=%@",message.messageId);
    
    [[DeviceDBHelper sharedInstance] addNewMessage:message andSessionId:message.sessionId];
    
    return message;
}

-(void)downloadMediaMessage:(ECMessage*)message andCompletion:(void(^)(ECError *error, ECMessage* message))completion{
    
    ECFileMessageBody *mediaBody = (ECFileMessageBody*)message.messageBody;
    mediaBody.localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:mediaBody.displayName];
        
    [[ECDevice sharedInstance].messageManager downloadMediaMessage:message progress:self completion:^(ECError *error, ECMessage *message) {
        if (error.errorCode == ECErrorType_NoError) {
            [[IMMsgDBAccess sharedInstance] updateMessageLocalPath:message.messageId withPath:mediaBody.localPath withDownloadState:((ECFileMessageBody*)message.messageBody).mediaDownloadStatus andSession:message.sessionId];
        } else {
            mediaBody.localPath = nil;
            [[IMMsgDBAccess sharedInstance] updateMessageLocalPath:message.messageId withPath:@"" withDownloadState:((ECFileMessageBody*)message.messageBody).mediaDownloadStatus andSession:message.sessionId];
        }
        
        if (completion != nil) {
            completion(error, message);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_DownloadMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:message}];

    }];
}

//重发消息
-(ECMessage*)resendMessage:(ECMessage*)message{
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    
    if (message.messageBody.messageBodyType == MessageBodyType_Text) {
        ECTextMessageBody *messageBody = (ECTextMessageBody *)message.messageBody;
        messageBody.text = [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:messageBody.text];
    }
#warning 入库前设置本地时间，以本地时间排序和以本地时间戳获取本地数据库缓存数据
    message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    
    NSString *oldMsgId = message.messageId;
    if ([KDeskNumber isEqualToString:message.to]) {
        message.messageId = [[ECDevice sharedInstance].messageManager sendToDeskMessage:message progress:self completion:^(ECError *error, ECMessage *amessage) {
            
            if (error.errorCode == ECErrorType_NoError) {
                [self playSendMsgSound];
            } else if (error.errorCode == ECErrorType_Have_Forbid || error.errorCode == ECErrorType_File_Have_Forbid) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您已被禁言" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            } else if (error.errorCode == ECErrorType_ContentTooLong) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error.errorDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
            
            [[IMMsgDBAccess sharedInstance] updateState:message.messageState ofMessageId:message.messageId andSession:message.sessionId];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SendMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:amessage}];
        }];
    } else {
        message.messageId = [[ECDevice sharedInstance].messageManager sendMessage:message progress:self completion:^(ECError *error, ECMessage *amessage) {
            
            if (error.errorCode == ECErrorType_NoError) {
                [self playSendMsgSound];
            } else if (error.errorCode == ECErrorType_Have_Forbid || error.errorCode == ECErrorType_File_Have_Forbid) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您已被禁言" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            } else if (error.errorCode == ECErrorType_ContentTooLong) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error.errorDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
            
            [[IMMsgDBAccess sharedInstance] updateState:message.messageState ofMessageId:message.messageId andSession:message.sessionId];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SendMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:amessage}];
        }];
    }
    
    //更新消息id
    [[DeviceDBHelper sharedInstance] updateMessageId:message andTime:(long long)tmp ofMessageId:oldMsgId];

    return nil;
}

//创建文件存储路径
- (NSString *)createSavePath {
    //文件名使用 "voiceFile+当前时间的时间戳"
    NSString *fileName = [self createFileName];
    
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *writeFilePath = [cacheDir stringByAppendingPathComponent:fileName];
    BOOL isExist =  [[NSFileManager defaultManager]fileExistsAtPath:writeFilePath];
    if (isExist) {
        //如果存在则移除 以防止 文件冲突
        NSError *err = nil;
        [[NSFileManager defaultManager]removeItemAtPath:writeFilePath error:&err];
    }
    
    return writeFilePath;
}

- (NSString *)createFileName {
    NSString *fileName = [NSString stringWithFormat:@"voiceFile%lld.amr",(long long)[NSDate timeIntervalSinceReferenceDate]];
    return fileName;
}
@end
