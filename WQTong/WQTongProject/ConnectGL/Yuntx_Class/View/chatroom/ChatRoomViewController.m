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

#import "ChatRoomViewController.h"
#import "RoomMemberViewController.h"
#import "DeviceDelegateHelper+Meeting.h"

#define ChatRoomVIEW_BACKGROUND_COLOR [UIColor colorWithRed:35.0f/255.0f green:47.0f/255.0f blue:60.0f/255.0f alpha:1.0f]
#define ChatRoomVIEW_dissolve 9999
#define ChatRoomVIEW_addmember 9998
#define ChatRoomVIEW_addmember_voip 9900
#define ChatRoomVIEW_RoomDisslove 9997
#define ChatRoomVIEW_kickOff 9996
#define ChatRoomVIEW_exitAlert 9995
#define ChatRoomVIEW_joinChatroomErr 9994
#define ChatRoomVIEW_addNullNumber 9993
#define ChatRoomVIEW_refuse 9992


@interface ChatRoomViewController () {
    UILabel *statusView;
    UIView *membersListView;
    UILabel *tipsLabel;
    UILabel *netStatusLabel;
    UIView *amplitudeView;
    BOOL isMute;
    NSTimer *animationBoxTimer;
    NSInteger animationBoxCount;
    UIImageView *animBackview;
    BOOL isLoud;
    
    BOOL isCreatorExit;
}
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) NSMutableArray *membersArray;
@end

@implementation ChatRoomViewController

-(void)addMember:(BOOL)isloading {
    if (isloading) {
        UIAlertView *alertView = alertView = [[UIAlertView alloc] initWithTitle:@"接听电话加入群聊" message:@"请输入要邀请加入聊天室的号码（固号需加区号），对方接听免费电话后即可加入聊天。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = ChatRoomVIEW_addmember;
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alertView textFieldAtIndex:0];
        textField.keyboardType = UIKeyboardTypePhonePad;
        textField.placeholder = @"请输入号码，固话需加拨区号";
        [alertView show];
    } else {
        UIAlertView *alertView = alertView = [[UIAlertView alloc] initWithTitle:@"VoIP加入群聊" message:@"请输入要邀请加入聊天室的VoIP账号，对方接听后即可加入聊天。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = ChatRoomVIEW_addmember_voip;
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alertView textFieldAtIndex:0];
        textField.placeholder = @"请输入VoIP号";
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    @try {
        
        if (alertView.tag == ChatRoomVIEW_RoomDisslove|| alertView.tag == ChatRoomVIEW_kickOff) {
            
            [self backToView];
            
        } else if (alertView.tag ==  ChatRoomVIEW_dissolve) {
            
            if (buttonIndex == 1) {
                MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = @"请稍后...";
                hud.removeFromSuperViewOnHide = YES;
                
                __weak __typeof(self) weakSelf = self;
                [[ECDevice sharedInstance].meetingManager deleteMultMeetingByMeetingType:ECMeetingType_MultiVoice andMeetingNumber:self.curChatroomId completion:^(ECError *error, NSString *meetingNumber) {
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                    if (error.errorCode == ECErrorType_NoError) {
                        isCreatorExit = YES;
                        //可以等收到解散通知再退出界面
                    } else if (error.errorCode == 101020 || error.errorCode == 110183) {
                        //101020或者110183会议不存在这时候可以直接退出
                        [self backToView];
                    } else if (error.errorCode == 110095) {
                        UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"提示" message:@"解散会议失败，权限验证失败，只有创建者才能解散"  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alertview show];
                    } else if (error.errorCode == 170005) {
                        //网络错误，直接挂机
                        [[ECDevice sharedInstance].meetingManager exitMeeting];
                    } else {
                        NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                        [strongSelf showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
                    }
                }];
            }
            
        } else if(alertView.tag==ChatRoomVIEW_addmember || alertView.tag==ChatRoomVIEW_addmember_voip) {
            
            UITextField *textField = [alertView textFieldAtIndex:0];
            if (buttonIndex == 1) {
                if ([textField.text length]==0) {
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"邀请的号码不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    alert.tag = ChatRoomVIEW_addNullNumber;
                    [alert show];
                    return;
                } else {
                    __weak __typeof(self) weakSelf = self;
                    [[ECDevice sharedInstance].meetingManager inviteMembersJoinToVoiceMeeting:self.curChatroomId andIsLoandingCall:(alertView.tag==ChatRoomVIEW_addmember) andMembers:@[textField.text] completion:^(ECError *error, NSString *meetingNumber) {
                        __strong __typeof(weakSelf)strongSelf = weakSelf;
                        if (error.errorCode != ECErrorType_NoError) {
                            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                            [strongSelf showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
                        }
                    }];
                }
            }
            
        } else if(alertView.tag == ChatRoomVIEW_exitAlert) {
            
            if (buttonIndex == 1) {
                [self exitCurChatroom];
            }
            
        } else if(alertView.tag == ChatRoomVIEW_joinChatroomErr) {
            [self exitCurChatroom];
        } else if (alertView.tag == ChatRoomVIEW_refuse){
            
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
    }
}

-(void)management
{
    if (self.menuView == nil) {
        
        self.menuView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ClearView)];
        [self.menuView addGestureRecognizer:tap];
        
        NSArray *menuTitles = @[@"邀请用户(电话)", @"邀请用户(VoIP)", @"管理成员", @"解散房间", isLoud?@"听筒":@"扬声器"];
        
        CGFloat menuHeight = 40.0f;
        CGFloat menuWight = 150.0f;
        
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(screenWidth/2, 64.0f, menuWight, menuHeight*menuTitles.count)];
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
            [self addMember:YES];
            break;
        case 1:
            [self addMember:NO];
            break;
        case 2:
            [self kickOff];
            break;
        case 3:
            [self dissolve];
            break;
        case 4:
            [self loudSperker:nil];
            break;
        default:
            break;
    }
    [self ClearView];
}

