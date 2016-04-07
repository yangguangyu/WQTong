//
//  VideoViewController.m
//  ytxVoIPDemo
//
//  Created by lrn on 15/3/10.
//  Copyright (c) 2015年 lrn. All rights reserved.
//
#define IPHONE5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#import "VideoViewController.h"
#import "CameraDeviceInfo.h"
#import "DeviceDelegateHelper.h"
#import "DeviceDelegateHelper+VoIP.h"

//视频呼叫是1
@interface VideoViewController () {
    UILabel *statusLabel;
    UIImageView *imgViewStatus;
    UILabel *timeLabel;
    UILabel *callStatusLabel;
    UIView *localVideoView;
    UIView *remoteVideoView;
    
    NSInteger curCameraIndex;
    BOOL isKickOff;
    
    NSInteger deviceRotate;
    NSInteger remoteRotate;
    
    UITouch *touch;
    CGPoint curLocation;
    CGPoint preLocation;
}
@property (nonatomic, retain) UIView *makeCallView;
@property (nonatomic, retain) UIView *incomingCallView;
@property (nonatomic, retain) UIView *callingView;
@property (nonatomic, retain) NSArray *cameraInfoArr;

-(void)makeCallViewLayout;
-(void)incomingCallViewLayout;
-(void)callingViewLayout;
-(void)switchCamera;
@end

#define ACTION_CALL_VIEW_FRAME CGRectMake(0.0f, self.bgView.frame.size.height-54.0f, 320.0f, 54.0f)
#define ACTION_CALL_VIEW_BACKGROUNTCOLOR [UIColor colorWithRed:75.0f/255.0f green:85.0f/255.0f blue:150.0f/255.0f alpha:1.0f]

#define Width [UIScreen mainScreen].bounds.size.width - frame.size.width;
#define Height [UIScreen mainScreen].bounds.size.height - frame.size.height - self.callingView.frame.size.height-20;

@implementation VideoViewController
- (id)initWithCallerName:(NSString *)name andVoipNo:(NSString *)voipNo andCallstatus:(NSInteger)status {
    if (self = [super init]) {
        self.callerName = name;
        self.voipNo = voipNo;
        hhInt = 0;
        mmInt = 0;
        ssInt = 0;
        callStatus = status;
        isKickOff = NO;
        [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:YES];
        
        self.cameraInfoArr = [[ECDevice sharedInstance].VoIPManager getCameraInfo];
        
        if (curCameraIndex >= 0) {
            //获取摄像头信息
            CameraDeviceInfo *camera = [self.cameraInfoArr objectAtIndex:curCameraIndex];
            CameraCapabilityInfo *capability = [camera.capabilityArray objectAtIndex:0];
            
            [[ECDevice sharedInstance].VoIPManager selectCamera:camera.index capability:0 fps:capability.maxfps rotate:Rotate_0];
        }
    }
    return self;
}

