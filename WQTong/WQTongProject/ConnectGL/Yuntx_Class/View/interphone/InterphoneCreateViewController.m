//
//  InviteJoinViewController.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/8.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "InterphoneCreateViewController.h"
#import "InterphoneCreateCell.h"
#import "ChatViewController.h"
#import "CommonTools.h"
#import "IntercomingViewController.h"

@interface InterphoneCreateViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *localAddressBook;
@property (nonatomic, strong) NSArray *allAddressKeys;
@property (nonatomic, strong) NSMutableArray *selectedArray;
@end

@implementation InterphoneCreateViewController {
    UITableView * _inviteTableView;
    NSMutableArray * _selectedArray;
    UILabel * countLabel;
    UIButton * createBtn;
}

#pragma mark - prepareUI
-(void)prepareUI
{
    CGFloat hight = [[UIScreen mainScreen] bounds].size.height;
    self.selectedArray = [NSMutableArray new];
    self.title = @"创建实时对讲";
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
    label.text = @"  请勾选要邀请加入实时对讲的联系人";
    label.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    [self.view addSubview:label];
    
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
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.tableView.frame = CGRectMake(0.0f, 50.0f, screenWidth, hight-110.0f);
        self.edgesForExtendedLayout =  UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else {
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
    
    createBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/2, hight-60-64, screenWidth/2, 60)];
//    [createBtn setBackgroundImage:[CommonTools createImageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
    createBtn.backgroundColor = themeColor;
    [createBtn addTarget:self action:@selector(createBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [createBtn setTitle:@"创建" forState:UIControlStateNormal];
    [self.view addSubview:createBtn];
    
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
    static NSString *contactlistcellid = @"InterphoneCreateCellidentifier";
    InterphoneCreateCell *cell = [tableView dequeueReusableCellWithIdentifier:contactlistcellid];
    if (cell == nil) {
        cell = [[InterphoneCreateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contactlistcellid];
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
    [self.navigationController popViewControllerAnimated:YES];
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
    if ([_selectedArray containsObject:book]) {
        selectimage.image = [UIImage imageNamed:@"select_account_list_unchecked"];
        [_selectedArray removeObject:book];
    }
    else{
        selectimage.image = [UIImage imageNamed:@"select_account_list_checked"];
        [_selectedArray addObject:book];
    }
    countLabel.text = [NSString stringWithFormat:@"一共勾选了%d个人",(int)_selectedArray.count];
    createBtn.enabled = (_selectedArray.count>0);
}

-(void)createBtnClicked {
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在创建实时对讲";
    hud.removeFromSuperViewOnHide = YES;
    
    NSMutableArray * inviteArray = [[NSMutableArray alloc]init];
    for (AddressBook * book in _selectedArray) {
        NSString* phone = book.phones.allValues.firstObject;
        if (phone.length>0) {
            [inviteArray addObject:phone];
        }
    }
    __weak __typeof(self)weakSelf = self;
    
    [[ECDevice sharedInstance].meetingManager createInterphoneMeetingWithMembers:inviteArray completion:^(ECError *error, NSString *meetingNumber) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        
        if (error.errorCode == ECErrorType_NoError && meetingNumber.length > 0) {
            
            [DemoGlobalClass sharedInstance].curinterphoneid = meetingNumber;
            BOOL isExist = NO;
            for (NSString *interphoneid in [DemoGlobalClass sharedInstance].interphoneArray) {
                if ([interphoneid isEqualToString:meetingNumber]) {
                    isExist = YES;
                    break;
                }
            }
            
            if (!isExist) {
                [[DemoGlobalClass sharedInstance].interphoneArray addObject:meetingNumber];
            }
            
            IntercomingViewController *intercoming = [[IntercomingViewController alloc] init];
            intercoming.curInterphoneId = meetingNumber;
            intercoming.navigationItem.hidesBackButton = YES;
            intercoming.backView = self.backView;
            [self.navigationController pushViewController:intercoming animated:YES];
            
        } else {
            
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
            [strongSelf showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
        }
    }];
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
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:@"所有联系人已经在聊天列表中" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self prepareUI];
    
}

@end
