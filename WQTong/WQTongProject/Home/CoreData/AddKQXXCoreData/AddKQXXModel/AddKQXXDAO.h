//
//  AddKQXXDAO.h
//  WQTong
//
//  Created by ChenBinbin on 16/4/6.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataDAO.h"
#import "AddKQXX.h"
#import "AddKQXXModel.h"

@interface AddKQXXDAO : CoreDataDAO

+ (AddKQXXDAO *)sharedManager;

//插入UserInformation方法
- (int)create:(AddKQXX *)model;


//删除UserInformation方法
-(int) remove:(AddKQXX *)model;

////修改UserInformation方法
//-(int) modify:(UserInformation *)model;
//

//查询所有数据方法
-(NSMutableArray*) findAll;
//
////按照主键查询数据方法
//-(UserInformation *)findById:(UserInformation *)model;

@end
