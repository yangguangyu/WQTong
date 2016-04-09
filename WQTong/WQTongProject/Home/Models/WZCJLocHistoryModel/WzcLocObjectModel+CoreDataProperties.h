//
//  WzcLocObjectModel+CoreDataProperties.h
//  WQTong
//
//  Created by WuYongmin on 16/4/9.
//  Copyright © 2016年 cnbin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "WzcLocObjectModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WzcLocObjectModel (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *bumen;
@property (nullable, nonatomic, retain) NSDate *timestamp;
@property (nullable, nonatomic, retain) NSString *timestring;
@property (nullable, nonatomic, retain) NSString *userName;
@property (nullable, nonatomic, retain) NSString *wz;
@property (nullable, nonatomic, retain) NSOrderedSet<WzcLocationModel *> *locations;

@end

@interface WzcLocObjectModel (CoreDataGeneratedAccessors)

- (void)insertObject:(WzcLocationModel *)value inLocationsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLocationsAtIndex:(NSUInteger)idx;
- (void)insertLocations:(NSArray<WzcLocationModel *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLocationsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLocationsAtIndex:(NSUInteger)idx withObject:(WzcLocationModel *)value;
- (void)replaceLocationsAtIndexes:(NSIndexSet *)indexes withLocations:(NSArray<WzcLocationModel *> *)values;
- (void)addLocationsObject:(WzcLocationModel *)value;
- (void)removeLocationsObject:(WzcLocationModel *)value;
- (void)addLocations:(NSOrderedSet<WzcLocationModel *> *)values;
- (void)removeLocations:(NSOrderedSet<WzcLocationModel *> *)values;

@end

NS_ASSUME_NONNULL_END
