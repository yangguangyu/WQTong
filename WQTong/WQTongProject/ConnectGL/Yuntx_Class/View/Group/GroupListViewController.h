//
//  GroupListViewController.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
@interface GroupListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, assign) id<SlideSwitchSubviewDelegate> mainView;
@property (nonatomic,assign)NSInteger celltype;
@property(nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *discussArray;
//是否是讨论组
@property (nonatomic, assign) BOOL isDiscuss;
-(void)prepareGroupDisplay;
@end
