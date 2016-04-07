//
//  PersonInfoViewController.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 15/3/24.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "PersonInfoViewController.h"

@interface PersonInfoViewController ()<UITextFieldDelegate>

@end

@implementation PersonInfoViewController {
    UITextField * _nickNameField;
    
    UIImageView *_sexMale;
    UIImageView *_sexFemale;
    
    UIDatePicker *_datepicker;
    UITextField *_birthField;
    UITextView *_signField;
    
    ECSexType _sex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人信息";
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    if (self.isDisplayBack) {
        UIBarButtonItem * leftItem = nil;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
        } else {
            leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
        }
        self.navigationItem.leftBarButtonItem =leftItem;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 74.0f, 35.0f, 30.0f)];
    label.text = @"昵称:";
    [self.view addSubview:label];
    label.font = [UIFont systemFontOfSize:14.0f];
    
    _nickNameField = [[UITextField alloc] initWithFrame:CGRectMake(70.0f, 74.0f, 210.0f, 30.0f)];
    _nickNameField.borderStyle = UITextBorderStyleRoundedRect;
    _nickNameField.placeholder =@"请输入昵称";
    _nickNameField.text = [DemoGlobalClass sharedInstance].nickName;
    [self.view addSubview:_nickNameField];

    label = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 115.0f, 35.0f, 20.0f)];
    label.text = @"性别:";
    [self.view addSubview:label];
    label.font = [UIFont systemFontOfSize:14.0f];
    
    _sex = [DemoGlobalClass sharedInstance].sex;
    
    {
        _sexMale = [[UIImageView alloc] initWithFrame:CGRectMake(75.0f, 115.0f, 20.0f, 20.0f)];
        _sexMale.image = [UIImage imageNamed:@"select_account_list_unchecked"];
        [_sexMale setHighlightedImage:[UIImage imageNamed:@"select_account_list_checked"]];
        [self.view addSubview:_sexMale];
        
        UILabel *pLabel = [[UILabel alloc] initWithFrame:CGRectMake(_sexMale.frame.size.width+_sexMale.frame.origin.x+2, _sexMale.frame.origin.y, 30.0f, 20.0f)];
        pLabel.text = @"男";
        pLabel.font = [UIFont systemFontOfSize:13.0f];
        [self.view addSubview:pLabel];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(_sexMale.frame.origin.x, _sexMale.frame.origin.y, _sexMale.frame.size.width+pLabel.frame.size.width, _sexMale.frame.size.height);
        [button addTarget:self action:@selector(chageModeBtn:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1;
        [self.view addSubview:button];
    }
    
    {
        _sexFemale = [[UIImageView alloc] initWithFrame:CGRectMake(135.0f, _sexMale.frame.origin.y, 20.0f, _sexMale.frame.size.height)];
        _sexFemale.image = [UIImage imageNamed:@"select_account_list_unchecked"];
        [_sexFemale setHighlightedImage:[UIImage imageNamed:@"select_account_list_checked"]];
        [self.view addSubview:_sexFemale];
        
        UILabel *pLabel = [[UILabel alloc] initWithFrame:CGRectMake(_sexFemale.frame.size.width+_sexFemale.frame.origin.x+2, _sexFemale.frame.origin.y, 30.0f, 20.0f)];
        pLabel.text = @"女";
        pLabel.font = [UIFont systemFontOfSize:13.0f];
        [self.view addSubview:pLabel];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(_sexFemale.frame.origin.x, _sexFemale.frame.origin.y, _sexFemale.frame.size.width+pLabel.frame.size.width, _sexFemale.frame.size.height);
        [button addTarget:self action:@selector(chageModeBtn:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 2;
        [self.view addSubview:button];
    }
    
    [self refreshModeCheckImage];
    
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, _sexMale.frame.origin.y+_sexMale.frame.size.height+20.0f, 90.0f, 20.0f)];
    label.text = @"选取生日:";
    [self.view addSubview:label];
    label.font = [UIFont systemFontOfSize:14.0f];
    
    UITextField *birthField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame)-15.0f, label.frame.origin.y-5.0f, 150.0f, 30.0f)];
    birthField.delegate = self;
    birthField.borderStyle = UITextBorderStyleRoundedRect;
    birthField.placeholder = @"请输入生日";
    birthField.text = [DemoGlobalClass sharedInstance].birth;
    _birthField = birthField;
    [self.view addSubview:_birthField];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, _sexMale.frame.origin.y+_sexMale.frame.size.height+70.0f, 90.0f, 20.0f)];
    label.text = @"个性签名";
    label.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:label];
    
    _signField = [[UITextView alloc] initWithFrame:CGRectMake(30.0f, CGRectGetMaxY(label.frame), self.view.frame.size.width-30.0f*2, 70)];
    _signField.layer.borderColor = [UIColor grayColor].CGColor;
    _signField.layer.borderWidth = 1.0f;
    _signField.font = [UIFont systemFontOfSize:15.0f];
    _signField.text = [DemoGlobalClass sharedInstance].sign;
    [self.view addSubview:_signField];
    
    UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveBtnClicked)];
    [rightBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [rightBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem =rightBtn;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_datepicker removeFromSuperview];
    _datepicker = nil;
}

