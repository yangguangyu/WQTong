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
#import "MultiVideoConfListViewController.h"
#import "MultiVideoConfNameViewController.h"
#import "MultiVideoConfViewController.h"
#import "MultiVideoConfViewController.h"
#import "DeviceDelegateHelper.h"
#import "ECMeetingRoom.h"
#import "DeviceDelegateHelper+Meeting.h"
#import "SRRefreshView.h"

@interface MultiVideoConfListViewController ()<SRRefreshDelegate>
{
    UITableView *ConfListView;
    UIView * noneView;
}
@property (nonatomic, strong) NSMutableArray *multiVideoConfsArray;
@property (nonatomic, strong) SRRefreshView *refreshView;
@end

@implementation MultiVideoConfListViewController

- (void)loadView
{
    self.title = @"视频会议列表";

    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] ;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *leftItem = nil;
    UIBarButtonItem *rightItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"videoConf03"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(popBack)];
        
        rightItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"videoConfAdd"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(createVideoRoom)];
                     
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"videoConf03"] style:UIBarButtonItemStyleDone target:self action:@selector(popBack)];
        rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"videoConfAdd"] style:UIBarButtonItemStyleBordered target:self action:@selector(createVideoRoom)];
    }
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIImageView *pointImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_new_tips.png"]];
    pointImg.frame = CGRectMake(0.0f, 0.0f, screenWidth, 22.0f);
    [self.view addSubview:pointImg];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(11.0f, 0.0f, screenWidth, 22.0f)];
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.font = [UIFont systemFontOfSize:13.0f];
    statusLabel.text = @"点击即可加入视频会议";
    statusLabel.contentMode = UIViewContentModeCenter;
    [self.view addSubview:statusLabel];
    
    
    UIView *noneDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 29.0f, screenWidth, 480.0f)];
    noneView = noneDataView;
    [self.view addSubview:noneDataView];
    
    UIImageView *iconimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"videoConf32.png"]];
    iconimage.frame = CGRectMake(70.0f, 152.0f, 21.0f, 21.0f);
    [noneView addSubview:iconimage];
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(96.0f, 152.0f, 175.0f, 25.0f)];
    text.text = @"暂无房间，请先创建一个";
    text.font = [UIFont systemFontOfSize:15.0f];
    text.backgroundColor = [UIColor clearColor];
    text.textColor = [UIColor colorWithRed:204.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
    [noneView addSubview:text];
    
    self.multiVideoConfsArray = [NSMutableArray array];
    
    //获取视频会议列表
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -44.0f, self.view.frame.size.width, self.view.frame.size.height+44.0f) style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.backgroundView = [[UIView alloc] init];
    tableView.backgroundColor = [UIColor whiteColor];
	tableView.delegate = self;
	tableView.dataSource = self;
    tableView.rowHeight = 45.0f;
    tableView.tableFooterView = [[UIView alloc] init];
    ConfListView = tableView;
	[self.view addSubview:tableView];
    
    self.refreshView = [[SRRefreshView alloc] initWithFrame:CGRectMake(0, -44.0f, self.view.frame.size.width, 44.0f)];
    self.refreshView.delegate = self;
    self.refreshView.upInset = 44;
    [ConfListView addSubview:self.refreshView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveVideoConfMsg:) name:KNOTIFICATION_onReceiveMultiVideoMeetingMsg object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getMultiVideoMeetingRoomFromService];
}

#pragma mark -通知收到多路视频
- (void)onReceiveVideoConfMsg:(NSNotification *)noti
{
    ECMultiVideoMeetingMsg* receiveMsgInfo = noti.object;
    if([receiveMsgInfo isKindOfClass:[ECMultiVideoMeetingMsg class]]) {
        __weak __typeof(self) weakSelf = self;
        [[ECDevice sharedInstance].meetingManager listAllMultMeetingsByMeetingType:ECMeetingType_MultiVideo andKeywords:nil completion:^(ECError *error, NSArray *meetingList) {
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (error.errorCode == ECErrorType_NoError) {
                [strongSelf.multiVideoConfsArray removeAllObjects];
                [strongSelf.multiVideoConfsArray addObjectsFromArray:meetingList];
                [strongSelf viewRefresh];
            }
        }];
    }
}

#pragma mark -获取多路视频会议列表
- (void)getMultiVideoMeetingRoomFromService {
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍后...";
    hud.removeFromSuperViewOnHide = YES;
    
    __weak __typeof(self) weakSelf = self;
    [[ECDevice sharedInstance].meetingManager listAllMultMeetingsByMeetingType:ECMeetingType_MultiVideo andKeywords:nil completion:^(ECError *error, NSArray *meetingList) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf closeProgress];
        if (error.errorCode == ECErrorType_NoError) {
            
            [strongSelf.multiVideoConfsArray removeAllObjects];
            [strongSelf.multiVideoConfsArray addObjectsFromArray:meetingList];
            [strongSelf viewRefresh];
            
        } else {
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
            [strongSelf showProgress:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail] andHide:YES];
        }
    }];
}

