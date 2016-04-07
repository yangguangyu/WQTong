//
//  DetailsViewController.m
//  ECSDKDemo_OC
//
//  Created by lrn on 14/12/12.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "DetailsViewController.h"
#import "InviteJoinViewController.h"
#import "DetailsListViewCell.h"
#import "CommonTools.h"
#import "GroupCardViewController.h"

#define AlertView_Delete_Tag 1000
#define AlertView_Forbid_Tag 1500
#define AlertView_Resume_Tag 2000

#define AlertView_ModifyGroup_Name_Tag 2500
#define AlertView_ModifyGroup_Declared_Tag 2501

#define AlertView_ChangeGroup_Admin_Tag 3000
#define AlertView_HasGroup_Admin_Tag 3001

#define limitGroupMemberCount 8

const char KAlertCellTag;
const char KAlertGroup;
const char KSwitchKey;

@interface DetailsViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIActionSheetDelegate>
@property(nonatomic,strong)NSMutableArray * tableViewArray;
@property(nonatomic,strong)ECGroup *groupDetail;
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)NSMutableArray *memberArray;
@property(nonatomic,strong)ECGroupMember *member;
@property(nonatomic,assign)NSInteger adminMemberCount;
@end

@implementation DetailsViewController
{
    UILabel * tellLabel;
    UITextView * _groupTell;
    BOOL isSeeMoreGroupMembers;
}

#pragma mark - prepareUI
-(void)prepareUI {
    
    self.title = [NSString stringWithFormat:@"%@成员",_isDiscussOrGroupName];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }

    _isOwner =NO;
    _isCreater = NO;
    _isChangeGroupAdmin = NO;
    isSeeMoreGroupMembers = YES;
    _isHidden = NO;
    _adminMemberCount = 0;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0.0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _tableView.delegate =self;
    _tableView.dataSource =self;
    [self.view addSubview:_tableView];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundView = [[UIView alloc] init];
//    self.tableView.backgroundColor = [UIColor colorWithRed:0.937254905f green:0.937254905f blue:0.956862747f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _member = [[ECGroupMember alloc] init];
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

#pragma mark - BtnClick
-(void)addBtnClicked {
    InviteJoinViewController * ijvc = [[InviteJoinViewController alloc]init];
    ijvc.groupId =self.groupId;
    ijvc.showTableView = self.tableViewArray;
    ijvc.isDiscuss = self.isDiscuss;
    ijvc.isGroupCreateSuccess = YES;
    ijvc.backView = self;
    [self.navigationController pushViewController:ijvc animated:YES];
}

- (void)seeMoreGroupMemberBtnClicked:(UIButton *)btn {
    
    btn.selected = !isSeeMoreGroupMembers;
    isSeeMoreGroupMembers = btn.selected;
    if (!isSeeMoreGroupMembers) {
        [self queryGroupMembers];
    } else {
        if (_tableViewArray.count >=limitGroupMemberCount) {
            [_tableViewArray removeObjectsInRange:NSMakeRange(limitGroupMemberCount, _tableViewArray.count-limitGroupMemberCount)];
        }
        [self.tableView reloadData];
    }
}

