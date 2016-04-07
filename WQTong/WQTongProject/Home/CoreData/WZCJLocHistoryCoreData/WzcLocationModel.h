//
//  WzcLocationModel.h
//  WQTong
//
//  Created by WuYongmin on 16/4/7.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WzcLocObjectModel;

@interface WzcLocationModel : NSManagedObject
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSDate *timestamp;
@property (nullable, nonatomic, retain) WzcLocObjectModel *wzcLocObject;

@end

