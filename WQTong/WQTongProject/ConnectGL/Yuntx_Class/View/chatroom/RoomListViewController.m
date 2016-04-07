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
#import "RoomListViewController.h"
#import "RoomNameViewController.h"
#import "ChatRoomViewController.h"
#import "RoomMemberViewController.h"
#import "MBProgressHUD.h"
#import "SRRefreshView.h"

#define TAG_ALERTVIEW_ChatroomPwd 9999
@interface RoomListViewController ()<SRRefreshDelegate>
{
    UITableView *roomListView;
    UIView * noneView;
}
@property (nonatomic, strong) NSMutableArray *chatroomsArray;
@property (nonatomic, strong) SRRefreshView *refreshView;
@end

@implementation RoomListViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"语音群聊列表";
    self.view.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];

    CGFloat frameY = 0.0f;
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"创建房间" style:UIBarButtonItemStyleDone target:self action:@selector(startCharRoom:)];
    [rightBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [rightBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    UIImageView *pointImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"point_bg.png"]];
    pointImg.frame = CGRectMake(0.0f, frameY, screenWidth, 29.0f);
    [self.view addSubview:pointImg];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:pointImg.frame];
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.font = [UIFont systemFontOfSize:13.0f];
    statusLabel.text = @"点击即可加入语音群聊";
    statusLabel.contentMode = UIViewContentModeCenter;
    statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:statusLabel];
    
    
    UIView *noneDataView = [[UIView alloc] initWithFrame:CGRectMake(0, frameY+29.0f, screenWidth, 480.0f)];
    noneView = noneDataView;
    [self.view addSubview:noneDataView];
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, frameY+30.0f, screenWidth, 25.0f)];
    text.text = @"还没有群聊房间，请先创建一个";
    text.font = [UIFont systemFontOfSize:15.0f];
    text.textAlignment = NSTextAlignmentCenter;
    text.textColor = [UIColor colorWithRed:150.0f/255.0f green:150.0f/255.0f blue:150.0f/255.0f alpha:1.0f];
    [noneDataView addSubview:text];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame = CGRectMake(82.0f, frameY+70.0f, 136.0f, 38.0f);
    startBtn.titleLabel.textColor = [UIColor whiteColor];
    [startBtn setTitle:@"创建语音房间" forState:UIControlStateNormal];
    startBtn.backgroundColor = interphoneImageColor;
    [startBtn addTarget:self action:@selector(startCharRoom:) forControlEvents:UIControlEventTouchUpInside];
    [noneDataView addSubview:startBtn];
    
    [self.view addSubview:noneDataView];
    
    self.chatroomsArray = [NSMutableArray array];
    
    UITableView *tableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, -44.0f, self.view.frame.size.width, self.view.frame.size.height+44.0f) style:UITableViewStylePlain];;
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.backgroundView = [[UIView alloc] init];
    tableView.backgroundColor = [UIColor whiteColor];
    
    tableView.delegate = self;
	tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc] init];
    roomListView = tableView;
	[self.view addSubview:tableView];
    
    self.refreshView = [[SRRefreshView alloc] initWithFrame:CGRectMake(0, -44.0f, self.view.frame.size.width, 44.0f)];
    self.refreshView.delegate = self;
    self.refreshView.upInset = 44;
    [roomListView addSubview:self.refreshView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveChatroomMsg:) name:KNOTIFICATION_onReceiveMultiVoiceMeetingMsg object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //获取聊天室列表
    [self getMultiVoiceMeetingRoomFromService];
}

-(void)returnClicked {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)getMultiVoiceMeetingRoomFromService {
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍后...";
    hud.removeFromSuperViewOnHide = YES;
    
    __weak __typeof(self) weakSelf = self;
    [[ECDevice sharedInstance].meetingManager listAllMultMeetingsByMeetingType:ECMeetingType_MultiVoice andKeywords:nil completion:^(ECError *error, NSArray *meetingList) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        if (error.errorCode == ECErrorType_NoError) {
            [strongSelf.chatroomsArray removeAllObjects];
            [strongSelf.chatroomsArray addObjectsFromArray:meetingList];
            [strongSelf viewRefresh];
        } else {
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
            [strongSelf showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
        }
        
    }];
}

