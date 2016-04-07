//
//  ComFatherViewController.m
//  WQTong
//
//  Created by ChenBinbin on 16/3/25.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "ComFatherViewController.h"

@interface ComFatherViewController () {
    
//    MBProgressHUD *_hud;//正常网络请求弹出的加载
//    MBProgressHUD *_handHud;//手动调用的加载

}

@end

@implementation ComFatherViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        _isVCDidAppear = NO;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initFatherData];
    [self initFatherUIControl];
    [self showBackBtn:YES];

}

- (void)returnClick {
    
    if ([[self.navigationController viewControllers] count] ==1) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }

}

#pragma mark - 显示返回按钮

- (void)showBackBtn:(BOOL)show {
    
    if (self.navigationItem)
    {
        if (show)
        {
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClick)];
            self.navigationItem.leftBarButtonItem = item;
        }
    }
    
}

#pragma mark - 事件相应

- (void)returnToPreviosView {
    
   }

- (void)initFatherUIControl {
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
}

- (void)initFatherData {
    
//    _hud = nil;
//    _handHud = nil;
  
}

/**
 *  显示加载
 */
- (void)showLoadHud {
    
//    if (!_handHud)
//    {
////        _handHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    }
//    
//    [_handHud show:YES];
    
}

/**
 *  隐藏加载
 */
- (void)hideLoadHud {
    
//    if (_handHud)
//    {
//        [_handHud hide:YES];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
