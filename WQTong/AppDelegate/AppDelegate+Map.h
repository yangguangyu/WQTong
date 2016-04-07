//
//  AppDelegate+Map.h
//  WQTong
//
//  Created by ChenBinbin on 16/3/25.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import "TimerUploadModel.h"
#import "UserInformationModel.h"
#import "WzcLocObjectModel.h"
#import "WzcLocationModel.h"

@interface AppDelegate (Map)<MAMapViewDelegate,AMapSearchDelegate,AMapLocationManagerDelegate>

-(void)initMapService:(UIApplication *)application WithOption:(NSDictionary *)launchOptions;

@end
