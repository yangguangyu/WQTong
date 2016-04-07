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
#define kKeyboardBtnpng             @"dial_icon.png"
#define kKeyboardBtnOnpng           @"dial_icon_on.png"
#define kHandsfreeBtnpng            @"handsfree_icon.png"
#define kHandsfreeBtnOnpng          @"handsfree_icon_on.png"
#define kMuteBtnpng                 @"mute_icon.png"
#define kMuteBtnOnpng               @"mute_icon_on.png"
NSString * const kCallBg01pngVoip           = @"call_bg01.png";
NSString * const kCallHangUpButtonpng       = @"call_hang_up_button.png";
NSString * const kCallHangUpButtonOnpng     = @"call_hang_up_button_on.png";

#import "VoipCallController.h"
#import "AppDelegate.h"
#import "ECDeviceHeaders.h"

#import "DeviceDelegateHelper.h"
#import "DeviceDelegateHelper+VoIP.h"

@interface VoipCallController ()
{
    BOOL isShowKeyboard;
    BOOL isKickOff;
}
@property (nonatomic,retain) UIView *keyboardView;

- (void)handfree;
- (void)mute;
- (void)hangupCall;
- (void)backFronts;
- (void)releaseCall;
- (void)showKeyboardView;
@end

@implementation VoipCallController