-(void)returnClicked{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        
        __weak __typeof(self)weakSelf = self;

        if (alertView.tag == AlertView_ModifyGroup_Name_Tag || alertView.tag == AlertView_ModifyGroup_Declared_Tag) {
            UITextField *textField = [alertView textFieldAtIndex:0];
            ECGroup* group = objc_getAssociatedObject(alertView, &KAlertGroup);
            if (alertView.tag == AlertView_ModifyGroup_Name_Tag) {
                group.name = textField.text;
            }else if (alertView.tag == AlertView_ModifyGroup_Declared_Tag){
                group.declared = textField.text;
            }
            
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"请稍等...";
            hud.removeFromSuperViewOnHide = YES;

            [[ECDevice sharedInstance].messageManager modifyGroup:group completion:^(ECError *error, ECGroup *group) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                if (error.errorCode ==ECErrorType_NoError) {
                    [strongSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:alertView.tag-AlertView_ModifyGroup_Name_Tag inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }else{
                    NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                    [strongSelf showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
                }
                
            }];
            return;
        }
        
        DetailsListViewCell * cell = (DetailsListViewCell *)objc_getAssociatedObject(alertView, &KAlertCellTag);
        NSIndexPath* indexpath = [self.tableView indexPathForCell:cell];
        NSLog(@"cell.memberId%@",cell.memberId);
        
        if (alertView.tag == AlertView_Delete_Tag)
        {
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"正在踢出";
            hud.removeFromSuperViewOnHide = YES;
            
            [[ECDevice sharedInstance].messageManager deleteGroupMember:self.groupId member:cell.memberId completion:^(ECError *error, NSString *groupId, NSString *member) {
                
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                if (error.errorCode ==ECErrorType_NoError) {
                    [_tableViewArray removeObjectAtIndex:indexpath.row];
                    [_tableView deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                else
                {
                    NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                    [strongSelf showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
                }
            }];

        } else if (alertView.tag == AlertView_Forbid_Tag || AlertView_Resume_Tag == alertView.tag) {
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"请稍后...";
            hud.removeFromSuperViewOnHide = YES;
            
            ECSpeakStatus status = alertView.tag==AlertView_Forbid_Tag?ECSpeakStatus_Forbid:ECSpeakStatus_Allow;
            [[ECDevice sharedInstance].messageManager forbidMemberSpeakStatus:self.groupId member:cell.memberId speakStatus:status completion:^(ECError *error, NSString *groupId, NSString *memberId) {

                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                if (error.errorCode ==ECErrorType_NoError) {
                    cell.member.speakStatus = status;
                    [_tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
                } else {
                    NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                    [strongSelf showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
                }
            }];
        } else if (alertView.tag == AlertView_HasGroup_Admin_Tag) {
            [self quitGroup];
        }
    } else {
        if (alertView.tag == AlertView_ChangeGroup_Admin_Tag) {
            [self quitGroup];
        }
    }
}

- (void)quitGroup {
    __weak typeof(self) weakSelf = self;
    [[ECDevice sharedInstance].messageManager quitGroup:self.groupId completion:^(ECError *error, NSString *groupId) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        if (error.errorCode == ECErrorType_NoError) {
            [[DeviceDBHelper sharedInstance] deleteAllMessageOfSession:strongSelf.groupId];
            [strongSelf.navigationController popToRootViewControllerAnimated:YES];
        } else {
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
            [strongSelf showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
        }
    }];
}

-(void)removeBtnClicked:(UIButton *)sender {
    UIView* view = sender.superview;
    DetailsListViewCell * cell;
    while (1) {
        cell = (DetailsListViewCell *)view;
        if ([cell class] == [DetailsListViewCell class]) {
            break;
        }
        view = view.superview;
    }
    NSString*name = cell.member.display.length>0?cell.member.display:[[DemoGlobalClass sharedInstance] getOtherNameWithPhone:cell.member.memberId];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"是否要踢出%@",name] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = AlertView_Delete_Tag;
    objc_setAssociatedObject(alertView, &KAlertCellTag, cell, OBJC_ASSOCIATION_ASSIGN);
    [alertView show];
}


-(void)forbidBtnClicked:(UIButton *)sender {
    UIView* view = sender.superview;
    DetailsListViewCell * cell;
    while (1) {
        cell = (DetailsListViewCell *)view;
        if ([cell class] == [DetailsListViewCell class]) {
            break;
        }
        view = view.superview;
    }
    NSString*name = cell.member.display.length>0?cell.member.display:[[DemoGlobalClass sharedInstance] getOtherNameWithPhone:cell.member.memberId];
    
    UIAlertView *alertView = nil;
    if (cell.member.speakStatus == ECSpeakStatus_Forbid) {
        alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"是否恢复%@的发言",name] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = AlertView_Resume_Tag;
    } else {
        alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"是否禁止%@的发言",name] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = AlertView_Forbid_Tag;
    }
    objc_setAssociatedObject(alertView, &KAlertCellTag, cell, OBJC_ASSOCIATION_ASSIGN);
    [alertView show];
}

//清除聊天记录
-(void)clearTalkBtnClicked:(UIButton *)btn {
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在清除聊天内容";
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[DeviceDBHelper sharedInstance] deleteAllMessageSaveSessionOfSession:self.groupId];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"mainviewdidappear" object:nil];
            [hud hide:YES afterDelay:1];
        });
    });
}

