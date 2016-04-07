//
//  LoginViewController.m
//  ECSDKDemo_OC
//
//  Created by Chenbinbin on 16/04/01.
//  Copyright (c) 2016年 广东华讯网络投资有限公司. All rights reserved.
//

#import "LoginViewController.h"
#import "ECDeviceHeaders.h"
#import "CommonTools.h"
#import "DemoGlobalClass.h"
#import "SessionViewController.h"
#import "SwitchIPViewController.h"

@interface LoginViewController()<UIAlertViewDelegate>

@end

@implementation LoginViewController {
    UITextField * _userName;
    UITextField * _password;
    UIButton * _nextBtn;
}

//界面布局
-(void)prepareUI {
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(changeIPAndAppToken:)];
    [titleView addGestureRecognizer:longGesture];
    
    UILabel	*titleText = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 80, 20)];
    [titleText setText:@"通讯录"];
    titleText.textColor = [UIColor whiteColor];
    [titleView addSubview:titleText];
    self.navigationItem.titleView = titleView;
 
    CGFloat frameY = 30.0f;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7){

        frameY = 90.0f;
    }
    
    UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"切换登录模式" style:UIBarButtonItemStyleDone target:self action:@selector(switchLoginAuthType)];
    [rightBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightBtn;

    _userName = [[UITextField alloc]initWithFrame:CGRectMake(15.0f, frameY, screenWidth-30, 44.0f)];
    _userName.borderStyle = UITextBorderStyleLine;
    _userName.placeholder = @"请输入您的手机号";
    _userName.keyboardType = UIKeyboardTypeNumberPad;
    _userName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"lasttimeuser"];
    [self.view addSubview:_userName];
    
    _password = [[UITextField alloc] initWithFrame:CGRectMake(15.0f, _userName.frame.origin.y+_userName.frame.size.height+15.0f, screenWidth-30, 44.0f)];
    _password.borderStyle = UITextBorderStyleLine;
    _password.placeholder = @"输入您的VoIP密码";
    _password.keyboardAppearance = UIKeyboardTypeASCIICapable;
    [self.view addSubview:_password];
    
    UIView *textfile = _password;
    if ([DemoGlobalClass sharedInstance].loginAuthType == LoginAuthType_NormalAuth) {
        _password.hidden = YES;
        textfile = _userName;
    } else {
        [DemoGlobalClass sharedInstance].loginAuthType = LoginAuthType_PasswordAuth;
        _userName.placeholder = @"输入您的VoIP账号";
    }
    _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextBtn.frame =CGRectMake(15, textfile.frame.origin.y+textfile.frame.size.height+15.0f, screenWidth-30, 45);
    _nextBtn.backgroundColor = themeColor;
    _nextBtn.layer.borderWidth = 1.0f;
    _nextBtn.layer.borderColor = (__bridge CGColorRef)themeColor;
    _nextBtn.layer.cornerRadius = 5;
    _nextBtn.layer.masksToBounds =YES;
    
    [_nextBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_nextBtn addTarget:self action:@selector(nextBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextBtn];
}

-(void)switchLoginAuthType {
    
    if ([DemoGlobalClass sharedInstance].loginAuthType == LoginAuthType_NormalAuth) {
        [DemoGlobalClass sharedInstance].loginAuthType = LoginAuthType_PasswordAuth;
    } else {
        [DemoGlobalClass sharedInstance].loginAuthType = LoginAuthType_NormalAuth;
    }
    
    UIView *textfile = _password;
    if ([DemoGlobalClass sharedInstance].loginAuthType == LoginAuthType_NormalAuth) {
        _password.hidden = YES;
        textfile = _userName;
        _userName.placeholder = @"请输入您的手机号";
    } else {
        _password.hidden = NO;
        [DemoGlobalClass sharedInstance].loginAuthType = LoginAuthType_PasswordAuth;
        _userName.placeholder = @"输入您的VoIP账号";
    }
    _nextBtn.frame =CGRectMake(10, textfile.frame.origin.y+textfile.frame.size.height+15.0f, 300, 45);
}

