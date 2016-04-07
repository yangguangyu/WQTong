//
//  DetailsViewController.h
//  ECSDKDemo_OC
//
//  Created by lrn on 14/12/12.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsViewController : UIViewController
@property(nonatomic,assign)BOOL isOwner;
@property (nonatomic,strong)NSString * groupId;
//群组还是讨论组
@property (nonatomic, copy) NSString *isDiscussOrGroupName;
//是否是讨论组
@property (nonatomic, assign) BOOL isDiscuss;

@property(nonatomic,assign)BOOL isCreater;
@property(nonatomic,assign)BOOL isChangeGroupAdmin;
@property(nonatomic,assign)BOOL isHidden;
@end
