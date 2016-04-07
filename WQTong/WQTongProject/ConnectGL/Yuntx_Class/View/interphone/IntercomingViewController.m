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

#import "DeviceDelegateHelper+Meeting.h"
#import "IntercomingViewController.h"
@interface IntercomingViewController ()
{
    UILabel *statusView;
    UITableView *memberListView;
    UIButton *controlMicButton;
    NSInteger controlMicBtnStatus; //0:未控麦状态 1:控麦中 2:控麦成功
    UILabel *inlineNumLabel;
    UILabel *timeLabel;
    NSInteger speakTimeInterval;
    NSInteger rememberRealTalk;// 记录是否收到实时对讲
}

@property (nonatomic, retain) NSMutableArray *membersArray;
@end

@implementation IntercomingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    rememberRealTalk = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
    NSString *title = self.curInterphoneId.length>3?[self.curInterphoneId substringFromIndex:(self.curInterphoneId.length-3)]:@"";
    self.title = [NSString stringWithFormat:@"在%@对讲", title];
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];

    UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStyleDone target:self action:@selector(exitCurInterphon)];
    [rightBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [rightBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
//    UIImageView *pointImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"point_bg.png"]];
//    pointImg.frame = CGRectMake(0.0f, 0.0f, screenWidth, 29.0f);
//    [self.view addSubview:pointImg];
    
    UIImageView *pointImg = [[UIImageView alloc] init];
    pointImg.frame = CGRectMake(0.0f, 0.0f, screenWidth, 29.0f);
    pointImg.backgroundColor = interphoneImageColor;
    [self.view addSubview:pointImg];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, 265.0f, 29.0f)];
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.font = [UIFont systemFontOfSize:13.0f];
    statusView = statusLabel;
    statusLabel.text = [NSString stringWithFormat:@"正在%@对讲",self.curInterphoneId];
    [self.view addSubview:statusLabel];
    
    UIImageView *tmpImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inter_phone_persons_ic.png"]];
    tmpImg.frame = CGRectMake(270.0f, 5.0f, 20.0f, 20.0f);
    [self.view addSubview:tmpImg];
    
    UILabel *numlabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-30, 0.0f, 30.0f, 29.0f)];
    numlabel.backgroundColor = [UIColor clearColor];
    numlabel.textColor = [UIColor whiteColor];
    numlabel.font = [UIFont systemFontOfSize:13.0f];
    inlineNumLabel = numlabel;
    numlabel.text = @"";
    [self.view addSubview:numlabel];
    
    self.membersArray = [NSMutableArray array];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 29.0f, screenWidth, 184.0f) style:UITableViewStylePlain];;
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	tableView.delegate = self;
	tableView.dataSource = self;
    tableView.allowsSelection = NO;
    memberListView = tableView;
	[self.view addSubview:tableView];
    
    UIView *micView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 169.0f, screenWidth, 145.0f)];
    [self.view addSubview:micView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(260, 5, 50, 30)];
    timeLabel = label;
    speakTimeInterval = 0;
    label.textColor = [UIColor blueColor];
    label.font = [UIFont systemFontOfSize:13.0f];
    [micView addSubview:label];
    
    UIButton *micButton = [UIButton buttonWithType:UIButtonTypeCustom];
    micButton.frame = CGRectMake(94.0f, 7.0f, screenWidth-94*2, 132.0f);
    [micView addSubview:micButton];
    controlMicButton = micButton;
    [micButton setImage:[UIImage imageNamed:@"voice_button01.png"] forState:UIControlStateNormal];
    [micButton addTarget:self action:@selector(releaseMic:) forControlEvents:UIControlEventTouchUpInside];
    [micButton addTarget:self action:@selector(releaseMic:) forControlEvents:UIControlEventTouchUpOutside];
    [micButton addTarget:self action:@selector(releaseMic:) forControlEvents:UIControlEventTouchCancel];
    [micButton addTarget:self action:@selector(controlMic:) forControlEvents:UIControlEventTouchDown];
    
    UILabel *text_a = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 320.0f, screenWidth, 25.0f)];
    text_a.textColor = [UIColor blackColor];
    text_a.font = [UIFont systemFontOfSize:15.0f];
    text_a.textAlignment = NSTextAlignmentCenter;
    text_a.text = @"长按麦克风开始抢麦";
    [self.view addSubview:text_a];
    
    UILabel *text_b = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 345.0f, screenWidth, 20.0f)];
    text_b.textColor = [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
    text_b.font = [UIFont systemFontOfSize:13.0f];
    text_b.textAlignment = NSTextAlignmentCenter;
    text_b.text = @"抢麦成功会有震动反馈即可开始说话";
    [self.view addSubview:text_b];
    
    UILabel *text_c = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 365.0f, screenWidth, 20.0f)];
    text_c.textColor = [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
    text_c.font = [UIFont systemFontOfSize:13.0f];
    text_c.textAlignment = NSTextAlignmentCenter;
    text_c.text = @"失败则需要重新抢";
    [self.view addSubview:text_c];
    
    UILabel *text_d = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 385.0f, screenWidth, 20.0f)];
    text_d.textColor = [UIColor blackColor];
    text_d.font = [UIFont systemFontOfSize:10.0f];
    text_d.textAlignment = NSTextAlignmentCenter;
    text_d.text = @"其实...等TA说完再按就不用抢了吗...";
    [self.view addSubview:text_d];
    
    controlMicBtnStatus = 0;
    rememberRealTalk = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveInterphoneMsg:) name:KNOTIFICATION_onReceiveInterphoneMeetingMsg object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    __weak __typeof(self) weakSelf = self;
    [[ECDevice sharedInstance].meetingManager queryMeetingMembersByMeetingType:ECMeetingType_Interphone andMeetingNumber:self.curInterphoneId completion:^(ECError *error, NSArray *members) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (error.errorCode == ECErrorType_NoError) {
            
            [strongSelf.membersArray removeAllObjects];
            [strongSelf.membersArray addObjectsFromArray:members];
            
            for (ECInterphoneMeetingMember *member in strongSelf.membersArray) {
                if ([[DemoGlobalClass sharedInstance].userName isEqualToString:member.number]) {
                    member.isOnline = YES;
                    [strongSelf.membersArray exchangeObjectAtIndex:0 withObjectAtIndex:[strongSelf.membersArray indexOfObject:member]];
                    break;
                }
            }
            
            [memberListView reloadData];
            [strongSelf updateNumLabel];
            
        } else {
            
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
            hud.labelText = [NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail];
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:2];
        }
        
    }];
}

