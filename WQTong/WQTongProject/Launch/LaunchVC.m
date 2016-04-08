//
//  LaunchVC.m
//  WQTong
//
//  Created by ChenBinbin on 16/3/25.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "LaunchVC.h"

@interface LaunchVC ()

@property (nonatomic, strong) UITextField *nameTextField;

@property (nonatomic, strong) UITextField *passwordTextField;

@property (nonatomic, strong) UIButton *loginButton;

@end

@implementation LaunchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title =@"外勤通";
    
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(successLoginAction:)
                                                 name:@"successLoginAction"
                                               object:nil];
}

- (void)initUI {
    
    //初始化文本框和登录按钮
     _nameTextField = [[UITextField alloc]initWithFrame:(CGRect){30,80,screenWidth-60,44}];
     _nameTextField.placeholder = @"请输入您的手机号";
     _nameTextField.font = [UIFont fontWithName:@"Helvetica" size:15];
     _nameTextField.layer.cornerRadius=5.0f;
     _nameTextField.layer.masksToBounds=YES;
     _nameTextField.layer.borderColor= [themeColor CGColor];;
     _nameTextField.layer.borderWidth= 1.0f;
     [_nameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];//去掉键盘输入时默认字母为大写
     [_nameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    
     _passwordTextField = [[UITextField alloc]initWithFrame:(CGRect){30,_nameTextField.frame.size.height+_nameTextField.frame.origin.y+10,screenWidth-30*2,44}];
     _passwordTextField.placeholder = @"请输入您的密码";
     _passwordTextField.font = [UIFont fontWithName:@"Helvetica" size:15];
     _passwordTextField.layer.cornerRadius=5.0f;
     _passwordTextField.layer.masksToBounds=YES;
     _passwordTextField.layer.borderColor= [themeColor CGColor];;
     _passwordTextField.layer.borderWidth= 1.0f;
     [_passwordTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
     [_passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];

     _loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     _loginButton.frame = CGRectMake(30, _passwordTextField.frame.size.height+_passwordTextField.frame.origin.y+10, screenWidth-30*2, 44);
     [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
     [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     _loginButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
     _loginButton.backgroundColor = themeColor;
     _loginButton.layer.borderWidth = 2;
     _loginButton.layer.borderColor = (__bridge CGColorRef _Nullable)(themeColor);
     _loginButton.layer.masksToBounds = YES;
    
     UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect: _loginButton.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
     CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
     maskLayer2.frame =   _loginButton.bounds;
     maskLayer2.path = maskPath2.CGPath;
     _loginButton.layer.mask = maskLayer2;

     [_loginButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        
         [self initWebUserData];
         
     }];

     [self.view addSubview:_nameTextField];
     [self.view addSubview:_passwordTextField];
     [self.view addSubview:_loginButton];
}


- (void)initWebUserData {
    
    //加载网络用户数据
    LaunchRequestManager *requestHelper =[[LaunchRequestManager alloc]init];
    requestHelper.userName = _nameTextField;
    requestHelper.passWord = _passwordTextField;
    [requestHelper setUpRequest];
}

#pragma mark - 加载成功

- (void)successLoginAction:(NSNotification *)notification{
    
    [self.view makeToast:@"登录成功" duration:1.0 position:@"center"];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"key_isLogined"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self.delegate LaunchVCDelegate:self];
        
    });
    
}

#pragma mark - 加载失败

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
