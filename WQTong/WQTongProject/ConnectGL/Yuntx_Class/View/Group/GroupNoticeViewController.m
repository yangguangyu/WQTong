//
//  GroupNoticeViewController.m
//  ECSDKDemo_OC
//
//  Created by lrn on 14/12/18.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "GroupNoticeViewController.h"
#import "GroupNoticeTableViewCell.h"

@interface GroupNoticeViewController ()<UIActionSheetDelegate>
@property(nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong) NSMutableArray* messageArray;
@end

#define TAG_SHEET_propose 100
#define TAG_SHEET_invite 150

const char KSheetGroupNotice;

@implementation GroupNoticeViewController

#pragma mark - prepareUI

-(void)prepareUI {
    
    self.title = @"系统通知";
    _messageArray = [[NSMutableArray alloc]init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
    leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem =leftItem;

    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStyleDone target:self action:@selector(clearBtnClicked)];
    [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem =rightItem;

    [self refreshTableView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTableView) name:KNOTIFICATION_onReceivedGroupNotice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:KNotice_ReloadSessionGroup object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self prepareUI];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[DeviceDBHelper sharedInstance] markGroupMessagesAsRead];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[DeviceDBHelper sharedInstance] markGroupMessagesAsRead];
}

-(void)clearBtnClicked {
    [[DeviceDBHelper sharedInstance] clearGroupMessageTable];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mainviewdidappear" object:nil];
    [self.messageArray removeAllObjects];
    [self.tableView reloadData];
}

-(void)refreshTableView {
    
    [self.messageArray removeAllObjects];
    [self.messageArray addObjectsFromArray:[[DeviceDBHelper sharedInstance] getLatestHundredGroupNotice]];
    [self.tableView reloadData];
}

-(void)returnClicked {
    [self.navigationController popViewControllerAnimated:YES];
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

-(void)popConfirmSheet:(ECGroupNoticeMessage*)message {
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:message.groupName delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"同意",@"拒绝", nil];
    objc_setAssociatedObject(sheet, &KSheetGroupNotice, message, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSString* button = [actionSheet buttonTitleAtIndex:buttonIndex];
        ECGroupNoticeMessage* groupNotice = objc_getAssociatedObject(actionSheet, &KSheetGroupNotice);
        if (groupNotice.messageType == ECGroupMessageType_Propose) {
            NSString *groupid = groupNotice.groupId;
            NSString *member = ((ECProposerMsg *)groupNotice).proposer;
            if ([button isEqualToString:@"同意"]) {
                [self replyJoinGroup:groupid memeber:member ackType:EAckType_Agree];
            } else if ([button isEqualToString:@"拒绝"]) {
                [self replyJoinGroup:groupid memeber:member ackType:EAckType_Reject];
            }
        } else if (groupNotice.messageType == ECGroupMessageType_Invite) {
            NSString *groupid = groupNotice.groupId;
            NSString *invitor = ((ECInviterMsg *)groupNotice).admin;
            if ([button isEqualToString:@"同意"]) {
                [self replyInviteGroup:groupid invitor:invitor ackType:EAckType_Agree];
            } else if ([button isEqualToString:@"拒绝"]) {
                [self replyInviteGroup:groupid invitor:invitor ackType:EAckType_Reject];
            }
        }
    }
}


-(void)replyInviteGroup:(NSString*)groupId invitor:(NSString*)invitor ackType:(ECAckType)ack {
    __weak __typeof(self)weakSelf = self;
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍等...";
    hud.removeFromSuperViewOnHide = YES;
    [[ECDevice sharedInstance].messageManager ackInviteJoinGroupRequest:groupId invitor:invitor ackType:ack completion:^(ECError *error, NSString *gorupId) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [MBProgressHUD hideHUDForView:strongSelf.view animated:NO];
        if (error.errorCode == ECErrorType_NoError || error.errorCode == ECErrorType_Have_Joined) {
            [[IMMsgDBAccess sharedInstance] markGroupMessagesAsDownOfGroup:groupId andAdminId:invitor];
            [strongSelf refreshTableView];
        } else {
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
            [strongSelf showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
        }
    }];
}