- (void)dealloc
{
    self.curInterphoneId = nil;
    self.membersArray = nil;
    self.controlMicTimer = nil;
    self.speakTimer = nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark - table DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.membersArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellid = @"interphonemember_cellid";
    UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellid];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_icon01.png"]];
        image.center = CGPointMake(15.0f, 10.0f);
        image.tag = 1000;
        [cell.contentView addSubview:image];
        
        UILabel *voipLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 0.0f, 110.0f, 20.0f)];
        voipLabel.font = [UIFont systemFontOfSize:13];
        voipLabel.tag = 1001;
        [cell.contentView addSubview:voipLabel];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(150.0f, 0.0f, 170.0f, 20.0f)];
        textLabel.textColor = [UIColor colorWithRed:112.0f/255.0f green:112.0f/255.0f blue:112.0f/255.0f alpha:1.0f];
        textLabel.font = [UIFont systemFontOfSize:13];
        textLabel.tag = 1002;
        [cell.contentView addSubview:textLabel];
    }

    UIImageView *statusImgView = (UIImageView *)[cell viewWithTag:1000];
    UILabel *memberLabel = (UILabel*)[cell viewWithTag:1001];
    UILabel *statusLabel = (UILabel*)[cell viewWithTag:1002];
    
    ECInterphoneMeetingMember *member = [self.membersArray objectAtIndex:indexPath.row];
    memberLabel.text = member.number;
    statusImgView.image = [UIImage imageNamed:@"status_icon01.png"];
    
    NSString *text_a = @"等待加入";
    NSString *text_b = @"";
    if (member.isOnline) {
        statusImgView.image = [UIImage imageNamed:@"status_icon02.png"];
        text_a = @"已加入";
        
        if (member.isMic) {
            statusImgView.image = [UIImage imageNamed:@"status_icon03.png"];
            text_b = @",正在讲话中...";
        }
    }else if (member.isOnline == NO&&rememberRealTalk == 1){
        statusImgView.image = [UIImage imageNamed:@"status_icon01.png"];
        text_a = @"已退出";
    }
    
    if ([[DemoGlobalClass sharedInstance].userName isEqualToString:member.number]) {
        statusImgView.image = [UIImage imageNamed:@"status_icon_me.png"];
    }

    statusLabel.text = [NSString stringWithFormat:@"%@%@", text_a, text_b];
    return cell;
}

