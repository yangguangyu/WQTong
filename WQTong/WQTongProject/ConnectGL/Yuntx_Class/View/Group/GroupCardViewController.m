//
//  GroupCardViewController.m
//  ECSDKDemo_OC
//
//  Created by admin on 15/10/27.
//  Copyright © 2015年 ronglian. All rights reserved.
//

#import "GroupCardViewController.h"

const char KAlertGroupMember;

#define AlertView_ModifyGroupMember_Tag 3500
#define AlertView_ModifyGroupMember_Display_Tag 3503
#define AlertView_ModifyGroupMember_Tel_Tag 3504
#define AlertView_ModifyGroupMember_Mail_Tag 3505
#define AlertView_ModifyGroupMember_Remark_Tag 3506

@interface GroupCardViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *display;
@property (nonatomic, copy) NSString *tel;
@property (nonatomic, copy) NSString *mail;
@property (nonatomic, copy) NSString *remark;
@property (nonatomic, strong) ECGroupMember *groupMember;
@property(nonatomic,strong)UITableView *tableView;
@end

@implementation GroupCardViewController

-(GroupCardViewController *)initWithGroupID:(NSString *)groupId
{
    if (self = [super init]) {
        self.groupId = groupId;
        self.groupMember = [[ECGroupMember alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"群组名片";
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    [leftBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [leftBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem =leftBtn;
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveBtnClicked)];
    [rightBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [rightBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem =rightBtn;
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _tableView.delegate =self;
    _tableView.dataSource =self;
    [self.view addSubview:_tableView];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.rowHeight = 50.0f;
    
    [self quaryMemberCard];
}

- (void)quaryMemberCard {
    
    __weak __typeof(self) weakSelf = self;
    [[ECDevice sharedInstance].messageManager queryMemberCard:[DemoGlobalClass sharedInstance].userName belong:self.groupId completion:^(ECError *error, ECGroupMember *member) {
        if (error.errorCode == ECErrorType_NoError) {
            weakSelf.groupMember = member;
            [weakSelf.tableView reloadData];
        }
    }];
}

-(void)returnClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveBtnClicked {
    
    if (self.groupMember.display.length <= 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"请输入昵称" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [self.view endEditing:YES];
    
    __weak typeof(self) weakself = self;
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:weakself.view animated:YES];
    hud.labelText = @"正在加载群名片，请稍等...";
    hud.removeFromSuperViewOnHide = YES;
    
    [[ECDevice sharedInstance].messageManager modifyMemberCard:self.groupMember completion:^(ECError *error, ECGroupMember *member) {
        [MBProgressHUD hideHUDForView:weakself.view animated:YES];
        if (error.errorCode == ECErrorType_NoError) {
            self.groupMember = member;
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
            hud.labelText = [NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail];
        }
    } ];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *detailistcellid = @"groupMemberCard_groupMemberCardcellid";
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
    
    if(indexPath.row==0) {
        cell.textLabel.text = [NSString stringWithFormat:@"群组id"];
        cell.detailTextLabel.text = self.groupMember.groupId;
    } else if (indexPath.row==1) {
        cell.textLabel.text = [NSString stringWithFormat:@"个人id"];
        cell.detailTextLabel.text = self.groupMember.memberId;
    }  else if(indexPath.row==2)  {
        cell.textLabel.text = [NSString stringWithFormat:@"性别"];
        cell.detailTextLabel.text = self.groupMember.sex==ECSexType_Male?@"男":@"女";
    } else if (indexPath.row==3) {
        cell.textLabel.text = [NSString stringWithFormat:@"昵称"];
        cell.detailTextLabel.text = self.groupMember.display;
    } else if(indexPath.row==4)  {
        cell.textLabel.text = [NSString stringWithFormat:@"电话"];
        cell.detailTextLabel.text = self.groupMember.tel;
    } else if(indexPath.row==5)  {
        cell.textLabel.text = [NSString stringWithFormat:@"E-mail"];
        cell.detailTextLabel.text = self.groupMember.mail;
    } else if(indexPath.row==6)  {
        cell.textLabel.text = [NSString stringWithFormat:@"可扩展字段"];
        cell.detailTextLabel.text = self.groupMember.remark;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row>2) {
        [self popDeclaredAlertView:self.groupMember andModifyTag:indexPath.row +AlertView_ModifyGroupMember_Tag];
    }
}

-(void)popDeclaredAlertView:(ECGroupMember*)groupMember andModifyTag:(NSInteger)tag {
    UIAlertView *alertView = alertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = tag;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    objc_setAssociatedObject(alertView, &KAlertGroupMember, groupMember, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    UITextField *textField = [alertView textFieldAtIndex:0];
    if (tag == AlertView_ModifyGroupMember_Display_Tag) {
        alertView.title = [NSString stringWithFormat:@"昵称"];;
        textField.text = groupMember.display;
    } else if (tag == AlertView_ModifyGroupMember_Tel_Tag) {
        textField.text = groupMember.tel;
        alertView.title = [NSString stringWithFormat:@"电话"];
    } else if (tag == AlertView_ModifyGroupMember_Mail_Tag) {
        textField.text = groupMember.mail;
        alertView.title = [NSString stringWithFormat:@"E-mail"];
    } else if (tag == AlertView_ModifyGroupMember_Remark_Tag) {
        textField.text = groupMember.remark;
        alertView.title = [NSString stringWithFormat:@"备注"];
    }
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        
        UITextField *textField = [alertView textFieldAtIndex:0];
        textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSInteger maxLength = 50;
        if (textField.text.length > maxLength) {
            textField.text = [textField.text substringToIndex:maxLength];
        }

        ECGroupMember* groupMember = objc_getAssociatedObject(alertView, &KAlertGroupMember);
        if (alertView.tag == AlertView_ModifyGroupMember_Display_Tag) {
            groupMember.display = textField.text;
        } else if (alertView.tag == AlertView_ModifyGroupMember_Tel_Tag){
            groupMember.tel = textField.text;
        } else if (alertView.tag == AlertView_ModifyGroupMember_Mail_Tag){
            groupMember.mail = textField.text;
        } else if (alertView.tag == AlertView_ModifyGroupMember_Remark_Tag){
            groupMember.remark = textField.text;
        }
        self.groupMember = groupMember;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:alertView.tag - AlertView_ModifyGroupMember_Tag inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
