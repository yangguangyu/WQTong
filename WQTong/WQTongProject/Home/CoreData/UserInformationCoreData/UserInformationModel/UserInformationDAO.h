//
//  UserInformationDAO.h
//  WQTong
//
//  Created by ChenBinbin on 16/3/26.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataDAO.h"
#import "UserInformation.h"
#import "UserInformationModel.h"

@interface UserInformationDAO : CoreDataDAO

+ (UserInformationDAO *)sharedManager;

//插入UserInformation方法
- (int)create:(UserInformation *)model;


//删除UserInformation方法
-(int) remove:(UserInformation *)model;

////修改UserInformation方法
//-(int) modify:(UserInformation *)model;
//

//查询所有数据方法
-(NSMutableArray*) findAll;
//
////按照主键查询数据方法
//-(UserInformation *)findById:(UserInformation *)model;

@end
