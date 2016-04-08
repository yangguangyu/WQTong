//
//  DateDetailsViewController.h
//  waiqintong
//
//  Created by Apple on 11/11/15.
//  Copyright © 2015 cnbin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import "Tracking.h"
#import "WzcLocationModel.h"
#import "WzcLocObjectModel.h"
#import "StartAnnotation.h"
#import "EndAnnotation.h"

@class WzcLocObjectModel;

@interface DateDetailsViewController : ComFatherViewController<MAMapViewDelegate,TrackingDelegate>

@end
