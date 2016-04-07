//
//  DeviceDelegateHelper+VoIP.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 15/6/30.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "DeviceDelegateHelper+Meeting.h"
#import "VoipIncomingViewController.h"
#import "VideoViewController.h"

@implementation DeviceDelegateHelper(Meeting)

/**
 @brief 有会议呼叫邀请
 @param callid      会话id
 @param calltype    呼叫类型
 @param meetingData 会议的数据
 */
- (NSString*)onMeetingCallReceived:(NSString*)callid withCallType:(CallType)calltype withMeetingData:(NSDictionary*)meetingData {
    
    if ([DemoGlobalClass sharedInstance].isCallBusy) {
        [[ECDevice sharedInstance].VoIPManager rejectCall:callid andReason:ECErrorType_CallBusy];
        return @"";
    }
    
    UIViewController *incomingCallView = nil;
    if (calltype == VIDEO) {
        VideoViewController *incomingVideoView = [[VideoViewController alloc] initWithCallerName:meetingData[ECMeetingDelegate_CallerName] andVoipNo:meetingData[ECMeetingDelegate_CallerPhone] andCallstatus:1];
        incomingVideoView.callID = callid;
        incomingCallView = incomingVideoView;
    } else {
        VoipIncomingViewController* incomingVoiplView = [[VoipIncomingViewController alloc] initWithName:meetingData[ECMeetingDelegate_CallerName] andPhoneNO:meetingData[ECMeetingDelegate_CallerPhone] andCallID:callid];
        incomingVoiplView.contactVoip = meetingData[ECMeetingDelegate_CallerConfId];
        incomingVoiplView.status = IncomingCallStatus_incoming;
        incomingCallView = incomingVoiplView;
    }
    
    id rootviewcontroller = [AppDelegate shareInstance].window.rootViewController;
    if ([rootviewcontroller isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *nav = (UINavigationController*)rootviewcontroller;
        if (nav.visibleViewController!=nil) {
            rootviewcontroller = nav.visibleViewController;
        } else {
            rootviewcontroller = nav.topViewController;
        }
        [rootviewcontroller presentViewController:incomingCallView animated:YES completion:nil];
    } else if ([rootviewcontroller isKindOfClass:[UIViewController class]]) {
        [rootviewcontroller presentViewController:incomingCallView animated:YES completion:nil];
    }
    [DemoGlobalClass sharedInstance].isCallBusy = YES;
    return nil;
}

-(void)onReceiveInterphoneMeetingMsg:(ECInterphoneMeetingMsg *)message {
    
//    [[AppDelegate shareInstance] toast:@"onReceiveInterphoneMeetingMsg 收到"];
    
    if (message.type == Interphone_INVITE) {
        
        if (message.interphoneId.length > 0) {
            BOOL isExist = NO;
            for (NSString *interphoneid in [DemoGlobalClass sharedInstance].interphoneArray) {
                if ([interphoneid isEqualToString:message.interphoneId]) {
                    isExist = YES;
                    break;
                }
            }
            
            if (!isExist) {
                [[DemoGlobalClass sharedInstance].interphoneArray addObject:message.interphoneId];
            }
        }
        
    } else if (message.type == Interphone_OVER) {
        
        if (message.interphoneId.length > 0) {
            for (NSString *interphoneid in [DemoGlobalClass sharedInstance].interphoneArray) {
                if ([interphoneid isEqualToString:message.interphoneId]) {
                    [[DemoGlobalClass sharedInstance].interphoneArray removeObject:interphoneid];
                    break;
                }
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onReceiveInterphoneMeetingMsg object:message];
}

-(void)onReceiveMultiVoiceMeetingMsg:(ECMultiVoiceMeetingMsg *)message {
//    [[AppDelegate shareInstance] toast:@"onReceiveMultiVoiceMeetingMsg 收到"];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onReceiveMultiVoiceMeetingMsg object:message];
}

- (void)onReceiveMultiVideoMeetingMsg:(ECMultiVideoMeetingMsg *)msg
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onReceiveMultiVideoMeetingMsg object:msg];
}
@end