- (void)viewRefresh
{
    if (self.multiVideoConfsArray.count > 0)
    {
        ConfListView.alpha = 1.0f;
         noneView.alpha = 0.0f;
    } else {
        ConfListView.alpha = 0.0f;
        noneView.alpha = 0.0f;
    }
    [ConfListView reloadData];
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
    
    [self getMultiVideoMeetingRoomFromService];
    [refreshView endRefresh];
}

#pragma mark -蒙版
-(void)showProgress:(NSString *)labelText andHide:(BOOL)ishide{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = labelText;
    hud.mode = MBProgressHUDModeText;
    hud.margin = 30.0f;
    hud.removeFromSuperViewOnHide = YES;
    if (ishide) {
        [hud hide:YES afterDelay:1.0f];
    }
}

-(void)closeProgress{
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
#pragma mark -页面按钮点击的方法
- (void)popBack
{
    [self closeProgress];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createVideoRoom
{
    MultiVideoConfNameViewController* ConfNameView = [[MultiVideoConfNameViewController alloc] init];
    ConfNameView.backView = self;
    [self.navigationController pushViewController:ConfNameView animated:YES];
}

#pragma mark -tableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_multiVideoConfsArray count];
}

static NSString* cellid = @"VideoConf_cellid";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECMultiVideoMeetingRoom *roomInfo = [self.multiVideoConfsArray objectAtIndex:indexPath.row];
    
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

#pragma mark - tableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECMultiVoiceMeetingRoom *selectRoom = [_multiVideoConfsArray objectAtIndex:indexPath.row];
    if(selectRoom.roomNo.length > 0  && selectRoom.square >= selectRoom.joinNum)
    {
        BOOL iscreator = NO;
        self.curRoomNo = nil;
        self.curRoomName = nil;
        for (ECMultiVoiceMeetingRoom *room in _multiVideoConfsArray)
        {
            if ([room.roomNo isEqualToString:selectRoom.roomNo])
            {
                self.curRoomName = [NSString stringWithFormat:@"%@",selectRoom.roomName];
                if ([room.creator isEqualToString:[DemoGlobalClass sharedInstance].userName])
                {
                    iscreator = YES;
                }
                break;
            }
        }
        if (iscreator)
        {
            self.curRoomName = [NSString stringWithFormat:@"%@",selectRoom.roomName];
            self.curRoomNo = [NSString stringWithFormat:@"%@",selectRoom.roomNo];
            self.curRoomVideoAddr = nil;
            UIActionSheet *menu = nil;
            if (selectRoom.square > selectRoom.joinNum) {
                menu = [[UIActionSheet alloc] initWithTitle: @"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"加入会议",@"解散会议",@"取消",nil];
                menu.tag = 1000;
                [menu setCancelButtonIndex:2];
            } else {
                menu = [[UIActionSheet alloc] initWithTitle: @"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"解散会议",@"取消",nil];
                menu.tag = 1001;
            }
            [menu showInView:self.view.window];
        }
        else if (selectRoom.square > selectRoom.joinNum)
        {
            [self joinConfWithRoomNo:selectRoom.roomNo andRoomname:selectRoom.roomName andCreator:iscreator andAddr:nil];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -UIActionSheet的代理方法
- (void)deleteVideoRoom
{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍后...";
    hud.removeFromSuperViewOnHide = YES;
    
    __weak __typeof(self) weakSelf = self;
    [[ECDevice sharedInstance].meetingManager deleteMultMeetingByMeetingType:ECMeetingType_MultiVideo andMeetingNumber:self.curRoomNo completion:^(ECError *error, NSString *meetingNumber) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf closeProgress];
        if (error.errorCode == ECErrorType_NoError) {
            
            [self getMultiVideoMeetingRoomFromService];
        } else {
            
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
            [strongSelf showProgress:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail] andHide:YES];
        }
    }];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1000)
    {
        switch (buttonIndex)
        {
            case 0:
                
                [self joinConfWithRoomNo:self.curRoomNo andRoomname:self.curRoomName andCreator:YES andAddr:self.curRoomVideoAddr];
                break;
            case 1: {
                [self deleteVideoRoom];
                }
                break;
        }
    } else if (actionSheet.tag == 1001) {
        switch (buttonIndex) {
            case 0:{
                [self deleteVideoRoom];
            }
                break;
            case 1:
                
                break;
            default:
                break;
        }
    }
}

#pragma mark -点击加入视频会议房间
-(void)joinConfWithRoomNo:(NSString*)roomNo andRoomname:(NSString*)roomname andCreator:(BOOL)creator andAddr:(NSString*)addr
{
    MultiVideoConfViewController *VideoConfview = [[MultiVideoConfViewController alloc] init];
    VideoConfview.navigationItem.hidesBackButton = YES;
    VideoConfview.curVideoConfId = roomNo;
    VideoConfview.Confname = roomname;
    VideoConfview.backView = self;
    VideoConfview.isCreator = creator;
    VideoConfview.addr = addr;
    [self.navigationController pushViewController:VideoConfview animated:YES];
    [VideoConfview joinInVideoConf];
}

- (void)dealloc
{
    self.backView = nil;
    ConfListView = nil;
    noneView = nil;
}
@end
