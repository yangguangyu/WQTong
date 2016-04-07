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

#import "MultiVideoConfViewController.h"
#import "CameraDeviceInfo.h"
#import "DeviceDelegateHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "ECMeetingMember.h"
#import "DeviceDelegateHelper+Meeting.h"

#define Camera_Resolution_KEY           @"camera_Resolution_key"
#define Camera_fps_KEY                  @"camera_fps_key"

#define VideoConfVIEW_addNullNumber  9992
#define VideoConfVIEW_addmember    9993
#define VideoConfVIEW_addmember_voip 9994
#define VideoConfVIEW_exitAlert    9995
#define VideoConfVIEW_kickOff      9996
#define VideoConfVIEW_ConfDisslove 9997
#define VideoConfVIEW_refuse       9998

#define VideoConfVIEW_BtnChangeCam 8001
#define VideoConfVIEW_BtnMic       8002
#define VideoConfVIEW_BtnExit      8003

#define VideoConfVIEW_ViewMain    7000
#define VideoConfVIEW_View1       7001
#define VideoConfVIEW_View2       7002
#define VideoConfVIEW_View3       7003
#define VideoConfVIEW_View4       7004
#define VideoConfVIEW_View5       7005

@interface MultiVideoConfViewController ()
{
    UILabel *statusView;
    BOOL isMute;
    NSInteger videoCount;
}
@property (nonatomic, retain) NSMutableArray *membersArray;
@property (nonatomic, assign) NSInteger myVideoState;
@property (nonatomic, retain) NSString *confAddr;
@property (nonatomic, strong) UIView *menuView;
@end

@implementation MultiVideoConfViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self controllerSpeak:YES];
        self.isCreatorExit = NO;
        self.cameraInfoArr = [[ECDevice sharedInstance].VoIPManager getCameraInfo];
        self.membersArray = [[NSMutableArray alloc] init] ;

        //默认使用前置摄像头
        curCameraIndex = self.cameraInfoArr.count-1;
        if (curCameraIndex >= 0) {
            CameraDeviceInfo *camera = [self.cameraInfoArr objectAtIndex:curCameraIndex];
            [self selectCamera:camera.index];
        }
    }
    return self;
}

-(void)controllerSpeak:(BOOL)isSpeak{
    
    [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:isSpeak];
}

//选择摄像头
- (NSInteger)selectCamera:(NSInteger)cameraIndex
{
    if (cameraIndex >= self.cameraInfoArr.count) {
        return -1;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger fps = [userDefaults integerForKey:Camera_fps_KEY];
    if (fps == 0){
        fps = 12;
    }
    
    NSInteger capabilityIndex = [userDefaults integerForKey:Camera_Resolution_KEY];
    CameraDeviceInfo *camera = [self.cameraInfoArr objectAtIndex:cameraIndex];
    if (capabilityIndex >= camera.capabilityArray.count) {
        capabilityIndex = 0;
    }
    
    return [[ECDevice sharedInstance].VoIPManager selectCamera:cameraIndex capability:capabilityIndex fps:fps rotate:Rotate_Auto];
}

- (void)loadView
{
    self.title = self.Confname;
    CGRect range = [UIScreen mainScreen].bounds;

    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view.backgroundColor = [UIColor grayColor];
    
    UIBarButtonItem *leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"videoConf03"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(exitAlert)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"videoConf03"] style:UIBarButtonItemStyleDone target:self action:@selector(exitAlert)];
    }
    self.navigationItem.leftBarButtonItem = leftItem;
    
    if (self.isCreator) {
        
        UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:@"管理" style:UIBarButtonItemStyleDone target:self action:@selector(management)];
        [rightBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
        [rightBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = rightBar;
        
    }
    
    //创建头部UI
    [self createTitleUI];

    //创建视频窗口
    [self createVideoUI];
    
    //创建控麦、切换摄像头和结束视频
    [self createButtonWithRect:CGRectMake(45-11,CGRectGetMaxY(self.view4.frame)+20.0f, 44, 44) andTag:VideoConfVIEW_BtnChangeCam andImageName:@"videoConf05"];
    [self createButtonWithRect:CGRectMake(147-11, CGRectGetMaxY(self.view4.frame)+20.0f, 44, 44) andTag:VideoConfVIEW_BtnMic andImageName:@"videoConf07"];
    [self createButtonWithRect:CGRectMake(11, range.size.height-44.0f*3, screenWidth-22, 44) andTag:VideoConfVIEW_BtnExit andImageName:@"videoConf58"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[ECDevice sharedInstance].VoIPManager setVideoView:nil andLocalView:self.view1.bgView];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMultiVideoMeetingMsg:) name:KNOTIFICATION_onReceiveMultiVideoMeetingMsg object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