-(void)kickOff {
    NSMutableArray* array = [NSMutableArray arrayWithArray:self.membersArray];
    for (ECMultiVoiceMeetingMember* member in array) {
        if ([member.account.account isEqualToString:[DemoGlobalClass sharedInstance].userName]){//把自己过滤出来
            
            [array removeObject:member];
            break;
        }
    }
    
    if ([array count] > 0) {
        RoomMemberViewController* view = [[RoomMemberViewController alloc] initWithRoomNo:self.curChatroomId Members:array];
        [self.navigationController pushViewController:view animated:YES];
    } else {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有可以管理的成员" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertview show];
    }
}

-(void)dissolve {
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"解散确认" message:@"你确定要解散房间吗？解散后不可恢复。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"解散", nil];
    alertview.tag = ChatRoomVIEW_dissolve;
    [alertview show];
}

- (void)loadView {
    
    isLoud = YES;
    self.title = self.roomname;
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] ;
    self.view.backgroundColor = ChatRoomVIEW_BACKGROUND_COLOR;
    
    self.membersArray = [NSMutableArray array];
    
    if (self.isJoin ) {
        
        UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStyleDone target:self action:@selector(showExitAlert)];
        [left setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
        [left setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = left;

    } else {
        
        UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(backToView)];
        [left setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
        [left setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = left;
    }

    
    if (self.isCreator) {
        
        UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:@"管理" style:UIBarButtonItemStyleDone target:self action:@selector(management)];
        [rightBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
        [rightBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = rightBar;
        
    } else {
        
        UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:isLoud?@" 听筒 ":@"扬声器" style:UIBarButtonItemStyleDone target:self action:@selector(loudSperker:)];
        [rightBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
        [rightBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = rightBar;
        
    }
    
    CGFloat frameY = 0.0f;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        frameY = 64.0f;
    }

    UIImageView *pointImg = [[UIImageView alloc] init];
    pointImg.frame = CGRectMake(0.0f, frameY, screenWidth, 29.0f);
    pointImg.backgroundColor = interphoneImageColor;
    
    [self.view addSubview:pointImg];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, frameY, 265.0f, 29.0f)];
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.font = [UIFont systemFontOfSize:13.0f];
    statusView = statusLabel;
    statusLabel.text = [NSString stringWithFormat:@"正在%@房间",self.curChatroomId];
    [self.view addSubview:statusLabel];
    
    UILabel *memberlistLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, frameY+40.0f, 100.0f, 15.0f)];
    memberlistLabel.backgroundColor = ChatRoomVIEW_BACKGROUND_COLOR;
    memberlistLabel.textColor = [UIColor whiteColor];
    memberlistLabel.text = @"成员列表";
    [self.view addSubview:memberlistLabel];
    
    UIView *listView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frameY+55.0f, screenWidth, 80.0f)];
    [self.view addSubview:listView];
    membersListView = listView;