- (void)loadView {
    self.navigationController.navigationBar.hidden = YES;
    UIView *tmpView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.bgView = tmpView;
    remoteRotate = 0;
    deviceRotate = 0;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
#if __IPHONE_7_0
        self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
        [self.view addSubview:self.bgView];
#else
        self.view = self.bgView;
#endif
    } else {
        self.view = self.bgView;
    }
    
    self.bgView.backgroundColor = [UIColor colorWithRed:45.0f/255.0f green:52.0f/255.0f blue:61.0f/255.0f alpha:1.0f];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *pointImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"point_bg.png"]];
    pointImg.frame = CGRectMake(0.0f, 0.0f, 320.0f, 29.0f);
    [self.bgView addSubview:pointImg];
    imgViewStatus = pointImg;
    
    UIImageView *videoIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_icon.png"]];
    videoIcon.center = CGPointMake(160.0f, 213.0f);
    [self.bgView addSubview:videoIcon];
    
    UILabel *statusLabeltmp = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, 265.0f, 29.0f)];
    statusLabeltmp.backgroundColor = [UIColor clearColor];
    statusLabeltmp.textColor = [UIColor whiteColor];
    statusLabeltmp.font = [UIFont systemFontOfSize:13.0f];
    statusLabel = statusLabeltmp;
    [self.bgView addSubview:statusLabeltmp];
    
    UIView *tmpView1 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, self.bgView.frame.size.height - 54.0f)];
    remoteVideoView = tmpView1;
    tmpView1.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:tmpView1];
    
    UIView *tmpView2 = [[UIView alloc] initWithFrame:CGRectMake(15.0f, self.bgView.frame.size.height>480.0f?330.0f:283.0f, 80.0f, 107.0f)];
    tmpView1.backgroundColor = [UIColor clearColor];
    localVideoView = tmpView2;
    [self.bgView addSubview:tmpView2];
    
    //0:呼出视频 1:视频呼入 2:视频中
    if (callStatus == 0) {
        //进来之后先拨号
        self.callID = [[ECDevice sharedInstance].VoIPManager makeCallWithType:VIDEO andCalled:self.voipNo];
        
        //获取CallID失败，即拨打失败
        if (self.callID.length <= 0) {
            statusLabel.text = @"对方不在线或网络不给力";
        } else {
            statusLabel.text = @"正在等待对方接受邀请......";
        }
        [self makeCallViewLayout];
        
    } else if(callStatus == 1) {
        statusLabel.text = [NSString stringWithFormat:@"%@邀请您进行视频通话", self.voipNo];
        [self incomingCallViewLayout];
    }

    self.view.backgroundColor = [UIColor colorWithRed:45.0f/255.0f green:52.0f/255.0f blue:61.0f/255.0f alpha:1.0f];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallEvents:) name:KNOTIFICATION_onCallEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSystemEvents:) name:KNOTIFICATION_onSystemEvent object:nil];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch1 = [touches anyObject];
    touch = touch1;
    [self setVideoViewWithWiew:localVideoView];
}
- (void)setVideoViewWithWiew:(UIView *)view
{
    preLocation = [touch previousLocationInView:view];
    curLocation = [touch locationInView:view];
    CGRect frame = localVideoView.frame;
    frame.origin.x += curLocation.x - preLocation.x;
    frame.origin.y += curLocation.y - preLocation.y;
    CGFloat W = Width;
    CGFloat H = Height;
    if (frame.origin.x <= 0 ) {
        frame.origin.x = 0;
    } else if (frame.origin.y <= 0) {
        frame.origin.y = 0;
    } else if (frame.origin.x >= W) {
        frame.origin.x = W;
    } else if (frame.origin.y >= H) {
        frame.origin.y = H;
    }
    view.frame = frame;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect frame = localVideoView.frame;
    CGFloat W = Width
    CGFloat H = Height;
    if (frame.origin.x<W/2 && frame.origin.y<H/2) {
        frame.origin = CGPointZero;
    } else if (W/2<frame.origin.x<W && frame.origin.y<H/2) {
        frame.origin = CGPointMake(W, 0);
    } else if (frame.origin.x<W/2 && H/2<frame.origin.y<H) {
        frame.origin = CGPointMake(0, H);
    } else if (W/2<frame.origin.x<W && H/2<frame.origin.y<H) {
        frame.origin = CGPointMake(W, H);
    }
    localVideoView.frame = frame;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2988) {
        if (buttonIndex == 1) {
            exit(0);
        } else {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    设置视频通话显示的view
    [[ECDevice sharedInstance].VoIPManager setVideoView:remoteVideoView andLocalView:localVideoView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:NO];
    [super viewDidDisappear:animated];
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
        timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hhInt,mmInt,ssInt];
    } else {
        timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",mmInt,ssInt];
    }
}

- (void)updateRealTimeStatusLabel {
    statusLabel.text = @"正在挂机...";
}

