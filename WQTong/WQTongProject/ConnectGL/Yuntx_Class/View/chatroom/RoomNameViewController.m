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

#import "RoomNameViewController.h"
#import "ChatRoomViewController.h"

#define TAG_ALERTVIEW_ChatroomPwd  9999
#define TAG_ALERTVIEW_ChatroomName 9998

@interface RoomNameViewController ()
{
    NSInteger iVoiceMod;
    NSInteger bAutoDelete;
}
@property (nonatomic,retain)UITextField *nameTextField;
@property (nonatomic,retain)UITextField *pwdTextField;
@end

@implementation RoomNameViewController
@synthesize nameTextField;
@synthesize pwdTextField;
@synthesize backView;
@synthesize myScrollView;

- (void)loadView
{
    self.title = @"创建房间";
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] ;
    self.view.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];

    CGFloat frameY = 0.0f;
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        frameY = 104.0f;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    } else {
        frameY = 60.0f;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 240.0f+frameY)];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        scrollView.contentSize = CGSizeMake(self.view.frame.size.width,310.0f);
    } else {
        scrollView.contentSize = CGSizeMake(self.view.frame.size.width,self.view.frame.size.height);
    }
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.scrollsToTop = NO;
    [self.view addSubview :scrollView];
    self.myScrollView = scrollView;
    self.myScrollView.delegate = self;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 8.0f, 80.0f, 20.0f)];
    label.text = @"房间名称";
    label.textColor = [UIColor grayColor];
    [self.myScrollView addSubview:label];
    
    UITextField *name = [[UITextField alloc] initWithFrame:CGRectMake(90.0f, 3.0f, screenWidth-110, 35.0f)];
    name.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    name.backgroundColor = [UIColor whiteColor];
    name.placeholder = @"请输入房间名";
    self.nameTextField = name;
    self.nameTextField.tag = TAG_ALERTVIEW_ChatroomName;
    self.nameTextField.delegate = self;
    [self.myScrollView addSubview:name];
    
    UILabel *labelPwd = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 55.0f, 80.0f, 20.0f)];
    labelPwd.text = @"房间密码";
    labelPwd.textColor = [UIColor grayColor];
    [self.myScrollView addSubview:labelPwd];
    
    UITextField *pwd = [[UITextField alloc] initWithFrame:CGRectMake(90.0f, 50.0f, screenWidth-110, 35.0f)];
    pwd.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    pwd.backgroundColor = [UIColor whiteColor];
    pwd.placeholder = @"请输入1-8位密码（可选）";
    [pwd setSecureTextEntry:YES];
    pwd.keyboardType = UIKeyboardTypeDefault;
    self.pwdTextField = pwd;
    self.pwdTextField.tag = TAG_ALERTVIEW_ChatroomPwd;
    self.pwdTextField.delegate = self;
    [self.myScrollView addSubview:pwd];
    

    UILabel *labelVoiceMod = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 95.0f, 80.0f, 20.0f)];
    labelVoiceMod.text = @"声音设置";
    labelVoiceMod.textColor = [UIColor grayColor];
    [self.myScrollView addSubview:labelVoiceMod];
    
    NSArray *voiceModArray = [[NSArray alloc]initWithObjects:@"仅有背景音",@"全部提示音",@"无声",nil];
     UISegmentedControl *voiceModSgControl = [[UISegmentedControl alloc]initWithItems:voiceModArray];
    voiceModSgControl.frame = CGRectMake(90.0, 90.0, screenWidth-110, 35.0);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7)
    {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [UIFont systemFontOfSize:13],UITextAttributeFont,
                                                 [UIColor whiteColor],UITextAttributeTextColor,
                                                 [UIColor blackColor],UITextAttributeTextShadowColor,
                                                 [NSValue valueWithCGSize:CGSizeMake(1, 1)],UITextAttributeTextShadowOffset,nil];
        [voiceModSgControl setTitleTextAttributes:dic forState:UIControlStateNormal];
    }
    voiceModSgControl.selectedSegmentIndex = 1;//设置默认选择项索引
    voiceModSgControl.segmentedControlStyle = UISegmentedControlStylePlain;
    voiceModSgControl.tag = 1001;
    [self.myScrollView addSubview:voiceModSgControl];
    [voiceModSgControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];

    UILabel *labelAutoDelete = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 135.0f, 80.0f, 20.0f)];
    labelAutoDelete.text = @"房间类型";
    labelAutoDelete.textColor = [UIColor grayColor];
    [self.myScrollView addSubview:labelAutoDelete];
    
    NSArray *autoDeleteSgArray = [[NSArray alloc]initWithObjects:@"自动删除房间",@"不自动删除",nil];
    UISegmentedControl *autoDeleteSgControl = [[UISegmentedControl alloc]initWithItems:autoDeleteSgArray];
    autoDeleteSgControl.frame = CGRectMake(90.0, 130.0, screenWidth-110, 35.0);
    autoDeleteSgControl.selectedSegmentIndex = 0;//设置默认选择项索引
    autoDeleteSgControl.segmentedControlStyle = UISegmentedControlStylePlain;
    autoDeleteSgControl.tag = 1002;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7)
    {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [UIFont systemFontOfSize:13.0f],UITextAttributeFont,
                             [UIColor whiteColor],UITextAttributeTextColor,
                             [UIColor blackColor],UITextAttributeTextShadowColor,
                             [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)],UITextAttributeTextShadowOffset,nil];
        [autoDeleteSgControl setTitleTextAttributes:dic forState:UIControlStateNormal];
    }
    [self.myScrollView addSubview:autoDeleteSgControl];
    [autoDeleteSgControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    UIButton* btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btn.frame = CGRectMake(0.0f, 170.0f, 290.0f, 30.0f);
    UIImage* img = [UIImage imageNamed:@"choose_on.png"];
    btn.tag = 1;
    [btn setImage: img forState:(UIControlStateNormal)];
    btn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [btn setTitle:@"创建人退出时自动解散(单击选择)" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnChooseIsAutoClose:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.myScrollView addSubview:btn];
    
    UIButton* btnIsAutoJoin = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btnIsAutoJoin.frame = CGRectMake(0.0f, 205.0f, 272.0f, 30.0f);
    UIImage* imgIsAutoJoin = [UIImage imageNamed:@"choose.png"];
    btnIsAutoJoin.tag = 1;
    [btnIsAutoJoin setImage: imgIsAutoJoin forState:(UIControlStateNormal)];
    btnIsAutoJoin.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [btnIsAutoJoin setTitle:@"创建后自动加入会议(单击选择)" forState:UIControlStateNormal];
    [btnIsAutoJoin setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnIsAutoJoin addTarget:self action:@selector(btnChooseIsAutoJoin:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.myScrollView addSubview:btnIsAutoJoin];
    
    UIButton *createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    createBtn.frame = CGRectMake(82.0f, 240.0f, screenWidth-82*2, 38.0f);
    createBtn.titleLabel.textColor = [UIColor whiteColor];
    [createBtn setTitle:@"创建" forState:UIControlStateNormal];
    createBtn.showsTouchWhenHighlighted = YES;
    
    UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect:createBtn.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
    maskLayer2.frame = createBtn.bounds;
    maskLayer2.path = maskPath2.CGPath;
    createBtn.layer.mask = maskLayer2;

    createBtn.backgroundColor = themeColor;
    [createBtn addTarget:self action:@selector(createCharRoom:) forControlEvents:UIControlEventTouchUpInside];
    [self.myScrollView addSubview:createBtn];
    iVoiceMod = 2;
    isAutoClose = YES;
    bAutoDelete = YES;
    isAutoJoin = NO;
    square = 30;
}
- (void)viewDidAppear:(BOOL)animated
{
    [self.pwdTextField becomeFirstResponder];
    [self.nameTextField becomeFirstResponder];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
-(void)returnClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)segmentAction:(UISegmentedControl *)Seg {
    
    [self.view endEditing:YES];
    switch (Seg.selectedSegmentIndex)
    {
        case 0:
            if(Seg.tag == 1001) {
                iVoiceMod = 1;
            } else {
                bAutoDelete = YES;
            }
            break;
        case 1:
            if(Seg.tag == 1001) {
                iVoiceMod = 2;
            } else {
                bAutoDelete = NO;
            }
            break;
        case 2:
            if(Seg.tag == 1001) {
                iVoiceMod = 3;
            }
            break;
        default:
            break;
    }
}

-(void)btnChooseIsAutoJoin:(id)sender {
    
    [self.view endEditing:YES];
    UIButton* btn = sender;
    if (btn.tag == 0) {
        btn.tag = 1;
        UIImage* img = [UIImage imageNamed:@"choose_on.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isAutoJoin = YES;
    } else {
        btn.tag = 0;
        UIImage* img = [UIImage imageNamed:@"choose.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isAutoJoin = NO;
    }
}

-(void)btnChooseIsAutoClose:(id)sender {
    
    UIButton* btn = sender;
    if (btn.tag == 0) {
        btn.tag = 1;
        UIImage* img = [UIImage imageNamed:@"choose_on.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isAutoClose = YES;
    } else {
        btn.tag = 0;
        UIImage* img = [UIImage imageNamed:@"choose.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isAutoClose = NO;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (range.length == 1) {
        return YES;
    }
    
    NSMutableString *text = [textField.text mutableCopy];
    [text replaceCharactersInRange:range withString:string];
    if (textField.tag == TAG_ALERTVIEW_ChatroomPwd) {
        return [text length] <= 8;
    }
    return [text length] <= 50;
}

- (void)createCharRoom:(id)sender
{
    if (nameTextField.text.length > 0 ) {
        if (isAutoJoin) {
            //创建并加入
            ChatRoomViewController *chatroomview = [[ChatRoomViewController alloc] init];
            chatroomview.navigationItem.hidesBackButton = YES;
            chatroomview.curChatroomId = nil;
            chatroomview.roomname = nameTextField.text;
            chatroomview.backView = self.backView;
            chatroomview.isCreator = YES;
            [self.navigationController pushViewController:chatroomview animated:YES];
            [chatroomview createChatroomWithChatroomName:nameTextField.text andPassword:pwdTextField.text andSquare:square andKeywords:@""  andIsAutoClose:isAutoClose andVoiceMod:iVoiceMod andAutoDelete:bAutoDelete andIsAutoJoin:isAutoJoin];
        } else {
            ECCreateMeetingParams *params = [[ECCreateMeetingParams alloc] init];
            params.meetingType = ECMeetingType_MultiVoice;
            params.meetingName = nameTextField.text;
            params.meetingPwd = pwdTextField.text;
            params.square = square;
            params.autoClose = isAutoClose;
            params.autoDelete = bAutoDelete;
            params.voiceMod = iVoiceMod;
            params.autoJoin = isAutoJoin;
            
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"请稍后...";
            hud.removeFromSuperViewOnHide = YES;
            
            __weak __typeof(self) weakSelf = self;
            [[ECDevice sharedInstance].meetingManager createMultMeetingByType:params completion:^(ECError *error, NSString *meetingNumber) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                if (error.errorCode == ECErrorType_NoError) {
                    [self returnClicked];
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
    } else {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入会议名称";
        hud.margin = 10.0f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:2];
    }
}

-(void)dealloc {
    self.nameTextField = nil;
    self.pwdTextField = nil;
    self.myScrollView = nil;
    self.backView = nil;
}

@end