//    animBackview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"animation_bg.png"]];
//    animBackview.center = CGPointMake(screenWidth/2, frameY+self.view.frame.size.height*0.5);
//    animBackview.clipsToBounds = YES;
//    animationBoxCount = screenWidth/13.0f;
//    
//    for (NSInteger i=0; i<animationBoxCount; i++) {
//        int index = arc4random() % 4 + 1;
//        NSString *fileName = [NSString stringWithFormat:@"animation_box0%d.png",index];
//        UIImageView *tmpImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];
//        tmpImg.frame = CGRectMake(2.0f+13.0f*i, 58.0f-tmpImg.frame.size.height-3.0f, 9.0f, tmpImg.frame.size.height);
//        [animBackview addSubview:tmpImg];
//        tmpImg.tag = 500;
//    }
//    
//    animationBoxTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateAnimationBox) userInfo:nil repeats:YES];
//    
//    UIImageView *tmpImg2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"multivoice_icon.png"]];
//    tmpImg2.center = CGPointMake(screenWidth/2-30, animBackview.frame.size.height*0.5);
//    tmpImg2.clipsToBounds = YES;
//    [animBackview addSubview:tmpImg2];
//    
//    [self.view addSubview:animBackview];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height-150.0f-44+frameY, screenWidth, 28.0f)];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:10];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"";
    netStatusLabel = label;
    [self.view addSubview:label];
    
    CGFloat buttom_Y = self.view.frame.size.height-150.0f-44+30+frameY;
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, buttom_Y,screenWidth, 20.0f)];
    label1.textColor = [UIColor whiteColor];
    label1.backgroundColor = [UIColor clearColor];
    label1.font = [UIFont systemFontOfSize:20];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.text = @"您的发言能让成员都听到";
    [self.view addSubview:label1];
    
    buttom_Y = buttom_Y + 30.0f;
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, buttom_Y, screenWidth, 14.0f)];
    label2.textColor = [UIColor grayColor];
    label2.backgroundColor = [UIColor clearColor];
    label2.font = [UIFont systemFontOfSize:13];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"点击下方麦克风静音";
    [self.view addSubview:label2];
    tipsLabel = label2;
    
    UIView* view1 = [[UIView alloc] init];
    view1.frame = CGRectMake(0, self.view.frame.size.height-74+frameY, screenWidth, 30);
    view1.backgroundColor = ChatRoomVIEW_BACKGROUND_COLOR;
    [self.view addSubview:view1];
    amplitudeView = view1;
    
    isMute = NO;
    UIButton *micBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    micBtn.frame = CGRectMake(115.0f*scaleModulus, self.view.frame.size.height-105.0f+frameY, 89.0f, 61.0f);
    [micBtn addTarget:self action:@selector(muteMic:) forControlEvents:UIControlEventTouchUpInside];
    [micBtn setImage:[UIImage imageNamed:@"mike_icon.png"] forState:UIControlStateNormal];
    [self.view addSubview:micBtn];

    for (int i = 0; i<=13; i++) {
        UIImageView* iv1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status01_icon_off.png"]];
        int left1 = 7+(16*i);
        if (i>=7)
            left1 = left1+95;
        iv1.frame = CGRectMake(left1*scaleModulus,12, 9, 9);
        iv1.tag = 1007;
        [amplitudeView addSubview:iv1];
        
        UIImageView* iv2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status01_icon_on.png"]];
        int left2 = 7+(16*i);
        if (i>=7)
            left2 = left2+95;
        iv2.frame = CGRectMake(left2*scaleModulus,12, 9, 9);
        iv2.tag = 2000+i;
        iv2.hidden = YES;
        [amplitudeView addSubview:iv2];
    }
    [self playAmplitude];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveChatroomMsg:) name:KNOTIFICATION_onReceiveMultiVoiceMeetingMsg object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.curChatroomId length] > 0) {
        [self querymeetingmember];
    }
}

