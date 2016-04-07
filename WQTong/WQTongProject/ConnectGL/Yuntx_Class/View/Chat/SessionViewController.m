//
//  SessionViewController.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "SessionViewController.h"
#import "SessionViewCell.h"
#import "ChatViewController.h"
#import "ECSession.h"
#import "GroupNoticeViewController.h"

extern CGFloat NavAndBarHeight;
@interface SessionViewController()

@property (nonatomic, strong) NSMutableArray *sessionArray;
@property (nonatomic, strong) ECGroupNoticeMessage *message;
@property (nonatomic, strong) UIView * linkview;
@end

@implementation SessionViewController{
    UITableViewCell * _memoryCell;
    LinkJudge linkjudge;
}

-(void)viewDidLoad{
    
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,screenWidth,self.view.frame.size.height-NavAndBarHeight) style:UITableViewStylePlain];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    self.sessionArray = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDisplay) name:KNOTIFICATION_onMesssageChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDisplay) name:KNOTIFICATION_onReceivedGroupNotice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDisplay) name:@"mainviewdidappear" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(linkSuccess:) name:KNOTIFICATION_onConnected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:KNotice_ReloadSessionGroup object:nil];
    
    [self autoLoginClient];
}

-(void)updateLoginStates:(LinkJudge)link{
    
    if (link == success) {
        _tableView.tableHeaderView = nil;
        [_linkview removeFromSuperview];
        _linkview = nil;
    } else {
        [_linkview removeFromSuperview];
        _linkview = nil;
        
        _linkview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 45.0f)];
        _linkview.backgroundColor = [UIColor colorWithRed:1.00f green:0.87f blue:0.87f alpha:1.00f];
        if (link==failed) {
            UIImageView * image = [[UIImageView alloc]initWithFrame:CGRectMake(10, 8, 30, 30)];
            image.image = [UIImage imageNamed:@"messageSendFailed"];
            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, screenWidth-50 , 45)];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:14];
            label.textColor =[UIColor colorWithRed:0.46f green:0.40f blue:0.40f alpha:1.00f];
            label.text = @"无法连接到服务器";
            [_linkview addSubview:image];
            [_linkview addSubview:label];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginWithHaveUserLogined)];
            [_linkview addGestureRecognizer:tap];

        } else if(link == linking) {
            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 310 , 45)];
            label.font = [UIFont systemFontOfSize:14];
            label.backgroundColor = [UIColor clearColor];
            label.text = @"连接中...";
            label.textColor =[UIColor colorWithRed:0.46f green:0.40f blue:0.40f alpha:1.00f];
            [_linkview addSubview:label];
        }
        _tableView.tableHeaderView = _linkview;
    }
}

-(void)linkSuccess:(NSNotification *)link {
    ECError* error = link.object;
    if (error.errorCode == ECErrorType_NoError) {
        [self updateLoginStates:success];
    } else if (error.errorCode == ECErrorType_Connecting) {
        [self updateLoginStates:linking];
    } else {
        [self updateLoginStates:failed];
    }
}

-(void)prepareDisplay {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.sessionArray removeAllObjects];
        [self.sessionArray addObjectsFromArray:[[DeviceDBHelper sharedInstance] getMyCustomSession]];
        [self.tableView reloadData];
    });
}

-(void)autoLoginClient {
    
    if ([DemoGlobalClass sharedInstance].isAutoLogin) {
        [DemoGlobalClass sharedInstance].isAutoLogin = NO;
        [self loginWithHaveUserLogined];
    }
}

