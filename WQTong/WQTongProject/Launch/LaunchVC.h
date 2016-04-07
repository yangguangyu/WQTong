//
//  LaunchVC.h
//  WQTong
//
//  Created by ChenBinbin on 16/3/25.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "ComFatherViewController.h"
#import <UIKit/UIKit.h>
#import "LaunchRequestManager.h"

@class LaunchVC;

@protocol LaunchVCDelegate <NSObject>

- (void)LaunchVCDelegate :(LaunchVC *)launchVC;

@end

//启动视图
@interface LaunchVC : UIViewController

@property (nonatomic, weak) id<LaunchVCDelegate> delegate;

@end
