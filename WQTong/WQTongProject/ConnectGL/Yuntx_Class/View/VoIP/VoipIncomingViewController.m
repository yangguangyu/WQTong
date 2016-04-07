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
#import "VoipIncomingViewController.h"
#import "AppDelegate.h"
#import "ECDeviceHeaders.h"
#import "DeviceDelegateHelper.h"

#import "DeviceDelegateHelper+VoIP.h"

@interface VoipIncomingViewController ()
{
    BOOL isShowKeyboard;
    BOOL isKickOff;
    ECDevice * device;
}

@property (nonatomic,retain) UIView *keyboardView;

- (void)accept;
- (void)refreshView;
- (void)exitView;
- (void)dismissView;
- (void)showKeyboardView;
@end

@implementation VoipIncomingViewController

#define portraitLeft  100
#define portraitTop   120
#define portraitWidth 150
#define portraitHeight 150

#pragma mark - init初始化
- (id)initWithName:(NSString *)name andPhoneNO:(NSString *)phoneNO andCallID:(NSString*)callid
{
    self = [super init];
    if (self)
    {
        device = [ECDevice sharedInstance];
        self.contactName     = name;
        self.callID          = callid;
        self.contactPhoneNO  = phoneNO;
        hhInt = 0;
        mmInt = 0;
        ssInt = 0;
        isLouder = NO;
        isKickOff = NO;
        self.status = IncomingCallStatus_incoming;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    self.navigationController.navigationBar.hidden = YES;
    
    UIView *tmpView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    tmpView.backgroundColor = [UIColor redColor];
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
#pragma mark - viewDidLoad界面初始化
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *backImage = [UIImage imageNamed:kCallBg02pngVoip];
    UIImageView *backGroupImageView = [[UIImageView alloc] initWithImage:backImage];
    backgroundImg = backGroupImageView;
    backGroupImageView.center = CGPointMake(160.0, self.bgView.frame.size.height*0.5);
    [self.bgView addSubview:backGroupImageView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    self.lblName = nameLabel;
    self.lblName.frame = CGRectMake(0, 30, 320, 20);
    self.lblName.textAlignment = NSTextAlignmentCenter;
    self.lblName.backgroundColor = [UIColor clearColor];
    self.lblName.textColor = [UIColor whiteColor];
    self.lblName.text = self.contactName.length>0?self.contactName:@"";
    [self.bgView addSubview:self.lblName];
    
    UILabel *phoneLabel = [[UILabel alloc] init];
    self.lblPhoneNO = phoneLabel;
    self.lblPhoneNO.frame = CGRectMake(0, 53, 320, 22);
    self.lblPhoneNO.textAlignment = NSTextAlignmentCenter;
    self.lblPhoneNO.backgroundColor = [UIColor clearColor];
    self.lblPhoneNO.textColor = [UIColor whiteColor];
    self.lblPhoneNO.text = self.contactPhoneNO.length>0?self.contactPhoneNO:self.contactVoip;
    [self.bgView addSubview:self.lblPhoneNO];
    
    UILabel* incomingLabel = [[UILabel alloc] init];
    self.lblIncoming = incomingLabel;
    self.lblIncoming.frame = CGRectMake(0, 80, 320, 20);
    self.lblIncoming.textAlignment = NSTextAlignmentCenter;
    self.lblIncoming.backgroundColor = [UIColor clearColor];
    self.lblIncoming.textColor = [UIColor whiteColor];
    self.lblIncoming.text = @"";
    [self.bgView addSubview:self.lblIncoming];
    
    
    UILabel *tempStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f/2-150.0f, 106.0f, 300.0f, 16.0f)];
    tempStatusLabel.text = @"";
    tempStatusLabel.textColor = [UIColor whiteColor];
    tempStatusLabel.backgroundColor = [UIColor clearColor];
    tempStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel = tempStatusLabel;
    [self.bgView addSubview:self.statusLabel];
    
    UILabel *tempNetStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f/2-150.0f, 126.0f, 300.0f, 28.0f)];
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
    
    isShowKeyboard = NO;
    //免提和静音背景图
    UIView *tempfunctionAreaView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f-10.0f-43.0f-5.0f-10, 320.0f, 50.0f)];
    [self.bgView addSubview:tempfunctionAreaView];
    tempfunctionAreaView.backgroundColor = [UIColor clearColor];
    self.functionAreaView = tempfunctionAreaView;
    self.functionAreaView.hidden = YES;
    
    //键盘显示按钮
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
    [tempMuteButton setImage:[UIImage imageNamed:kMuteBtnpng] forState:UIControlStateNormal];
    tempMuteButton.titleLabel.font = [UIFont systemFontOfSize:13];
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
    [tempHandFreeButton setImage:[UIImage imageNamed:kHandsfreeBtnpng] forState:UIControlStateNormal];
    tempHandFreeButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [tempHandFreeButton setTitle:@"免提" forState:UIControlStateNormal];
    tempHandFreeButton.titleEdgeInsets  = UIEdgeInsetsMake(50,-29, 0, 0);
    tempHandFreeButton.imageEdgeInsets = UIEdgeInsetsMake(-10,22, 0, 0);
    self.handfreeButton = tempHandFreeButton;
    tempHandFreeButton.enabled = NO;
    [tempHandFreeButton addTarget:self action:@selector(handfree) forControlEvents:UIControlEventTouchUpInside];
    [self.functionAreaView addSubview:tempHandFreeButton];
    
    //拒接
    UIButton *tempRejectButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    tempRejectButton.frame = CGRectMake(24.0f, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f, 127, 42);
    [tempRejectButton setImage:[UIImage imageNamed:@"call_refuse_button.png"] forState:UIControlStateNormal];
    [tempRejectButton setImage:[UIImage imageNamed:@"call_refuse_button_on.png"] forState:UIControlStateHighlighted];
    [tempRejectButton setImage:[UIImage imageNamed:@"call_refuse_button_on.png"] forState:UIControlStateSelected];
    [tempRejectButton  addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
    self.rejectButton = tempRejectButton;
    [self.bgView addSubview:self.rejectButton];
    
    //挂机
    UIButton *tempHangupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tempHangupButton.frame = CGRectMake(24.0f, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f, 320.0f-24.0f-24.0f, 42.0f);
    [tempHangupButton setImage:[UIImage imageNamed:@"call_hang_up_button.png"] forState:UIControlStateNormal];
    [tempHangupButton setImage:[UIImage imageNamed:@"call_hang_up_button_on.png"] forState:UIControlStateHighlighted];
    [tempHangupButton setImage:[UIImage imageNamed:@"call_hang_up_button_on.png"] forState:UIControlStateSelected];
    [tempHangupButton addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
    tempHangupButton.hidden = YES;
    self.hangUpButton = tempHangupButton;
    [self.bgView addSubview:self.hangUpButton];
    
    //接听
    UIButton *tempAnswerButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    tempAnswerButton.frame = CGRectMake(24.0f+127+14, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f, 127, 42.0f);
    [tempAnswerButton setImage:[UIImage imageNamed:@"call_answer_button.png"] forState:UIControlStateNormal];
    [tempAnswerButton setImage:[UIImage imageNamed:@"call_answer_button_on.png"] forState:UIControlStateHighlighted];
    [tempAnswerButton setImage:[UIImage imageNamed:@"call_answer_button_on.png"] forState:UIControlStateSelected];
    [tempAnswerButton  addTarget:self action:@selector(accept) forControlEvents:UIControlEventTouchUpInside];
    self.answerButton = tempAnswerButton;
    [self.bgView addSubview:self.answerButton];
    
    
    [self refreshView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallEvents:) name:KNOTIFICATION_onCallEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSystemEvents:) name:KNOTIFICATION_onSystemEvent object:nil];
}

