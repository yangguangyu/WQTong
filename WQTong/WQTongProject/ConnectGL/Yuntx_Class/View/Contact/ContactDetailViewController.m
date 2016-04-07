//
//  ContactDetailViewController.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/6.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ContactDetailViewController.h"
#import "ChatViewController.h"
#import "CommonTools.h"
#import "VoipCallController.h"
#import "VideoViewController.h"

extern NSString * Notification_ChangeMainDisplay;


@interface ContactDetailViewController ()<UIActionSheetDelegate>

@end

@implementation ContactDetailViewController
-(void)prepareUI {
    
    self.title =@"联系人详情";
    
    CGFloat frameY = 0.0f;
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        frameY = 64.0f;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    } else {
        frameY = 0.0f;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIImageView * bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, frameY, screenWidth, 140.0f)];
    bgImageView.image = [UIImage imageNamed:@"personal_center_bg"];
    [self.view addSubview:bgImageView];

    UIImageView * headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(20.0f, 40.0f, 70.0f, 70.0f)];
    [headImageView setImage:_dict[imageKey]];
    [bgImageView addSubview:headImageView];
    UILabel * nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(110.0f, 46.0f, 150.0f, 30.0f)];
    nameLabel.text = _dict[nameKey];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:23];
    nameLabel.textColor = [UIColor whiteColor];
    [bgImageView addSubview:nameLabel];
    
    UILabel * numLabel = [[UILabel alloc]initWithFrame:CGRectMake(110.0f, 75.0f, 150.0f, 30.0f)];
    numLabel.text = _dict[phoneKey];
    numLabel.textColor = [UIColor whiteColor];
    numLabel.backgroundColor = [UIColor clearColor];
    [bgImageView addSubview:numLabel];
    
    UIButton * contactBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    contactBtn.frame =CGRectMake(20.0f, bgImageView.frame.origin.y+bgImageView.frame.size.height+20.0f, screenWidth-40, 45.0f);
    contactBtn.backgroundColor = themeColor;
    [contactBtn setTitle:@"与对方沟通(IM)" forState:UIControlStateNormal];
    [contactBtn addTarget:self action:@selector(contactBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:contactBtn];
   
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: contactBtn.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = contactBtn.bounds;
    maskLayer.path = maskPath.CGPath;
    contactBtn.layer.mask = maskLayer;
    
    UIButton * voipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    voipBtn.frame =CGRectMake(20.0f, contactBtn.frame.origin.y+contactBtn.frame.size.height+20.0f, screenWidth-40, 45.0f);
    voipBtn.backgroundColor = themeColor;
    [voipBtn setTitle:@"与对方沟通(VoIP)" forState:UIControlStateNormal];
    [voipBtn addTarget:self action:@selector(voipCallBtnTouch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:voipBtn];
    
    UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect: voipBtn.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
    maskLayer2.frame =  voipBtn.bounds;
    maskLayer2.path = maskPath2.CGPath;
   voipBtn.layer.mask = maskLayer2;
    

    if ([self.dict[phoneKey] isEqualToString:[DemoGlobalClass sharedInstance].userName] || ![DemoGlobalClass sharedInstance].isSDKSupportVoIP) {
        [voipBtn setHidden:YES];
    }
}

-(void)returnClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)contactBtnClicked {
    ChatViewController * cvc = [[ChatViewController alloc] initWithSessionId:_dict[phoneKey]];
    [self.navigationController setViewControllers:[NSArray arrayWithObjects:[self.navigationController.viewControllers objectAtIndex:0],cvc, nil] animated:YES];
}

-(void)voipVoiceCall {
    VoipCallController * VVC = [[VoipCallController alloc] initWithCallerName:_dict[nameKey] andCallerNo:_dict[phoneKey] andVoipNo:_dict[phoneKey] andCallType:1];
    [self presentViewController:VVC animated:YES completion:nil];
}

-(void)voipLandingCall {
    VoipCallController * VVC = [[VoipCallController alloc] initWithCallerName:_dict[nameKey] andCallerNo:_dict[phoneKey] andVoipNo:_dict[phoneKey] andCallType:0];
    [self presentViewController:VVC animated:YES completion:nil];
}

-(void)voipCallBack {
    VoipCallController * VVC = [[VoipCallController alloc] initWithCallerName:_dict[nameKey] andCallerNo:_dict[phoneKey] andVoipNo:_dict[phoneKey] andCallType:2];
    [self presentViewController:VVC animated:YES completion:nil];
}

-(void)voipVideoCall {
    [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:YES];
    VideoViewController * vvc = [[VideoViewController alloc]initWithCallerName:[_dict objectForKey:nameKey] andVoipNo:[_dict objectForKey:phoneKey] andCallstatus:0];
    [self presentViewController:vvc animated:YES completion:nil];    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self prepareUI];
}

- (void)voipCallBtnTouch{
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"呼叫类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"VoIP音频", @"VoIP视频", @"落地电话", nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSString* button = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([button isEqualToString:@"VoIP音频"]) {
            [self voipVoiceCall];
        } else if ([button isEqualToString:@"VoIP视频"]) {
            [self voipVideoCall];
        } else if ([button isEqualToString:@"落地电话"]) {
            [self voipLandingCall];
        }
    }
}

@end
