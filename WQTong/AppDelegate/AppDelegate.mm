//
//  AppDelegate.m
//  WQTong
//
//  Created by ChenBinbin on 16/3/24.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "AppDelegate.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
   
    //初始化启动页
    [self initLaunchVC:application WithOption:launchOptions];
    
    //初始化容联云通讯服务
    [self initRLYunService:application WithOption:launchOptions];
    
    //初始化高德地图服务
    [self initMapService:application WithOption:launchOptions];
   // [self initMapParam];

    return YES;
}

- (void)initMapParam {
    
    self.timeLocationsArray = [NSMutableArray array];//
    
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
   
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  
    
}

- (void)applicationWillTerminate:(UIApplication *)application {

}

@end
