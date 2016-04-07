//
//  AboutViewController.m
//  ECSDKDemo_OC
//
//  Created by admin on 16/3/9.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "AboutViewController.h"
#import "CommonTools.h"
#import "DownloadViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"关于";
    
    UIBarButtonItem *item;
    if ([UIDevice currentDevice].systemVersion.integerValue>7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        item = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClick)];
    } else {
        item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClick)];
    }
    self.navigationItem.leftBarButtonItem = item;
    
    [self buildUI];
}

- (void)buildUI {
    
    UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    imageBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-120.0f)/2, 10.0f, 120.0f, 120.0f);
    
    NSString *data = @"http://www.baidu.com";
    ZXMultiFormatWriter *writer = [[ZXMultiFormatWriter alloc] init];
    ZXBitMatrix *result = [writer encode:data
                                  format:kBarcodeFormatQRCode
                                   width:imageBtn.frame.size.width
                                  height:imageBtn.frame.size.width
                                   error:nil];
    
    if (result) {
        
        ZXImage *image = [ZXImage imageWithMatrix:result];
        [imageBtn setImage:[UIImage imageWithCGImage:image.cgimage] forState:UIControlStateNormal];
        
    } else {
        
         [imageBtn setImage:nil forState:UIControlStateNormal];
    }

    [self.view addSubview:imageBtn];
    

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, CGRectGetMaxY(imageBtn.frame), [UIScreen mainScreen].bounds.size.width-60.0f*2, 30.0f)];
    label.text = @"Copyright@2016-2016";
    label.font = [UIFont systemFontOfSize:14.0f];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, label.frame.origin.y+label.frame.size.height+1, [UIScreen mainScreen].bounds.size.width-60.0f*2, 30.0f)];
    label1.text = @"广东华讯网络投资有限公司";
    label1.font = [UIFont systemFontOfSize:14.0f];
    label1.numberOfLines = 0;
    label1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label1];
    
//    UIButton *dowloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    dowloadBtn.frame =CGRectMake(20.0f, CGRectGetMaxY(label1.frame)+40.0f, screenWidth-40, 50.0f);
//    dowloadBtn.backgroundColor = themeColor;
//    [dowloadBtn setTitle:@"下载" forState:UIControlStateNormal];
//    [dowloadBtn addTarget:self action:@selector(dowloadBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:dowloadBtn];
//    
//    UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect: dowloadBtn.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
//    CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
//    maskLayer2.frame = dowloadBtn.bounds;
//    maskLayer2.path = maskPath2.CGPath;
//    dowloadBtn.layer.mask = maskLayer2;
}

- (void)dowloadBtnClicked {
    DownloadViewController *vc = [[DownloadViewController alloc] init];
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)returnClick {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
