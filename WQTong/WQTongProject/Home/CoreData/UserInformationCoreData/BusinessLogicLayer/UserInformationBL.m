//
//  UserInformationBL.m
//  WQTong
//
//  Created by ChenBinbin on 16/3/26.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "UserInformationBL.h"

@implementation UserInformationBL

#pragma mark - 插入UserInformation方法

- (NSMutableArray*)createUserInformation:(UserInformation*)model {
    UserInformationDAO *dao = [UserInformationDAO sharedManager];
    [dao create:model];
    
    return [dao findAll];
}

#pragma mark - 删除UserInformation方法

- (NSMutableArray*)remove:(UserInformation*)model {
    UserInformationDAO *dao = [UserInformationDAO sharedManager];
    [dao remove:model];
    
    return [dao findAll];
}

#pragma mark - 查询所用数据方法

- (NSMutableArray*)findAll {
    UserInformationDAO *dao = [UserInformationDAO sharedManager];
    return [dao findAll];
}

@end
