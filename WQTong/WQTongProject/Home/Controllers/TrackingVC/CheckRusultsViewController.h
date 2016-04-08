//
//  CheckRusultsViewController.h
//  waiqintong
//
//  Created by Apple on 11/14/15.
//  Copyright © 2015 cnbin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import "WzcLocObjectModel.h"
#import "Tracking.h"
#import "WzcLocationModel.h"
#import "FindStartAnnotation.h"
#import "FindEndAnnotation.h"

@class WzcLoctionModel;

@interface CheckRusultsViewController : ComFatherViewController<MAMapViewDelegate,TrackingDelegate>

@end
