//
//  AddKQXXBL.h
//  WQTong
//
//  Created by ChenBinbin on 16/4/6.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddKQXX.h"

@interface AddKQXXBL : NSObject

//插入UserInformation方法
- (NSMutableArray*)createAddKQXX:(AddKQXX *)model;

////删除UserInformation方法
//-(NSMutableArray*) remove:(UserInformation*)model;

//查询所用数据方法
- (NSMutableArray*)findAll;
@end