- (void)dealloc
{
    [DemoGlobalClass sharedInstance].isCallBusy = NO;
    self.contactVoip = nil;
    self.KeyboardButton = nil;
    self.keyboardView = nil;
    self.lblIncoming = nil;
    self.functionAreaView = nil;
    self.lblName = nil;
    self.lblPhoneNO = nil;
    self.contactName = nil;
    self.contactPhoneNO = nil;
    self.contactPortrait = nil;
    self.hangUpButton = nil;
    self.handfreeButton = nil;
    self.muteButton = nil;

    self.statusLabel = nil;
    self.netStatusLabel = nil;
    self.p2pStatusLabel = nil;
    self.bgView = nil;
    self.menuActionSheet = nil;
    device = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Appear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor colorWithRed:24/255.0 green:24/255.0 blue:24/255.0 alpha:1.0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissView) name:@"Notification_DismissModalView" object:nil];
}

#pragma mark - 按钮点击
- (void)updateRealtimeLabel
{
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
        self.lblIncoming.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hhInt,mmInt,ssInt];
    } else {
        self.lblIncoming.text = [NSString stringWithFormat:@"%02d:%02d",mmInt,ssInt];
    }
    //获取网络流量情况，因为需要实时获取，因此需要在定时器里，每隔一段时间获取一次才可以。第一次默认调用是为0