- (VoipCallController *)initWithCallerName:(NSString *)name andCallerNo:(NSString *)phoneNo andVoipNo:(NSString *)voipNo andCallType:(NSInteger)type
{
    if (self = [super init])
    {
        self.callerName = name;
        self.callerNo = phoneNo;
        self.voipNo = voipNo;
        hhInt = 0;
        mmInt = 0;
        ssInt = 0;
        isLouder = NO;
        isKickOff = NO;
        voipCallType = type;
        [ [ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:isLouder];
        return self;
    }
    
    return nil;
}

- (void)loadView
{
    UIView *tmpView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.bgView = tmpView;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
#if __IPHONE_7_0
        self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
        [self.view addSubview:self.bgView];
#else
        self.view = self.bgView;
#endif
    }
    else
    {
        self.view = self.bgView;
    }
    self.bgView.backgroundColor = [UIColor colorWithRed:24/255.0 green:24/255.0 blue:24/255.0 alpha:1.0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    UIImage *backImage = [UIImage imageNamed:kCallBg01pngVoip];
    UIImageView *backGroupImageView = [[UIImageView alloc] initWithImage:backImage];
    backGroupImageView.center = CGPointMake(160.0, self.bgView.frame.size.height*0.5);
    [self.bgView addSubview:backGroupImageView];
    
    //名字
    UILabel *tempCallerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f/2-100.0f, 28.0f, 200.0f, 22.0f)];
    tempCallerNameLabel.text = self.callerName;
    tempCallerNameLabel.font = [UIFont systemFontOfSize:20.0f];
    tempCallerNameLabel.textColor = [UIColor whiteColor];
    tempCallerNameLabel.backgroundColor = [UIColor clearColor];
    tempCallerNameLabel.textAlignment = NSTextAlignmentCenter;
    self.callerNameLabel = tempCallerNameLabel;
    [self.bgView addSubview:self.callerNameLabel];
    
    //电话
    UILabel *tempCallerNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f/2-100.0f, 54.0f, 200.0f, 20.0f)];
    tempCallerNoLabel.text = self.callerNo;
    tempCallerNoLabel.font = [UIFont systemFontOfSize:18.0f];
    tempCallerNoLabel.textColor = [UIColor whiteColor];
    tempCallerNoLabel.backgroundColor = [UIColor clearColor];
    tempCallerNoLabel.textAlignment = NSTextAlignmentCenter;
    self.callerNoLabel = tempCallerNoLabel;
    [self.bgView addSubview:self.callerNoLabel];
    
    //连接状态提示
    UILabel *tempRealTimeStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80.0f, 320.0f, 32.0f)];
    tempRealTimeStatusLabel.numberOfLines = 2;
    tempRealTimeStatusLabel.lineBreakMode = NSLineBreakByWordWrapping;
    tempRealTimeStatusLabel.text = @"网络正在连接请稍后...";
    tempRealTimeStatusLabel.textColor = [UIColor whiteColor];
    tempRealTimeStatusLabel.backgroundColor = [UIColor clearColor];
    tempRealTimeStatusLabel.textAlignment = NSTextAlignmentCenter;
    tempRealTimeStatusLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    self.realTimeStatusLabel = tempRealTimeStatusLabel;
    [self.bgView addSubview:self.realTimeStatusLabel];
    
    UILabel *tempStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f/2-150.0f, 106.0f, 300.0f, 16.0f)];
    tempStatusLabel.text = @"";
    tempStatusLabel.textColor = [UIColor whiteColor];
    tempStatusLabel.backgroundColor = [UIColor clearColor];
    tempStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel = tempStatusLabel;
    [self.bgView addSubview:self.statusLabel];
    
    UILabel *tempNetStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f/2-150.0f, 126.0f, 300.0f, 28)];
    tempNetStatusLabel.text = @"";
    tempNetStatusLabel.textColor = [UIColor whiteColor];
    tempNetStatusLabel.backgroundColor = [UIColor clearColor];
    tempNetStatusLabel.textAlignment = NSTextAlignmentCenter;
    tempNetStatusLabel.font = [UIFont systemFontOfSize:11];
    tempNetStatusLabel.numberOfLines = 0;
    tempNetStatusLabel.lineBreakMode = 0;
    self.netStatusLabel = tempNetStatusLabel;
    [self.bgView addSubview:self.netStatusLabel];
    
    
    UILabel *tempp2pstatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f/2-150.0f, 156.0f, 300.0f, 16.0f)];
    tempp2pstatusLabel.text = @"";
    tempp2pstatusLabel.textColor = [UIColor whiteColor];
    tempp2pstatusLabel.backgroundColor = [UIColor clearColor];
    tempp2pstatusLabel.textAlignment = NSTextAlignmentCenter;
    self.p2pStatusLabel = tempp2pstatusLabel;
    [self.bgView addSubview:self.p2pStatusLabel];
    
    //免提和静音背景图
    UIView *tempfunctionAreaView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f-10.0f-50.0f-5.0f-10, 320.0f, 50.0f)];
    self.functionAreaView = tempfunctionAreaView;
    tempfunctionAreaView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:tempfunctionAreaView];
    
    isShowKeyboard = NO;
    //键盘显示按钮
    UIButton *tempKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.KeyboardButton = tempKeyboardButton;
    tempKeyboardButton.frame = CGRectMake(21, 0.0f, 79, 50);
    [tempKeyboardButton setImage:[UIImage imageNamed:kKeyboardBtnpng] forState:UIControlStateNormal];
    tempKeyboardButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [tempKeyboardButton setTitle:@"键盘" forState:UIControlStateNormal];
    tempKeyboardButton.titleEdgeInsets  = UIEdgeInsetsMake(50,-29, 0, 0);
    tempKeyboardButton.imageEdgeInsets = UIEdgeInsetsMake(-10,22, 0, 0);
    [tempKeyboardButton addTarget:self action:@selector(showKeyboardView) forControlEvents:UIControlEventTouchUpInside];
    [self.functionAreaView addSubview:tempKeyboardButton];
    
    //静音按钮
    UIButton *tempMuteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tempMuteButton.frame = CGRectMake(111, 0.0f, 79, 50);
    [tempMuteButton setImage:[UIImage imageNamed:@"mute_icon.png"] forState:UIControlStateNormal];      tempMuteButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [tempMuteButton setTitle:@"静音" forState:UIControlStateNormal];
    tempMuteButton.titleEdgeInsets  = UIEdgeInsetsMake(50,-29, 0, 0);
    tempMuteButton.imageEdgeInsets = UIEdgeInsetsMake(-10,21, 0, 0);
    [tempMuteButton addTarget:self action:@selector(mute) forControlEvents:UIControlEventTouchUpInside];
    self.muteButton = tempMuteButton;
    tempMuteButton.enabled = NO;
    [self.functionAreaView addSubview:tempMuteButton];
    
    //免提按钮
    UIButton *tempHandFreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tempHandFreeButton.frame = CGRectMake(201, 0.0f, 79, 50);
    [tempHandFreeButton setImage:[UIImage imageNamed:@"handsfree_icon.png"] forState:UIControlStateNormal];
    tempHandFreeButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [tempHandFreeButton setTitle:@"免提" forState:UIControlStateNormal];
    tempHandFreeButton.titleEdgeInsets  = UIEdgeInsetsMake(50,-29, 0, 0);
    tempHandFreeButton.imageEdgeInsets = UIEdgeInsetsMake(-10,22, 0, 0);
    self.handfreeButton = tempHandFreeButton;   
    tempHandFreeButton.enabled = NO;
    [tempHandFreeButton addTarget:self action:@selector(handfree) forControlEvents:UIControlEventTouchUpInside];
    [self.functionAreaView addSubview:tempHandFreeButton];
    
    //挂机
    UIButton *tempHangupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tempHangupButton.frame = CGRectMake(24.0f, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f, 320.0f-24.0f-24.0f, 42.0f);
    [tempHangupButton setImage:[UIImage imageNamed:kCallHangUpButtonpng] forState:UIControlStateNormal];
    [tempHangupButton setImage:[UIImage imageNamed:kCallHangUpButtonOnpng] forState:UIControlStateHighlighted];
    [tempHangupButton addTarget:self action:@selector(hangupCall) forControlEvents:UIControlEventTouchUpInside];
    self.hangUpButton = tempHangupButton;
    [self.bgView addSubview:self.hangUpButton];
    
    //进来之后先拨号
    if (voipCallType==0) {
        self.callid =[[ECDevice sharedInstance].VoIPManager makeCallWithType:LandingCall andCalled:self.voipNo];

    } else if(voipCallType==1) {
        //等待调用SDK中网络直拨接口
        self.callid = [[ECDevice sharedInstance].VoIPManager makeCallWithType:VOICE andCalled:self.callerNo];
    }
    
    if (voipCallType==2) {
        
        self.realTimeStatusLabel.text = @"正在回拨...";
        self.handfreeButton.hidden = YES;
        self.handfreeButton.enabled = NO;
        self.transferCallButton.hidden = YES;
        self.transferCallButton.enabled = NO;
        self.muteButton.hidden = YES;
        self.muteButton.enabled = NO;
        self.hangUpButton.hidden = NO;
        self.hangUpButton.enabled = YES;
        self.functionAreaView.hidden = YES;
        self.KeyboardButton.hidden = YES;
        self.KeyboardButton.enabled = NO;
        
        ECCallBackEntity *newCall = [[ECCallBackEntity alloc] init];
        newCall.src = [DemoGlobalClass sharedInstance].userName;
        newCall.dest = self.callerNo;
        
        __weak __typeof(self)weakSelf = self;
        [[ECDevice sharedInstance].VoIPManager makeCallback:newCall completion:^(ECError *error, ECCallBackEntity *callBackEntity) {
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (error.errorCode == ECErrorType_NoError) {
                strongSelf.realTimeStatusLabel.text = @"回拨呼叫成功,请注意接听系统来电";
            } else {
                strongSelf.realTimeStatusLabel.font = [UIFont systemFontOfSize:14.0f];
                
                NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                strongSelf.realTimeStatusLabel.text = [NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail];
                [strongSelf.bgView bringSubviewToFront:strongSelf.realTimeStatusLabel];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [strongSelf backFronts];
            });
        }];
        
    } else if (self.callid.length <= 0) {
        
        //获取CallID失败，即拨打失败
        self.realTimeStatusLabel.text = @"对方不在线或网络不给力";
        self.handfreeButton.hidden = YES;
        self.handfreeButton.enabled = NO;
        self.muteButton.hidden = YES;
        self.muteButton.enabled = NO;
        self.hangUpButton.hidden = NO;
        self.hangUpButton.enabled = YES;
        self.functionAreaView.hidden = YES;
        isShowKeyboard = YES;
        [self showKeyboardView];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallEvents:) name:KNOTIFICATION_onCallEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSystemEvents:) name:KNOTIFICATION_onSystemEvent object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor colorWithRed:24/255.0 green:24/255.0 blue:24/255.0 alpha:1.0];
}