#pragma mark - tabl Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 20.0f;
}

- (void)speakTimeIntervalGrow {
    
    speakTimeInterval ++ ;
    NSInteger mm = 0;
    NSInteger ss = 0;
    if (speakTimeInterval > 60) {
        mm = speakTimeInterval/60;
    }
    ss = speakTimeInterval % 60;
    timeLabel.text = [NSString stringWithFormat:@"%0.2d:%0.2d", (int)mm, (int)ss];
}

- (void)updateNumLabel {
    
    int count = 0;
    for (ECInterphoneMeetingMember *member in self.membersArray) {
        if (member.isOnline) {
            count++;
        }
    }
    inlineNumLabel.text = [NSString stringWithFormat:@"%d/%d", count, (int)self.membersArray.count];
}

- (void)backToView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popToViewController:self.backView animated:YES];
}

//退出当前的对讲场景
-(void)exitCurInterphon
{
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(exitInterphone) userInfo:nil repeats:NO];
}

-(void)exitInterphone {
    [DemoGlobalClass sharedInstance].curinterphoneid = nil;
    [[ECDevice sharedInstance].meetingManager exitMeeting];
    [self backToView];
}

-(void)controlMic {
    
    controlMicBtnStatus = 1;
    if (controlMicButton) {
        [controlMicButton setImage:[UIImage imageNamed:@"voice_button02.png"] forState:UIControlStateNormal];
        [controlMicButton setImage:[UIImage imageNamed:@"voice_button02.png"] forState:UIControlStateHighlighted];
    }
    
    __weak __typeof(self) weakSelf = self;
    [[ECDevice sharedInstance].meetingManager controlMicInInterphoneMeeting:self.curInterphoneId completion:^(ECError *error, NSString *memberVoip) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (error.errorCode == ECErrorType_NoError) {
            
            if (controlMicBtnStatus == 0) {
                controlMicBtnStatus = 2;
                [strongSelf releaseMic];
            } else {
                
                for (ECInterphoneMeetingMember *member in strongSelf.membersArray) {
                    if ([[DemoGlobalClass sharedInstance].userName isEqualToString:member.number]) {
                        member.isMic=YES;
                        break;
                    }
                }
                
                [memberListView reloadData];
                controlMicBtnStatus = 2;
                statusView.text = @"控麦成功，请讲话";
                [strongSelf.speakTimer invalidate];
                strongSelf.speakTimer = [NSTimer scheduledTimerWithTimeInterval:1. target:strongSelf selector:@selector(speakTimeIntervalGrow) userInfo:nil repeats:YES];
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
        } else {
            
            if (controlMicBtnStatus == 1) {
                statusView.text = @"控麦失败，稍后重试";
                [controlMicButton setImage:[UIImage imageNamed:@"voice_button03.png"] forState:UIControlStateNormal];
                [controlMicButton setImage:[UIImage imageNamed:@"voice_button03.png"] forState:UIControlStateHighlighted];
            }
            
            controlMicBtnStatus = 0;
            
            if (memberVoip.length > 0) {
                for (ECInterphoneMeetingMember *member in strongSelf.membersArray) {
                    member.isMic = NO;
                    if ([memberVoip isEqualToString:member.number]) {
                        member.isMic = YES;
                    }
                }
                [memberListView reloadData];
            }
            
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
            hud.labelText = [NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail];
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:2];
        }
    }];
}
//控麦
-(void)controlMic:(id)sender
{
    if(self.controlMicTimer) {
        [self.controlMicTimer invalidate];
        self.controlMicTimer = nil;
    } else {
        self.controlMicTimer = [NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(controlMic) userInfo:nil repeats:NO];
    }
}

