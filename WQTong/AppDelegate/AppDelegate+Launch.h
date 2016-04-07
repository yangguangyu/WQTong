//
//  AppDelegate+Launch.h
//  WQTong
//
//  Created by ChenBinbin on 16/3/25.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "LaunchVC.h"

@interface AppDelegate (Launch)<LaunchVCDelegate>

-(void)initLaunchVC:(UIApplication *)application WithOption:(NSDictionary *)launchOptions;

@end