- (void)backFront {
    
    if ([timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [DemoGlobalClass sharedInstance].isCallBusy = NO;
    self.callID = nil;
    self.callerName = nil;
    self.voipNo = nil;
    self.acceptButton = nil;
    self.incomingCallView = nil;
    self.callingView = nil;
    self.makeCallView =nil;
    self.netStatusLabel = nil;
    self.p2pStatusLabel = nil;
    self.cameraInfoArr = nil;
    self.bgView = nil;
    self.tipsLabel = nil;
}

//通话回调函数，判断通话状态
- (void)onCallEvents:(NSNotification *)notification {
    
    VoIPCall* voipCall = notification.object;
    if (![self.callID isEqualToString:voipCall.callID]) {
        return;
    }
    
    switch (voipCall.callStatus) {
        case ECallProceeding: {
            statusLabel.text = @"呼叫中...";
        }
            break;
            
        case ECallAlerting: {
            statusLabel.text = @"等待对方接听";
        }
            break;
            
        case ECallStreaming: {
            [DemoGlobalClass sharedInstance].isCallBusy = YES;
            [self callingViewLayout];
            statusLabel.text = @"通话中...";
            timeLabel.text = @"00:00";
            if (![timer isValid]) {
                timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(updateRealtimeLabel) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
                [timer fire];
            }
            [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:YES];
        }
            break;
            
        case ECallFailed: {
            [DemoGlobalClass sharedInstance].isCallBusy = NO;
            if( voipCall.reason == ECErrorType_NoResponse) {
                statusLabel.text = @"网络不给力";
            } else if ( voipCall.reason == ECErrorType_CallBusy || voipCall.reason == ECErrorType_Declined ) {
                statusLabel.text = @"您拨叫的用户正忙，请稍后再拨";
            } else if ( voipCall.reason == ECErrorType_OtherSideOffline) {
                statusLabel.text = @"对方不在线";
            } else if ( voipCall.reason == ECErrorType_CallMissed ) {
                statusLabel.text = @"呼叫超时";
            } else if ( voipCall.reason == ECErrorType_SDKUnSupport) {
                statusLabel.text = @"该版本不支持此功能";
            } else if ( voipCall.reason == ECErrorType_CalleeSDKUnSupport ) {
                statusLabel.text = @"对方版本不支持音频";
            } else {
                statusLabel.text = @"呼叫失败";
            }
            
            [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(hangup) userInfo:nil repeats:NO];
        }
            break;
            
        case ECallEnd: {
            [DemoGlobalClass sharedInstance].isCallBusy = NO;
            statusLabel.text = @"正在挂机...";
            if (!isKickOff)
                [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(backFront) userInfo:nil repeats:NO];
        }
            break;
            
        default:
            break;
    }
}

//系统的回调事件
- (void)onSystemEvents:(NSNotification *)notification {
    
}

- (void)hangup {
    
    //播放铃声停止
    if ([timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
    statusLabel.text = @"正在挂机...";
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(backFront) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(releaseCall) userInfo:nil repeats:NO];
}

- (void)accept {
    [self performSelector:@selector(answer) withObject:nil afterDelay:0.1];
}

- (void)answer {
    NSInteger ret = [[ECDevice sharedInstance].VoIPManager acceptCall:self.callID withType:VIDEO];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    if (ret == 0) {
        [self callingViewLayout];
    } else {
        [self backFront];
    }
}

- (void)releaseCall {
    [DemoGlobalClass sharedInstance].isCallBusy = NO;
    [[ECDevice sharedInstance].VoIPManager releaseCall:self.callID];
}

-(void)makeCallViewLayout {
    
    if (self.makeCallView == nil) {
        self.makeCallView = [[UIView alloc] initWithFrame:ACTION_CALL_VIEW_FRAME];
        [self.bgView addSubview:self.makeCallView];

        UIButton* hangupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        hangupBtn.frame = CGRectMake(15.0f, 6.0f, 291.0f, 42.0f);
        [hangupBtn setBackgroundImage:[UIImage imageNamed:@"video_button2_on.png"] forState:UIControlStateHighlighted];
        [hangupBtn setBackgroundImage:[UIImage imageNamed:@"video_button2_off.png"] forState:UIControlStateNormal];
        [hangupBtn setTitle:@"结束视频通话" forState:UIControlStateNormal];
        hangupBtn.titleLabel.textColor = [UIColor whiteColor];
        [hangupBtn addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
        self.hangUpButton = hangupBtn;
        [self.makeCallView addSubview:self.hangUpButton];
    } else {
        [self.bgView bringSubviewToFront:self.makeCallView];
    }
}

-(void)incomingCallViewLayout {
    
    if (self.incomingCallView == nil) {
        self.incomingCallView = [[UIView alloc] initWithFrame:ACTION_CALL_VIEW_FRAME];
        [self.bgView addSubview:self.incomingCallView];
        self.incomingCallView.backgroundColor = ACTION_CALL_VIEW_BACKGROUNTCOLOR;
        UIButton* answerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.incomingCallView addSubview:answerBtn];
        answerBtn.frame = CGRectMake(15.0f, 6.0f, 201.0f, 42.0f);
        [answerBtn setBackgroundImage:[UIImage imageNamed:@"video_button_on.png"] forState:UIControlStateHighlighted];
        [answerBtn setBackgroundImage:[UIImage imageNamed:@"video_button_off.png"] forState:UIControlStateNormal];
        [answerBtn setTitle:@"开始视频通话" forState:UIControlStateNormal];
        answerBtn.titleLabel.textColor = [UIColor whiteColor];
        [answerBtn addTarget:self action:@selector(answer) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* hangupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.incomingCallView addSubview:hangupBtn];
        hangupBtn.frame = CGRectMake(15.0f+210.0f+13.0f, 6.0f, 76.0f, 42.0f);
        [hangupBtn setBackgroundImage:[UIImage imageNamed:@"video_button1_on.png"] forState:UIControlStateHighlighted];
        [hangupBtn setBackgroundImage:[UIImage imageNamed:@"video_button1_off.png"] forState:UIControlStateNormal];
        [hangupBtn setTitle:@"结束" forState:UIControlStateNormal];
        hangupBtn.titleLabel.textColor = [UIColor whiteColor];
        [hangupBtn addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
        
    } else {
        [self.bgView bringSubviewToFront:self.incomingCallView];
    }
}
//视频通话界面
-(void)callingViewLayout {
    
    callStatus = 1;
    statusLabel.hidden = YES;
    imgViewStatus.hidden = YES;
    
    if (self.callingView == nil) {
        self.callingView = [[UIView alloc] initWithFrame:ACTION_CALL_VIEW_FRAME];
        self.callingView.backgroundColor = [UIColor clearColor];
        [self.bgView addSubview:self.callingView];
        [self.makeCallView removeFromSuperview];
        [self.incomingCallView removeFromSuperview];
        self.makeCallView = nil;
        self.incomingCallView = nil;
        
        UIButton *tempHangupButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.hangUpButton = tempHangupButton;
        tempHangupButton.frame = CGRectMake(15.0f, 6.0f, 291.0f, 42.0f);
        
        [tempHangupButton setImage:[UIImage imageNamed:@"call_hang_up_button.png"] forState:UIControlStateNormal];
        [tempHangupButton setImage:[UIImage imageNamed:@"call_hang_up_button_on.png"] forState:UIControlStateHighlighted];
        
        [tempHangupButton addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
        [self.callingView addSubview:self.hangUpButton];
        
        UILabel *timeLabeltmp = [[UILabel alloc] initWithFrame:CGRectMake(200.0f, 15.0f, 55.0f, 24.0f)];
        timeLabel = timeLabeltmp;
        timeLabeltmp.backgroundColor =  [UIColor clearColor];
        [self.callingView addSubview:timeLabeltmp];
        timeLabeltmp.textColor = [UIColor whiteColor];
        timeLabeltmp.textAlignment = NSTextAlignmentRight;
        timeLabeltmp.font = [UIFont systemFontOfSize:14];

        if (self.cameraInfoArr.count>1) {
            UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [switchBtn setImage:[UIImage imageNamed:@"camera_switch.png"] forState:UIControlStateNormal];
            switchBtn.frame = CGRectMake(230.0f, 35.0f, 70.0f, 35.0f);
            [self.bgView addSubview:switchBtn];
            [switchBtn addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
        }
        
    } else {
        [self.bgView bringSubviewToFront:self.callingView];
    }
    
}

-(void)changeTextColor {
    if (self.tipsLabel.textColor == [UIColor orangeColor]) {
        self.tipsLabel.textColor = [UIColor whiteColor];
    } else {
        self.tipsLabel.textColor = [UIColor orangeColor];
    }
}

-(void)showTipsLabel {
    self.tipsLabel.textColor = [UIColor whiteColor];
    self.tipsLabel.font = [UIFont systemFontOfSize:17];
    self.tipsLabel.text = [NSString stringWithFormat:@"与%@视频通话中", (self.voipNo.length>3?[self.voipNo substringFromIndex:(self.voipNo.length-3)]:@"")];
}

//选择摄像头
-(void)switchCamera {
    
    curCameraIndex ++;
    if (curCameraIndex >= self.cameraInfoArr.count) {
        curCameraIndex = 0;
    }
    
    CameraDeviceInfo *camera = [self.cameraInfoArr objectAtIndex:curCameraIndex];
    CameraCapabilityInfo *capability = [camera.capabilityArray objectAtIndex:0];
    
    [[ECDevice sharedInstance].VoIPManager selectCamera:camera.index capability:0 fps:capability.maxfps rotate:Rotate_0];
}

@end
