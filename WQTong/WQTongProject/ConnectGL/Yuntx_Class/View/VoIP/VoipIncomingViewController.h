/*
 *  Copyright (c) 2013 The CCP project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a Beijing Speedtong Information Technology Co.,Ltd license
 *  that can be found in the LICENSE file in the root of the web site.
 *
 *                    http://www.yuntongxun.com
 *
 *  An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#define InComingCall1 0  //呼入
#define OutGoingCall1 1  //呼出
#define MuteFlagIsMute1 1 //静音
#define MuteFlagNotMute1 0 //非静音

#define kCallBg02pngVoip            @"call_bg02.png"

typedef enum
{
    IncomingCallStatus_accepting = 19,
    IncomingCallStatus_incoming,
    IncomingCallStatus_accepted,
    IncomingCallStatus_over
}IncomingCallStatus;

@interface VoipIncomingViewController : UIViewController
{
    int hhInt;
    int mmInt;
    int ssInt;
    NSTimer *timer;
    UIImageView *backgroundImg;
    BOOL isLouder;
}

@property(nonatomic, strong) UIView* bgView; //适配ios7使用
@property(nonatomic, strong) NSString *contactName;
@property(nonatomic, strong) NSString *contactPhoneNO;
@property(nonatomic, strong) NSString *contactVoip;
@property(nonatomic, strong) UILabel *lblIncoming;
@property(nonatomic, strong) UILabel *lblName;
@property(nonatomic, strong) UILabel *lblPhoneNO;
@property(nonatomic, strong) UIView *functionAreaView;
@property(nonatomic, strong) UIImage   *contactPortrait;
@property(nonatomic, strong) NSString *callID;

//挂断电话
@property (nonatomic, strong) UIButton *hangUpButton;
//拒接
@property (nonatomic, strong) UIButton *rejectButton;
//接听
@property (nonatomic, strong) UIButton *answerButton;
//键盘
@property (nonatomic, strong) UIButton *KeyboardButton;
//免提
@property (nonatomic, strong) UIButton *handfreeButton;
//静音
@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic,assign) IncomingCallStatus status;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *netStatusLabel;
@property (nonatomic, strong) UILabel *p2pStatusLabel;
@property (nonatomic, strong) UIActionSheet *menuActionSheet;
- (id)initWithName:(NSString *)name andPhoneNO:(NSString *)phoneNO andCallID:(NSString*)callid;

@end