- (void)showKeyboardView {
    
    isShowKeyboard = !isShowKeyboard;
    
    if (self.keyboardView == nil) {
        
        CGFloat viewWidth = 86.0f*3;
        CGFloat viewHeight = 46.0*4;
        UIView *tmpKeyboardView = [[UIView alloc] initWithFrame:CGRectMake(160.0f-viewWidth*0.5f, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f-10.0f-80.0f-viewHeight, viewWidth, viewHeight)];
        tmpKeyboardView.backgroundColor = [UIColor clearColor];
        self.keyboardView = tmpKeyboardView;
        [self.bgView addSubview:tmpKeyboardView];
        
        for (NSInteger i = 0; i<4; i++) {
            for (NSInteger j = 0; j<3; j++) {
                //Button alloc
                UIButton* numberButton = [UIButton buttonWithType:UIButtonTypeCustom];
                numberButton.frame = CGRectMake(86.0f*j, 46.0f*i, 86.0f, 46.0f);
                [numberButton addTarget:self action:@selector(dtmfNumber:) forControlEvents:UIControlEventTouchUpInside];
                
                //设置数字图片
                NSInteger numberNum = i*3+j+1;
                if (numberNum == 11) {
                    numberNum = 0;
                } else if (numberNum == 12) {
                    numberNum = 11;
                }
                NSString * numberImgName = [NSString stringWithFormat:@"keyboard_%0.2ld.png",(long)numberNum];
                NSString * numberImgOnName = [NSString stringWithFormat:@"keyboard_%0.2ld_on.png",(long)numberNum];
                numberButton.tag = 1000 + numberNum;
                
                [numberButton setImage:[UIImage imageNamed:numberImgName] forState:UIControlStateNormal];
                [numberButton setImage:[UIImage imageNamed:numberImgOnName] forState:UIControlStateHighlighted];
                
                [self.keyboardView addSubview:numberButton];
            }
        }
    }
    
    if (isShowKeyboard) {
        [self.bgView bringSubviewToFront:self.keyboardView];
        [self.KeyboardButton setImage:[UIImage imageNamed:kKeyboardBtnOnpng] forState:UIControlStateNormal];
        [self.KeyboardButton setTitleColor:[UIColor colorWithRed:46/255.0 green:184/255.0 blue:111/255.0 alpha:1] forState:UIControlStateNormal];
    } else {
        [self.KeyboardButton setImage:[UIImage imageNamed:kKeyboardBtnpng] forState:UIControlStateNormal];
        [self.KeyboardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.keyboardView removeFromSuperview];
        self.keyboardView = nil;
    }
}

