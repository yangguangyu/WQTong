//
//  UINavigationBar(Helpers).m
//  SevenMMobile
//
//  Created by  on 12-5-21.
//  Copyright (c) 2012年 IEXIN. All rights reserved.
//

#import "AppDelegate.h"
#import "UINavigationBar(Helpers).h"

@implementation UINavigationBar (Helpers)
- (void)drawRect:(CGRect)rect{
    //AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[delegate.navImage drawInRect:CGRectMake(0, 0, self.frame.size.width,self.frame.size.height)];
}
@end

@implementation UIBarButtonItem (Additions)

+(UIBarButtonItem *)returnBackButton:(id)sender action:(SEL)action{
    UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
    //    [button setImage:[UIImage imageNamed:@"TitleBar_Return"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    //[button setBackgroundImage:[UIImage imageNamed:@"btn_021"] forState:UIControlStateHighlighted];
    [button addTarget:sender action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftbutton=[[UIBarButtonItem alloc]initWithCustomView:button];
    
    return leftbutton;
}

+(UIBarButtonItem *)returnBarButton:(id)sender action:(SEL)action image:(UIImage *)image image2:(UIImage *)image2{
    CGSize size;
    if (image2) {
        size = image2.size;
    }else{
        size = CGSizeMake(40, 40);
    }
    
    UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    button.imageView.contentMode = UIViewContentModeCenter;
    [button setImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:image2 forState:UIControlStateHighlighted];
    [button addTarget:sender action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barbutton=[[UIBarButtonItem alloc]initWithCustomView:button];
    
    return barbutton;
}

+(UIBarButtonItem *)returnBarButton:(id)sender action:(SEL)action text:(NSString *)text image2:(UIImage *)image2{
    CGSize size;
    if (image2) {
        size = image2.size;
    }else{
        size = CGSizeMake(40, 40);
    }
    
    UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    button.imageView.contentMode = UIViewContentModeCenter;
    [button setTitle:text forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [button setBackgroundImage:image2 forState:UIControlStateNormal];
    [button addTarget:sender action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barbutton=[[UIBarButtonItem alloc]initWithCustomView:button];
    
    return barbutton;
}

@end

@implementation UINavigationItem (Additions)

- (void)addLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem
{
    if (CURRENT_IOS_VERSION >= 7.0) {
        // Add a negative spacer on iOS >= 7.0
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                        target:nil action:nil];
        //negativeSpacer.width = -10;
        [self setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, leftBarButtonItem, nil]];
    } else {
        // Just set the UIBarButtonItem as you would normally
        [self setLeftBarButtonItem:leftBarButtonItem];
    }
}

- (void)addRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem
{
    if (CURRENT_IOS_VERSION >= 7.0) {
        // Add a negative spacer on iOS >= 7.0
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        //negativeSpacer.width = -10;
        [self setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, rightBarButtonItem, nil]];
    } else {
        // Just set the UIBarButtonItem as you would normally
        [self setRightBarButtonItem:rightBarButtonItem];
    }
}

@end

@implementation UINavigationController (Additions)

+ (UINavigationController *) initWithCustomRootViewController:(UIViewController *) viewController{
    UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:viewController];
    [navi.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationBar.png"] forBarMetrics:0];
    
    return navi;
}

@end