-(void)management
{
    if (self.menuView == nil) {
        
        self.menuView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ClearView)];
        [self.menuView addGestureRecognizer:tap];
        
        NSArray *menuTitles = @[@"邀请用户(VoIP)",@"邀请用户(电话)"];
        
        CGFloat menuHeight = 40.0f;
        CGFloat menuWight = 150.0f;
        
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(160.0f, 64.0f, menuWight, menuHeight*menuTitles.count)];
        view.tag = 50;
        view.backgroundColor = [UIColor blackColor];
        [self.menuView addSubview:view];
        
        for (NSString* title in menuTitles) {
            NSUInteger index = [menuTitles indexOfObject:title];
            UIButton * menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            menuBtn.tag = index;
            menuBtn.frame =CGRectMake(0.0f, menuHeight*index, menuWight, menuHeight);
            [menuBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [menuBtn setTitle:title forState:UIControlStateNormal];
            [menuBtn addTarget:self action:@selector(menuListBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:menuBtn];
        }
    }
    
    if (self.menuView.superview == nil) {
        [self.view.window addSubview:self.menuView];
    }
}

-(void)ClearView {
    [self.menuView removeFromSuperview];
    self.menuView = nil;
}

-(void)menuListBtnClicked:(id)sender {
    UIButton *button = (UIButton*)sender;
    switch (button.tag)
    {
        case 0:
            [self addMember:NO];
            break;
            
        case 1:
            [self addMember:YES];
            break;
            
        default:
            break;
    }
    [self ClearView];
}

-(void)addMember:(BOOL)isloading {
    if (isloading == NO) {
        
        UIAlertView *alertView = alertView = [[UIAlertView alloc] initWithTitle:@"VoIP加入群聊" message:@"请输入要邀请加入聊天室的VoIP账号，对方接听后即可加入聊天。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = VideoConfVIEW_addmember_voip;
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alertView textFieldAtIndex:0];
        textField.placeholder = @"请输入VoIP号";
        [alertView show];
    } else {
        
        UIAlertView *alertView = alertView = [[UIAlertView alloc] initWithTitle:@"接听电话加入群聊" message:@"请输入要邀请加入聊天室的号码（固号需加区号），对方接听免费电话后即可加入聊天。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = VideoConfVIEW_addmember;
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alertView textFieldAtIndex:0];
        textField.keyboardType = UIKeyboardTypePhonePad;
        textField.placeholder = @"请输入号码，固话需加拨区号";
        [alertView show];
    }
}


//创建头部UI
- (void)createTitleUI {
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_Tips.png"]];
    NSMutableArray *  images = [[NSMutableArray alloc] init];
    [images addObject:[UIImage imageNamed:@"video_Tips.png"]];
    [images addObject:[UIImage imageNamed:@"video_new_tips.png"]];
    imgView.animationImages = images;
    imgView.frame = CGRectMake(0.0f, 0.0f, screenWidth, 22);
    [self.view addSubview:imgView];
    self.pointImg = imgView;
    self.pointImg.animationDuration = 0.5;//设置动画时间
    self.pointImg.animationRepeatCount = 6;//设置动画次数 0 表示无限
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(11.0f, 0.0f, 265.0f, 22)];
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.font = [UIFont systemFontOfSize:13.0f];
    statusView = statusLabel;
    statusLabel.text = [NSString stringWithFormat:@"正在加入会议..."];
    [self.view addSubview:statusLabel];
}

//创建视频窗口
- (void)createVideoUI {
    
    MultiVideoView *mainView = [[MultiVideoView alloc] initWithFrame:CGRectMake(11, 33, 195, 195)];
    mainView.myDelegate = self;
    mainView.voipLabel.text = @"";
    mainView.tag = VideoConfVIEW_ViewMain;
    mainView.icon.hidden = YES;
    [self.view addSubview:mainView];
    self.mainView = mainView;
    
    MultiVideoView *view1 = [[MultiVideoView alloc] initWithFrame:CGRectMake(self.mainView.frame.origin.x+self.mainView.frame.size.width+11, 33, 92, 92)];
    view1.tag = VideoConfVIEW_View1;
    view1.videoLabel.text  = @"";
    view1.myDelegate = self;
    [self.view addSubview:view1];
    self.view1 = view1;
    self.view1.isDisplayVideo=YES;
    
    MultiVideoView *view2 = [[MultiVideoView alloc] initWithFrame:CGRectMake(self.view1.frame.origin.x, self.view1.frame.origin.y+92+11, 92, 92)];
    view2.tag = VideoConfVIEW_View2;
    view2.myDelegate = self;
    [self.view addSubview:view2];
    self.view2 = view2;
    
    MultiVideoView *view3 = [[MultiVideoView alloc] initWithFrame:CGRectMake(self.mainView.frame.origin.x, self.mainView.frame.origin.y+195+11, 92, 92)];
    view3.tag = VideoConfVIEW_View3;
    view3.myDelegate = self;
    [self.view addSubview:view3];
    self.view3 = view3;
    
    MultiVideoView *view4 = [[MultiVideoView alloc] initWithFrame:CGRectMake(self.mainView.frame.origin.x+92+11, self.mainView.frame.origin.y+195+11, 92, 92)];
    view4.tag = VideoConfVIEW_View4;
    view4.myDelegate = self;
    [self.view addSubview:view4];
    self.view4 = view4;
    
    MultiVideoView *view5 = [[MultiVideoView alloc] initWithFrame:CGRectMake(self.mainView.frame.origin.x+92+11+92+11, self.mainView.frame.origin.y+195+11, 92, 92)];
    view5.tag = VideoConfVIEW_View5;
    view5.myDelegate = self;
    [self.view addSubview:view5];
    self.view5 = view5;
}