// 获取日期键盘的日期
- (NSString *)getDateStr:(NSDate *)date
{
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [dateFormate stringFromDate:date];
    return dateStr;
}

- (NSDate *)getDate:(NSString *)dateStr
{
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormate dateFromString:dateStr];
    return date;
}
#pragma mark -UITextFiedDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.view endEditing:YES];
    [_datepicker removeFromSuperview];
    _datepicker = nil;
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self keyboardHide];
    _datepicker = [[UIDatePicker alloc] init];
    _datepicker.datePickerMode = UIDatePickerModeDate;
    _datepicker.frame = CGRectMake(0, self.view.frame.size.height, 0, 0);
    [[UIApplication sharedApplication].keyWindow addSubview:_datepicker];
    [UIView animateWithDuration:0.25f animations:^{
        _datepicker.frame = CGRectMake(0, 352, 320, 216);
    }];
    _birthField.text = [self getDateStr:_datepicker.date];
    [_datepicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
}

- (void)changeDate:(id)sender {
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    NSDate *date = datePicker.date;
    _birthField.text = [self getDateStr:date];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _birthField.text = [self getDateStr:_datepicker.date];
    [UIView animateWithDuration:0.25f animations:^{
        [_datepicker removeFromSuperview];
        _datepicker = nil;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)keyboardHide {
    [self.view endEditing:YES];
    if (_datepicker != nil) {
        _birthField.text = [self getDateStr:_datepicker.date];
        [_datepicker removeFromSuperview];
        _datepicker = nil;
    }
}

-(void)chageModeBtn:(id)sender {
    _sex = ((UIButton*)sender).tag;
    [self refreshModeCheckImage];
}

-(void)refreshModeCheckImage {
    _sexFemale.highlighted = NO;
    _sexMale.highlighted = NO;

    if (_sex==ECSexType_Male) {
        _sexMale.highlighted = YES;
    } else if (_sex==ECSexType_Female) {
        _sexFemale.highlighted = YES;
    }
}

-(void)returnClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveBtnClicked {
    [_datepicker removeFromSuperview];
    _datepicker = nil;
    ECSexType aSex = _sex;
    NSString* nickName = _nickNameField.text;
    if (nickName.length <= 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"请输入昵称" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (aSex != ECSexType_Female && aSex != ECSexType_Male) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"请选择性别" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [self.view endEditing:YES];
    
    NSString *dateStr = nil;
    if (_birthField.text.length >0) {
       dateStr = _birthField.text;
    } else {
        dateStr = [DemoGlobalClass sharedInstance].birth;
    }
    
    __weak typeof(self) weakself = self;
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.margin = 10.0f;
    hud.yOffset = 50;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2.0f];
    NSString *curDteStr = [self getDateStr:[NSDate date]];
    if ([dateStr compare:curDteStr] == NSOrderedDescending) {
        hud.labelText = @"你选择的日期大于当前日期，请重新选择";
        hud.labelFont = [UIFont systemFontOfSize:14.0f];
    } else {
        hud.labelText = @"请稍等...";
        
        ECPersonInfo *person = [[ECPersonInfo alloc] init];
        person.nickName = _nickNameField.text;
        person.sex = _sex;
        person.birth = dateStr;
        person.sign = _signField.text;
        
        [[ECDevice sharedInstance] setPersonInfo:person completion:^(ECError *error, ECPersonInfo *person) {
            
            
            if (error.errorCode == ECErrorType_NoError) {
                [DemoGlobalClass sharedInstance].nickName = nickName;
                [DemoGlobalClass sharedInstance].sex = aSex;
                [DemoGlobalClass sharedInstance].birth = dateStr;
                [DemoGlobalClass sharedInstance].sign = _signField.text;
                [DemoGlobalClass sharedInstance].dataVersion = person.version;
                [DemoGlobalClass sharedInstance].isNeedSetData = NO;
                
                [weakself.navigationController popViewControllerAnimated:YES];
                //            if (!weakself.isDisplayBack) {
                //                [weakself.navigationController popViewControllerAnimated:YES];
                //            } else {
                //                hud.labelText = @"修改成功";
                //            }
            } else {
                NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\rerrorDescription:%@",error.errorDescription]:@"";
                hud.labelText = [NSString stringWithFormat:@"errorCode:%d%@",(int)error.errorCode,detail];
            }
        }];
    }
}
@end
