//
//  WzcLocObjectModel.h
//  WQTong
//
//  Created by WuYongmin on 16/4/7.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WzcLocObjectModel : NSManagedObject

@property (nullable, nonatomic, retain) NSString *bumen;
@property (nullable, nonatomic, retain) NSDate *timestamp;
@property (nullable, nonatomic, retain) NSString *timestring;
@property (nullable, nonatomic, retain) NSString *userName;
@property (nullable, nonatomic, retain) NSString *wz;
@property (nullable, nonatomic, retain) NSOrderedSet<NSManagedObject *> *locations;

@end