//    NetworkStatistic *net = [[ECDevice sharedInstance].VoIPManager getNetworkStatisticWithCallId:self.callID];
//    NSLog(@"NetworkStatistic-%lld_%lld_%lld",net.txBytes_wifi,net.rxBytes_wifi,net.duration);
    //同上
//    CallStatisticsInfo *info = [[ECDevice sharedInstance].VoIPManager getCallStatisticsWithCallid:self.callID andType:VOICE];
//    NSLog(@"getCallStatisticsWithCallid-%lu_%lu_%lu",(unsigned long)info.rlBytesSent,(unsigned long)info.rlBytesReceived,(unsigned long)info.rlPacketsReceived);
}

- (void)onCallEvents:(NSNotification *)notification {
    
    VoIPCall* voipCall = notification.object;
    if (![self.callID isEqualToString:voipCall.callID])
    {
        return;
    }
    
    switch (voipCall.callStatus) {
            
        case ECallProceeding:
        {
        }
            break;
            
        case ECallStreaming:
        {
            [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:NO];
            self.lblIncoming.text = @"00:00";
            if (![timer isValid])
            {
                timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(updateRealtimeLabel) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
                [timer fire];
            }
            
            self.rejectButton.enabled = NO;
            self.rejectButton.hidden = YES;
            
            self.answerButton.enabled = NO;
            self.answerButton.hidden = YES;
            
            self.handfreeButton.enabled = YES;
            self.handfreeButton.hidden = NO;
            
            self.muteButton.enabled = YES;
            self.muteButton.hidden = NO;
            
            self.hangUpButton.enabled = YES;
            self.hangUpButton.hidden = NO;
            
            self.functionAreaView.hidden = NO;
            backgroundImg.image = [UIImage imageNamed:@"call_bg01.png"];
        }
            break;
            
        case ECallAlerting:
        {
            self.handfreeButton.enabled = YES;
            self.handfreeButton.hidden = NO;
            self.muteButton.enabled = YES;
            self.muteButton.hidden = NO;
            self.hangUpButton.enabled = YES;
            self.hangUpButton.hidden =NO;
            
        }
            break;
            
        case ECallEnd:
        {
            [self releaseCall];
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(exitView) userInfo:nil repeats:NO];
        }
            break;
            
        case ECallRing:
        {
        }
            break;
            
        case ECallPaused:
        {
            self.lblIncoming.text = @"呼叫保持...";
        }
            break;
            
        case ECallPausedByRemote:
        {
            self.lblIncoming.text = @"呼叫被对方保持...";
        }
            break;
            
        case ECallResumed:
        {
            self.lblIncoming.text = @"呼叫恢复...";
        }
            break;
            
        case ECallResumedByRemote:
        {
            self.lblIncoming.text = @"呼叫被对方恢复...";
        }
            break;
            
        case ECallTransfered:
        {
            self.lblIncoming.text = @"呼叫被转移...";
        }
            break;
            
        case ECallFailed:
        {
            [DemoGlobalClass sharedInstance].isCallBusy = NO;
        }
            break;
            
        default:
            break;
    }
}

//系统的回调事件
- (void)onSystemEvents:(NSNotification *)notification {
    
}

//呼叫振铃
- (void)removeVoIPCallBackForCallId:(NSString *)callid
{
    VoIPCall * voipcall;
    voipcall.callStatus = ECallAlerting;
}

