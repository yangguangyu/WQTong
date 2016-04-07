//
//  DeviceDelegateHelper+VoIP.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 15/6/30.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "DeviceDelegateHelper.h"
#import "DeviceDelegateHelper+VoIP.h"
#import "VoipIncomingViewController.h"
#import "VideoViewController.h"
#import "AppDelegate.h"

@implementation DeviceDelegateHelper(VoIP)
//有呼叫进入
- (NSString*)onIncomingCallReceived:(NSString*)callid withCallerAccount:(NSString *)caller withCallerPhone:(NSString *)callerphone withCallerName:(NSString *)callername withCallType:(CallType)calltype {
    [AppDelegate shareInstance].callid = nil;
    if ([DemoGlobalClass sharedInstance].isCallBusy) {
        [[ECDevice sharedInstance].VoIPManager rejectCall:callid andReason:ECErrorType_CallBusy];
        return @"";
    }
    
    UIViewController *incomingCallView = nil;
    if (calltype == VIDEO) {
        VideoViewController *incomingVideoView = [[VideoViewController alloc] initWithCallerName:callername andVoipNo:caller andCallstatus:1];
        incomingVideoView.callID = callid;
        incomingCallView = incomingVideoView;
    } else {
        VoipIncomingViewController* incomingVoiplView = [[VoipIncomingViewController alloc] initWithName:callername andPhoneNO:callerphone andCallID:callid];
        incomingVoiplView.contactVoip = caller;
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

//呼叫事件
- (void)onCallEvents:(VoIPCall*)voipCall {
    if (voipCall.callStatus == ECallStreaming) {
        [DemoGlobalClass sharedInstance].isCallBusy = YES;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onCallEvent object:voipCall];
}

/**
 @brief 收到dtmf
 @param callid 会话id
 @param dtmf   键值
 */
- (void)onReceiveFrom:(NSString *)callid DTMF:(NSString *)dtmf {
    
}


/**
 @brief 收到对方切换音视频的请求
 @param callid  会话id
 @param requestType 视频:需要响应 音频:请求删除视频（不需要响应，双方自动去除视频）
 */
- (void)onSwitchCallMediaTypeRequest:(NSString *)callid withMediaType:(CallType)requestType {
    [[ECDevice sharedInstance].VoIPManager responseSwitchCallMediaType:callid withMediaType:requestType];
}

/**
 @brief 收到对方应答切换音视频请求
 @param callid   会话id
 @param responseType
 */
- (void)onSwitchCallMediaTypeResponse:(NSString *)callid withMediaType:(CallType)responseType {
    
}

- (NSString*)onGetOfflineCallId {
    NSLog(@"推送 onGetOfflineCallId=%@", [AppDelegate shareInstance].callid);
    return [AppDelegate shareInstance].callid;
}

@end
