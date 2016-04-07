//
//  InviteJoinViewController.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/8.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "InviteJoinViewController.h"
#import "InviteJoinListViewCell.h"
#import "ChatViewController.h"
#import "CommonTools.h"

#define ECINVITE_ALERTERVIE_Contacts 1002
@interface InviteJoinViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *localAddressBook;
@property (nonatomic, strong) NSArray *allAddressKeys;
@property (nonatomic, strong) NSMutableArray *selectedArray;
@end


@implementation InviteJoinViewController
{
    UITableView * _inviteTableView;
    NSMutableArray * _selectedArray;
    UILabel * countLabel;
    UIButton * inviteBtn;
}

#pragma mark - prepareUI
-(void)prepareUI
{
    CGFloat hight = [[UIScreen mainScreen] bounds].size.height;
    self.selectedArray = [NSMutableArray new];
    self.title = [NSString stringWithFormat:@"邀请加入%@",_isDiscuss?@"讨论组":@"群组"];
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
    label.text = [NSString stringWithFormat:@"  请勾选要邀请加入%@的联系人",_isDiscuss?@"讨论组":@"群组"];
    label.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    [self.view addSubview:label];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    self.localAddressBook = [[AddressBookManager sharedInstance] NewallContactsBySorted];
    [self judgeArrayCount];
    
    self.allAddressKeys = [self.localAddressBook.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *letter1 = obj1;
        NSString *letter2 = obj2;
        if (KCNSSTRING_ISEMPTY(letter2)) {
            return NSOrderedDescending;
        }else if ([letter1 characterAtIndex:0] < [letter2 characterAtIndex:0]) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];

    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0.0f, 50.0f, screenWidth, hight-110.0f) style:UITableViewStylePlain];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        self.tableView.frame = CGRectMake(0.0f, 50.0f, screenWidth, hight-110.0f);
    }
    else
    {
        self.tableView.frame = CGRectMake(0.0f, 50.0f, screenWidth, hight-110.0f-20.0f);
    }
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.sectionIndexColor = themeColor;
    [self.view addSubview:self.tableView];
    
    countLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, hight-60-64, screenWidth/2, 60.0f)];
    countLabel.text = @"一共勾选了0个人";
    countLabel.textColor = [UIColor whiteColor];
    countLabel.backgroundColor =[UIColor colorWithRed:0.20f green:0.20f blue:0.20f alpha:1.00f];
    [self.view addSubview:countLabel];
    
    inviteBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/2, hight-60-64, screenWidth/2, 60)];
    inviteBtn.backgroundColor = themeColor;
    [inviteBtn addTarget:self action:@selector(inviteBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [inviteBtn setTitle:[NSString stringWithFormat:@"%@",_isDiscuss?@"邀请":@"下一步"] forState:UIControlStateNormal];
    [self.view addSubview:inviteBtn];
    
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7){
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }else{
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem =leftItem;
}


#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 20)];
    headView.backgroundColor = [UIColor whiteColor];
    
    // 文字
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, screenWidth-15, 20)];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor darkGrayColor];
    [headView addSubview:label];
    label.text = self.allAddressKeys[section];
    
    // line
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, 19, screenWidth, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [headView addSubview:lineView];
    
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0f;
}

#pragma mark - UITableViewDataSource
//创建右侧索引表，返回需要显示的索引表数组
- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.allAddressKeys;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.allAddressKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [(NSArray*)self.localAddressBook[self.allAddressKeys[section]] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *contactlistcellid = @"InviteJoinListViewCellidentifier";
    InviteJoinListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactlistcellid];
    if (cell == nil) {
        cell = [[InviteJoinListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contactlistcellid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellSelectBtnClicked:)];
        cell.contentView.userInteractionEnabled = YES;
        [cell.contentView addGestureRecognizer:tap];
        
    }
    AddressBook *book = [self.localAddressBook[self.allAddressKeys[indexPath.section]] objectAtIndex:indexPath.row];
    cell.portraitImg.image = book.head;
    cell.nameLabel.text = book.name;
    cell.numberLabel.text = book.phones.allValues.firstObject;
    cell.selecImage.tag =indexPath.row+1000;
    
    //判断selectedArray里面有没有当前这个数据
    if ([_selectedArray containsObject:book]) {
        cell.selecImage.image = [UIImage imageNamed:@"select_account_list_checked"];
    } else {
        cell.selecImage.image = [UIImage imageNamed:@"select_account_list_unchecked"];
    }
    return cell;
}

#pragma mark - BtnClick

-(void)returnClicked
{
    [self.navigationController popToViewController:self.backView animated:YES];
}

