//
//  UserInformationDAO.h
//  WQTong
//
//  Created by ChenBinbin on 16/3/26.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataDAO : NSObject

//被管理的对象上下文
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//被管理的对象模型
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
//持久化存储协调者
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;

@end