- (void)dtmfNumber:(id)sender {
    NSString *numberString = nil;
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 1000:
            numberString = @"0";
            break;
        case 1001:
            numberString = @"1";
            break;
        case 1002:
            numberString = @"2";
            break;
        case 1003:
            numberString = @"3";
            break;
        case 1004:
            numberString = @"4";
            break;
        case 1005:
            numberString = @"5";
            break;
        case 1006:
            numberString = @"6";
            break;
        case 1007:
            numberString = @"7";
            break;
        case 1008:
            numberString = @"8";
            break;
        case 1009:
            numberString = @"9";
            break;
        case 1010:
            numberString = @"*";
            break;
        case 1011:
            numberString = @"#";
            break;
        default:
            numberString = @"#";
            break;
    }
    [[ECDevice sharedInstance].VoIPManager sendDTMF:self.callid dtmf:numberString];
    
}

- (void)updateRealtimeLabel {
    
    ssInt +=1;
    if (ssInt >= 60) {
        mmInt += 1;
        ssInt -= 60;
        if (mmInt >=  60) {
            hhInt += 1;
            mmInt -= 60;
            if (hhInt >= 24) {
                hhInt = 0;
            }
        }
    }
        
    if (hhInt > 0) {
        self.realTimeStatusLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hhInt,mmInt,ssInt];
    } else {
        self.realTimeStatusLabel.text = [NSString stringWithFormat:@"%02d:%02d",mmInt,ssInt];
    }
    //获取网络流量情况，因为需要实时获取，因此需要在定时器里，每隔一段时间获取一次才可以。第一次默认调用是为0
