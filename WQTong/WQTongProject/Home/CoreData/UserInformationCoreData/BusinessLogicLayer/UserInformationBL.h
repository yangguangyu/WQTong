//
//  UserInformationBL.h
//  WQTong
//
//  Created by ChenBinbin on 16/3/26.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UserInformation.h"
#import "UserInformationDAO.h"


@interface UserInformationBL : NSObject

//插入UserInformation方法
- (NSMutableArray*)createUserInformation:(UserInformation*)model;

////删除UserInformation方法
//-(NSMutableArray*) remove:(UserInformation*)model;

//查询所用数据方法
- (NSMutableArray*)findAll;

@end