#pragma mark - private
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2988)
    {
        if (buttonIndex == 1)
        {
            exit(0);
        }
        else
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)showKeyboardView
{
    isShowKeyboard = !isShowKeyboard;
    
    if (self.keyboardView == nil)
    {
        CGFloat viewWidth = 86.0f*3;
        CGFloat viewHeight = 46.0*4;
        UIView *tmpKeyboardView = [[UIView alloc] initWithFrame:CGRectMake(160.0f-viewWidth*0.5f, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f-10.0f-80.0f-viewHeight, viewWidth, viewHeight)];
        tmpKeyboardView.backgroundColor = [UIColor clearColor];
        self.keyboardView = tmpKeyboardView;
        [self.bgView addSubview:tmpKeyboardView];
        for (NSInteger i = 0; i<4; i++)
        {
            for (NSInteger j = 0; j<3; j++)
            {
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
        [self.KeyboardButton setImage:[UIImage imageNamed:kKeyboardBtnOnpng] forState:UIControlStateNormal];
        [self.KeyboardButton setTitleColor:[UIColor colorWithRed:46/255.0 green:184/255.0 blue:111/255.0 alpha:1] forState:UIControlStateNormal];
        [self.bgView bringSubviewToFront:self.keyboardView];
    } else {
        [self.KeyboardButton setImage:[UIImage imageNamed:kKeyboardBtnpng] forState:UIControlStateNormal];
        [self.KeyboardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.keyboardView removeFromSuperview];
        self.keyboardView = nil;
    }
}

- (void)dtmfNumber:(id)sender
{
    NSString *numberString = nil;
    UIButton *button = (UIButton *)sender;
    switch (button.tag)
    {
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
    [device.VoIPManager sendDTMF:self.callID dtmf:numberString];
}

- (void)answer {
    NSInteger ret = [device.VoIPManager acceptCall:self.callID];
    if (ret == 0) {
        self.status = IncomingCallStatus_accepted;
        [self refreshView];
    } else {
        [self exitView];
    }
}

- (void)handfree
{
    //成功时返回0，失败时返回-1
    NSInteger returnValue = [device.VoIPManager enableLoudsSpeaker:!isLouder];
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
    
    int muteFlag = [device.VoIPManager getMuteStatus];
    if (muteFlag == MuteFlagNotMute1) {
        [self.muteButton setImage:[UIImage imageNamed:kMuteBtnOnpng] forState:UIControlStateNormal];
        [device.VoIPManager setMute:MuteFlagIsMute1];
        [self.muteButton setTitleColor:[UIColor colorWithRed:46/255.0 green:184/255.0 blue:111/255.0 alpha:1] forState:UIControlStateNormal];
    } else {
        [self.muteButton setImage:[UIImage imageNamed:kMuteBtnpng] forState:UIControlStateNormal];
        [device.VoIPManager setMute:MuteFlagNotMute1];
        [self.muteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)releaseCall{
    [DemoGlobalClass sharedInstance].isCallBusy = NO;
    [device.VoIPManager releaseCall:self.callID];
}

- (void)hangup{
    [DemoGlobalClass sharedInstance].isCallBusy = NO;
    [device.VoIPManager releaseCall:self.callID];

    [self exitView];
}

- (void)refreshView
{
    if (self.status == IncomingCallStatus_accepting)
    {
        self.lblIncoming.text = @"正在接听...";
        self.rejectButton.enabled = NO;
        self.rejectButton.hidden = YES;
        
        self.answerButton.enabled = NO;
        self.answerButton.hidden = YES;
        
        self.handfreeButton.enabled = YES;
        self.handfreeButton.hidden = NO;
        
        self.muteButton.enabled = YES;
        self.muteButton.hidden = NO;
        
        self.hangUpButton.enabled = YES;
        self.hangUpButton.hidden = NO;
        
        self.functionAreaView.hidden = NO;
        backgroundImg.image = [UIImage imageNamed:@"call_bg01.png"];

        [self performSelector:@selector(answers) withObject:nil afterDelay:0.1];
    }
    else if (self.status == IncomingCallStatus_incoming)
    {
        
    }
    else if(self.status == IncomingCallStatus_accepted)
    {
    }
    else
    {
        
    }
}
- (void)answers {
    [device.VoIPManager enableLoudsSpeaker:YES];
    [device.VoIPManager acceptCall:self.callID withType:VOICE];
}

- (void)accept {
    self.status = IncomingCallStatus_accepting;
    [self refreshView];
}

-(void) exitView {
    if ([timer isValid])
    {
        [timer invalidate];
        timer = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)process
{
    if ([timer isValid]) 
    {
        [timer invalidate];
        timer = nil;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissView
{
    [NSThread detachNewThreadSelector:@selector(process) toTarget:self withObject:nil];
}

@end
