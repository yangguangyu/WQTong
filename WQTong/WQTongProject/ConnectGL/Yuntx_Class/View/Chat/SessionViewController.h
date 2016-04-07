//
//  SessionViewController.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

//设置登录状态
typedef enum {
    linking,
    failed,
    success,
} LinkJudge;

@interface SessionViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,UIActionSheetDelegate>
@property (nonatomic, assign) id<SlideSwitchSubviewDelegate> mainView;
@property (nonatomic,assign)BOOL isLogin;
@property (nonatomic, strong) UITableView *tableView;
-(void)prepareDisplay;
-(void)updateLoginStates:(LinkJudge)link;
@end
