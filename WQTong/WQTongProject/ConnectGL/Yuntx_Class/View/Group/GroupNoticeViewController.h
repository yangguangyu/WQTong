//
//  GroupNoticeViewController.h
//  ECSDKDemo_OC
//
//  Created by lrn on 14/12/18.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface GroupNoticeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, assign) id<SlideSwitchSubviewDelegate> mainView;
@end
