//
//  AddKQXXDAO.m
//  WQTong
//
//  Created by ChenBinbin on 16/4/6.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "AddKQXXDAO.h"

@implementation AddKQXXDAO

static AddKQXXDAO *sharedManager = nil;

+ (AddKQXXDAO*)sharedManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        sharedManager = [[self alloc] init];
        [sharedManager managedObjectContext];
        
    });
    return sharedManager;
}

#pragma mark - 插入UserInformation方法

- (int)create:(AddKQXX *)model {
    
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    AddKQXXModel *addKQXXModel = [NSEntityDescription insertNewObjectForEntityForName:@"AddKQXXModel" inManagedObjectContext:cxt];
    
    [addKQXXModel setValue: model.username forKey:@"username"];
    [addKQXXModel setValue: model.bumen forKey:@"bumen"];
    [addKQXXModel setValue: model.poi forKey:@"poi"];
    [addKQXXModel setValue: model.wz forKey:@"wz"];
    [addKQXXModel setValue: model.lx forKey:@"lx"];
    [addKQXXModel setValue: model.x  forKey:@"x"];
    [addKQXXModel setValue: model.y forKey:@"y"];
    [addKQXXModel setValue: model.tp forKey:@"tp"];
    [addKQXXModel setValue: model.timestamp forKey:@"timestamp"];
    [addKQXXModel setValue: model.isAddKQXXSuccess forKey:@"isAddKQXXSuccess"];

    NSError *savingError = nil;
    if ([self.managedObjectContext save:&savingError]){
        
        NSLog(@"插入数据成功");
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"successAddModelAction" object:self userInfo:nil];
        
    } else {
        NSLog(@"插入数据失败");
        return -1;
    }
    
    return 0;
    
}

#pragma mark - 删除UserInformation方法

- (int)remove:(UserInformationModel*)model {
    
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"AddKQXXModel" inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"timestamp = %@", model.timestamp];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    if ([listData count] > 0) {
        AddKQXXModel *note = [listData lastObject];
        [self.managedObjectContext deleteObject:note];
        
        NSError *savingError = nil;
        if ([self.managedObjectContext save:&savingError]){
            NSLog(@"删除数据成功");
        } else {
            NSLog(@"删除数据失败");
            return -1;
        }
    }
    
    return 0;
}

#pragma mark - 查询所有数据方法

- (NSMutableArray*)findAll {
    
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"AddKQXXModel" inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    
    NSMutableArray *resListData = [[NSMutableArray alloc] init];
    
    for (AddKQXXModel *mo in listData) {
        
        AddKQXX *addKQXX = [[AddKQXX alloc] init];
        
        addKQXX.username = mo.username;
        addKQXX.bumen = mo.bumen;
        addKQXX.poi = mo.poi;
        addKQXX.wz = mo.wz;
        addKQXX.lx = mo.lx;
        
        addKQXX.x = mo.x;
        addKQXX.y = mo.y;
        addKQXX.tp = mo.tp;
        addKQXX.timestamp = mo.timestamp;
        
        addKQXX.isAddKQXXSuccess = mo.isAddKQXXSuccess;
        
        [resListData addObject:addKQXX];
    }
    
    return resListData;
}

@end
