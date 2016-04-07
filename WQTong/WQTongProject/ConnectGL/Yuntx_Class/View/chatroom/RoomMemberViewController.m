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


#import "RoomMemberViewController.h"
#import "ChatRoomViewController.h"

@interface RoomMemberViewController ()
@property (nonatomic, strong) NSString* curRoomNo;
@end

@implementation RoomMemberViewController

-(id)initWithRoomNo:(NSString*)roomNo Members:(NSArray*) members {
    if (self = [super init]) {
        chatMemberArray = [[NSMutableArray alloc] initWithArray:members];
        self.curRoomNo = roomNo;
    }
    return self;
}

- (void)loadView {
    self.title = @"成员管理";
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];

    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 35.0f, 200.0f, 20.0f)];
    label.text = @"可将指定成员踢出房间";
    label.textColor = [UIColor grayColor];
    [self.view addSubview:label];
    
    UITableView *tableView =  [[UITableView alloc] initWithFrame:CGRectMake(0, 0.0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	tableView.delegate = self;
	tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc] init];
    memberTable = tableView;
	[self.view addSubview:tableView];
}

- (void)kickOff:(id) sender {
    UIView *cell = [sender superview];
    while (![cell isKindOfClass:[UITableViewCell class]]) {
        cell = [cell superview];
    };
    NSIndexPath * indexPath = [memberTable indexPathForCell:(UITableViewCell*)cell];
    if (indexPath.row >= [chatMemberArray count])
    {
        return;
    }
    curIndex = indexPath.row;
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍后...";
    hud.removeFromSuperViewOnHide = YES;
    
    __weak __typeof(self) weakSelf = self;
    ECMultiVoiceMeetingMember* member = [chatMemberArray objectAtIndex:curIndex];
    [[ECDevice sharedInstance].meetingManager removeMemberFromMultMeetingByMeetingType:ECMeetingType_MultiVoice andMeetingNumber:self.curRoomNo andMember:member.account completion:^(ECError *error, ECVoIPAccount *memberVoip) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (error.errorCode == ECErrorType_NoError) {
            if (curIndex >= [chatMemberArray count]) {
                [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                return;
            }
            ECMultiVoiceMeetingMember * chatMember = [chatMemberArray objectAtIndex:curIndex];
            if (chatMember.role == 1 && [member.account.account isEqualToString:[DemoGlobalClass sharedInstance].userName]) {
                //创建人踢出自己
                [strongSelf dismissChatroom];
                return;
            }
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            [chatMemberArray removeObjectAtIndex:curIndex];
            [memberTable reloadData];
            
        } else {
            
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
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

-(void)returnClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissChatroom {
    __weak __typeof(self) weakSelf = self;
    [[ECDevice sharedInstance].meetingManager deleteMultMeetingByMeetingType:ECMeetingType_MultiVoice andMeetingNumber:self.curRoomNo completion:^(ECError *error, NSString *meetingNumber) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        if (error.errorCode == ECErrorType_NoError) {
            [strongSelf.navigationController popToViewController: [strongSelf.navigationController.viewControllers objectAtIndex:1] animated:YES];
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
#pragma mark - table DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [chatMemberArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellid = @"chatroom_cellid";
    UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    for (UIView *view in cell.contentView.subviews) {
        if (view.tag == 2001 || view.tag == 2002) {
            [view removeFromSuperview];
        }
    }
    
    ECMultiVoiceMeetingMember *member = [chatMemberArray objectAtIndex:indexPath.row];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 220, 28)];
    textLabel.text = member.account.account;
    textLabel.tag= 2002;
    textLabel.font = [UIFont systemFontOfSize:12.0f];
    [cell.contentView addSubview:textLabel];
    
    UIButton* btnKickOff = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnKickOff.frame = CGRectMake(240, 8, 60, 28);
    [btnKickOff setTitle:@"踢出" forState:(UIControlStateNormal)];
    btnKickOff.tag = 2001;
    [btnKickOff addTarget:self action:@selector(kickOff:) forControlEvents:UIControlEventTouchDown];
    [cell.contentView addSubview:btnKickOff];
    return cell;
}

#pragma mark - tabl Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

@end