-(void)exitBtnClicked {
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    
    __weak typeof(self) weakSelf = self;
    if (_isCreater && self.isDiscuss == NO) {
        hud.labelText = @"正在解散群";
        [[ECDevice sharedInstance].messageManager deleteGroup:self.groupId completion:^(ECError *error, NSString *groupId) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            if (error.errorCode == ECErrorType_NoError) {
                [[DeviceDBHelper sharedInstance] deleteAllMessageOfSession:strongSelf.groupId];
                [strongSelf.navigationController popToRootViewControllerAnimated:YES];
            } else {
                NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                [strongSelf showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
            }
        }];
    } else {
        if (self.isDiscuss == NO) {
            hud.labelText = @"正在退出群聊";
        } else {
            hud.labelText = @"正在退出讨论组";
        }
        [[ECDevice sharedInstance].messageManager quitGroup:self.groupId completion:^(ECError *error, NSString *groupId) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            if (error.errorCode == ECErrorType_NoError) {
                [[DeviceDBHelper sharedInstance] deleteAllMessageOfSession:strongSelf.groupId];
                [strongSelf.navigationController popToRootViewControllerAnimated:YES];
            } else {
                NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                [strongSelf showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
            }
        }];
    }
}

-(void)popAlertView:(ECGroup*)group andChangeRoleTag:(NSInteger)tag {
    UIAlertView *alertView = alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = tag;
    if (tag == AlertView_HasGroup_Admin_Tag) {
        alertView.title = @"是否确定退出群组";
    } else if (tag == AlertView_ChangeGroup_Admin_Tag) {
        alertView.title = @"您是该群群主，该群未指定管理员，是否指定管理员后退出";
    }
    [alertView show];
}

-(void)CreaterExitBtnClicked {
    
    if (_adminMemberCount>=1 || _isChangeGroupAdmin) {
        [self popAlertView:self.groupDetail andChangeRoleTag:AlertView_HasGroup_Admin_Tag];
    } else {
        [self popAlertView:self.groupDetail andChangeRoleTag:AlertView_ChangeGroup_Admin_Tag];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self prepareUI];
    
    if ([self.isDiscussOrGroupName isEqualToString:@"群组"]) {
        self.isDiscuss = NO;
    } else if ([self.isDiscussOrGroupName isEqualToString:@"讨论组"]) {
        self.isDiscuss = YES;
    }
    self.memberArray = [NSMutableArray array];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self queryGroupMembers];
}

-(void)queryGroupMembers {
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = [NSString stringWithFormat:@"正在获取%@详情",_isDiscussOrGroupName];
    hud.removeFromSuperViewOnHide = YES;
    
    __weak __typeof(self) weakSelf = self;
    //请求群组/讨论组信息
    [[ECDevice sharedInstance].messageManager getGroupDetail:self.groupId completion:^(ECError *error, ECGroup *group) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (error.errorCode == ECErrorType_NoError) {
            strongSelf.groupDetail = group;
        }
        [strongSelf judgeSuccess:error];
    }];
    
    
    [[ECDevice sharedInstance].messageManager queryGroupMembers:self.groupId completion:^(ECError *error, NSString* groupId, NSArray *members) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (error.errorCode == ECErrorType_NoError) {
            strongSelf.tableViewArray = [[NSMutableArray alloc] initWithArray:[members sortedArrayUsingComparator:
                                                                               ^(ECGroupMember *obj1, ECGroupMember* obj2){
                                                                                   if(obj1.role < obj2.role) {
                                                                                       return(NSComparisonResult)NSOrderedAscending;
                                                                                   }else {
                                                                                       return(NSComparisonResult)NSOrderedDescending;
                                                                                   }
                                                                               }]];
            strongSelf.memberArray = [NSMutableArray arrayWithArray:members];
            NSLog(@"_tableViewArray%@",_tableViewArray);
            
            NSString *myVoip = [DemoGlobalClass sharedInstance].userName;
            
            for (ECGroupMember *member in members) {
                if (!_isDiscuss && (member.role == ECMemberRole_Admin)) {
                    _adminMemberCount++;
                }
                if (member.memberId.length>0 && myVoip.length>0 && [member.memberId hasSuffix:myVoip]) {
                    if (member.role == ECMemberRole_Creator || member.role == ECMemberRole_Admin) {
                        _isOwner = YES;
                        _isCreater = (member.role == ECMemberRole_Creator)?YES:NO;
                        _isHidden = (member.role == ECMemberRole_Admin)?YES:NO;
                       
                    }
                }
                [[IMMsgDBAccess sharedInstance] addUserName:member.memberId name:member.display andSex:member.sex];
            }
        }
        [strongSelf judgeSuccess:error];
    }];
}

