//
//  SwitchIPViewController.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 15/11/5.
//  Copyright © 2015年 ronglian. All rights reserved.
//

#import "SwitchIPViewController.h"

@implementation SwitchIPViewController
-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIScrollView *myview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    myview.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height+100.0f);
    self.view = myview;
    myview.userInteractionEnabled = YES;
    self.view.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.96f alpha:1.00f];
    
    // 单击的 Recognizer
    UITapGestureRecognizer* singleRecognizer;
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTap:)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [self.view addGestureRecognizer:singleRecognizer];
    
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem =leftItem;
    
    UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"重置配置" style:UIBarButtonItemStyleDone target:self action:@selector(resetConfig)];
    [rightBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [rightBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    CGFloat marginX = 10.0f;
    CGFloat marginY = 10.0f;
    CGFloat heigth = 30.0f;
    CGFloat wigth = 300.0f;
    NSArray *placeHolderArr = @[@"Connect IP",@"Connect Port",@"LVS IP",@"LVS Port", @"File IP",@"File Port", @"APP ID",@"APP Token"];
    NSInteger i=0;
    for (; i<placeHolderArr.count; i++) {
        UITextField *text = [[UITextField alloc] initWithFrame:CGRectMake(marginX, marginX+(marginY+heigth)*i, wigth, heigth)];
        text.tag = 100+i;
        text.keyboardType = UIKeyboardTypeASCIICapable;
        text.borderStyle = UITextBorderStyleRoundedRect;
        text.placeholder = placeHolderArr[i];
        [self.view addSubview:text];
    }
    
    cip_textfield = (UITextField*)[self.view viewWithTag:100];
    cport_textfield = (UITextField*)[self.view viewWithTag:101];
    lip_textfield = (UITextField*)[self.view viewWithTag:102];
    lport_textfield = (UITextField*)[self.view viewWithTag:103];
    fip_textfield = (UITextField*)[self.view viewWithTag:104];
    fport_textfield = (UITextField*)[self.view viewWithTag:105];
    key_textfield = (UITextField*)[self.view viewWithTag:106];
    token_textfield = (UITextField*)[self.view viewWithTag:107];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10.0f, marginX+(marginY+heigth)*i, 90.0f, heigth);
    [button setTitle:@"设置IP" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"select_account_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(setIPConfig) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(110.0f, marginX+(marginY+heigth)*i, 90.0f, heigth);
    [button setTitle:@"设置APP" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"select_account_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(setAPPConfig) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(210.0f, marginX+(marginY+heigth)*i, 90.0f, heigth);
    [button setTitle:@"设置全部" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"select_account_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(setAllConfig) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)SingleTap:(UITapGestureRecognizer*)recognizer {
    [self.view endEditing:YES];
}

- (void)returnClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetConfig {
    [[DemoGlobalClass sharedInstance] resetResourceServer];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设置成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

-(void)setIPConfig {
    
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if ([cip_textfield.text stringByTrimmingCharactersInSet:ws].length==0
        || [cport_textfield.text stringByTrimmingCharactersInSet:ws].length == 0
        || [lip_textfield.text stringByTrimmingCharactersInSet:ws].length == 0
        || [lport_textfield.text stringByTrimmingCharactersInSet:ws].length == 0
        || [fip_textfield.text stringByTrimmingCharactersInSet:ws].length == 0
        || [fport_textfield.text stringByTrimmingCharactersInSet:ws].length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"检查输入内容" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [[DemoGlobalClass sharedInstance] setConfigData:[cip_textfield.text stringByTrimmingCharactersInSet:ws] :[cport_textfield.text stringByTrimmingCharactersInSet:ws] :[lip_textfield.text stringByTrimmingCharactersInSet:ws] :[lport_textfield.text stringByTrimmingCharactersInSet:ws] :[fip_textfield.text stringByTrimmingCharactersInSet:ws] :[fport_textfield.text stringByTrimmingCharactersInSet:ws]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设置成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

-(void)setAPPConfig {
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if ( [key_textfield.text stringByTrimmingCharactersInSet:ws].length == 0
        || [token_textfield.text stringByTrimmingCharactersInSet:ws].length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"检查输入内容" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [[DemoGlobalClass sharedInstance] setAppKey:[key_textfield.text stringByTrimmingCharactersInSet:ws] AndAppToken:[token_textfield.text stringByTrimmingCharactersInSet:ws]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设置成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

-(void)setAllConfig {
    
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if ([cip_textfield.text stringByTrimmingCharactersInSet:ws].length==0
        || [cport_textfield.text stringByTrimmingCharactersInSet:ws].length == 0
        || [lip_textfield.text stringByTrimmingCharactersInSet:ws].length == 0
        || [lport_textfield.text stringByTrimmingCharactersInSet:ws].length == 0
        || [fip_textfield.text stringByTrimmingCharactersInSet:ws].length == 0
        || [fport_textfield.text stringByTrimmingCharactersInSet:ws].length == 0
        || [key_textfield.text stringByTrimmingCharactersInSet:ws].length == 0
        || [token_textfield.text stringByTrimmingCharactersInSet:ws].length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"检查输入内容" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [[DemoGlobalClass sharedInstance] setConfigData:[cip_textfield.text stringByTrimmingCharactersInSet:ws] :[cport_textfield.text stringByTrimmingCharactersInSet:ws] :[lip_textfield.text stringByTrimmingCharactersInSet:ws] :[lport_textfield.text stringByTrimmingCharactersInSet:ws] :[fip_textfield.text stringByTrimmingCharactersInSet:ws] :[fport_textfield.text stringByTrimmingCharactersInSet:ws]];
    
    [[DemoGlobalClass sharedInstance] setAppKey:[key_textfield.text stringByTrimmingCharactersInSet:ws] AndAppToken:[token_textfield.text stringByTrimmingCharactersInSet:ws]];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设置成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}
@end
