//
//  SettingViewController.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "SettingViewController.h"
#import "DemoGlobalClass.h"
#import "CommonTools.h"
#import "PersonInfoViewController.h"
#import "AboutViewController.h"


#define TAG_SwitchSound     100
#define TAG_SwitchShake     101
#define TAG_SwitchPlayEar   102

#define Group_Margin_Heigth 20.0f
#define Line_Margin_Heigth 1.0f

@interface SettingViewController()<UIAlertViewDelegate> {
    UILabel * _nameLabel;
    UIImageView * _headImageView;
     UILabel * _signLabel;
}
@end

@implementation SettingViewController
#pragma mark - prepareUI
-(void)prepareUI {
    CGFloat frameY = 0.0f;
    UIImageView * bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, frameY, screenWidth, 120.0f)];
    bgImageView.image = [UIImage imageNamed:@"personal_center_bg"];
    [self.view addSubview:bgImageView];
    
    _headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(20.0f, 20.0f, 70.0f, 70.0f)];
    [bgImageView addSubview:_headImageView];
    
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(120.0f, 20.0f, 150.0f, 30.0f)];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.font = [UIFont systemFontOfSize:20];
    [bgImageView addSubview:_nameLabel];
    
    UILabel * numLabel = [[UILabel alloc]initWithFrame:CGRectMake(120.0f, 40.0f, 150.0f, 30.0f)];
    numLabel.text = [DemoGlobalClass sharedInstance].userName;
    numLabel.textColor = [UIColor whiteColor];
    [bgImageView addSubview:numLabel];
    numLabel.backgroundColor = [UIColor clearColor];
    
    _signLabel = [[UILabel alloc]initWithFrame:CGRectMake(120.0f, 60.0f, 150.0f, 50.0f)];
    _signLabel.textColor = [UIColor whiteColor];
    _signLabel.backgroundColor = [UIColor clearColor];
    _signLabel.font = [UIFont systemFontOfSize:15.0f];
    _signLabel.numberOfLines = 0;
    [bgImageView addSubview:_signLabel];
    
    UIView *soundView = [self switchViewFrameY:(bgImageView.frame.origin.y+bgImageView.frame.size.height) andTag:TAG_SwitchSound];
    
    UIView *shakeView = [self switchViewFrameY:(Line_Margin_Heigth+soundView.frame.origin.y+soundView.frame.size.height) andTag:TAG_SwitchShake];
    
    UIView *playEarView = [self switchViewFrameY:(Group_Margin_Heigth+shakeView.frame.origin.y+shakeView.frame.size.height) andTag:TAG_SwitchPlayEar];

    UIButton * updateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [updateBtn setBackgroundImage:[CommonTools createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [updateBtn setBackgroundImage:[CommonTools createImageWithColor:[UIColor whiteColor]] forState:UIControlStateDisabled];
    updateBtn.frame =CGRectMake(0.0f, playEarView.frame.origin.y+playEarView.frame.size.height+Group_Margin_Heigth, screenWidth, 50.0f);
    [updateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [updateBtn addTarget:self action:@selector(updateBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:updateBtn];
    UILabel *updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 0.0f, 200.0f, 50)];
    updateLabel.text = [NSString stringWithFormat:@"当前版本(%@)",kSofeVer];
    updateLabel.backgroundColor = [UIColor clearColor];
    [updateBtn addSubview:updateLabel];
    updateBtn.enabled = [DemoGlobalClass sharedInstance].isNeedUpdate;

    if ([DemoGlobalClass sharedInstance].isNeedUpdate) {
        UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(260.0f, 23.0f, 40.0f, 14.0f)];
        newLabel.text = @"new";
        newLabel.font = [UIFont systemFontOfSize:13.0f];
        newLabel.textAlignment = NSTextAlignmentCenter;
        newLabel.backgroundColor = [UIColor redColor];
        newLabel.textColor = [UIColor whiteColor];
        newLabel.layer.cornerRadius = 7.0f;
        newLabel.layer.masksToBounds = YES;
        [updateBtn addSubview:newLabel];
    }
    
    UIButton * excOrderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [excOrderBtn setBackgroundImage:[CommonTools createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    excOrderBtn.frame =CGRectMake(0.0f, updateBtn.frame.origin.y+updateBtn.frame.size.height+Group_Margin_Heigth, screenWidth, 50.0f);
    [excOrderBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 0.0f, 200.0f, 50.0f)];
    updateLabel.text = @"退出客户端";
    updateLabel.backgroundColor = [UIColor clearColor];
    [excOrderBtn addSubview:updateLabel];
    excOrderBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [excOrderBtn addTarget:self action:@selector(excOrderBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:excOrderBtn];
    
    UIButton * excNowNumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    excNowNumBtn.frame =CGRectMake(0.0f, excOrderBtn.frame.origin.y+excOrderBtn.frame.size.height+Line_Margin_Heigth, screenWidth, 50.0f);
    [excNowNumBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 0.0f, 200.0f, 50.0f)];
    updateLabel.text = @"退出当前账号";
    updateLabel.backgroundColor = [UIColor clearColor];
    [excNowNumBtn addSubview:updateLabel];
    excNowNumBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [excNowNumBtn setBackgroundImage:[CommonTools createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [excNowNumBtn addTarget:self action:@selector(excNowNumBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:excNowNumBtn];
    
    UIButton *aboutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    aboutBtn.frame =CGRectMake(0.0f, excNowNumBtn.frame.origin.y+excNowNumBtn.frame.size.height+Group_Margin_Heigth, screenWidth, 50.0f);
    [aboutBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UILabel *aboutLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 0.0f, 200.0f, 50.0f)];
    aboutLabel.text = @"关于";
    aboutLabel.backgroundColor = [UIColor clearColor];
    [aboutBtn addSubview:aboutLabel];
    aboutBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [aboutBtn setBackgroundImage:[CommonTools createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [aboutBtn addTarget:self action:@selector(aboutBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:aboutBtn];
    
    self.title =@"设置";
    
    ((UIScrollView*)self.view).contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, aboutBtn.frame.origin.y+aboutBtn.frame.size.height+Group_Margin_Heigth);
    
    UIBarButtonItem * leftItem = nil;
    UIBarButtonItem * rightBtn = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
        rightBtn = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"all_top_icon_card"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(rightBtnClicked)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
        rightBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"all_top_icon_card"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBtnClicked)];
    }
    self.navigationItem.leftBarButtonItem =leftItem;
    self.navigationItem.rightBarButtonItem =rightBtn;
}

-(UIView*)switchViewFrameY:(CGFloat)frameY andTag:(NSInteger)tag {
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0.0f, frameY, screenWidth, 50.0f)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(30.0f, 5.0f, 200.0f, 40.0f)];
    label.textColor = [UIColor blackColor];
    [view addSubview:label];
    
    UISwitch * switchs = [[UISwitch alloc] init];//[[UISwitch alloc]initWithFrame:CGRectMake(250.0f, 10.0f, 50.0f, 40.0f)];
    switchs.tag = tag;
    [switchs addTarget:self action:@selector(switchsChanged:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:switchs];
    
    CGRect frame = switchs.frame;
    frame.origin.x = view.frame.size.width-switchs.frame.size.width-20.0f;
    frame.origin.y = (view.frame.size.height-switchs.frame.size.height)*0.5;
    switchs.frame = frame;
    
    switch (tag) {
        case TAG_SwitchPlayEar: {
            label.text = @"听筒模式";
            [switchs setOn:[DemoGlobalClass sharedInstance].isPlayEar];
            break;
        }
        case TAG_SwitchShake: {
            label.text = @"新消息震动";
            [switchs setOn:[DemoGlobalClass sharedInstance].isMessageShake];
            break;
        }
        case TAG_SwitchSound: {
            label.text = @"新消息声音";
            [switchs setOn:[DemoGlobalClass sharedInstance].isMessageSound];
            break;
        }
        default:
            break;
    }
    return view;
}

#pragma mark - BtnClick

-(void)returnClicked {
    [self.navigationController popToViewController:self.backView animated:YES];
}

-(void)rightBtnClicked {
    PersonInfoViewController *pivc = [[PersonInfoViewController alloc] init];
    pivc.isDisplayBack = YES;
    [self.navigationController pushViewController:pivc animated:YES];
}

-(void)switchsChanged:(UISwitch *)switches {
    switch (switches.tag) {
        case TAG_SwitchSound:
            [DemoGlobalClass sharedInstance].isMessageSound = switches.isOn;
            break;
        case TAG_SwitchShake:
            [DemoGlobalClass sharedInstance].isMessageShake = switches.isOn;
            break;
        case TAG_SwitchPlayEar:
            [DemoGlobalClass sharedInstance].isPlayEar = switches.isOn;
            break;
        default:
            break;
    }
}

-(void)updateBtnClicked {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://dwz.cn/F8pPd"]];
}

//退出客户端
-(void)excOrderBtnClicked {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"退出" message:@"确认要退出客户端吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 100;
    [alertView show];
}

//退出当前账号
-(void)excNowNumBtnClicked {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注销" message:@"确认要退出当前账号吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 101;
    [alertView show];
}

- (void)aboutBtnClicked {
    AboutViewController *controller = [[AboutViewController alloc] init];
    [self.navigationController pushViewController:controller animated:NO];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == 100) {
            exit(0);
        } else if (alertView.tag == 101) {

            MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hub.removeFromSuperViewOnHide = YES;
            hub.labelText = @"正在注销...";
            
            [[ECDevice sharedInstance] logout:^(ECError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                [DemoGlobalClass sharedInstance].userName = nil;
                
                [DemoGlobalClass sharedInstance].isLogin = NO;
                
                //为了页面的跳转，使用了该错误码，用户在使用过程中，可以自定义消息，或错误码值
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onConnected object:[ECError errorWithCode:10]];
                
//                [self.navigationController popToRootViewControllerAnimated:YES];
                
            }];
        }
    }
}

-(void)viewDidLoad {
    [super viewDidLoad];
    UIScrollView *myview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.view = myview;
    self.view.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.96f alpha:1.00f];
    [self prepareUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _nameLabel.text = [DemoGlobalClass sharedInstance].nickName;
    _headImageView.image = [DemoGlobalClass sharedInstance].sex==ECSexType_Female?[UIImage imageNamed:@"female_default_head_img"]:[UIImage imageNamed:@"male_default_head_img"];
    _signLabel.text = [DemoGlobalClass sharedInstance].sign;
}
@end