-(void)judgeSuccess:(ECError*)error {
    if (error.errorCode != ECErrorType_NoError) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
        [self showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
        return;
    }
    
    if (self.tableViewArray.count>0 && _groupDetail!=nil) {
        if (isSeeMoreGroupMembers && _tableViewArray.count>limitGroupMemberCount) {
            [_tableViewArray removeObjectsInRange:NSMakeRange(limitGroupMemberCount, _tableViewArray.count-limitGroupMemberCount)];
        }
        [self.tableView reloadData];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==2) {
        if (indexPath.row == 2){
            GroupCardViewController *groupCardVC = [[GroupCardViewController alloc] initWithGroupID:self.groupId];
            [self.navigationController pushViewController:groupCardVC animated:YES];
        }
        else if (_isOwner || self.isDiscuss) {
            [self popDeclaredAlertView:self.groupDetail andModifyTag:indexPath.row+AlertView_ModifyGroup_Name_Tag];
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 65.0f;
    } else if (indexPath.section == 2) {

        NSString *string = @"";
        if (indexPath.row==0 && self.groupDetail.name.length>0) {
            string = self.groupDetail.name;
        } else if (indexPath.row==1){
            string = self.groupDetail.declared.length>0?self.groupDetail.declared:@"暂无公告";
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGSize bubbleSize = [string sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(233.0f, 200.0f) lineBreakMode:NSLineBreakByCharWrapping];
#pragma clang diagnostic pop
        
        return bubbleSize.height>45.0f?bubbleSize.height+10.0f:55.0f;
    }
    return 50.0f;
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section==0) {
        return [NSString stringWithFormat:@"%@成员(%d)",self.isDiscussOrGroupName,(int)self.memberArray.count];
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.tableViewArray.count>0 && _groupDetail!=nil) {
        return 4;
    } else {
        return 0;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section ==0) {
//        NSInteger count = (_isOwner?1:0);
//        if (self.isDiscuss && !_isOwner) {
//            count = count +1 ;
//        }
        return _tableViewArray.count+1;
    } else if (section == 1) {
        return 2;
    } else if (section == 2){
        return 3;
    } else {
        if (_isDiscuss == NO && _isCreater) {
            return 3;
        } else {
            return 2;
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row<_tableViewArray.count) {
            
            static NSString *detailistcellid = @"DetailsViewController";
            DetailsListViewCell *cell =[tableView dequeueReusableCellWithIdentifier:detailistcellid];
            if (cell == nil) {
                cell = [[DetailsListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:detailistcellid];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.removeBtn addTarget:self action:@selector(removeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell.forbidBtn addTarget:self action:@selector(forbidBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                cell.backgroundColor = [UIColor whiteColor];
                cell.contentView.backgroundColor = [UIColor whiteColor];
            }
        
            
            ECGroupMember * member = (ECGroupMember *)[_tableViewArray objectAtIndex:indexPath.row];
            cell.member = member;
            cell.memberId = member.memberId;
            cell.removeBtn.tag = indexPath.row;
            
            BOOL isChangeGroupAdmin = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@_%@",cell.member.groupId?:self.groupId,cell.member.memberId]];
            _isChangeGroupAdmin = isChangeGroupAdmin;
            
            cell.removeBtn.hidden = ((cell.member.role==ECMemberRole_Creator) || (_isHidden&&(cell.member.role==ECMemberRole_Admin)) || !_isOwner)?YES:NO;
            
            if ([[DemoGlobalClass sharedInstance].userName isEqualToString:cell.memberId]) {
                cell.nameLabel.text = ([DemoGlobalClass sharedInstance].nickName.length>0?[DemoGlobalClass sharedInstance].nickName:[DemoGlobalClass sharedInstance].userName);
            } else {
                cell.nameLabel.text = member.display.length>0?member.display:[[DemoGlobalClass sharedInstance] getOtherNameWithPhone:member.memberId];
                if (member.role!=ECMemberRole_Creator && self.isDiscuss == NO && _isCreater) {
                    UILongPressGestureRecognizer *cellLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(setGroupMemberRole:)];
                    [cell addGestureRecognizer:cellLongPress];
                }
            }
            
            cell.forbidBtn.hidden = cell.removeBtn.hidden || _isDiscuss;
            cell.forbidBtn.tag = cell.removeBtn.tag;
            if (member.speakStatus == ECSpeakStatus_Forbid) {
                [cell.forbidBtn setTitle:@"恢复" forState:UIControlStateNormal];
                [cell.forbidBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            } else {
                [cell.forbidBtn setTitle:@"禁言" forState:UIControlStateNormal];
                [cell.forbidBtn setTitleColor:[UIColor colorWithRed:0.04f green:0.75f blue:0.40f alpha:1.00f] forState:UIControlStateNormal];
            }

            NSString *roleStr = @"";
            if (member.role==ECMemberRole_Creator && self.isDiscuss == NO) {
                roleStr = @"群主";
            } else if (member.role==ECMemberRole_Admin || (member.role==ECMemberRole_Creator && self.isDiscuss == YES)) {
                roleStr = @"管理员";
            } else if (member.role == ECMemberRole_Member) {
                roleStr = @"成员";
            }
            cell.nameLabel.text = [NSString stringWithFormat:@"%@[%@]",cell.nameLabel.text,roleStr];
            cell.headImage.image = member.sex==ECSexType_Female?[UIImage imageNamed:@"female_default_head_img"]:[UIImage imageNamed:@"male_default_head_img"];
            cell.numberLabel.text = member.memberId;
            return cell;
        } else {
            static NSString *detailistcellid = @"DetailsViewControllerinvite";
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:detailistcellid];
            
            if (_isOwner || self.isDiscuss) {
                
                UIButton* addBtn = [[UIButton alloc]initWithFrame:CGRectMake(0.0f, 0, 225, 65.0f)];
                addBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                [addBtn setBackgroundImage:[CommonTools createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                [cell.contentView addSubview:addBtn];
                [addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
                UILabel* addlabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 17.5, 140, 30)];
                addlabel.text =@"邀请成员加入";
                [addBtn addSubview:addlabel];
                UIImageView* imageview = [[UIImageView alloc]initWithFrame:CGRectMake(20.0f, 10.0f, 45.0f, 45.0f)];
                imageview.image = [UIImage imageNamed:@"add_contact"];
                [addBtn addSubview:imageview];
            }
            
            if (self.memberArray.count>8) {
                
                UIButton* seeMoreGroupMemberBtn = [[UIButton alloc]initWithFrame:CGRectMake(230, 0.0f, cell.bounds.size.width-235.0f, 65.0f)];
                seeMoreGroupMemberBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                [seeMoreGroupMemberBtn setBackgroundImage:[CommonTools createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                [cell.contentView addSubview:seeMoreGroupMemberBtn];
                [seeMoreGroupMemberBtn addTarget:self action:@selector(seeMoreGroupMemberBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(10, 17.5, cell.bounds.size.width-235.0f-10.0f, 30)];
                label.text = isSeeMoreGroupMembers?@"查看更多":@"收起";
                [seeMoreGroupMemberBtn addSubview:label];
            }
            
            return cell;
        }
    } else if (indexPath.section == 1) {
        static NSString *detailistcellid = @"DetailsViewControllernopushsetcell";
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:detailistcellid];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:detailistcellid];
            cell.backgroundColor = [UIColor whiteColor];
            
            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(30.0f, 5.0f, 200.0f, 40.0f)];
            label.tag = 50;
            label.backgroundColor = [UIColor whiteColor];
            label.textColor = [UIColor blackColor];
            label.text = @"消息免打扰";
            [cell.contentView addSubview:label];
            
            UISwitch * switchs = [[UISwitch alloc] init];//[[UISwitch alloc]initWithFrame:CGRectMake(250.0f, 10.0f, 50.0f, 40.0f)];
            switchs.tag = 100;
            [switchs addTarget:self action:@selector(switchsChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchs];
            
            CGRect frame = switchs.frame;
            frame.origin.x = screenWidth-switchs.frame.size.width-20.0f;
            frame.origin.y = (cell.contentView.frame.size.height-switchs.frame.size.height)*0.5;
            switchs.frame = frame;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        UILabel *label = (UILabel*)[cell.contentView viewWithTag:50];
        UISwitch *uiswitch = (UISwitch*)[cell.contentView viewWithTag:100];
        objc_setAssociatedObject(uiswitch, &KSwitchKey, @(indexPath.row), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (indexPath.row==0) {
            uiswitch.on = !self.groupDetail.isNotice;
            label.text = @"消息免打扰";
        } else {
            uiswitch.on = self.groupDetail.isPushAPNS;
            label.text = @"消息推送";
        }
        return cell;
        
    } else if (indexPath.section == 2) {
        static NSString *detailistcellid = @"groupdetail_groupdetailcellid";
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:detailistcellid];
        cell.backgroundColor = [UIColor whiteColor];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:detailistcellid];
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
            cell.detailTextLabel.lineBreakMode = NSLineBreakByCharWrapping;
            cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
            cell.detailTextLabel.backgroundColor = cell.backgroundColor;
        }
        cell.textLabel.backgroundColor = cell.backgroundColor;
        if (indexPath.row==0) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@名称",self.isDiscussOrGroupName];
            cell.detailTextLabel.text = self.groupDetail.name;
        } else if(indexPath.row==1)  {
            cell.textLabel.text = [NSString stringWithFormat:@"%@公告",self.isDiscussOrGroupName];
            cell.detailTextLabel.text = self.groupDetail.declared.length>0?self.groupDetail.declared:@"暂无公告";
        } else if(indexPath.row==2)  {
            cell.textLabel.text = [NSString stringWithFormat:@"%@名片",self.isDiscussOrGroupName];
            cell.detailTextLabel.text = @"查看";
        }

        return cell;
    } else {
        static NSString *clearcellid = @"clearCell";
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:clearcellid];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:clearcellid];
            
            UIButton * clearTalkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [clearTalkBtn setBackgroundImage:[CommonTools createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            clearTalkBtn.tag = 1000;
            clearTalkBtn.frame =CGRectMake(0.0f, 0.0f, 320.0f, 49.0f);
            clearTalkBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [clearTalkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [cell.contentView addSubview:clearTalkBtn];
        }
        
        UIButton * button = (UIButton*)[cell.contentView viewWithTag:1000];
        if (indexPath.row == 0) {
            [button addTarget:self action:@selector(clearTalkBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"清空聊天记录" forState:UIControlStateNormal];
        } else if(indexPath.row ==1){
            [button addTarget:self action:@selector(exitBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            if (self.isDiscuss == NO) {
                [button setTitle:(_isCreater?@"解散该群组":@"退出群聊") forState:UIControlStateNormal];
            } else {
                [button setTitle:@"退出群聊" forState:UIControlStateNormal];
            }
        } else if(indexPath.row ==2) {
            [button addTarget:self action:@selector(CreaterExitBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"退出群聊" forState:UIControlStateNormal];
        }
        
        return cell;
    }
    return nil;

}

-(void)popDeclaredAlertView:(ECGroup*)group andModifyTag:(NSInteger)tag {
    UIAlertView *alertView = alertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = tag;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    objc_setAssociatedObject(alertView, &KAlertGroup, group, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    UITextField *textField = [alertView textFieldAtIndex:0];
    if (tag == AlertView_ModifyGroup_Name_Tag) {
        alertView.title = [NSString stringWithFormat:@"%@名称",self.isDiscussOrGroupName];
        textField.text = group.name;
    } else if (tag == AlertView_ModifyGroup_Declared_Tag) {
        textField.text = group.declared;
        alertView.title = [NSString stringWithFormat:@"%@公告",self.isDiscussOrGroupName];
    }
    [alertView show];
}

-(void)switchsChanged:(UISwitch *)switches {
    
    NSNumber* switchTag = objc_getAssociatedObject(switches, &KSwitchKey);
    if (switchTag.integerValue == 0) {
        ECGroupOption *option = [[ECGroupOption alloc] init];
        option.groupId = self.groupId;
        option.isPushAPNS = self.groupDetail.isPushAPNS;
        option.isNotice = !switches.on;
        
        __weak __typeof(self)weakSelf = self;
        [[ECDevice sharedInstance].messageManager setGroupMessageOption:option completion:^(ECError *error, NSString *groupId) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (error.errorCode == ECErrorType_NoError) {
                strongSelf.groupDetail.isNotice = !switches.on;
                [[IMMsgDBAccess sharedInstance] setIsNotice:strongSelf.groupDetail.isNotice ofGroupId:groupId];
                [[NSNotificationCenter defaultCenter] postNotificationName:KNotice_ReloadSessionGroup object:groupId];
            } else {
                switches.on = !switches.on;
            }
        }];
    } else {
        ECGroupOption *option = [[ECGroupOption alloc] init];
        option.groupId = self.groupId;
        option.isPushAPNS = switches.on;
        option.isNotice = self.groupDetail.isNotice;
        
        __weak __typeof(self)weakSelf = self;
        [[ECDevice sharedInstance].messageManager setGroupMessageOption:option completion:^(ECError *error, NSString *groupId) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (error.errorCode == ECErrorType_NoError) {
                strongSelf.groupDetail.isPushAPNS = switches.on;
                [[IMMsgDBAccess sharedInstance] setIsNotice:strongSelf.groupDetail.isNotice ofGroupId:groupId];
                [[NSNotificationCenter defaultCenter] postNotificationName:KNotice_ReloadSessionGroup object:groupId];
            } else {
                switches.on = !switches.on;
            }
        }];
    }
    
}
#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length == 0) {
        tellLabel.hidden = NO;
    } else {
        tellLabel.hidden = YES;
    }
}

const char KSheet;
- (void)setGroupMemberRole:(UIGestureRecognizer*)gestureRecognizer {
    
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    DetailsListViewCell *cell = (DetailsListViewCell*)gestureRecognizer.view;
    cell.tag = [self.tableView indexPathForRowAtPoint:point].row;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        UIActionSheet *sheet = [[UIActionSheet alloc] init];
        sheet.delegate = self;
        if (cell.member.role == ECMemberRole_Admin) {
            [sheet addButtonWithTitle:@"取消管理员"];
        } else if (cell.member.role == ECMemberRole_Member) {
            [sheet addButtonWithTitle:@"设置管理员"];
        }
        [sheet addButtonWithTitle:@"取消"];
        sheet.actionSheetStyle = UIActionSheetStyleDefault;
        [sheet showInView:self.view];
        objc_setAssociatedObject(sheet, &KSheet, cell, OBJC_ASSOCIATION_RETAIN);

    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    DetailsListViewCell *cell = (DetailsListViewCell*)objc_getAssociatedObject(actionSheet, &KSheet);
    
    if (buttonIndex == 0) {
        ECMemberRole role = (ECMemberRole)cell.member.role==ECMemberRole_Member?ECMemberRole_Admin:ECMemberRole_Member;
        __weak typeof(self)weakSelf = self;
        [[ECDevice sharedInstance].messageManager setGroupMemberRole:self.groupId member:cell.member.memberId role:role completion:^(ECError *error, NSString *groupId, NSString *memberId) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (error.errorCode == ECErrorType_NoError) {
                BOOL isChangeGroupAdmin = role==ECMemberRole_Admin?YES:NO;
                [[NSUserDefaults standardUserDefaults] setBool:isChangeGroupAdmin forKey:[NSString stringWithFormat:@"%@_%@",cell.member.groupId?:strongSelf.groupId,cell.member.memberId]];
                [[NSUserDefaults standardUserDefaults] synchronize];
                cell.member.role = role;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cell.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                });
            } else {
                [strongSelf showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,error.description]];
            }
        }];
    }
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}
@end
