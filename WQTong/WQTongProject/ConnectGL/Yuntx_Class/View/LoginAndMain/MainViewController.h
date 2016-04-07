//
//  MainViewController.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SlideSwitchSubviewDelegate <NSObject>
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
-(void)showToast:(NSString *)message;
@end

@interface MainViewController : ComFatherViewController

@end
