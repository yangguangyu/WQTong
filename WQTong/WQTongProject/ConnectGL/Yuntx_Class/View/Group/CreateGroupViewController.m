//
//  CreateGroupViewController.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/8.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "CreateGroupViewController.h"
#import "InviteJoinViewController.h"
#import "CommonTools.h"
#import "GroupListViewController.h"
@interface CreateGroupViewController ()
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIScrollView *myScrollView;
@property (nonatomic, strong) UILabel *label5;
@end

@implementation CreateGroupViewController
{
    UITextField * _groupName;
    UITextField * _groupNotice;
    UITextField * _groupProvince;
    UITextField * _groupCity;
    
    UIImageView *_publicGroup;
    UIImageView *_authGroup;
    UIImageView *_privateGroup;
    
    NSInteger _groupMode;
    NSInteger _type;
}

#pragma mark - prepareUI
-(void)prepareUI
{
    self.title = [NSString stringWithFormat:@"建立新%@",_isDiscussOrGroupName];
    
    CGFloat frameY = 0.0f;
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        frameY = 64.0f;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    } else {
        frameY = 0.0f;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem =leftItem;
    
    _groupMode = 1;
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, frameY+16.0f, 35.0f, 30.0f)];
    label1.text = @"名称:";
    [self.view addSubview:label1];
    label1.font = [UIFont systemFontOfSize:14.0f];
    _groupName = [[UITextField alloc] initWithFrame:CGRectMake(50.0f, frameY+16.0f, screenWidth-50*2, 30.0f)];
    _groupName.placeholder = [NSString stringWithFormat:@"%@名称",_isDiscussOrGroupName];
    _groupName.borderStyle = UITextBorderStyleRoundedRect;
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, frameY+66.0f, 35.0f, 30.0f)];
    label2.text = @"公告:";
    [self.view addSubview:label2];
    label2.font = [UIFont systemFontOfSize:14.0f];
    _groupNotice = [[UITextField alloc]initWithFrame:CGRectMake(50.0f, frameY+66.0f, screenWidth-50*2, 30.0f)];
    _groupNotice.placeholder = [NSString stringWithFormat:@"%@公告（选填）",_isDiscussOrGroupName];
    _groupNotice.borderStyle = UITextBorderStyleRoundedRect;
    
    [self.view addSubview:_groupName];
    [self.view addSubview:_groupNotice];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, frameY+116.0f, 35.0f, 30.0f)];
    label3.text = @"省份:";
    [self.view addSubview:label3];
    label3.font = [UIFont systemFontOfSize:14.0f];
    _groupProvince = [[UITextField alloc] initWithFrame:CGRectMake(50.0f, frameY+116.0f, screenWidth-50*2, 30.0f)];
    _groupProvince.borderStyle = UITextBorderStyleRoundedRect;
    _groupProvince.placeholder =@"请输入省份（选填）";
    [self.view addSubview:_groupProvince];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, frameY+166.0f, 35.0f, 30.0f)];
    label4.text = @"城市:";
    [self.view addSubview:label4];
    label4.font = [UIFont systemFontOfSize:14.0f];
    _groupCity = [[UITextField alloc] initWithFrame:CGRectMake(50.0f, frameY+166.0f, screenWidth-50*2, 30.0f)];
    _groupCity.borderStyle = UITextBorderStyleRoundedRect;
    _groupCity.placeholder =@"请输入城市（选填）";
    [self.view addSubview:_groupCity];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(80.0f, frameY+206.0f, screenWidth-160, 30.0f)];
    [button setTitle:@"选择类型" forState:UIControlStateNormal];
    [button setBackgroundColor:themeColor];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect:button.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
    maskLayer2.frame = button.bounds;
    maskLayer2.path = maskPath2.CGPath;
    button.layer.mask = maskLayer2;

    
    UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(120.0f, frameY+246.0f, screenWidth-120*2, 30.0f)];
    label5.text = @"类型";
    label5.backgroundColor = themeColor;
    label5.textAlignment = NSTextAlignmentCenter;
    label5.textColor = [UIColor whiteColor];
    label5.layer.cornerRadius = 5;
    label5.layer.masksToBounds = YES;
    [self.view addSubview:label5];
    label5.font = [UIFont systemFontOfSize:16.0f];
    self.label5 = label5;
    
    if (self.isDiscuss == NO) {
        
        {
            _publicGroup = [[UIImageView alloc] initWithFrame:CGRectMake(90.0f*scaleModulus, frameY+286.0f, 20.0f, 20.0f)];
            _publicGroup.image = [UIImage imageNamed:@"select_account_list_unchecked"];
            [_publicGroup setHighlightedImage:[UIImage imageNamed:@"select_account_list_checked"]];
            [self.view addSubview:_publicGroup];
            
            UILabel *pLabel = [[UILabel alloc] initWithFrame:CGRectMake(_publicGroup.frame.size.width+_publicGroup.frame.origin.x, frameY+286.0f, 60.0f, 20.0f)];
            pLabel.text = @"公开群组";
            pLabel.textColor = [UIColor blackColor];
            pLabel.font = [UIFont systemFontOfSize:13.0f];
            [self.view addSubview:pLabel];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(_publicGroup.frame.origin.x, _publicGroup.frame.origin.y, _publicGroup.frame.size.width+pLabel.frame.size.width, _publicGroup.frame.size.height);
            [button addTarget:self action:@selector(chageModeBtn:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = 1;
            [self.view addSubview:button];
        }
        
        {
            _authGroup = [[UIImageView alloc] initWithFrame:CGRectMake(190.0f*scaleModulus, frameY+286.0f, 20.0f, 20.0f)];
            _authGroup.image = [UIImage imageNamed:@"select_account_list_unchecked"];
            [_authGroup setHighlightedImage:[UIImage imageNamed:@"select_account_list_checked"]];
            [self.view addSubview:_authGroup];
            
            UILabel *pLabel = [[UILabel alloc] initWithFrame:CGRectMake(_authGroup.frame.size.width+_authGroup.frame.origin.x, frameY+286.0f, 60.0f, 20.0f)];
            pLabel.text = @"验证群组";
            pLabel.textColor = [UIColor blackColor];
            pLabel.font = [UIFont systemFontOfSize:13.0f];
            [self.view addSubview:pLabel];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(_authGroup.frame.origin.x, _authGroup.frame.origin.y, _authGroup.frame.size.width+pLabel.frame.size.width, _authGroup.frame.size.height);
            [button addTarget:self action:@selector(chageModeBtn:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = 2;
            [self.view addSubview:button];
        }
    }
    /*
    {
        _privateGroup = [[UIImageView alloc] initWithFrame:CGRectMake(215.0f, 175.0f, 20.0f, 20.0f)];
        _privateGroup.image = [UIImage imageNamed:@"select_account_list_unchecked"];
        [_privateGroup setHighlightedImage:[UIImage imageNamed:@"select_account_list_checked"]];
        [self.view addSubview:_privateGroup];
        
        UILabel *pLabel = [[UILabel alloc] initWithFrame:CGRectMake(_privateGroup.frame.size.width+_privateGroup.frame.origin.x, 175.0f, 60.0f, 20.0f)];
        pLabel.text = @"私有群组";
        pLabel.font = [UIFont systemFontOfSize:13.0f];
        [self.view addSubview:pLabel];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(_privateGroup.frame.origin.x, _privateGroup.frame.origin.y, _privateGroup.frame.size.width+pLabel.frame.size.width, _privateGroup.frame.size.height);
        [button addTarget:self action:@selector(chageModeBtn:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 3;
        [self.view addSubview:button];
    }
     */
    
    [self refreshModeCheckImage];
    
    UIButton *createGroupBtn = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, frameY+326.0f, screenWidth-10*2, 44.0f)];
//    [createGroupBtn setBackgroundImage:[CommonTools createImageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
    createGroupBtn.backgroundColor = themeColor;
    [createGroupBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [createGroupBtn setTitle:@"创建" forState:UIControlStateNormal];
    [createGroupBtn addTarget:self action:@selector(createGroupBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createGroupBtn];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:createGroupBtn.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = createGroupBtn.bounds;
    maskLayer.path = maskPath.CGPath;
    createGroupBtn.layer.mask = maskLayer;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide)];
    [self.view addGestureRecognizer:tap];
}

#pragma mark - BtnClick

-(void)selectType:(id)sender {
    
    [self.view endEditing:YES];
    if (self.menuView == nil) {
        
        self.menuView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ClearView)];
        [self.menuView addGestureRecognizer:tap];
    
        NSArray *menuTitles = @[@"同学", @"朋友", @"同事", @"亲友", @"闺蜜", @"粉丝",@"基友", @"驴友", @"出国", @"家政",@"小区", @"比赛", @"其他"];
        CGFloat menuHeight = 40.0f;
        CGFloat menuWight = 150.0f;
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(85.0f, 120.0f, menuWight, menuHeight*8)];
        scrollView.contentSize = CGSizeMake(0,menuTitles.count *menuHeight);
        scrollView.backgroundColor = [UIColor grayColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.bounces = NO;
        scrollView.scrollsToTop = YES;
        [self.menuView addSubview :scrollView];
        self.myScrollView = scrollView;
        
        for (NSString* title in menuTitles) {
            NSUInteger index = [menuTitles indexOfObject:title];
            UIButton * menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            menuBtn.tag = index+1;
            menuBtn.frame = CGRectMake(0.0f, menuHeight*index, menuWight, menuHeight);
            [menuBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [menuBtn setTitle:title forState:UIControlStateNormal];
            [menuBtn addTarget:self action:@selector(menuListBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView addSubview:menuBtn];
        }    }
    
    if (self.menuView.superview == nil) {
        [self.view.window addSubview:self.menuView];
    }
}

- (void)menuListBtnClicked:(UIButton *)sender {
    [self ClearView];
    UIButton *button = (UIButton*)sender;
    NSString *btnTitle = [button titleForState:UIControlStateNormal];
    self.label5.text = btnTitle;
    _type = button.tag;
}

-(void)ClearView {
    [self.view endEditing:YES];
    [self.menuView removeFromSuperview];
}

-(void)chageModeBtn:(id)sender {
    _groupMode = ((UIButton*)sender).tag;
    [self refreshModeCheckImage];
}

-(void)refreshModeCheckImage {
    _publicGroup.highlighted = NO;
    _privateGroup.highlighted = NO;
    _authGroup.highlighted = NO;
    if (_groupMode==1) {
        _publicGroup.highlighted = YES;
    } else if(_groupMode==2) {
        _authGroup.highlighted = YES;
    } else {
        _privateGroup.highlighted = YES;
    }
}

-(void)returnClicked {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)createGroupBtn {
    
    if (_groupName.text.length <= 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"请输入名称" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    _groupProvince.text = [_groupProvince.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _groupCity.text = [_groupCity.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger maxLength = 50;
    if (_groupProvince.text.length > maxLength) {
        _groupProvince.text = [_groupProvince.text substringToIndex:maxLength];
    }
    
    if (_groupCity.text.length>maxLength) {
        _groupCity.text = [_groupCity.text substringToIndex:maxLength];
    }
    
    [self.view endEditing:YES];
    [_groupName resignFirstResponder];
    [_groupNotice resignFirstResponder];
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = [NSString stringWithFormat:@"正在创建%@",_isDiscussOrGroupName];
    hud.removeFromSuperViewOnHide = YES;
    
    ECGroup * newgroup = [[ECGroup alloc] init];
    newgroup.name = _groupName.text;
    newgroup.declared = _groupNotice.text;
    if (self.isDiscuss == NO) {
        newgroup.mode = _groupMode;
    } else {
        newgroup.isDiscuss = self.isDiscuss;
    }
    newgroup.province = _groupProvince.text;
    newgroup.city = _groupCity.text;
    if (![_label5.text isEqualToString:@"类型"]) {
        newgroup.type = _type;
        
    }
    
    __weak __typeof(self)weakSelf = self;
    [[ECDevice sharedInstance].messageManager createGroup:newgroup completion:^(ECError *error, ECGroup *group) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        if (error.errorCode == ECErrorType_NoError) {
            
            group.isNotice = YES;
            [[IMMsgDBAccess sharedInstance] addGroupIDs:@[group]];
            
            InviteJoinViewController * ijvc = [[InviteJoinViewController alloc]init];
            ijvc.groupId = group.groupId;
            ijvc.isDiscuss = NO;
            ijvc.isGroupCreateSuccess = NO;
            ijvc.backView = self;
            [strongSelf.navigationController pushViewController:ijvc animated:YES];

        } else {
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
            [strongSelf showToast:[NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail]];
        }
    }];
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

//收起键盘
-(void)keyboardHide {
    
    [self.view endEditing:YES];
    [self.menuView removeFromSuperview];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self prepareUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