- (void)viewRefresh {
    if (self.chatroomsArray.count > 0) {
        roomListView.alpha = 1.0f;
        noneView.alpha = 0.0f;
    } else {
        roomListView.alpha = 0.0f;
        noneView.alpha = 1.0f;
    }
    [roomListView reloadData];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.refreshView) {
        [self.refreshView scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.refreshView) {
        [self.refreshView scrollViewDidEndDraging];
    }
}

#pragma mark - SRRefreshDelegate
- (void)slimeRefreshStartRefresh:(SRRefreshView*)refreshView {
    
    [self getMultiVoiceMeetingRoomFromService];
    [refreshView endRefresh];
}

#pragma mark - table DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chatroomsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ECMultiVoiceMeetingRoom *roomInfo = [self.chatroomsArray objectAtIndex:indexPath.row];
    static NSString* cellid = @"chatroom_cellid";
    UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellid];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        UILabel *Label1 = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 0.0f, screenWidth-88.0f, 24.0f)];
        Label1.font = [UIFont systemFontOfSize:17.0f];
        Label1.tag = 1001;
        [cell.contentView addSubview:Label1];
        
        UILabel *Label2 = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 24.0f, screenWidth-88.0f, 15.0f)];
        Label2.font = [UIFont systemFontOfSize:14.0f];
        Label2.textColor = [UIColor grayColor];
        Label2.tag = 1002;
        [cell.contentView addSubview:Label2];
        
        UIImageView * lock_closedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock_closed.png"]];
        lock_closedImage.center = CGPointMake(screenWidth-44.0f, 20.0f);
        lock_closedImage.tag = 1003;
        [cell.contentView addSubview:lock_closedImage];
        
        UIImageView *accessImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon02.png"]];
        accessImage.center = CGPointMake(screenWidth-22.0f, 22.0f);
        [cell.contentView addSubview:accessImage];
    }

    UILabel * nameLabel = (UILabel*)[cell viewWithTag:1001];
    UILabel * infoLabel = (UILabel*)[cell viewWithTag:1002];
    UIImageView * lock_closedImage = (UIImageView*)[cell viewWithTag:1003];
    
    NSString *name = nil;
    if (roomInfo.roomName.length>0) {
        name = roomInfo.roomName;
    } else {
        name = [NSString stringWithFormat:@"%@房间", (roomInfo.roomNo.length>4?[roomInfo.roomNo substringFromIndex:(roomInfo.roomNo.length-4)]:roomInfo.roomNo)];
    }
    nameLabel.text = name;
    
    NSString *info = nil;
    if (roomInfo.square == roomInfo.joinNum) {
        info = [NSString stringWithFormat:@"%d人加入(已满)", (int)roomInfo.joinNum];
    } else {
        info = [NSString stringWithFormat:@"%d人加入", (int)roomInfo.joinNum];
    }
    
    NSUInteger fromIndex = roomInfo.creator.length>4?(roomInfo.creator.length-4):0;
    infoLabel.text = [NSString stringWithFormat:@"%@,由%@创建", info, [roomInfo.creator substringFromIndex:fromIndex]];
    
    if (roomInfo.isValidate) {
        lock_closedImage.hidden = NO;
    } else {
        lock_closedImage.hidden = YES;
    }
    return cell;
}

