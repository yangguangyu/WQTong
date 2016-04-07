//
//  AppDelegate+Launch.m
//  WQTong
//
//  Created by ChenBinbin on 16/3/25.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "AppDelegate+Launch.h"
#import "BBTabBarController.h"

@implementation AppDelegate (Launch)

-(void)initLaunchVC:(UIApplication *)application WithOption:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [[UINavigationBar appearance] setBarTintColor:themeColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
    BOOL isLogined = [[NSUserDefaults standardUserDefaults] boolForKey:@"key_isLogined"];

    if (isLogined) {
        
        [self showHome];
       
    }
    
    else {
        
        [self showLogin];
    }
}

#pragma mark - 实现委托跳转视图

- (void)LaunchVCDelegate :(LaunchVC *)loginViewController {
    
    [self showHome];
}


#pragma mark - 视图切换

- (void)showHome {
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UITabBarController *tabVC = [storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Tabbar"];
    self.window.rootViewController = tabVC;
    
}

#pragma mark - 根控制器为LoginViewController

- (void)showLogin {
    
    LaunchVC *launchVC = [[LaunchVC alloc]init];
    launchVC.delegate = self;
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:launchVC];
    
}

@end
