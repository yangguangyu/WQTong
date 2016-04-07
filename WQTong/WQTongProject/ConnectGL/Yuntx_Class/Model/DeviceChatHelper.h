//
//  DeviceChatHelper.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/15.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>

#import "ECFileMessageBody.h"

#define KNOTIFICATION_SendMessageCompletion       @"KNOTIFICATION_SendMessageCompletion"
#define KNOTIFICATION_DownloadMessageCompletion   @"KNOTIFICATION_DownloadMessageCompletion"
#define KNOTIFICATION_ReceiveMessageDelete   @"KNOTIFICATION_ReceiveMessageDelete"

#define KErrorKey   @"kerrorkey"
#define KMessageKey @"kmessagekey"


@interface DeviceChatHelper : NSObject<ECProgressDelegate>

+(DeviceChatHelper*)sharedInstance;

-(ECMessage*)sendLocationMessage:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)title to:(NSString*)to;

-(ECMessage*)sendTextMessage:(NSString*)text to:(NSString*)to;
-(ECMessage*)sendTextMessage:(NSString*)text to:(NSString*)to withUserData:(NSString*)userData;

-(ECMessage*)sendMediaMessage:(ECFileMessageBody*)mediaBody to:(NSString*)to withUserData:(NSString*)userData;

-(ECMessage*)sendMediaMessage:(ECFileMessageBody*)mediaBody to:(NSString*)to;

-(ECMessage*)resendMessage:(ECMessage*)message;

-(void)downloadMediaMessage:(ECMessage*)message andCompletion:(void(^)(ECError *error, ECMessage* message))completion;;

- (NSString *)createSavePath;
@end