#pragma mark - tabl Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ECMultiVoiceMeetingRoom *selectRoom = [self.chatroomsArray objectAtIndex:indexPath.row];
    self.curSelectRoom = selectRoom;
    if(selectRoom.roomNo.length > 0  && selectRoom.square > selectRoom.joinNum) {
        
        BOOL iscreator = NO;
        if ([selectRoom.creator isEqualToString:[DemoGlobalClass sharedInstance].userName]) {
            iscreator = YES;
        }
        
        if (iscreator) {
            UIActionSheet *menu = [[UIActionSheet alloc]
                                   initWithTitle: @"选择"
                                   delegate:self
                                   cancelButtonTitle:nil
                                   destructiveButtonTitle:nil
                                   otherButtonTitles:@"IP加入会议",@"解散会议",@"管理会议",@"取消",nil];
            [menu setCancelButtonIndex:3];
            menu.tag = 1000;
            [menu showInView:self.view.window];
            
        } else {
            
            if (selectRoom.isValidate) {
                [self showIpuntPassWord];
            } else {
                [self joinChatroomInRoomWithSelectRoom:selectRoom andPwd:nil isJoin:YES];
            }
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)showIpuntPassWord {
    
    UIAlertView *alertView = alertView = [[UIAlertView alloc] initWithTitle:@"输入密码" message:@"该聊天室设置了身份验证, 请输入密码" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.tag = TAG_ALERTVIEW_ChatroomPwd;
    textField.placeholder = @"请输入密码";
    [alertView show];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == 1000) {
        switch (buttonIndex) {
                
            case 0:
                if (self.curSelectRoom.isValidate) {
                    [self showIpuntPassWord];
                } else {
                    [self joinChatroomInRoomWithSelectRoom:self.curSelectRoom andPwd:nil isJoin:YES];
                }
                break;
                
            case 1:{
                MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = @"请稍后...";
                hud.removeFromSuperViewOnHide = YES;
                
                __weak __typeof(self) weakSelf = self;
                [[ECDevice sharedInstance].meetingManager deleteMultMeetingByMeetingType:ECMeetingType_MultiVoice andMeetingNumber:self.curSelectRoom.roomNo completion:^(ECError *error, NSString *meetingNumber) {
                    
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                    if (error.errorCode == ECErrorType_NoError) {
                        [strongSelf getMultiVoiceMeetingRoomFromService];
                    } else {
                        NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                        [strongSelf showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
                    }
                }];
            }
                break;
                
            case 2:
                [self joinChatroomInRoomWithSelectRoom:self.curSelectRoom andPwd:nil isJoin:NO];
                break;
                
            default:
                break;
        }
    }
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex != alertView.cancelButtonIndex) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        //确认操作
        NSLog(@"CustomeAlertViewDismiss 确认操作");
        if ([textField.text length]==0) {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"邀请的号码不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        } else {
            [self joinChatroomInRoomWithSelectRoom:self.curSelectRoom andPwd:textField.text isJoin:YES];
        }
    }
}

//通知客户端收到新的聊天室信息
- (void)onReceiveChatroomMsg:(NSNotification *)notification {
    
    ECMultiVoiceMeetingMsg* receiveMsgInfo = notification.object;
    if([receiveMsgInfo isKindOfClass:[ECMultiVoiceMeetingMsg class]]) {
        __weak __typeof(self) weakSelf = self;
        [[ECDevice sharedInstance].meetingManager listAllMultMeetingsByMeetingType:ECMeetingType_MultiVoice andKeywords:nil completion:^(ECError *error, NSArray *meetingList) {
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (error.errorCode == ECErrorType_NoError) {
                [strongSelf.chatroomsArray removeAllObjects];
                [strongSelf.chatroomsArray addObjectsFromArray:meetingList];
                [strongSelf viewRefresh];
            }
            
        }];
    }
}

-(void)joinChatroomInRoomWithSelectRoom:(ECMultiVoiceMeetingRoom*) selectRoom andPwd:(NSString*) pwd isJoin:(BOOL)isJoin {
    
    BOOL iscreator = NO;
    if ([selectRoom.creator isEqualToString:[DemoGlobalClass sharedInstance].userName]) {
        iscreator = YES;
    }
    
    ChatRoomViewController *chatroomview = [[ChatRoomViewController alloc] init];
    chatroomview.navigationItem.hidesBackButton = YES;
    chatroomview.roomname = selectRoom.roomName;
    chatroomview.backView = self;
    chatroomview.isCreator = iscreator;
    chatroomview.curChatroomId = selectRoom.roomNo;
    chatroomview.isJoin = isJoin;
    [self.navigationController pushViewController:chatroomview animated:YES];
    if (isJoin) {
        [chatroomview joinChatroomInRoom:selectRoom.roomNo andPwd:pwd];
    }
}

#pragma mark - chatroom method
- (void)startCharRoom:(id)sender
{
    RoomNameViewController* roomNameView = [[RoomNameViewController alloc] init];
    roomNameView.backView = self;
    [self.navigationController pushViewController:roomNameView animated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (range.length == 1) {
        return YES;
    }
    
    NSMutableString *text = [textField.text mutableCopy];
    [text replaceCharactersInRange:range withString:string];
    if (textField.tag == TAG_ALERTVIEW_ChatroomPwd) {
        return [text length] <= 8;
    }
    return [text length] <= 30;
}

-(void)dealloc {
    self.curSelectRoom = nil;
}
@end
