/*
 *  Copyright (c) 2013 The CCP project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a Beijing Speedtong Information Technology Co.,Ltd license
 *  that can be found in the LICENSE file in the root of the web site.
 *
 *                    http://www.yuntongxun.com
 *
 *  An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "MultiVideoConfNameViewController.h"
#import "MultiVideoConfViewController.h"
#import "CommonTools.h"

#define IPHONE5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
#define Chatroom3_6_3_NewFlow

@interface MultiVideoConfNameViewController ()
{
    NSInteger iVoiceMod;
    BOOL bAutoDelete;
}
@property (nonatomic,retain)UITextField *nameTextField;
@end

@implementation MultiVideoConfNameViewController

- (void)loadView
{
    isAutoClose = YES;
    iVoiceMod = 1;
    bAutoDelete = YES;
    isAutoJoin = YES;
    self.title = @"创建视频会议房间";
    
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [self.view setBackgroundColor:[UIColor grayColor]];

    UIBarButtonItem *leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"videoConf03"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(popBack)];
        
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"videoConf03"] style:UIBarButtonItemStyleDone target:self action:@selector(popBack)];
    }
    self.navigationItem.leftBarButtonItem = leftItem;
    
    int iHeight = 240;
    int iValue = 360;
    if (IPHONE5)
    {
        iValue  = 320;
        iHeight = 280;
    }
    
#ifdef Chatroom3_6_3_NewFlow
    iHeight = 240;
    iValue = 360;
    if (IPHONE5)
    {
        iValue  = 320;
        iHeight = 280;
    }
#endif
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, iHeight)];
    scrollView.contentSize = CGSizeMake(320, iValue);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.scrollsToTop = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview :scrollView];
    self.myScrollView = scrollView;
    self.myScrollView.delegate = self;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(11.0f, 5.0f, 200.0f, 18.0f)];
    label.text = @"房间名称:";
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [self.myScrollView addSubview:label];
    
    UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"videoConfPortrait.png"]];
    imageview.center = CGPointMake(33.0f, 52.0f);
    [self.myScrollView addSubview:imageview];
    
    UITextField *name = [[UITextField alloc] initWithFrame:CGRectMake(55.0f, 30.0f, screenWidth-66.0f, 44.0f)];
    name.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    name.keyboardAppearance = UIKeyboardAppearanceAlert;
    name.background = [UIImage imageNamed:@"videoConfInput.png"];
    name.delegate = self;
    name.textColor = [UIColor whiteColor];
    name.placeholder = @"请输入房间名称";
    name.clearButtonMode = UITextFieldViewModeWhileEditing;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        [name setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.nameTextField = name;
    name.textColor = [UIColor whiteColor];
    [self.myScrollView addSubview:name];
    
    UILabel *labelVoiceMod = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 85.0f, 80.0f, 20.0f)];
    labelVoiceMod.text = @"声音设置";
    labelVoiceMod.textColor = [UIColor whiteColor];
    labelVoiceMod.backgroundColor = [UIColor clearColor];
    [self.myScrollView addSubview:labelVoiceMod];
    
    NSArray *voiceModArray = [[NSArray alloc]initWithObjects:@"仅有背景音",@"全部提示音",@"无声",nil];
    UISegmentedControl *voiceModSgControl = [[UISegmentedControl alloc]initWithItems:voiceModArray];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5 && !iOS7)
    {
         NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [UIFont systemFontOfSize:13],UITextAttributeFont,
                             [UIColor whiteColor],UITextAttributeTextColor,
                             [UIColor blackColor],UITextAttributeTextShadowColor,
                             [NSValue valueWithCGSize:CGSizeMake(1, 1)],UITextAttributeTextShadowOffset,nil];
        [voiceModSgControl setTitleTextAttributes:dic forState:UIControlStateNormal];
    }
    voiceModSgControl.frame = CGRectMake(90.0, 80, 220.0, 35.0);
    voiceModSgControl.selectedSegmentIndex = 0;//设置默认选择项索引
    voiceModSgControl.segmentedControlStyle = UISegmentedControlStylePlain;
    voiceModSgControl.tintColor = [UIColor whiteColor];
    voiceModSgControl.tag = 1001;
    [self.myScrollView addSubview:voiceModSgControl];
    [voiceModSgControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];

    iValue = -30;
#ifdef Chatroom3_6_3_NewFlow
    iValue = 10;
    UILabel *labelAutoDelete = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 115.0f+iValue, 80.0f, 20.0f)];
    labelAutoDelete.text = @"房间类型";
    labelAutoDelete.textColor = [UIColor whiteColor];
    labelAutoDelete.backgroundColor = [UIColor clearColor];
    [self.myScrollView addSubview:labelAutoDelete];
    
    NSArray *autoDeleteSgArray = [[NSArray alloc]initWithObjects:@"自动删除房间",@"不自动删除",nil];
    UISegmentedControl *autoDeleteSgControl = [[UISegmentedControl alloc]initWithItems:autoDeleteSgArray];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5 && !iOS7)
    {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [UIFont systemFontOfSize:13],UITextAttributeFont,
                             [UIColor whiteColor],UITextAttributeTextColor,
                             [UIColor blackColor],UITextAttributeTextShadowColor,
                             [NSValue valueWithCGSize:CGSizeMake(1, 1)],UITextAttributeTextShadowOffset,nil];
        [autoDeleteSgControl setTitleTextAttributes:dic forState:UIControlStateNormal];
    }
    autoDeleteSgControl.frame = CGRectMake(90.0, 110.0+iValue, 220.0, 35.0);
    autoDeleteSgControl.selectedSegmentIndex = 0;//设置默认选择项索引
    autoDeleteSgControl.segmentedControlStyle = UISegmentedControlStylePlain;
    autoDeleteSgControl.tintColor = [UIColor whiteColor];
    autoDeleteSgControl.tag = 1002;
    [self.myScrollView addSubview:autoDeleteSgControl];
    [autoDeleteSgControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
#endif
    iValue = 160; //orgin 160.0f
    UIButton* btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btn.frame = CGRectMake(0, iValue, 294, 30);
    UIImage* img = [UIImage imageNamed:@"choose_on.png"];
    btn.tag = 1;
    [btn setImage: img forState:(UIControlStateNormal)];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    [btn setTitle:@"创建人退出时自动解散(单击选择)" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnChooseIsAutoClose:) forControlEvents:(UIControlEventTouchUpInside)];
    [btn sizeToFit];
    [self.myScrollView addSubview:btn];
    
    UIButton* btnIsAutoJoin = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btnIsAutoJoin.frame = CGRectMake(0, iValue+35, 276, 30);
    UIImage* imgIsAutoJoin = [UIImage imageNamed:@"choose_on.png"];
    btnIsAutoJoin.tag = 1;
    [btnIsAutoJoin setImage: imgIsAutoJoin forState:(UIControlStateNormal)];
    btnIsAutoJoin.titleLabel.font = [UIFont systemFontOfSize:17];
    [btnIsAutoJoin setTitle:@"创建后自动加入会议(单击选择)" forState:UIControlStateNormal];
    [btnIsAutoJoin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnIsAutoJoin addTarget:self action:@selector(btnChooseIsAutoJoin:) forControlEvents:(UIControlEventTouchUpInside)];
    [btnIsAutoJoin sizeToFit];
    [self.myScrollView addSubview:btnIsAutoJoin];
    
    UIButton *createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    createBtn.frame = CGRectMake(11.0f, 35.0f+iValue+35, 298.0f, 44.0f);
    [createBtn setImage:[UIImage imageNamed:@"videoConfCreate2.png"] forState:UIControlStateNormal];
    [createBtn setImage:[UIImage imageNamed:@"videoConfCreate2_on.png"] forState:UIControlStateHighlighted];
    [createBtn addTarget:self action:@selector(createVideoConference:) forControlEvents:UIControlEventTouchUpInside];
    [self.myScrollView addSubview:createBtn];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide)];
    [self.view addGestureRecognizer:tap];
    [self.navigationController.navigationBar addGestureRecognizer:tap];
    [self.myScrollView addGestureRecognizer:tap];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark -页面点击处理的方法
- (void)keyboardHide
{
    [self.view endEditing:YES];
    [self.navigationController.navigationBar endEditing:YES];
    [self.myScrollView endEditing:YES];
}

- (void)segmentAction:(UISegmentedControl *)Seg
{
    [self.nameTextField resignFirstResponder];
    switch (Seg.selectedSegmentIndex)
    {
        case 0:
            if(Seg.tag == 1001)
                iVoiceMod = 1;
            else
                bAutoDelete = YES;
            break;
        case 1:
            if(Seg.tag == 1001)
                iVoiceMod = 2;
            else
                bAutoDelete = NO;
            break;
        case 2:
            if(Seg.tag == 1001)
                iVoiceMod = 3;
            break;
        default:
            break;
    }
}

-(void)btnChooseIsAutoJoin:(id)sender
{
    [self.nameTextField resignFirstResponder];
    UIButton* btn = sender;
    if (btn.tag == 0)
    {
        btn.tag = 1;
        UIImage* img = [UIImage imageNamed:@"choose_on.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isAutoJoin = YES;
    }
    else
    {
        btn.tag = 0;
        UIImage* img = [UIImage imageNamed:@"choose.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isAutoJoin = NO;
    }
}

-(void)btnChooseIsAutoClose:(id)sender
{
    [self.nameTextField resignFirstResponder];
    UIButton* btn = sender;
    if (btn.tag == 0)
    {
        btn.tag = 1;
        UIImage* img = [UIImage imageNamed:@"choose_on.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isAutoClose = YES;
    }
    else
    {
        btn.tag = 0;
        UIImage* img = [UIImage imageNamed:@"choose.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isAutoClose = NO;
    }
}

#pragma mark -返回
- (void)popBack
{
    [self closeProgress];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.background = [UIImage imageNamed:@"videoConfInput_on.png"];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.background = [UIImage imageNamed:@"videoConfInput.png"];
}

#pragma mark -蒙版
-(void)showProgress:(NSString *)labelText{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = labelText;
    hud.mode = MBProgressHUDModeText;
    hud.margin = 30.0f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

-(void)closeProgress{
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

#pragma mark -private method
- (void)createVideoConference:(id)sender
{
    [self.nameTextField resignFirstResponder];
    if (self.nameTextField.text.length > 0 )
    {
        if (isAutoJoin)
        {
            MultiVideoConfViewController *VideoConfview = [[MultiVideoConfViewController alloc] init];
            VideoConfview.navigationItem.hidesBackButton = YES;
            VideoConfview.curVideoConfId = nil;
            VideoConfview.Confname = self.nameTextField.text;
            VideoConfview.backView = self.backView;
            VideoConfview.isCreator = YES;
            VideoConfview.isAutoClose = isAutoClose;
            [self.navigationController pushViewController:VideoConfview animated:YES];
            [VideoConfview createMultiVideoWithAutoClose:isAutoClose andIsPresenter:NO andiVoiceMod:iVoiceMod andAutoDelete:bAutoDelete andIsAutoJoin:isAutoJoin];
            
        }
        else
        {
            ECCreateMeetingParams *params = [[ECCreateMeetingParams alloc]init];
            params.meetingName = self.nameTextField.text;
            params.meetingPwd = @"";
            params.meetingType = ECMeetingType_MultiVideo;
            params.square = 5;
            params.autoClose = isAutoClose;
            params.autoJoin = NO;
            params.autoDelete = bAutoDelete;
            params.voiceMod = iVoiceMod;
            params.keywords = @"";
            
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"请稍后...";
            hud.removeFromSuperViewOnHide = YES;
            
            __weak __typeof(self) weakSelf = self;
            [[ECDevice sharedInstance].meetingManager createMultMeetingByType:params completion:^(ECError *error, NSString *meetingNumber) {
                
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [strongSelf closeProgress];
                if(error.errorCode ==ECErrorType_NoError) {
                    
                    [strongSelf.navigationController popToViewController:strongSelf.backView animated:YES];
                } else {
                    
                    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"创建会议失败";
                    hud.margin = 10.0f;
                    hud.removeFromSuperViewOnHide = YES;
                    [hud hide:YES afterDelay:2];

                }
            }];
        }
    }
    else
    {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入会议名称";
        hud.margin = 10.0f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:2];
    }
}
- (void)dealloc
{
    self.nameTextField = nil;
    self.myScrollView = nil;
    self.backView = nil;
}
@end