-(void)querymeetingmember {
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍后...";
    hud.removeFromSuperViewOnHide = YES;
    
    __weak __typeof(self) weakSelf = self;
    [[ECDevice sharedInstance].meetingManager queryMeetingMembersByMeetingType:ECMeetingType_MultiVoice andMeetingNumber:self.curChatroomId completion:^(ECError *error, NSArray *members) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        
        if (error.errorCode == ECErrorType_NoError) {
            
            [strongSelf.membersArray removeAllObjects];
            [strongSelf.membersArray addObjectsFromArray:members];
            for (ECMultiVoiceMeetingMember *member in strongSelf.membersArray) {
                
                if ([[DemoGlobalClass sharedInstance].userName isEqualToString:member.account.account]) {
                    [strongSelf.membersArray exchangeObjectAtIndex:0 withObjectAtIndex:[strongSelf.membersArray indexOfObject:member]];
                    break;
                }
            }
            [strongSelf reloadMembersData];
            
        } else {
            
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
            [strongSelf showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
        }
    }];
}

-(void) dealloc {
    [animationBoxTimer invalidate];
    animationBoxTimer = nil;
    self.membersArray = nil;
    self.curChatroomId = nil;
    self.roomname = nil;
}

- (void)updateAnimationBox {
    NSInteger originX_i = arc4random() % animationBoxCount;
    for (UIView *view in animBackview.subviews) {
        if (view.tag == 500) {
            originX_i++;
            if (originX_i == animationBoxCount) {
                originX_i = 0;
            }
            view.frame = CGRectMake(2.0f+13.0f*originX_i, 58.0f-view.frame.size.height-3.0f, 9.0f, view.frame.size.height);
        }
    }
}

-(void)playAmplitude {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(showAmplitude) userInfo:nil repeats:YES];
}

-(void)stopAmplitude {
    [self.timer invalidate];
    self.timer = nil;
    for (UIView *view in amplitudeView.subviews) {
        if (view.tag >=2000)
            [view setHidden:YES];
    }
}

-(void)showAmplitude {
    int i = arc4random() % 3;
    for (UIView *view in amplitudeView.subviews) {
        if (view.tag >= 2000 && view.tag < 2007) {
            int itag = 2000+i+1;
            if (view.tag > itag)
                view.hidden = NO;
            else
                view.hidden = YES;
        } else if (view.tag >= 2007 && view.tag <= 2013) {
            int itag = 2007+(7-i-2);
            if (view.tag < itag)
                view.hidden = NO;
            else
                view.hidden = YES;
        }
    }
}

- (void)muteMic:(id)sender {
    isMute = !isMute;
    [[ECDevice sharedInstance].VoIPManager setMute:isMute];
    if (isMute) {
        tipsLabel.text = @"麦克风已关闭，可点击开启";
        [self stopAmplitude];
    } else {
        tipsLabel.text = @"可点击下方麦克风静音";
        [self playAmplitude];
    }
}

- (void)loudSperker:(id)sender {
    isLoud = !isLoud;
    [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:isLoud];

    if (sender != nil) {
        UIBarButtonItem* btn = (UIBarButtonItem*)sender;
        btn.title = isLoud?@" 听筒 ":@"扬声器";
    }
}

- (void)backToView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popToViewController:self.backView animated:YES];
}

