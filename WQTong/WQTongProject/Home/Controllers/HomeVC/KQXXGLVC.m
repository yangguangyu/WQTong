//
//  KQXXGLViewController.m
//  WQTong
//
//  Created by ChenBinbin on 16/3/26.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "KQXXGLVC.h"


@interface KQXXGLVC ()

@property (nonatomic, strong) NSMutableArray *labelListArray;

@end

@implementation KQXXGLVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initUI];
}

- (void)initUI {
    
   UIImageView *themeImgView = [[UIImageView alloc]init];
   themeImgView.frame = CGRectMake(0, 64, screenWidth, 150);
   themeImgView.image = [UIImage imageNamed:@"tree.png"];
  
   [self.view addSubview:themeImgView];
    
    KQXXView *kQXXView = [[KQXXView alloc]initWithFrame:(CGRect){0,themeImgView.frame.size.height+themeImgView.frame.origin.y,screenWidth,screenHeiht}];
    kQXXView.delegate = self;
   [self.view addSubview:kQXXView];
    
}

- (void)initData {
    
    _labelListArray = [[NSMutableArray alloc]init];
    //可以加多天气，日历，开发中
    _labelListArray = [NSMutableArray arrayWithObjects:@"考勤打卡",@"考勤查询",@"历史轨迹",@"通讯录",nil];
}

- (void)viewAction:(NSString *)subViewIndex {
    
    if ([subViewIndex isEqualToString:@"subView1"]) {
     
        //考勤打卡
        [self performSegueWithIdentifier:@"KQDKVCSegue" sender:self];
    }
    
    if ([subViewIndex isEqualToString:@"subView2"]) {
        
        //考勤查询
        [self performSegueWithIdentifier:@"KQCXVCSegue" sender:self];
    }

    if ([subViewIndex isEqualToString:@"subView3"]) {
        
        //历史轨迹
        [self performSegueWithIdentifier:@"OldTrackingVCSegue" sender:self];
    }
    
    if ([subViewIndex isEqualToString:@"subView4"]) {
        
        //通讯录
        
        //是否有登录信息
        [DemoGlobalClass sharedInstance].isAutoLogin = [self getLoginInfo];
        if ([DemoGlobalClass sharedInstance].isAutoLogin) {
            
            //打开本地数据库
            [[DeviceDBHelper sharedInstance] openDataBasePath:[DemoGlobalClass sharedInstance].userName];
            [self showTXLMaster];
            
        } else {
            
            [self showTXLLogin];
        }

    }

    
    if ([subViewIndex isEqualToString:@"subView5"]) {
        
        NSLog(@"5");
        //定时上传
        [self performSegueWithIdentifier:@"TimerUploadVCSegue" sender:self];
    }

    
}

- (BOOL)getLoginInfo {
    
    NSString *loginInfo = [DemoGlobalClass sharedInstance].userName;
    if (loginInfo.length>0) {
        return YES;
    }
    return NO;
}

//通讯录登录
- (void)showTXLLogin {
    
    UIStoryboard * storyBoard = [UIStoryboard
                                 storyboardWithName:@"Main" bundle:nil];
   
    UIViewController *vc2 = [storyBoard instantiateViewControllerWithIdentifier:@"LoginStoryboardID"];
    [self presentViewController:[[UINavigationController alloc]initWithRootViewController:vc2] animated:NO completion:nil];
}

//通讯录主页面
- (void)showTXLMaster {

    UIStoryboard * storyBoard = [UIStoryboard
                                 storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc2 = [storyBoard instantiateViewControllerWithIdentifier:@"MainStoryboardID"];
    [self presentViewController:[[UINavigationController alloc]initWithRootViewController:vc2] animated:NO completion:nil];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
