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

#import "InterphoneViewController.h"
#import "IntercomingViewController.h"
#import "InterphoneCreateViewController.h"
#import "DeviceDelegateHelper+Meeting.h"
#import <AudioToolbox/AudioToolbox.h>

@interface InterphoneViewController () {
    UITableView *interphoneListView;
    NSMutableArray *interphoneIdArray;
    UIView * noneView;
}
@end

@implementation InterphoneViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"对讲列表";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat frameY = 0.0f;
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"发起对讲" style:UIBarButtonItemStyleDone target:self action:@selector(startInterphone:)];
    [rightBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [rightBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
//    UIImageView *pointImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"point_bg.png"]];
    UIImageView *pointImg = [[UIImageView alloc]init];
    pointImg.backgroundColor = [UIColor colorWithRed:60/255.0f green:179/255.0f blue:113/255.0f alpha:1];
    pointImg.frame = CGRectMake(0.0f, frameY, screenWidth, 29.0f);
    [self.view addSubview:pointImg];

    UILabel *statusLabel = [[UILabel alloc] initWithFrame:pointImg.frame];


    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.font = [UIFont systemFontOfSize:13.0f];
    statusLabel.text = @"点击即可加入实时对讲";
    statusLabel.contentMode = UIViewContentModeCenter;
    statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:statusLabel];
    
    UIView *noneDataView = [[UIView alloc] initWithFrame:CGRectMake(0, frameY+29.0f, screenWidth, 480.0f)];
    noneView = noneDataView;
    [self.view addSubview:noneDataView];
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, frameY+30.0f, screenWidth, 25.0f)];
    text.text = @"没有收到对讲邀请，可以主动发起";
    text.font = [UIFont systemFontOfSize:15.0f];
    text.textAlignment = NSTextAlignmentCenter;
    text.textColor = [UIColor colorWithRed:150.0f/255.0f green:150.0f/255.0f blue:150.0f/255.0f alpha:1.0f];
    [noneDataView addSubview:text];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame = CGRectMake(82.0f, frameY+70.0f, screenWidth-82*2, 38.0f);
    startBtn.titleLabel.textColor = [UIColor whiteColor];
    [startBtn setTitle:@"发起实时对讲" forState:UIControlStateNormal];
    startBtn.backgroundColor = themeColor;
    startBtn.showsTouchWhenHighlighted = YES;
    
    UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect:startBtn.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
    maskLayer2.frame =  startBtn.bounds;
    maskLayer2.path = maskPath2.CGPath;
    startBtn.layer.mask = maskLayer2;
//    [startBtn setBackgroundImage:[UIImage imageNamed:@"button03_off.png"] forState:UIControlStateNormal];
//    [startBtn setBackgroundImage:[UIImage imageNamed:@"button03_on.png"] forState:UIControlStateHighlighted];
    [startBtn addTarget:self action:@selector(startInterphone:) forControlEvents:UIControlEventTouchUpInside];
    [noneDataView addSubview:startBtn];
    
    [self.view addSubview:noneDataView];
    
    interphoneIdArray = [DemoGlobalClass sharedInstance].interphoneArray;
    
    UITableView *tableView =  [[UITableView alloc] initWithFrame:CGRectMake(0, 0.0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];;
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	tableView.delegate = self;
	tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc] init];
    interphoneListView = tableView;
	[self.view addSubview:tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveInterphoneMsg:) name:KNOTIFICATION_onReceiveInterphoneMeetingMsg object:nil];
}

-(void)returnClicked {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self viewRefresh];
}

- (void)viewRefresh
{
    if (interphoneIdArray.count > 0) {
        interphoneListView.alpha = 1.0f;
        noneView.alpha = 0.0f;
    } else {
        interphoneListView.alpha = 0.0f;
        noneView.alpha = 1.0f;
    }
    [interphoneListView reloadData];
}

#pragma mark - table DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [interphoneIdArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellid = @"interphonemember_cellid";
    UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellid];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon01.png"]];
        image.center = CGPointMake(22.0f, 22.0f);
        [cell.contentView addSubview:image];
        
        UILabel *voipLabel = [[UILabel alloc] initWithFrame:CGRectMake(44.0f, 0.0f, screenWidth-88.0f, 44.0f)];
        voipLabel.font = [UIFont systemFontOfSize:17.0f];
        voipLabel.tag = 1001;
        [cell.contentView addSubview:voipLabel];
        
        UIImageView *accessImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon02.png"]];
        accessImage.center = CGPointMake(screenWidth-22.0f, 22.0f);
        [cell.contentView addSubview:accessImage];
    }
    
    UILabel * interphoneLabel = (UILabel*)[cell viewWithTag:1001];
    
    NSString *interphoneid = [interphoneIdArray objectAtIndex:indexPath.row];
    interphoneLabel.text = interphoneid;
    return cell;
}

#pragma mark - tabl Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *selectId = [interphoneIdArray objectAtIndex:indexPath.row];
    if(selectId.length > 0) {
        
        if ([DemoGlobalClass sharedInstance].curinterphoneid.length>0) {
            
            //当前正在一个对讲中
            if ([[DemoGlobalClass sharedInstance].curinterphoneid isEqualToString:selectId]) {
                
                //选择的是当前所在的对讲
                IntercomingViewController *intercoming = [[IntercomingViewController alloc] init];
                intercoming.navigationItem.hidesBackButton = YES;
                intercoming.curInterphoneId = selectId;
                intercoming.backView = self;
                [self.navigationController pushViewController:intercoming animated:YES];
                
            } else {
                
                //选择的不是当前所在的对讲，需要先退出当前的对讲 再加入另一个对讲中
                [DemoGlobalClass sharedInstance].curinterphoneid = nil;
                [[ECDevice sharedInstance].meetingManager exitMeeting];
                [self joinInterphone:selectId];
                
            }

        } else {
            [self joinInterphone:selectId];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - interphone method
- (void)startInterphone:(id)sender {
    
    //当前正在一个对讲中,需要先退出才可创建
    [DemoGlobalClass sharedInstance].curinterphoneid = nil;
    [[ECDevice sharedInstance].meetingManager exitMeeting];
    
    InterphoneCreateViewController* selectView = [[InterphoneCreateViewController alloc] init];
    selectView.backView = self;
    [self.navigationController pushViewController:selectView animated:YES];
}

- (void)joinInterphone:(NSString*)interphoneid {
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍后...";
    hud.removeFromSuperViewOnHide = YES;
    
    __weak __typeof(self) weakSelf = self;
    [[ECDevice sharedInstance].meetingManager joinMeeting:interphoneid ByMeetingType:ECMeetingType_Interphone andMeetingPwd:nil completion:^(ECError *error, NSString *meetingNumber) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        
        if (error.errorCode == ECErrorType_NoError && meetingNumber.length > 0) {
            
            [DemoGlobalClass sharedInstance].curinterphoneid = meetingNumber;
            IntercomingViewController *intercoming = [[IntercomingViewController alloc] init];
            intercoming.navigationItem.hidesBackButton = YES;
            intercoming.curInterphoneId = interphoneid;
            intercoming.backView = strongSelf;
            [strongSelf.navigationController pushViewController:intercoming animated:YES];
            
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

/********************实时语音的方法********************/

//通知客户端收到新的实时语音信息        
- (void)onReceiveInterphoneMsg:(NSNotification *)notification {
    
    ECInterphoneMeetingMsg* receiveMsgInfo = notification.object;
    if (receiveMsgInfo.type == Interphone_INVITE || receiveMsgInfo.type == Interphone_OVER) {
        [self viewRefresh];
    }
}

@end
