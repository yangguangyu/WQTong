//
//  AppDelegate.h
//  WQTong
//
//  Created by ChenBinbin on 16/3/24.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"  

@interface AppDelegate (RLYunService)

-(void)initRLYunService:(UIApplication *)application WithOption:(NSDictionary *)launchOptions;

+(AppDelegate*)shareInstance;
-(void)updateSoftAlertViewShow:(NSString*)message isForceUpdate:(BOOL)isForce;
-(void)toast:(NSString*)message;

@end