//    NetworkStatistic *net = [[ECDevice sharedInstance].VoIPManager getNetworkStatisticWithCallId:self.callid];
//    NSLog(@"NetworkStatistic-%lld_%lld_%lld",net.txBytes_wifi,net.rxBytes_wifi,net.duration);
    //同上
//    CallStatisticsInfo *info = [[ECDevice sharedInstance].VoIPManager getCallStatisticsWithCallid:self.callid andType:VOICE];
//    NSLog(@"getCallStatisticsWithCallid-%lu_%lu_%lu",(unsigned long)info.rlBytesSent,(unsigned long)info.rlBytesReceived,(unsigned long)info.rlPacketsReceived);
}

- (void)updateRealTimeStatusLabel {
    self.realTimeStatusLabel.text = @"正在挂机...";
}

- (void)backFronts {
    if ([timer isValid])  {
        [timer invalidate];
        timer = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    
    [DemoGlobalClass sharedInstance].isCallBusy = NO;
    self.callid = nil;
    self.callerName = nil;
    self.callerNo = nil;
    self.voipNo = nil;
    self.topLabel = nil;
    self.callerNameLabel = nil;
    self.callerNoLabel = nil;
    self.realTimeStatusLabel = nil;
    self.statusLabel = nil;
    self.netStatusLabel = nil;
    self.hangUpButton = nil;
    self.KeyboardButton = nil;
    self.keyboardView = nil;
    self.handfreeButton = nil;
    self.muteButton = nil;
    self.functionAreaView = nil;
    self.p2pStatusLabel = nil;
    self.bgView = nil;
    self.menuActionSheet = nil;
}

//处理通话回调事件
- (void)onCallEvents:(NSNotification *)notification {
    
    VoIPCall* voipCall = notification.object;
    if (![self.callid isEqualToString:voipCall.callID]) {
        return;
    }
    
    switch (voipCall.callStatus) {
        case ECallProceeding: {
            self.realTimeStatusLabel.text = @"呼叫中...";
            self.handfreeButton.enabled = NO;
            self.handfreeButton.hidden = NO;
            self.muteButton.enabled = NO;
            self.muteButton.hidden = NO;
            self.hangUpButton.enabled = YES;
            self.hangUpButton.hidden =NO;
            
        }
            break;
            
        case ECallAlerting: {
            [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:NO];
            
            //关闭扬声器,听筒播放来电铃声
            self.realTimeStatusLabel.text = @"等待对方接听";
            if (voipCallType!=1) {
            }
            self.handfreeButton.enabled = NO;
            self.handfreeButton.hidden = NO;
            self.muteButton.enabled = NO;
            self.muteButton.hidden = NO;
            self.hangUpButton.enabled = YES;
            self.hangUpButton.hidden =NO;
           
        }
            break;
            
        case ECallStreaming: {
            [DemoGlobalClass sharedInstance].isCallBusy = YES;
            self.realTimeStatusLabel.text = @"00:00";
            if (![timer isValid]) {
                timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(updateRealtimeLabel) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
                [timer fire];
            }
            self.handfreeButton.enabled = YES;
            self.handfreeButton.hidden = NO;
            self.muteButton.enabled = YES;
            self.muteButton.hidden = NO;
            self.hangUpButton.enabled = YES;
            self.hangUpButton.hidden = NO;
            
        }
            break;
            
        case ECallFailed: {
            [DemoGlobalClass sharedInstance].isCallBusy = NO;
            if( voipCall.reason == ECErrorType_NoResponse) {
                self.realTimeStatusLabel.text = @"网络不给力";
            } else if ( voipCall.reason == ECErrorType_CallBusy || voipCall.reason == ECErrorType_Declined ) {
                self.realTimeStatusLabel.text = @"您拨叫的用户正忙，请稍后再拨";
            } else if ( voipCall.reason == ECErrorType_OtherSideOffline) {
                self.realTimeStatusLabel.text = @"对方不在线";
            } else if ( voipCall.reason == ECErrorType_CallMissed ) {
                self.realTimeStatusLabel.text = @"呼叫超时";
            } else if ( voipCall.reason == ECErrorType_SDKUnSupport) {
                self.realTimeStatusLabel.text = @"该版本不支持此功能";
            } else if ( voipCall.reason == ECErrorType_CalleeSDKUnSupport ) {
                self.realTimeStatusLabel.text = @"对方版本不支持音频";
            } else {
                self.realTimeStatusLabel.text = @"呼叫失败";
            }
            
            self.functionAreaView.hidden = YES;
            isShowKeyboard = YES;
            [self showKeyboardView];
            
            self.handfreeButton.enabled = NO;
            [self.handfreeButton setHidden:YES];
            self.muteButton.enabled = NO;
            [self.muteButton setHidden:YES];
            
            if ( voipCall.reason == ECErrorType_CallBusy || voipCall.reason == ECErrorType_Declined ) {
                
            } else {
                [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(backFronts) userInfo:nil repeats:NO];
            }
        }
            break;
            
        case ECallEnd: {
            if ([timer isValid]) {
                [timer invalidate];
                timer = nil;
            }
            [DemoGlobalClass sharedInstance].isCallBusy = NO;
            self.realTimeStatusLabel.text = @"正在挂机...";
            if (!isKickOff) {
                [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(backFronts) userInfo:nil repeats:NO];
            }
        }
            break;
        
        case ECallTransfered: {
            self.realTimeStatusLabel.text = @"呼叫被转移...";
        }
            break;
            
        default:
            break;
    }
}

//系统的回调事件
- (void)onSystemEvents:(NSNotification *)notification {
    
}

//设置回铃音
- (void)RingBackSound {
    NSString * ringPath = [[NSBundle mainBundle]pathForResource:@"ringback.wav" ofType:nil];
    NSData * ringData = [NSData dataWithContentsOfFile:ringPath];
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithData:ringData error:nil];
    newPlayer.delegate = self;
    self.ringbackplayer = newPlayer;
    [self.ringbackplayer prepareToPlay];
    [self.ringbackplayer play];
}