-(void)cellSelectBtnClicked:(UITapGestureRecognizer *)tap{
    
    CGPoint point = [tap locationInView:self.tableView];
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    UIImageView * selectimage = nil;
    for (UIView * view in tap.view.subviews) {
        if (view.tag >=indexPath.row+1000) {
            selectimage = (UIImageView *)view;
            break;
        }
    }
    
    AddressBook *book = [self.localAddressBook[self.allAddressKeys[indexPath.section]] objectAtIndex:indexPath.row];
    if ([book.phones.allValues.firstObject isEqualToString:[DemoGlobalClass sharedInstance].userName]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"不能邀请自己" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if ([_selectedArray containsObject:book]) {
        selectimage.image = [UIImage imageNamed:@"select_account_list_unchecked"];
        [_selectedArray removeObject:book];
    }
    else{
        selectimage.image = [UIImage imageNamed:@"select_account_list_checked"];
        [_selectedArray addObject:book];
    }
    countLabel.text = [NSString stringWithFormat:@"一共勾选了%d个人",(int)_selectedArray.count];
    if (_selectedArray.count == 0) {
        [inviteBtn setTitle:[NSString stringWithFormat:@"%@",_isDiscuss?@"邀请":@"下一步"] forState:UIControlStateNormal];
    } else {
        [inviteBtn setTitle:@"邀请" forState:UIControlStateNormal];
    }
}

-(void)inviteBtnClicked
{
    if (_selectedArray.count == 0) {
        if (_isDiscuss) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"讨论组没有邀请成员" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alert show];
            return;
        } else {
            ChatViewController * cvc = [[ChatViewController alloc]initWithSessionId:self.groupId];
            [self.navigationController setViewControllers:[NSArray arrayWithObjects:[self.navigationController.viewControllers objectAtIndex:0],cvc, nil] animated:YES];
            return;
        }
    }
    
    NSMutableArray * inviteArray = [[NSMutableArray alloc]init];
    for (AddressBook * book in _selectedArray) {
        NSString* phone = book.phones.allValues.firstObject;
        if (phone.length>0) {
            [inviteArray addObject:phone];
        }
    }
    NSInteger confirm;
    if (self.isGroupCreateSuccess && !_isDiscuss) {
        confirm = 2;
    } else {
        confirm = 1;
    }
    
    if (_isDiscuss && self.groupId.length == 0) {
        
        ECGroup * newgroup = [[ECGroup alloc] init];
        [_selectedArray enumerateObjectsUsingBlock:^(AddressBook *book, NSUInteger idx, BOOL * stop) {
            
            if (idx == 0) {
                newgroup.name = book.name;
            } else {
                newgroup.name = [NSString stringWithFormat:@"%@、%@",newgroup.name,book.name];
            }
        }];
        if (newgroup.name.length>50) {
            newgroup.name = [newgroup.name substringToIndex:50];
        }
        newgroup.isDiscuss = YES;
        
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"正在邀请";
        hud.removeFromSuperViewOnHide = YES;
        
        __weak __typeof(self)weakSelf = self;
        [[ECDevice sharedInstance].messageManager createGroup:newgroup completion:^(ECError *error, ECGroup *group) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (error.errorCode == ECErrorType_NoError) {
                group.isNotice = YES;
                [[IMMsgDBAccess sharedInstance] addGroupIDs:@[group]];
                
                [[ECDevice sharedInstance].messageManager inviteJoinGroup:group.groupId reason:@"" members:inviteArray confirm:confirm completion:^(ECError *error, NSString *groupId, NSArray *members) {
                    
                    [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                    if(error.errorCode ==ECErrorType_NoError) {
                        ChatViewController * cvc = [[ChatViewController alloc] initWithSessionId:groupId];
                        [strongSelf.navigationController setViewControllers:[NSArray arrayWithObjects:[strongSelf.navigationController.viewControllers objectAtIndex:0],cvc, nil] animated:YES];
                    } else {
                        NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                        [strongSelf showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
                    }
                }];
                
            } else {
                NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                [strongSelf showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
            }
        }];
    } else {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"正在邀请好友";
        hud.removeFromSuperViewOnHide = YES;
        
        __weak __typeof(self)weakSelf = self;
        [[ECDevice sharedInstance].messageManager inviteJoinGroup:self.groupId reason:@"" members:inviteArray confirm:confirm completion:^(ECError *error, NSString *groupId, NSArray *members) {
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            if(error.errorCode ==ECErrorType_NoError) {
                ChatViewController * cvc = [[ChatViewController alloc] initWithSessionId:strongSelf.groupId];
                [strongSelf.navigationController setViewControllers:[NSArray arrayWithObjects:[strongSelf.navigationController.viewControllers objectAtIndex:0],cvc, nil] animated:YES];
            } else {
                NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                [strongSelf showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
            }
        }];
    }
}

//Toast错误信息
-(void)showToast:(NSString *)message
{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

- (void)checkAddressBook:(NSString*)phone
{
    NSArray *keys = [NSArray arrayWithArray:self.localAddressBook.allKeys];
    for (NSString* key in keys) {
        NSMutableArray *arr = self.localAddressBook[key];
        for (AddressBook* address in arr) {
            NSArray* phones = [address.phones allValues];
            for (NSString *tePhone in phones) {
                if ([tePhone isEqualToString:phone]) {
                    [arr removeObject:address];
                    return;
                }
            }
        }
    }
}

//判断可选联系人个数
-(void)judgeArrayCount
{
    for (ECGroupMember * meb in _showTableView) {
        [self checkAddressBook:meb.memberId];
    }
    if (self.localAddressBook.allValues.count == 0) {
         UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alert.message = @"联系人列表为空";
        alert.tag = ECINVITE_ALERTERVIE_Contacts;
        [alert show];
    }
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ECINVITE_ALERTERVIE_Contacts) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self prepareUI];
    
}

@end
