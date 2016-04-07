//
//  AddKQXXModel.h
//  WQTong
//
//  Created by ChenBinbin on 16/4/6.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface AddKQXXModel : NSManagedObject

@property (nullable, nonatomic, retain) NSString *bumen;
@property (nullable, nonatomic, retain) NSNumber *isAddKQXXSuccess;
@property (nullable, nonatomic, retain) NSString *lx;
@property (nullable, nonatomic, retain) NSString *poi;
@property (nullable, nonatomic, retain) NSDate *timestamp;
@property (nullable, nonatomic, retain) NSString *tp;
@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSString *wz;
@property (nullable, nonatomic, retain) NSNumber *x;
@property (nullable, nonatomic, retain) NSNumber *y;

@end


