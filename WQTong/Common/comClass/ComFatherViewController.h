//
//  ComFatherViewController.h
//  WQTong
//
//  Created by ChenBinbin 16/3/25.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComFatherViewController : UIViewController

@property (nonatomic, assign) BOOL isVCDidAppear;   //是否视图已经显示

/**
 *  显示加载
 */
- (void)showLoadHud;

/**
 *  隐藏加载
 */
- (void)hideLoadHud;

@end
