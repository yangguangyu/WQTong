//
//  DownloadViewController.m
//  ECSDKDemo_OC
//
//  Created by admin on 16/3/9.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "DownloadViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>

@interface DownloadViewController ()<UIWebViewDelegate>
@property (nonatomic,strong) UIWebView *WebView;
@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"下载";
    
    UIBarButtonItem *leftItem;
    
    if ([UIDevice currentDevice].systemVersion.integerValue>7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClick)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClick)];
    }
    self.navigationItem.leftBarButtonItem = leftItem;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStyleDone target:self action:@selector(shareAppToWeixin)];
    [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    _WebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _WebView.delegate = self;
    [self.view addSubview:_WebView];
    NSURL *url = [NSURL URLWithString:@"http://m.yuntongxun.com/qrcode/tiyan/tiyan.html?m_im"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.WebView loadRequest:request];
}

- (void)returnClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareAppToWeixin {
    
     NSArray* imageArray = @[[UIImage imageNamed:@"im_img4.png"]];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:@"给开发者做的平台 功能全 技术强 集成快"
                                     images:imageArray
                                        url:[NSURL URLWithString:@"http://m.yuntongxun.com/qrcode/tiyan/tiyan.html?m_im"]
                                      title:@"云通讯集成平台"
                                       type:SSDKContentTypeAuto];
    
    [ShareSDK showShareActionSheet:nil items:nil shareParams:shareParams onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
        switch (state) {
            case SSDKResponseStateSuccess:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                [alertView show];
                break;
            }
            case SSDKResponseStateFail:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                message:[NSString stringWithFormat:@"%@",error]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
                break;
            }
            default:
                break;
        }
    }];
}
@end
