//
//  ECLocationViewController.h
//  ECSDKDemo_OC
//
//  Created by admin on 15/12/15.
//  Copyright © 2015年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECLocationPoint.h"

@class ECLocationViewController;

@protocol ECLocationViewControllerDelegate <NSObject>

-(void)onSendUserLocation:(ECLocationPoint*)point;

@end

@interface ECLocationViewController : UIViewController

@property (nonatomic, strong) UIViewController *backView;

@property (nonatomic, weak) id<ECLocationViewControllerDelegate> delegate;

- (instancetype)initWithLocationPoint:(ECLocationPoint*)locationPoint;
@end
