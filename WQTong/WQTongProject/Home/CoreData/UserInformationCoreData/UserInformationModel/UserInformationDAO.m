//
//  UserInformationDAO.m
//  WQTong
//
//  Created by ChenBinbin on 16/3/26.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "UserInformationDAO.h"

@implementation UserInformationDAO

static UserInformationDAO *sharedManager = nil;

+ (UserInformationDAO*)sharedManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^{

        sharedManager = [[self alloc] init];
        [sharedManager managedObjectContext];

    });
    return sharedManager;
}

#pragma mark - 插入UserInformation方法

- (int)create:(UserInformation *)model {

    NSManagedObjectContext *cxt = [self managedObjectContext];

    UserInformationModel *userInformationModel = [NSEntityDescription insertNewObjectForEntityForName:@"UserInformationModel" inManagedObjectContext:cxt];

    [userInformationModel setValue: model.idNumber forKey:@"idNumber"];
    [userInformationModel setValue: model.userName forKey:@"userName"];
    [userInformationModel setValue: model.userPwd forKey:@"userPwd"];
    [userInformationModel setValue: model.trueName forKey:@"trueName"];
    [userInformationModel setValue: model.serils forKey:@"serils"];

    [userInformationModel setValue: model.department forKey:@"department"];
    [userInformationModel setValue: model.jiaoSe forKey:@"jiaoSe"];
    [userInformationModel setValue: model.groupName forKey:@"groupName"];
    [userInformationModel setValue: model.zhiWei forKey:@"zhiWei"];
    [userInformationModel setValue: model.zaiGang forKey:@"zaiGang"];

    [userInformationModel setValue: model.emailsStr forKey:@"emailsStr"];
    [userInformationModel setValue: model.wzCJJG forKey:@"wzCJJG"];
    [userInformationModel setValue: model.poiFW forKey:@"poiFW"];
    [userInformationModel setValue: model.efence forKey:@"efence"];
    [userInformationModel setValue: [NSDate date] forKey:@"timestamp"];

    NSError *savingError = nil;
    if ([self.managedObjectContext save:&savingError]){
        NSLog(@"插入数据成功");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"successLoginAction" object:self userInfo:nil];
        
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
                                              entityForName:@"UserInformationModel" inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"timestamp = %@", model.timestamp];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    if ([listData count] > 0) {
        UserInformationModel *note = [listData lastObject];
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
                                              entityForName:@"UserInformationModel" inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    
    NSMutableArray *resListData = [[NSMutableArray alloc] init];
    
    for (UserInformationModel *mo in listData) {
        
         UserInformation *userInformation = [[UserInformation alloc] init];
        
         userInformation.idNumber = mo.idNumber;
         userInformation.userPwd = mo.userPwd;
         userInformation.trueName = mo.trueName;
         userInformation.serils = mo.serils;
         userInformation.department = mo.department;
        
         userInformation.jiaoSe = mo.jiaoSe;
         userInformation.groupName = mo.groupName;
         userInformation.zhiWei = mo.zhiWei;
         userInformation.zaiGang = mo.zaiGang;
        
         userInformation.emailsStr = mo.emailsStr;
         userInformation.wzCJJG = mo.wzCJJG;
         userInformation.poiFW = mo.poiFW;
         userInformation.efence = mo.efence;
         userInformation.timestamp = mo.timestamp;
        
         [resListData addObject:userInformation];
    }
    
    return resListData;
}

@end
