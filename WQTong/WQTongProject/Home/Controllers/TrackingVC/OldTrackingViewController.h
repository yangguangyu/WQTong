//
//  OldTrackingViewController.h
//  waiqintong
//
//  Created by Apple on 11/10/15.
//  Copyright © 2015 cnbin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tracking.h"
#import "WzcLocObjectModel.h"
#import "WzcLocationModel.h"
#import "StartAnnotation.h"
#import "EndAnnotation.h"
#import "CheckRusultsViewController.h"

@class WzcLocObjectModel;

@interface OldTrackingViewController : ComFatherViewController<MAMapViewDelegate,TrackingDelegate> {
   
    UIButton * zoomoutButton;
    UIButton * zoominButton;
    float zoomLevel;
}

@end