- (void)reloadMembersData
{
    for (UIView* view in membersListView.subviews) {
        if (view.tag >= 1001 && view.tag < 1005) {
            [view removeFromSuperview];
        }
    }
    
    int i = 0;
    for (ECMultiVoiceMeetingMember* member in self.membersArray) {
        NSString* strImg = nil;
        if (i == 0) {
            strImg = @"touxiang.png";
        } else {
            strImg = @"status01_icon.png";
        }
        UIImageView* iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:strImg]];
        int j = i % 2;
        int left = 30+150*j;
        int row = i/2;
        int top  = 20+(20*row);
        iv.frame = CGRectMake(left,top, 9, 9);
        iv.tag = 1001;
        [membersListView addSubview:iv];
        
        UILabel *lbMember = [[UILabel alloc] initWithFrame:CGRectMake(left+12, top-1, 100.0f, 13.0f)] ;
        lbMember.backgroundColor = [UIColor clearColor];
        lbMember.textColor = [UIColor whiteColor];
        lbMember.textAlignment = NSTextAlignmentLeft;
        lbMember.tag = 1002;
        lbMember.font = [UIFont systemFontOfSize:12.0f];
        lbMember.text = member.account.account;
        [membersListView addSubview:lbMember];
        i++;
    }
}

-(void)createChatroomWithChatroomName:(NSString*)chatroomName andPassword:(NSString *)roomPwd andSquare:(NSInteger)square andKeywords:(NSString *)keywords  andIsAutoClose:(BOOL)isAutoClose andVoiceMod:(NSInteger) voiceMod andAutoDelete:(BOOL) autoDelete andIsAutoJoin:(BOOL) isAutoJoin {
    
    statusView.text =@"连接中，请稍后....";
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍后...";
    hud.removeFromSuperViewOnHide = YES;
    
    ECCreateMeetingParams *params = [[ECCreateMeetingParams alloc] init];
    params.meetingType = ECMeetingType_MultiVoice;
    params.meetingName = chatroomName;
    params.meetingPwd = roomPwd;
    params.voiceMod = voiceMod;
    params.square = square;
    params.keywords = keywords;
    params.autoClose = isAutoClose;
    params.autoDelete = autoDelete;
    params.autoJoin = isAutoJoin;
    
    __weak __typeof(self) weakSelf = self;
    [[ECDevice sharedInstance].meetingManager createMultMeetingByType:params completion:^(ECError *error, NSString *meetingNumber) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        
        if (error.errorCode == ECErrorType_NoError && meetingNumber.length > 0) {
            
            UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStyleDone target:strongSelf action:@selector(showExitAlert)];
            [left setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
            [left setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
            strongSelf.navigationItem.leftBarButtonItem = left;
            
            strongSelf.curChatroomId = meetingNumber;
            if ([strongSelf.curChatroomId length] > 0) {
                [strongSelf querymeetingmember];
            }
            statusView.text = [NSString stringWithFormat:@"正在%@房间",strongSelf.curChatroomId];
            
        } else {
            
            if (error.errorCode == 707) {
                error.errorDescription = [NSString stringWithFormat: @"房间%@已解散或者不存在！",meetingNumber];
            } else if (error.errorCode == 708) {
                error.errorDescription = @"密码验证失败！";
            }
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
            UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"创建语音群聊失败" message:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]  delegate:strongSelf cancelButtonTitle:@"确定" otherButtonTitles:nil];
            alertview.tag = ChatRoomVIEW_RoomDisslove;
            [alertview show];
        }
        
    }];
}

- (void) joinChatroomInRoom:(NSString *)roomNo andPwd:(NSString *)pwd {
    
    statusView.text =@"连接中，请稍后....";
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍后...";
    hud.removeFromSuperViewOnHide = YES;
    
    __weak __typeof(self) weakSelf = self;
    [[ECDevice sharedInstance].meetingManager joinMeeting:roomNo ByMeetingType:ECMeetingType_MultiVoice andMeetingPwd:pwd completion:^(ECError *error, NSString *meetingNumber) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        
        if (error.errorCode == ECErrorType_NoError && meetingNumber.length > 0) {
            
            strongSelf.curChatroomId = roomNo;
            if ([strongSelf.curChatroomId length] > 0) {
                [strongSelf querymeetingmember];
            }
            statusView.text = [NSString stringWithFormat:@"正在%@房间",strongSelf.curChatroomId];
            
        } else {
            
            if (error.errorCode == 707) {
                error.errorDescription = [NSString stringWithFormat: @"房间%@已解散或者不存在！",roomNo];
            } else if (error.errorCode == 708) {
                error.errorDescription = @"密码验证失败！";
            }
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
            UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"加入群组失败" message:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            alertview.tag = ChatRoomVIEW_RoomDisslove;
            [alertview show];
        }
    }];
}