- (void)loginWithHaveUserLogined {
    NSString *userName = [DemoGlobalClass sharedInstance].userName;
    if (userName && [DemoGlobalClass sharedInstance].isLogin == NO) {
        [self updateLoginStates:linking];
        
        ECLoginInfo * loginInfo = [[ECLoginInfo alloc] init];
        loginInfo.username = userName;
        loginInfo.userPassword = [DemoGlobalClass sharedInstance].userPassword;
        loginInfo.appToken = [DemoGlobalClass sharedInstance].appToken;
        loginInfo.appKey = [DemoGlobalClass sharedInstance].appKey;
        loginInfo.authType = [DemoGlobalClass sharedInstance].loginAuthType;
        loginInfo.mode = LoginMode_AutoInputLogin;
        
        [[ECDevice sharedInstance] login:loginInfo completion:^(ECError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onConnected object:error];
        }];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.sessionArray.count == 0) {
        return 170.0f;
    }
    return 65.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.sessionArray.count == 0) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ECSession* session = [self.sessionArray objectAtIndex:indexPath.row];
    session.unreadCount = 0;
    if (session.type == 100) {
        GroupNoticeViewController * gnvc = [[GroupNoticeViewController alloc]init];
        [self.mainView pushViewController:gnvc animated:YES];
    } else if ([session.sessionId isEqualToString:KDeskNumber]) {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"请稍等...";
        hud.removeFromSuperViewOnHide = YES;
        
        __weak __typeof(self)weakSelf = self;
        [[ECDevice sharedInstance].messageManager startConsultationWithAgent:KDeskNumber completion:^(ECError *error, NSString *agent) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            if (error.errorCode == ECErrorType_NoError) {
                ChatViewController *chat = [[ChatViewController alloc] initWithSessionId:KDeskNumber];
                [strongSelf.mainView pushViewController:chat animated:YES];
            } else {
                NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                [strongSelf.mainView showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
            }
        }];
    } else {
        ChatViewController *cvc = [[ChatViewController alloc] initWithSessionId:session.sessionId];
        cvc.title = [[DemoGlobalClass sharedInstance] getOtherNameWithPhone:session.sessionId];
        [self.mainView pushViewController:cvc animated:YES];
    }
    [tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.sessionArray.count == 0) {
        return 1;
    }
    return _sessionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.sessionArray.count == 0) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        static NSString *noMessageCellid = @"sessionnomessageCellidentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noMessageCellid];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noMessageCellid];
            UILabel *noMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 100.0f, screenWidth, 50.0f)];
            noMsgLabel.text = @"暂无聊天消息";
            noMsgLabel.textColor = [UIColor darkGrayColor];
            noMsgLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:noMsgLabel];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    static NSString *sessioncellid = @"sessionCellidentifier";
    SessionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sessioncellid];
    
    if (cell == nil) {
        cell = [[SessionViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sessioncellid];
        UILongPressGestureRecognizer  * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPress:)];
        cell.nameLabel.tag =100;
        [cell.contentView addGestureRecognizer:longPress];
        cell.contentView.userInteractionEnabled = YES;
    }
    
    ECSession* session = [self.sessionArray objectAtIndex:indexPath.row];
    if (session.type == 100) {
        
        cell.nameLabel.text = session.sessionId;
        cell.portraitImg.image = [UIImage imageNamed:@"logo80x80"];
    } else {
        
        cell.nameLabel.text = [[DemoGlobalClass sharedInstance] getOtherNameWithPhone:session.sessionId];
        cell.portraitImg.image = [[DemoGlobalClass sharedInstance] getOtherImageWithPhone:session.sessionId];
    }
    
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [session.text stringByTrimmingCharactersInSet:ws];
    cell.contentLabel.text = trimmed;
    
    cell.dateLabel.text = [self getDateDisplayString:session.dateTime];
    
    BOOL isNotice = YES;
    if ([session.sessionId hasPrefix:@"g"]) {
        isNotice = [[IMMsgDBAccess sharedInstance] isNoticeOfGroupId:session.sessionId];
        cell.noPushImg.hidden = isNotice;
    } else {
        cell.noPushImg.hidden = YES;
    }
    
    if (isNotice) {
        if (session.unreadCount == 0) {
            cell.unReadLabel.hidden = YES;
        } else {
            cell.unReadLabel.text = [NSString stringWithFormat:@"%d",(int)session.unreadCount];
            cell.unReadLabel.hidden = NO;
            
        }
        cell.contentLabel.text = trimmed;
    } else {
        cell.unReadLabel.hidden = YES;
        if (session.unreadCount > 0) {
            cell.contentLabel.text = [NSString stringWithFormat:@"[%d条]%@",(int)session.unreadCount,trimmed];
        }
    }
    
    return cell;
}

//时间显示内容
-(NSString *)getDateDisplayString:(long long) miliSeconds{
    
    NSTimeInterval tempMilli = miliSeconds;
    NSTimeInterval seconds = tempMilli/1000.0;
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[ NSDate date ]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:myDate];
    
    NSDateFormatter *dateFmt = [[ NSDateFormatter alloc ] init ];
    if (nowCmps.year != myCmps.year) {
        dateFmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    } else {
        if (nowCmps.day==myCmps.day) {
            dateFmt.dateFormat = @"今天 HH:mm:ss";
        } else if((nowCmps.day-myCmps.day)==1) {
            dateFmt.dateFormat = @"昨天 HH:mm:ss";
        } else {
            dateFmt.dateFormat = @"MM-dd HH:mm:ss";
        }
    }
    return [dateFmt stringFromDate:myDate];
}

-(void)cellLongPress:(UILongPressGestureRecognizer * )longPress{
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        CGPoint point = [longPress locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
        if(indexPath == nil) return ;
        SessionViewCell  * cell = (SessionViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:cell.nameLabel.text delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles: nil];
        [sheet showInView:cell];
        _memoryCell = cell;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;{
    
    if (buttonIndex == 0) {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"删除该会话";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        NSIndexPath * path = [_tableView indexPathForCell:_memoryCell];
        ECSession* session = [self.sessionArray objectAtIndex:path.row];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if (session.type == 100) {
                [[DeviceDBHelper sharedInstance] clearGroupMessageTable];
            } else {
                [[DeviceDBHelper sharedInstance] deleteAllMessageOfSession:session.sessionId];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.sessionArray removeObjectAtIndex:path.row];
                _memoryCell = nil;
                [_tableView reloadData];
            });
        });
    }
}

@end