-(void)changeIPAndAppToken:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        SwitchIPViewController *view = [[SwitchIPViewController alloc] init];
        [self.navigationController pushViewController:view animated:YES];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [DemoGlobalClass sharedInstance].receiveData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [[DemoGlobalClass sharedInstance].receiveData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *receiveStr = [[NSString alloc]initWithData:[DemoGlobalClass sharedInstance].receiveData encoding:NSUTF8StringEncoding];
    NSLog(@"connectionDidFinishLoading receiverdata = %@", receiveStr);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}

//做完测试服务器上只配置了应用APPID:20150314000000110000000000000010；为了提高安全性，用户需要配置第三方服务器来保证apptoken不会泄露；
- (void)requestMd5 {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    //第一步，创建url
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://121.40.219.209:58001/platserver/authen/genSig?appid=%@&username=%@&timestamp=%@",[DemoGlobalClass sharedInstance].appKey, _userName.text, [dateFormatter stringFromDate:[NSDate date]]]];
    //第二步，创建请求
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    //第三步，连接服务器
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

-(void)nextBtnClicked {
    
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [_userName.text stringByTrimmingCharactersInSet:ws];
    
    //校验账号是否为手机号
//    NSString* errormessage = [LoginViewController valiMobile:trimmed];
    
    if (trimmed.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"账号为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (trimmed.length>0)
    {
        [self.view endEditing:YES];
        
        [[NSUserDefaults standardUserDefaults] setObject:trimmed forKey:@"lasttimeuser"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *userName = trimmed;
        NSString *password = [_password.text stringByTrimmingCharactersInSet:ws];
        
        ECLoginInfo * loginInfo = [[ECLoginInfo alloc] init];
        loginInfo.username = userName;
        loginInfo.userPassword = password;
        loginInfo.appKey = [DemoGlobalClass sharedInstance].appKey;
        loginInfo.appToken = [DemoGlobalClass sharedInstance].appToken;
        loginInfo.authType = [DemoGlobalClass sharedInstance].loginAuthType;
        loginInfo.mode = LoginMode_InputPassword;
        
        __weak typeof(self) weakself = self;
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:weakself.view animated:YES];
        hud.labelText = @"正在登录...";
        hud.removeFromSuperViewOnHide = YES;
        
        [DemoGlobalClass sharedInstance].userPassword = password;
        [[DeviceDBHelper sharedInstance] openDataBasePath:userName];
        [DemoGlobalClass sharedInstance].isHiddenLoginError = NO;
        [[ECDevice sharedInstance] login:loginInfo completion:^(ECError *error){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onConnected object:error];
            if (error.errorCode == ECErrorType_NoError) {
                [DemoGlobalClass sharedInstance].userName = userName;
            }
            
            __strong typeof(weakself) strongSelf = weakself;
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            
            //ChenBinbin add.
            [self LoginSuccess];
        }];
    }
    
   
}

//登录成功，页面跳转
-(void)LoginSuccess {
    
    MainViewController * lsvc = [[MainViewController alloc]init];
    [self.navigationController pushViewController:lsvc animated:YES];
//     [self presentViewController:[[UINavigationController alloc]initWithRootViewController: lsvc] animated:NO completion:nil];
   
}

//收起键盘
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

+ (NSString *)valiMobile:(NSString *)mobile {
    
    if (mobile.length < 11) {
        return @"手机号长度只能是11位";
    } else {
        /**
         * 移动号段正则表达式
         */
        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
        /**
         * 联通号段正则表达式
         */
        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
        /**
         * 电信号段正则表达式
         */
        NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
        BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
        BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
        BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
        
        if (isMatch1 || isMatch2 || isMatch3) {
            return nil;
        } else {
            return @"请输入正确的电话号码";
        }
    }
    
    return nil;
}
@end