//Toast错误信息
-(void)showToast:(NSString *)message {
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

-(void)showExitAlert {
    
    if (self.isCreator) {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"退出选项" message:@"真的要退出吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出", nil];
        alertview.tag = ChatRoomVIEW_exitAlert;
        [alertview show];
    } else {
        [self exitCurChatroom];
    }
}

//退出当前的房间
-(void)exitCurChatroom
{
    [self stopAmplitude];
    [[ECDevice sharedInstance].meetingManager exitMeeting];
    [self backToView];
}

//通知客户端收到新的聊天室信息
- (void)onReceiveChatroomMsg:(NSNotification *)notification {
    
    ECMultiVoiceMeetingMsg* receiveMsgInfo = notification.object;
    if (![receiveMsgInfo.roomNo isEqualToString: self.curChatroomId]) {
        return;
    }

    if (receiveMsgInfo.type == MultiVoice_JOIN) {
        
        //有人加入
        statusView.text = @"有人加入房间";
        for (ECVoIPAccount *who in receiveMsgInfo.joinArr) {
            
            BOOL isHave = NO;
            for (ECMultiVoiceMeetingMember* tmp in self.membersArray) {
                if ([tmp.account.account isEqualToString:who.account] && tmp.account.isVoIP == who.isVoIP) {
                    isHave = YES;
                    break;
                }
            }
            
            if (isHave) {
                continue;
            }
            ECMultiVoiceMeetingMember *member = [[ECMultiVoiceMeetingMember alloc] init];
            member.account = who;
            member.role = 0;
            [self.membersArray addObject:member];
        }
        [self reloadMembersData];
        
    } else if (receiveMsgInfo.type == MultiVoice_EXIT) {
        
        //有人退出
        statusView.text = @"有人退出房间";
        NSMutableArray *exitArr = [[NSMutableArray alloc] init];
        for (ECVoIPAccount *who in receiveMsgInfo.exitArr) {
            for (ECMultiVoiceMeetingMember *member in self.membersArray) {
                if ([who.account isEqualToString:member.account.account] && who.isVoIP == member.account.isVoIP) {
                    [exitArr addObject:member];
                }
            }
        }
        if (exitArr.count > 0) {
            [self.membersArray removeObjectsInArray:exitArr];
        }
        
        [self reloadMembersData];
        
    } else if (receiveMsgInfo.type == MultiVoice_DELETE) {
        
        if (isCreatorExit) {
            //创建者自己主动解散会议自己不再提示
            [self backToView];
        } else {
            UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"房间被解散" message:@"抱歉，该房间已经被创建者解散，点击确定可以退出！"  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alertview.tag = ChatRoomVIEW_RoomDisslove;
            [alertview show];
        }
        
    } else if(receiveMsgInfo.type == MultiVoice_REMOVEMEMBER) {
        
        if ([receiveMsgInfo.who.account isEqualToString:[DemoGlobalClass sharedInstance].userName] && receiveMsgInfo.who.isVoIP)//自己被踢出
        {
            UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"您已被请出房间" message:@"抱歉，您被创建者请出房间了，点击确定以退出"  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alertview.tag = ChatRoomVIEW_kickOff;
            [alertview show];
            return;
        }
        statusView.text = @"有人被踢出房间";
        NSMutableArray *delArr = [[NSMutableArray alloc] init];
        for (ECMultiVoiceMeetingMember *member in self.membersArray) {
            if ([receiveMsgInfo.who.account isEqualToString:member.account.account]) {
                [delArr addObject:member];
            }
        }
        if (delArr.count > 0) {
            [self.membersArray removeObjectsInArray:delArr];
        }
        [self reloadMembersData];
    } else if (receiveMsgInfo.type == MultiVoice_REFUSE) {
        
        UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"拒接" message:@"抱歉，对方拒绝了你的请求"  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alertview.tag = ChatRoomVIEW_refuse;
        [alertview show];
    }
}

@end