-(void)replyJoinGroup:(NSString*)groupId memeber:(NSString*)member ackType:(ECAckType)ack {
    __weak __typeof(self)weakSelf = self;
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍等...";
    hud.removeFromSuperViewOnHide = YES;
    [[ECDevice sharedInstance].messageManager ackJoinGroupRequest:groupId member:member ackType:ack completion:^(ECError *error, NSString *gorupId, NSString *memberId) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [MBProgressHUD hideHUDForView:strongSelf.view animated:NO];
        if (error.errorCode == ECErrorType_NoError || error.errorCode == ECErrorType_Have_Joined) {
            [[IMMsgDBAccess sharedInstance] markGroupMessagesAsDownOfGroup:groupId andMemberId:member];
            [strongSelf refreshTableView];
        } else {
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
            [strongSelf showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
        }
    }];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ECGroupNoticeMessage * msg = [_messageArray objectAtIndex:indexPath.row];
    if ([msg isKindOfClass:[ECProposerMsg class]] && ((ECProposerMsg*)msg).confirm != 2) {
        [self popConfirmSheet:msg];
    } else if ([msg isKindOfClass:[ECInviterMsg class]] && ((ECInviterMsg*)msg).confirm == 1) {
        [self popConfirmSheet:msg];
    }
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *contactlistcellid = @"GroupNoticeViewCellidentifier";
    GroupNoticeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactlistcellid];
    if (cell == nil) {
        cell = [[GroupNoticeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contactlistcellid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    ECGroupNoticeMessage * msg = [_messageArray objectAtIndex:indexPath.row];
    cell.cellContentId = msg;
    cell.cellConfirm = 0;
    NSString *name = @"";
    if (msg.isDiscuss) {
        name = @"讨论组";
    } else {
        name = @"群组";
    }
    
    NSString* groupName = [self getGroupName:msg.groupId andGroupName:msg.groupName];
    
    if (msg.messageType == ECGroupMessageType_Dissmiss) {
       
        cell.portraitImg.image = [UIImage imageNamed:@"group_head"];
        cell.contentLabel.text = [NSString stringWithFormat:@"%@\"%@\"被解散",name,groupName];

    } else if (msg.messageType == ECGroupMessageType_Invite) {
        
        ECInviterMsg * message = (ECInviterMsg *)msg;
        cell.portraitImg.image = [[DemoGlobalClass sharedInstance] getOtherImageWithPhone:message.admin];
        cell.cellConfirm = message.confirm;
        
        NSString *declared = @"";
        if (message.declared.length>0) {
            declared = [NSString stringWithFormat:@",理由:%@",message.declared];
        }
        cell.contentLabel.text = [NSString stringWithFormat:@"\"%@\"邀请您加入\"%@\"%@\"%@",[self getMemberName:message.admin andNickName:message.nickName],groupName,name,declared];
        
    } else if (msg.messageType == ECGroupMessageType_Propose) {
        
        ECProposerMsg * message = (ECProposerMsg *)msg;
        cell.portraitImg.image = [[DemoGlobalClass sharedInstance] getOtherImageWithPhone:message.proposer];
        cell.cellConfirm = message.confirm;
        
        NSString *declared = @"";
        if (message.declared.length>0) {
            declared = [NSString stringWithFormat:@",理由:%@",message.declared];
        }
        cell.contentLabel.text = [NSString stringWithFormat:@"\"%@\"申请加入%@\"%@\"%@",[self getMemberName:message.proposer andNickName:message.nickName],name,groupName,declared];
        
    } else if (msg.messageType == ECGroupMessageType_Join) {
        
        ECJoinGroupMsg *message = (ECJoinGroupMsg *)msg;
        cell.portraitImg.image = [[DemoGlobalClass sharedInstance]getOtherImageWithPhone:message.member];
        cell.contentLabel.text = [NSString stringWithFormat:@"\"%@\"加入%@\"%@\"",[self getMemberName:message.member andNickName:message.nickName],name,groupName];
        
    } else if (msg.messageType == ECGroupMessageType_Quit) {
        
        ECQuitGroupMsg *message = (ECQuitGroupMsg *)msg;
        cell.portraitImg.image = [[DemoGlobalClass sharedInstance]getOtherImageWithPhone:message.member];
        cell.contentLabel.text = [NSString stringWithFormat:@"\"%@\"退出%@\"%@\"",[self getMemberName:message.member andNickName:message.nickName],name,groupName];
        
    } else if (msg.messageType == ECGroupMessageType_RemoveMember) {
        
        ECRemoveMemberMsg *message = (ECRemoveMemberMsg *)msg;
        cell.portraitImg.image = [[DemoGlobalClass sharedInstance]getOtherImageWithPhone:message.member];
        cell.contentLabel.text = [NSString stringWithFormat:@"\"%@\"被移除%@\"%@\"",[self getMemberName:message.member andNickName:message.nickName],name,groupName];
        
    } else if (msg.messageType == ECGroupMessageType_ReplyJoin) {
        
        ECReplyJoinGroupMsg *message = (ECReplyJoinGroupMsg *)msg;
        cell.portraitImg.image = [[DemoGlobalClass sharedInstance]getOtherImageWithPhone:message.member];
        [[DemoGlobalClass sharedInstance]getOtherNameWithPhone:message.member];
        cell.contentLabel.text = [NSString stringWithFormat:@"%@\"%@\"%@\"%@\"的加入申请",groupName,message.confirm==2?@"同意":@"拒绝",name,[self getMemberName:message.member andNickName:message.nickName]];
        
    } else if (msg.messageType == ECGroupMessageType_ReplyInvite) {
        
        ECReplyInviteGroupMsg *message = (ECReplyInviteGroupMsg *)msg;
        cell.portraitImg.image = [[DemoGlobalClass sharedInstance]getOtherImageWithPhone:message.member];
        cell.contentLabel.text = [NSString stringWithFormat:@"\"%@\"%@\"%@\"的邀请加入%@\"%@\"",[self getMemberName:message.member andNickName:message.nickName],message.confirm==2?@"同意":@"拒绝",message.admin,name,groupName];
        
    } else if (msg.messageType == ECGroupMessageType_ModifyGroup) {
        
        ECModifyGroupMsg *message = (ECModifyGroupMsg *)msg;
        cell.portraitImg.image = [[DemoGlobalClass sharedInstance]getOtherImageWithPhone:message.member];
        
        NSString * jsonString = @"";
        if (message.modifyDic) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message.modifyDic options:NSJSONWritingPrettyPrinted error:nil];
            if (jsonData) {
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                jsonString = [jsonString stringByReplacingOccurrencesOfString:@" " withString:@""];
                jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
        }
        
        cell.contentLabel.text = [NSString stringWithFormat:@"\"%@\"修改%@\"%@\"信息:%@",[self getMemberName:message.member andNickName:nil],name, groupName, jsonString];
        
    } else if (msg.messageType == ECGroupMessageType_ChangeAdmin) {
        
        ECChangeAdminMsg *message = (ECChangeAdminMsg *)msg;
        cell.portraitImg.image = [[DemoGlobalClass sharedInstance]getOtherImageWithPhone:message.member];
        cell.contentLabel.text = [NSString stringWithFormat:@"\"%@\"成为\"%@%@的管理员\"",message.nickName, groupName,name];
    } else if (msg.messageType == ECGroupMessageType_ChangeMemberRole) {
        ECChangeMemberRoleMsg *message = (ECChangeMemberRoleMsg *)msg;
        ECMemberRole role = (ECMemberRole)[[message.roleDic objectForKey:@"role"] integerValue];
        NSString *roleText = nil;
        if (role == ECMemberRole_Member) {
            roleText = @"取消管理员";
        } else if (role == ECMemberRole_Admin) {
            roleText = @"设置为管理员";
        }
        cell.portraitImg.image = [[DemoGlobalClass sharedInstance]getOtherImageWithPhone:message.member];
        cell.contentLabel.text = [NSString stringWithFormat:@"\"%@\"被\"%@%@\"",message.nickName, message.sender,roleText];
    }

    return cell;
}

-(NSString*)getMemberName:(NSString*)phone andNickName:(NSString*)nickName
{
    NSString *name = [[DemoGlobalClass sharedInstance] getOtherNameWithPhone:phone];
    if ([name isEqualToString:phone] || name.length==0) {
        name = (nickName.length==0?phone:nickName);
    }
    return name;
}

-(NSString*)getGroupName:(NSString*)groupId andGroupName:(NSString*)groupName
{
    NSString * name = [[IMMsgDBAccess sharedInstance] getGroupNameOfId:groupId];
    if (name.length > 0) {
        return name;
    }
    
    if (groupName.length>0) {
        return groupName;
    }
    return groupId;
}
@end
