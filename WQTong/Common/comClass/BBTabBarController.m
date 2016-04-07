//
//  BBTableViewController.m
//  WQTong
//
//  Created by ChenBinbin on 16/3/25.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "BBTabBarController.h"


@interface BBTabBarController ()

@end

@implementation BBTabBarController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initTabUI];
}


- (void)initTabUI {
    
    //tabBarIdentity
    UITabBarController *tabBarController = (UITabBarController *)self;
    UITabBar *tabBar = tabBarController.tabBar;
    tabBarController.tabBar.superview.backgroundColor = [UIColor whiteColor];
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
//    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:1];
    
    tabBarItem1.title = @"首页";
//    tabBarItem2.title = @"通讯录";
    tabBarItem3.title = @"我的";
    
    self.tabBarController.tabBar.translucent = NO;
    
    tabBarItem1.image = [IconFont imageWithIcon:[IconFont icon:@"fa_home" fromFont:fontAwesome] fontName:fontAwesome iconColor:[UIColor whiteColor] iconSize:24.0f];
    
//    tabBarItem2.image = [IconFont imageWithIcon:[IconFont icon:@"fa_phone" fromFont:fontAwesome] fontName:fontAwesome iconColor:[UIColor whiteColor] iconSize:24.0f];
    
    tabBarItem3.image = [IconFont imageWithIcon:[IconFont icon:@"fa_user" fromFont:fontAwesome] fontName:fontAwesome iconColor:[UIColor whiteColor] iconSize:24.0f];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
