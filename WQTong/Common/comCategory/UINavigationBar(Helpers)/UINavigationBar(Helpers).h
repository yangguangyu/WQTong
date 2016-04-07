//
//  UINavigationBar(Helpers).h
//  SevenMMobile
//
//  Created by  on 12-5-21.
//  Copyright (c) 2012年 IEXIN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UINavigationBar (Helpers)

@end

@interface UIBarButtonItem (Additions)

+ (UIBarButtonItem *)returnBackButton:(id)sender action:(SEL)action;
+ (UIBarButtonItem *)returnBarButton:(id)sender action:(SEL)action image:(UIImage *)image image2:(UIImage *)image2;
+ (UIBarButtonItem *)returnBarButton:(id)sender action:(SEL)action text:(NSString *)text image2:(UIImage *)image2;
@end

@interface UINavigationItem (Additions)

- (void)addLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem;
- (void)addRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem;

@end

@interface UINavigationController (Additions)

+ (UINavigationController *) initWithCustomRootViewController:(UIViewController *) viewController;

@end