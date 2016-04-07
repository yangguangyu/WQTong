//
//  GroupMembersViewController.m
//  ECSDKDemo_OC
//
//  Created by admin on 15/10/26.
//  Copyright © 2015年 ronglian. All rights reserved.
//

#import "GroupMembersViewController.h"
#import "GroupMembersCell.h"
#import "ChatViewController.h"

@interface GroupMembersViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *membersArray;
@property(nonatomic,strong)UITableView *tableView;
@end

@implementation GroupMembersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"成员列表";
    
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem = leftItem;

    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _tableView.delegate =self;
    _tableView.dataSource =self;
    [self.view addSubview:_tableView];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.rowHeight = 60.0f;
    
    self.membersArray = [NSMutableArray array];
    [self queryGroupMembers];
}

-(void)returnClicked {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GroupMemberNickName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)queryGroupMembers {
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍等...";
    hud.removeFromSuperViewOnHide = YES;
    __weak __typeof(self) weakSelf = self;
    [[ECDevice sharedInstance].messageManager queryGroupMembers:self.groupID completion:^(ECError *error, NSString* groupId, NSArray *members) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        if (error.errorCode == ECErrorType_NoError && [strongSelf.groupID isEqualToString:groupId]) {
            
            strongSelf.membersArray = [[NSMutableArray alloc] initWithArray:[members sortedArrayUsingComparator:
                                                                             ^(ECGroupMember *obj1, ECGroupMember* obj2){
                                                                                 if(obj1.role < obj2.role) {
                                                                                     return(NSComparisonResult)NSOrderedAscending;
                                                                                 }else {
                                                                                     return(NSComparisonResult)NSOrderedDescending;
                                                                                 }
                                                                             }]];
            
            [strongSelf.membersArray enumerateObjectsUsingBlock:^(ECGroupMember *member, NSUInteger idx, BOOL *stop) {
                if ([member.memberId isEqualToString:[DemoGlobalClass sharedInstance].userName]) {
                    [strongSelf.membersArray removeObjectAtIndex:idx];
                }
                [[IMMsgDBAccess sharedInstance] addUserName:member.memberId name:member.display andSex:member.sex];
            }];
            
            [strongSelf.tableView reloadData];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.membersArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *memberCellId = @"memberCellId";
    GroupMembersCell *cell = [tableView dequeueReusableCellWithIdentifier:memberCellId];
    if (cell == nil) {
        cell = [[GroupMembersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:memberCellId];
    }
    
    ECGroupMember *groupMember = self.membersArray[indexPath.row];
    cell.headImage.image = groupMember.sex==ECSexType_Female?[UIImage imageNamed:@"female_default_head_img"]:[UIImage imageNamed:@"male_default_head_img"];
    NSString *text = @"";
    if (groupMember.role == ECMemberRole_Admin) {
        text = @"管理员";
    } else if (groupMember.role == ECMemberRole_Creator) {
        text = @"群主";
    } else if (groupMember.role == ECMemberRole_Member) {
        text = @"成员";
    }
    cell.role.text = text;
    cell.nameLabel.text = groupMember.display.length== 0?groupMember.memberId:groupMember.display;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ECGroupMember *member = self.membersArray[indexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject:member.display.length==0?member.memberId:member.display forKey:@"GroupMemberNickName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
