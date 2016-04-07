//
//  CreateGroupViewController.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/8.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateGroupViewController : UIViewController
//群组还是讨论组
@property (nonatomic, copy) NSString *isDiscussOrGroupName;

//是否是讨论组
@property (nonatomic, assign) BOOL isDiscuss;

@end
