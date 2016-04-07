//
//  GroupListViewController.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "GroupListViewController.h"
#import "GroupListViewCell.h"
#import "ApplyJoinGroupViewController.h"
#import "DetailsViewController.h"
#import "ChatViewController.h" 
#import "CreateGroupViewController.h"

extern CGFloat NavAndBarHeight;

@implementation GroupListViewController
{
    NSMutableArray *dataSourceArray;
}
-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    CGFloat frameY = 0.0f;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
        frameY = 64.0f;
    } else {
        frameY = 44.0f;
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,self.view.frame.size.width,self.view.frame.size.height-frameY) style:UITableViewStylePlain];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    self.discussArray = [NSMutableArray array];
    if (self.isDiscuss) {
        dataSourceArray = self.discussArray;
    } else {
        dataSourceArray = [DeviceDBHelper sharedInstance].joinGroupArray;
    }
}

#pragma mark - prepareGroupDisplay
-(void)prepareGroupDisplay{
    
    __weak __typeof(self)weakSelf = self;
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在获取列表";
    hud.removeFromSuperViewOnHide = YES;
    
    [[ECDevice sharedInstance].messageManager queryOwnGroupsWith:(weakSelf.isDiscuss?ECGroupType_Discuss:ECGroupType_Group) completion:^(ECError *error, NSArray *groups) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        
        if (error.errorCode == ECErrorType_NoError) {
            NSLog(@"groups%@",groups);
            [dataSourceArray removeAllObjects];
            [dataSourceArray addObjectsFromArray:groups];
            [strongSelf.tableView reloadData];
            [[IMMsgDBAccess sharedInstance] addGroupIDs:groups];
        } else {
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
            [strongSelf showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
        }
    }];
}

//Toast错误信息
-(void)showToast:(NSString *)message{
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = message;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1];
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (dataSourceArray.count == 0) {
        return;
    }
    ECGroup* group = [dataSourceArray objectAtIndex:indexPath.row];
    ChatViewController *chatView = [[ChatViewController alloc] initWithSessionId:group.groupId];
    chatView.title = group.name;
    [self.mainView pushViewController:chatView animated:YES];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (dataSourceArray.count >0) {
        return dataSourceArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *GroupListViewCellid = @"GroupListViewCellidentifier";
    GroupListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupListViewCellid];
    if (cell == nil) {
        cell = [[GroupListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GroupListViewCellid];
    }
    
    if (dataSourceArray.count <=0) {
        return nil;
    }
    ECGroup *group = [dataSourceArray objectAtIndex:indexPath.row];
    cell.isDiscuss = self.isDiscuss;
    [cell setTableViewCellNameLabel:group.name andNumberLabel:group.groupId andIsJoin:YES andMemberNumber:group.memberCount];
    
    return cell;
}

@end