- (void)handfree {
    //成功时返回0，失败时返回-1
    NSInteger returnValue = [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:!isLouder];
    if (0 == returnValue) {
        isLouder = !isLouder;
    }
    
    if (isLouder)  {
        [self.handfreeButton setImage:[UIImage imageNamed:kHandsfreeBtnOnpng] forState:UIControlStateNormal];
        [self.handfreeButton setTitleColor:[UIColor colorWithRed:46/255.0 green:184/255.0 blue:111/255.0 alpha:1] forState:UIControlStateNormal];
    } else {
        [self.handfreeButton setImage:[UIImage imageNamed:kHandsfreeBtnpng] forState:UIControlStateNormal];
        [self.handfreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)mute {
    int muteFlag = [[ECDevice sharedInstance].VoIPManager getMuteStatus];
    if (muteFlag == MuteFlagNotMute) {
        [self.muteButton setImage:[UIImage imageNamed:kMuteBtnOnpng] forState:UIControlStateNormal];
        [[ECDevice sharedInstance].VoIPManager setMute:MuteFlagIsMute];
        [self.muteButton setTitleColor:[UIColor colorWithRed:46/255.0 green:184/255.0 blue:111/255.0 alpha:1] forState:UIControlStateNormal];
    } else {
        [self.muteButton setImage:[UIImage imageNamed:kMuteBtnpng] forState:UIControlStateNormal];
        [[ECDevice sharedInstance].VoIPManager setMute:MuteFlagNotMute];
        [self.muteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)hangupCall {
    if (voipCallType == 2) {
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(backFronts) userInfo:nil repeats:NO];
    } else {
        if ([timer isValid]) {
            [timer invalidate];
            timer = nil;
        }
        self.realTimeStatusLabel.text = @"正在挂机...";
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(backFronts) userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(releaseCall) userInfo:nil repeats:NO];
    }
}

- (void)releaseCall {
    [DemoGlobalClass sharedInstance].isCallBusy = NO;
    [[ECDevice sharedInstance].VoIPManager releaseCall:self.callid];
}
@end