//创建控麦和摄像头
- (void)createButtonWithRect:(CGRect) frame andTag:(NSInteger) tag andImageName:(NSString*) imgName
{
    UIButton *btn= [UIButton buttonWithType:(UIButtonTypeCustom)];
    btn.frame = frame;
    btn.tag = tag;
    [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",imgName]] forState:(UIControlStateNormal)];
    [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_on.png",imgName]] forState:(UIControlStateSelected)];
    if (btn.tag == VideoConfVIEW_BtnChangeCam)
    {
        [btn addTarget:self action:@selector(changeCam:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    else if (btn.tag == VideoConfVIEW_BtnMic)
    {
        [btn addTarget:self action:@selector(muteMic:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    else if (btn.tag == VideoConfVIEW_BtnExit)
    {
        [btn addTarget:self action:@selector(exitAlert) forControlEvents:(UIControlEventTouchUpInside)];
    }
    [self.view addSubview:btn];
}

#pragma mark -点击按钮处理方法
-(void)changeCam:(id)sender
{
    curCameraIndex ++;
    if (curCameraIndex >= self.cameraInfoArr.count)
    {
        curCameraIndex = 0;
    }
    CameraDeviceInfo *camera = [self.cameraInfoArr objectAtIndex:curCameraIndex];
    [self selectCamera:camera.index];
}

- (void)muteMic:(id)sender
{
    isMute = !isMute;
    UIButton *btn = (UIButton*) sender;
    [[ECDevice sharedInstance].VoIPManager setMute:isMute];
    if (isMute)
    {
        [btn setImage:[UIImage imageNamed:@"videoConf13_on.png"] forState:(UIControlStateSelected)];
        [btn setImage:[UIImage imageNamed:@"videoConf13.png"] forState:(UIControlStateNormal)];
    }
    else
    {
        [btn setImage:[UIImage imageNamed:@"videoConf07_on.png"] forState:(UIControlStateSelected)];
        [btn setImage:[UIImage imageNamed:@"videoConf07.png"] forState:(UIControlStateNormal)];
        [self controllerSpeak:YES];
    }
}

-(void)exitAlert
{
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"退出视频会议" message:@"真的要结束会议吗？" delegate:self cancelButtonTitle:@"结束" otherButtonTitles:@"取消", nil];
    if (self.myAlertView)
    {
        [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
    }
    self.myAlertView = alertview;
    alertview.tag = VideoConfVIEW_exitAlert;
    [alertview show];
}

#pragma mark -UIAlertView的代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == VideoConfVIEW_ConfDisslove|| alertView.tag == VideoConfVIEW_kickOff) {
        
        if (self.myAlertView) {
            [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
        }
        [self exitVideoConf];
    } else if(alertView.tag == VideoConfVIEW_exitAlert) {
        
        if (buttonIndex == 0) {
            
            if (self.isCreator) {
                
                self.isCreatorExit = YES;
                
                if (self.isAutoDelete == NO||self.isAutoClose == NO) {
                    
                    [self exitVideoConf];
                    return;
                }
                
                [self deleteMultiVideo];
            } else {
                [self exitVideoConf];
            }
        }
    } else if(alertView.tag==VideoConfVIEW_addmember_voip || alertView.tag == VideoConfVIEW_addmember) {
        
        UITextField *textField = [alertView textFieldAtIndex:0];
        if (buttonIndex == 1) {
            if ([textField.text length]==0) {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"邀请的号码不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                alert.tag = VideoConfVIEW_addNullNumber;
                [alert show];
                return;
            } else {
                __weak __typeof(self) weakSelf = self;
                [[ECDevice sharedInstance].meetingManager inviteMembersJoinMultiMediaMeeting:self.curVideoConfId andIsLoandingCall:(alertView.tag == VideoConfVIEW_addmember) andMembers:@[textField.text] completion:^(ECError *error, NSString *meetingNumber) {
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    if (error.errorCode != ECErrorType_NoError) {
                    
                        NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                        [strongSelf showProgress:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
                    }
                }];
            }
        }
    }
}

#pragma mark -删除多路视频会议
- (void)deleteMultiVideo
{
    __weak __typeof(self) weakSelf = self;
    [[ECDevice sharedInstance].meetingManager deleteMultMeetingByMeetingType:ECMeetingType_MultiVideo andMeetingNumber:self.curVideoConfId completion:^(ECError *error, NSString *meetingNumber) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf closeProgress];
        
        if (error.errorCode == ECErrorType_NoError) {
            
            [strongSelf exitVideoConf];
        } else {
            
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
            hud.labelText = [NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail];
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:2];
            [self exitVideoConf];
        }
    }];

}

#pragma mark -退出当前的会议

- (void)exitVideoConf {
    [[ECDevice sharedInstance].meetingManager exitMeeting];
    [self backToView];
}

- (void)backToView {
    [self closeProgress];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popToViewController:self.backView animated:YES];
}

#pragma mark -蒙版
-(void)showProgress:(NSString *)labelText{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = labelText;
    hud.mode = MBProgressHUDModeText;
    hud.margin = 30.0f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.0];
}

-(void)closeProgress{
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

#pragma mark -joinInVideoConf
- (void)joinInVideoConf
{
    statusView.text =@"连接中，请稍后....";
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍后...";
    hud.removeFromSuperViewOnHide = YES;
    
    __weak __typeof(self) weakSelf = self;
    [[ECDevice sharedInstance].meetingManager joinMeeting:self.curVideoConfId ByMeetingType:ECMeetingType_MultiVideo andMeetingPwd:nil completion:^(ECError *error, NSString *meetingNumber) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf closeProgress];
        
        if (error.errorCode == ECErrorType_NoError) {
            
            strongSelf.curVideoConfId = meetingNumber;
            if (strongSelf.curVideoConfId.length>0) {
                [strongSelf queryMemberInVideoMeeting];
            }
            statusView.text = [NSString stringWithFormat:@"正在%@会议",strongSelf.curVideoConfId];
        }
        else {
            
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
            [strongSelf showProgress:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
        }
    }];
}

#pragma mark -创建会议房间
- (void)createMultiVideoWithAutoClose:(BOOL)isAutoClose andIsPresenter:(BOOL)isPresenter andiVoiceMod:(NSInteger)voiceMod andAutoDelete:(BOOL)autoDelete andIsAutoJoin:(BOOL)isAutoJoin
{
    ECCreateMeetingParams *params = [[ECCreateMeetingParams alloc]init];
    params.meetingName=_Confname;
    params.meetingPwd = @"";
    params.meetingType = ECMeetingType_MultiVideo;
    params.square = 5;
    params.autoClose = isAutoClose;
    params.autoJoin = isAutoJoin;
    params.autoDelete = autoDelete;
    params.voiceMod = voiceMod;
    params.keywords = @"";
    
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍后...";
    hud.removeFromSuperViewOnHide = YES;
    
    __weak __typeof(self) weakSelf = self;
    [[ECDevice sharedInstance].meetingManager createMultMeetingByType:params completion:^(ECError *error, NSString *meetingNumber) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf closeProgress];
        
        if(error.errorCode ==ECErrorType_NoError) {
            
            strongSelf.curVideoConfId = meetingNumber;
            strongSelf.isAutoClose = isAutoClose;
            strongSelf.isAutoDelete = autoDelete;
            if (strongSelf.curVideoConfId.length>0) {
                [strongSelf queryMemberInVideoMeeting];
            }
            statusView.text = [NSString stringWithFormat:@"正在%@会议",strongSelf.curVideoConfId];
        }
        else {
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
            [strongSelf showProgress:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
        }
    }];
}

-(void)queryMemberInVideoMeeting{
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍后...";
    hud.removeFromSuperViewOnHide = YES;
    
    if(self.curVideoConfId){
        
        __weak __typeof(self) weakSelf = self;
        [[ECDevice sharedInstance].meetingManager queryMeetingMembersByMeetingType:ECMeetingType_MultiVideo andMeetingNumber:self.curVideoConfId completion:^(ECError *error, NSArray *members) {
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf closeProgress];
            
            if(error.errorCode == ECErrorType_NoError){
                
                [strongSelf.membersArray removeAllObjects];
                [strongSelf.membersArray addObjectsFromArray:members];
                
                ECMultiVideoMeetingMember *meInfo = nil;
                NSArray *tmpMemberarr = [NSArray arrayWithArray:self.membersArray];
                for (ECMultiVideoMeetingMember *videoMembers in tmpMemberarr)
                {
                    if ([[DemoGlobalClass sharedInstance].userName isEqualToString:videoMembers.voipAccount.account])
                    {
                        meInfo = videoMembers;
                        strongSelf.myVideoState = videoMembers.videoState;
                        [strongSelf.membersArray removeObject:members];
                    }
                    [strongSelf addMemberToView:videoMembers];
                }
                if (meInfo) {
                    [strongSelf.membersArray insertObject:meInfo atIndex:0];
                }
            }
            else {
                
                NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                [strongSelf showProgress:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
            }
        }];
    }
}

- (void)addMemberToView:(ECMultiVideoMeetingMember *)member
{
    if (member && [member.voipAccount.account isEqualToString:[DemoGlobalClass sharedInstance].userName] && member.voipAccount.isVoIP)
    {
        self.view1.isDisplayVideo = YES;
        self.view1.strVoip = member.voipAccount;
        if (member.voipAccount.account.length >=4) {
            
            self.view1.voipLabel.text = [member.voipAccount.account substringFromIndex:[member.voipAccount.account length]-4];
        } else {
            
            self.view1.voipLabel.text = member.voipAccount.account;
        }
        self.view1.videoLabel.text = @"";
        return;
    }
    for (int i = VideoConfVIEW_View1+1; i<VideoConfVIEW_View1+5; i++)
    {
        MultiVideoView *tmpView = (MultiVideoView*)[self.view viewWithTag:i];
        
        if (tmpView && tmpView.strVoip == nil)
        {
            if (member)
            {
                tmpView.strVoip = member.voipAccount;
                if (member.voipAccount.account.length >=4) {
                    
                    tmpView.voipLabel.text = [member.voipAccount.account substringFromIndex:[member.voipAccount.account length]-4];
                } else {
                    
                    tmpView.voipLabel.text = member.voipAccount.account;
                }
                tmpView.videoLabel.text = @"";
                if (videoCount > 10) return;
                else
                {
                    NSArray *addrarr = [member.videoSource componentsSeparatedByString:@":"];
                    if (addrarr.count == 2)
                    {
                        tmpView.isDisplayVideo = YES;
                        
                        NSString *port = [addrarr objectAtIndex:1];
                        
                        [self setVideoConf:[addrarr objectAtIndex:0]];
                        
                        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        hud.labelText = @"请稍后...";
                        hud.removeFromSuperViewOnHide = YES;
                        
                        __weak __typeof(self) weakSelf = self;
                        [[ECDevice sharedInstance].meetingManager requestMemberVideoWithAccount:member.voipAccount.account andDisplayView:tmpView.bgView andVideoMeeting:self.curVideoConfId andPwd:nil andPort:[port integerValue] completion:^(ECError *error, NSString *meetingNumber, NSString *member) {
                            
                            __strong __typeof(weakSelf)strongSelf = weakSelf;
                            [strongSelf closeProgress];
                            
                            if (error.errorCode == ECErrorType_NoError) {
                                
                                 videoCount ++;
                            }
                            else {
                                
                                NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                                [strongSelf showProgress:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
                            }
                        }];
                    }
                }
            }
            break;
        }
    }
}

- (void) setVideoConf:(NSString *)videoConf {
    if (self.confAddr == nil && videoConf!=nil && videoConf.length > 0) {
        self.confAddr = videoConf;
        [[ECDevice sharedInstance].meetingManager setVideoConferenceAddr:self.confAddr];
    }
}

#pragma mark -视频分辨率发生变化
- (void)onCallVideoRatioChanged:(NSString *)callid andVoIP:(NSString *)voip andIsConfrence:(BOOL)isConference andWidth:(NSInteger)width andHeight:(NSInteger)height {
    
    if (isConference && voip.length > 0) {
        
        for (int i = VideoConfVIEW_View1+1; i<VideoConfVIEW_View1+5; i++) {
            MultiVideoView* tmpView = (MultiVideoView*)[self.view viewWithTag:i];
            if (tmpView.strVoip.account.length > 0 && [tmpView.strVoip.account isEqualToString:voip]) {
                [tmpView setVideoRatioChangedWithHeight:height withWidth:width];
                break;
            }
        }
    }
}

#pragma mark -通知客户端收到新的会议信息
-(void)receiveMultiVideoMeetingMsg:(NSNotification *)notification
{
    ECMultiVideoMeetingMsg *msg = (ECMultiVideoMeetingMsg *)notification.object;
    if (![msg.roomNo isEqualToString:self.curVideoConfId]) {
        return;
    }
    
    ECMultiVideoMeetingMsgType type=  msg.type;
    
    NSString *voip = [DemoGlobalClass sharedInstance].userName;
    if(type == MultiVideo_JOIN)
    {
        if ([self.curVideoConfId isEqualToString:msg.roomNo])
        {
            NSInteger joinCount = 0;
            for (ECVoIPAccount *who in msg.joinArr)
            {
                BOOL isJoin = NO;
                for (ECMultiVideoMeetingMember  *m in self.membersArray )
                {
                    if ([m.voipAccount.account isEqualToString:who.account] && m.voipAccount.isVoIP==who.isVoIP)
                    {
                        isJoin = YES;
                        break;
                    }
                }
                if (isJoin)
                {
                    continue;
                }
                
                ECMultiVideoMeetingMember *member = [[ECMultiVideoMeetingMember alloc] init];
                member.voipAccount = [[ECVoIPAccount alloc] init];
                member.voipAccount.account = who.account;
                member.voipAccount.isVoIP = who.isVoIP;
                
                if(![voip isEqualToString:who.account] && who.account.length>4){
                    [self showProgress:[NSString stringWithFormat:@"%@加入会议",[who.account substringFromIndex:[who.account length]-4]]];
                }
                member.role = 0;
                member.videoState = msg.videoState;
                member.videoSource = msg.videoSource;
                [self.membersArray addObject:member];
                [self addMemberToView:member];
                joinCount++;
            }
            
            if (joinCount > 0)
            {
                [self.pointImg stopAnimating];
                [self.pointImg startAnimating];
                statusView.text = @"有人加入会议";
            }
        }
    }
    else if(type == MultiVideo_EXIT)//有人退出
    {
        if ([self.curVideoConfId isEqualToString:msg.roomNo])
        {
            NSMutableArray *exitArr = [[NSMutableArray alloc] init];
            for (ECVoIPAccount *who in msg.exitArr)
            {
                for (ECMultiVideoMeetingMember *member in self.membersArray)
                {
                    if ([who.account isEqualToString:member.voipAccount.account] && who.isVoIP==member.voipAccount.isVoIP)
                    {
                        [exitArr addObject:member];
                        if(![voip isEqualToString:who.account] && who.account.length>4){
                            statusView.text = [NSString stringWithFormat:@"%@退出了会议",[who.account substringFromIndex:[who.account length]-4]];
                        }
                        [self removeMemberFromView:member];
                    }
                }
            }
            if (exitArr.count > 0)
            {
                [self.membersArray removeObjectsInArray:exitArr];
                [self.pointImg stopAnimating];
                [self.pointImg startAnimating];
                statusView.text = @"有人退出会议";
            }
        }
    }
    else if(type == MultiVideo_DELETE)
    {
        if ([msg.roomNo isEqualToString:self.curVideoConfId])
        {
            if (_isCreatorExit)//创建者退出时解散会议则不提示
            {
                if (self.myAlertView)
                {
                    [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
                }
                [self exitVideoConf];
            }
            else
            {
                UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"会议被解散" message:@"抱歉，该会议已经被创建者解散，点击确定可以退出！"  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                if (self.myAlertView)
                {
                    [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
                }
                self.myAlertView = alertview;
                alertview.tag = VideoConfVIEW_ConfDisslove;
                [alertview show];
            }
        };
    }
    else if(type == MultiVideo_REMOVEMEMBER)
    {
        if ([msg.roomNo isEqualToString: self.curVideoConfId])
        {
            if ([msg.who.account isEqualToString:[DemoGlobalClass sharedInstance].userName] && msg.who.isVoIP)//自己被踢出
            {
                UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"您已被请出会议" message:@"抱歉，您被创建者请出会议了，点击确定以退出"  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                if (self.myAlertView)
                {
                    [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
                }
                self.myAlertView = alertview;
                
                alertview.tag = VideoConfVIEW_kickOff;
                [alertview show];
                return;
            }
            NSInteger* exitCount = 0;
            NSMutableArray *removeArray = [NSMutableArray array];
            for (ECMultiVideoMeetingMember *member in self.membersArray)
            {
                if ([msg.who.account isEqualToString:member.voipAccount.account] && msg.who.isVoIP==member.voipAccount.isVoIP)
                {
                    [removeArray addObject:member];
                    if(![[DemoGlobalClass sharedInstance].userName isEqualToString:msg.who.account] && msg.who.account.length>4){
                        statusView.text = [NSString stringWithFormat:@"%@踢出了会议",[msg.who.account substringFromIndex:[msg.who.account length]-4]];
                    }
                    [self removeMemberFromView:member];
                    exitCount++;
                }
            }
            if (exitCount > 0)
            {
                [self.membersArray removeObjectsInArray:removeArray];
                [self.pointImg stopAnimating];
                [self.pointImg startAnimating];
                statusView.text = @"有人被踢出会议";
            }
        }
    }
    else if(type == MultiVideo_PUBLISH)
    {
        if ([msg.roomNo isEqualToString: self.curVideoConfId])
        {
            
            for (ECMultiVideoMeetingMember *member in self.membersArray)
            {
                if ([msg.who.account isEqualToString:member.voipAccount.account] && msg.who.isVoIP==member.voipAccount.isVoIP)
                {
                    member.videoState = msg.videoState;
                    member.videoSource = msg.videoSource;
                    break;
                }
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@发布视频",msg.who.account] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
    else if(type == MultiVideo_UNPUBLISH)
    {
        if ([msg.roomNo isEqualToString: self.curVideoConfId])
        {
            
            for (ECMultiVideoMeetingMember *member in self.membersArray)
            {
                if ([msg.who.account isEqualToString:member.voipAccount.account] && msg.who.isVoIP==member.voipAccount.isVoIP)
                {
                    member.videoState = msg.videoState;
                    member.videoSource = nil;
                    break;
                }
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@取消发布视频",msg.who.account] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    } else if (type == MultiVideo_REFUSE) {
        
        UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"拒接" message:@"抱歉，对方拒绝了你的请求"  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alertview.tag = VideoConfVIEW_refuse;
        [alertview show];
    }
}

#pragma mark -删除多路视频会议成员
-(void)removeMemberFromView:(ECMultiVideoMeetingMember *)member
{
    for (int i = VideoConfVIEW_View1; i<VideoConfVIEW_View1+5; i++)
    {
        MultiVideoView* tmpView = (MultiVideoView*)[self.view viewWithTag:i];
        if (tmpView && tmpView.strVoip != nil)
        {
            if (member && [tmpView.strVoip.account isEqualToString:member.voipAccount.account] && tmpView.strVoip.isVoIP==member.voipAccount.isVoIP)
            {
                
                __weak __typeof(self) weakSelf = self;
                [[ECDevice sharedInstance].meetingManager cancelMemberVideoWithAccount:member.voipAccount.account andVideoMeeting:self.curVideoConfId andPwd:nil completion:^(ECError *error, NSString *meetingNumber, NSString *member) {
                    
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    [strongSelf closeProgress];
                    if (error.errorCode == ECErrorType_NoError) {
                        
                        videoCount --;
                    } else {
                        
                        NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                        [strongSelf showProgress:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
                    }
                }];
                
                tmpView.isDisplayVideo = NO;
                tmpView.ivChoose.hidden = YES;
                for (UIView *view in tmpView.bgView.subviews) {
                    [view removeFromSuperview];
                }
                tmpView.bgView.backgroundColor = [UIColor clearColor];
                tmpView.bgView.layer.contents = nil;
                tmpView.strVoip = nil;
                tmpView.videoLabel.text = @"待加入";
                tmpView.voipLabel.text = @"";
                tmpView.icon.hidden = YES;
                break;
            }
        }
    }
}

#pragma mark -发布多路视频和取消多路视频
- (void)onChooseIndex:(NSInteger)index andVoipAccount:(ECVoIPAccount *)voip
{
    MultiVideoView* video = (MultiVideoView*)[self.view viewWithTag:index];
   
    self.curMember = voip;
    int i = 0;
    UIActionSheet *menu = nil;
    if ([[DemoGlobalClass sharedInstance].userName isEqualToString:voip.account] && voip.isVoIP) {
        menu = [[UIActionSheet alloc] initWithTitle: @"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        menu.tag = 105;
        if (self.myVideoState == 1) {//2代表未发布
            
            [menu addButtonWithTitle:@"取消发布视频"];
        } else if(self.myVideoState == 2){//1代表发布
            
            [menu addButtonWithTitle:@"发布视频"];
        }
        i++;
    } else {
        menu = [[UIActionSheet alloc] initWithTitle: @"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        menu.tag = 100;
        
        if (video.isDisplayVideo ) {
            
            [menu addButtonWithTitle:@"取消视频"];
        } else {
            
            [menu addButtonWithTitle:@"请求视频"];
        }
        i++;
    }
        
    if (video.isZoomBig) {
        
        [menu addButtonWithTitle:@"缩小"];
    } else {
        
        [menu addButtonWithTitle:@"放大"];
    }
    i++;
    
    if (self.isCreator && (![[DemoGlobalClass sharedInstance].userName isEqualToString:voip.account] || !voip.isVoIP)) {
        
        [menu addButtonWithTitle:@"移除成员"];
        i++;
    }
    if (menu != nil) {
        if (i > 0) {
            [menu addButtonWithTitle:@"取消"];
            [menu setCancelButtonIndex:i];
            [menu showInView:self.view.window];
        }
    }

}

-(void)resetVideoViewFrame
{
    for (int i = VideoConfVIEW_View1; i<VideoConfVIEW_View1+5; i++)
    {
        MultiVideoView* tmpView = (MultiVideoView*)[self.view viewWithTag:i];
        if (tmpView.isZoomBig)
        {
            tmpView.isZoomBig = NO;
            tmpView.frame = tmpView.originFrame;
        }
    }
}

#pragma mark -UIActionSheet的代理方法
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 100)//视频处理
    {
        MultiVideoView *view = nil;
        if ([self.view2.strVoip.account isEqualToString:self.curMember.account] && self.view2.strVoip.isVoIP == self.curMember.isVoIP) {
            view =self.view2;
        }
        else if ([self.view3.strVoip.account isEqualToString:self.curMember.account] && self.view3.strVoip.isVoIP == self.curMember.isVoIP) {
            view = self.view3;
        }
        else if ([self.view4.strVoip.account isEqualToString:self.curMember.account] && self.view4.strVoip.isVoIP == self.curMember.isVoIP) {
            view = self.view4;
        }
        else if ([self.view5.strVoip.account isEqualToString:self.curMember.account] && self.view5.strVoip.isVoIP == self.curMember.isVoIP) {
            view = self.view5;
        }
        
        if (buttonIndex == 0)
        {
            if (view.isDisplayVideo)
            {
                __weak __typeof(self) weakSelf = self;
                [[ECDevice sharedInstance].meetingManager cancelMemberVideoWithAccount:self.curMember.account andVideoMeeting:self.curVideoConfId andPwd:nil completion:^(ECError *error, NSString *meetingNumber, NSString *member) {
                    
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    if (error.errorCode == ECErrorType_NoError) {
                        
                    } else {
                        
                        NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                        [strongSelf showProgress:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
                    }
                }];
                videoCount --;
                view.isDisplayVideo = NO;
            }
            else {
                if (videoCount>10) {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"  message:@"视频数过多，请先取消一个" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                    return;
                }
                
                for (ECMultiVideoMeetingMember *member in self.membersArray)
                {
                    if ([self.curMember.account isEqualToString:member.voipAccount.account] && self.curMember.isVoIP == member.voipAccount.isVoIP)
                    {
                        NSArray *addrarr = [member.videoSource componentsSeparatedByString:@":"];
                        if (addrarr.count == 2)
                        {
                            NSString* port = [addrarr objectAtIndex:1];
                            [self setVideoConf:[addrarr objectAtIndex:0]];
                            
                            __weak __typeof(self) weakSelf = self;
                            [[ECDevice sharedInstance].meetingManager requestMemberVideoWithAccount:self.curMember.account andDisplayView:view.bgView andVideoMeeting:self.curVideoConfId andPwd:nil andPort:port.integerValue completion:^(ECError *error, NSString *meetingNumber, NSString *member) {
                                
                                __strong __typeof(weakSelf)strongSelf = weakSelf;
                                if (error.errorCode == ECErrorType_NoError) {
                                    
                                    videoCount ++;
                                    view.isDisplayVideo = YES;
                                } else {
                                    
                                    NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                                    [strongSelf showProgress:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
                                }
                            }];
                        }
                    }
                }
            }
        }
        else if(buttonIndex == 1)
        {
            if (view.isZoomBig) {
                [self resetVideoViewFrame];
            } else {
                [self resetVideoViewFrame];
                view.isZoomBig = YES;
                view.frame = self.mainView.frame;
            }
        }
        else if (buttonIndex == 2) {
            
            if (self.isCreator) {
                
                MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = @"请稍后...";
                hud.removeFromSuperViewOnHide = YES;
                
                ECVoIPAccount *member = [[ECVoIPAccount alloc] init];
                member.account = self.curMember.account;
                member.isVoIP = self.curMember.isVoIP;
                
                __weak __typeof(self) weakSelf = self;
                [[ECDevice sharedInstance].meetingManager removeMemberFromMultMeetingByMeetingType:ECMeetingType_MultiVideo andMeetingNumber:self.curVideoConfId andMember:member completion:^(ECError *error, ECVoIPAccount *memberVoip) {
                    
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    [strongSelf closeProgress];
                    if (error.errorCode == ECErrorType_NoError) {
                        if (!strongSelf.isCreator) {
                            [strongSelf.membersArray removeObject:memberVoip];
                        }
                    } else {
                        
                        NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                        [strongSelf showProgress:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
                    }
                }];
            }
        }
    }
   else if (actionSheet.tag == 105)
    {
        if (buttonIndex == 0)
        {
            if (self.myVideoState == 1)
            {
                __weak __typeof(self) weakSelf = self;
                [[ECDevice sharedInstance].meetingManager cancelPublishSelfVideoFrameInVideoMeeting:self.curVideoConfId completion:^(ECError *error, NSString *meetingNumber) {
                    
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    if(error.errorCode==ECErrorType_NoError){
                        
                        strongSelf.myVideoState = 2;
                    }else {
                        
                        NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                        [strongSelf showProgress:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
                    }
                }];
            }
            else
            {
                __weak __typeof(self) weakSelf = self;
                [[ECDevice sharedInstance].meetingManager publishSelfVideoFrameInVideoMeeting:self.curVideoConfId completion:^(ECError *error, NSString *meetingNumber) {
               
                     __strong __typeof(weakSelf)strongSelf = weakSelf;
                    if(error.errorCode==ECErrorType_NoError){
                        
                        strongSelf.myVideoState = 1;
                    }else {
                        
                        NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                        [strongSelf showProgress:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
                    }
                }];
            }
        }
        else if (buttonIndex == 1)
        {
            if (self.view1.isZoomBig) {
                
                [self resetVideoViewFrame];
            } else {
                
                [self resetVideoViewFrame];
                self.view1.frame = self.mainView.frame;
                self.view1.isZoomBig = YES;
            }
        }
    }
}
@end
