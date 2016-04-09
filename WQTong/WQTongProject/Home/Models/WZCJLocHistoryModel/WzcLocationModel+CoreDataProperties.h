//
//  WzcLocationModel+CoreDataProperties.h
//  WQTong
//
//  Created by WuYongmin on 16/4/9.
//  Copyright © 2016年 cnbin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "WzcLocationModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WzcLocationModel (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSDate *timestamp;
@property (nullable, nonatomic, retain) WzcLocObjectModel *wzcLocObject;

@end

NS_ASSUME_NONNULL_END