- (void)releaseMic {
    if(self.controlMicTimer) {
        [self.controlMicTimer invalidate];
        self.controlMicTimer = nil;
    }
    
    if (controlMicBtnStatus == 2) {
        __weak __typeof(self) weakSelf = self;
        [[ECDevice sharedInstance].meetingManager releaseMicInInterphoneMeeting:self.curInterphoneId completion:^(ECError *error, NSString *memberVoip) {
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (error.errorCode == ECErrorType_NoError) {
                statusView.text = [NSString stringWithFormat:@"正在%@对讲",strongSelf.curInterphoneId];
                for (ECInterphoneMeetingMember *member in strongSelf.membersArray) {
                    if ([[DemoGlobalClass sharedInstance].userName isEqualToString:member.number]) {
                        member.isMic = NO;
                        break;
                    }
                }
                [memberListView reloadData];
            } else {
                MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                hud.labelText = [NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail];
                hud.margin = 10.f;
                hud.removeFromSuperViewOnHide = YES;
                [hud hide:YES afterDelay:2];
            }
            
            if (strongSelf.speakTimer) {
                speakTimeInterval = 0;
                timeLabel.text = @"";
                [strongSelf.speakTimer invalidate];
                strongSelf.speakTimer  = nil;
            }
        }];
    }
    [controlMicButton setImage:[UIImage imageNamed:@"voice_button01.png"] forState:UIControlStateNormal];
    [controlMicButton setImage:nil forState:UIControlStateHighlighted];
    controlMicBtnStatus = 0;
}

//放麦
-(void)releaseMic:(id)sender
{
    [self releaseMic];
}
/********************实时语音的方法********************/

//通知客户端收到新的实时语音信息
- (void)onReceiveInterphoneMsg:(NSNotification *)notification {
    
    ECInterphoneMeetingMsg* receiveMsgInfo = notification.object;
    if (![self.curInterphoneId isEqualToString:receiveMsgInfo.interphoneId]) {
        return;
    }
    rememberRealTalk = 1;
    if (receiveMsgInfo.type == Interphone_INVITE) {
        //收到邀请
        statusView.text = [NSString stringWithFormat:@"%@邀请您加入对讲%@", receiveMsgInfo.fromVoip, receiveMsgInfo.interphoneId];
        
    } else if (receiveMsgInfo.type == Interphone_JOIN) {
        
        //有人加入
        statusView.text = @"有人加入对讲";
        for (NSString *who in receiveMsgInfo.joinArr) {
            for (ECInterphoneMeetingMember *member in self.membersArray) {
                if ([who isEqualToString:member.number]) {
                    member.isOnline = YES;
                }
            }
        }
        [memberListView reloadData];
        [self updateNumLabel];
        
    } else if (receiveMsgInfo.type == Interphone_EXIT) {
        
        //有人退出
        statusView.text = @"有人退出对讲";
        for (NSString *who in receiveMsgInfo.exitArr) {
            for (ECInterphoneMeetingMember *member in self.membersArray) {
                if ([who isEqualToString:member.number]) {
                    member.isOnline = NO;
                    member.isMic = NO;
                }
            }
        }
        [memberListView reloadData];
        [self updateNumLabel];
        
    } else if (receiveMsgInfo.type == Interphone_CONTROLMIC) {
        
        //有人控麦
        statusView.text = [NSString stringWithFormat:@"%@控麦", receiveMsgInfo.voip];
        for (ECInterphoneMeetingMember *member in self.membersArray) {
            member.isMic = NO;
            if ([receiveMsgInfo.voip isEqualToString:member.number]) {
                member.isMic = YES;
            }
        }
        [memberListView reloadData];
        [self.speakTimer invalidate];
        self.speakTimer = [NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(speakTimeIntervalGrow) userInfo:nil repeats:YES];
        
    } else if (receiveMsgInfo.type == Interphone_RELEASEMIC) {
        
        //有人放麦
        statusView.text = [NSString stringWithFormat:@"%@放麦", receiveMsgInfo.voip];
        for (ECInterphoneMeetingMember *member in self.membersArray) {
            if ([receiveMsgInfo.voip isEqualToString:member.number]) {
                member.isMic = NO;
                break;
            }
        }
        [memberListView reloadData];
        
        if (self.speakTimer) {
            speakTimeInterval = 0;
            timeLabel.text = @"";
            [self.speakTimer invalidate];
            self.speakTimer = nil;
        }
    }
}

@end
