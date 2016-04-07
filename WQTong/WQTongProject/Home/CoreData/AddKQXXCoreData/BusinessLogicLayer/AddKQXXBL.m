//
//  AddKQXXBL.m
//  WQTong
//
//  Created by ChenBinbin on 16/4/6.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "AddKQXXBL.h"
#import "AddKQXXDAO.h"

@implementation AddKQXXBL

- (NSMutableArray*)createAddKQXX:(AddKQXX*)model {
    
    AddKQXXDAO *dao = [AddKQXXDAO sharedManager];
    [dao create:model];
    
    return [dao findAll];
}

#pragma mark - 删除UserInformation方法

- (NSMutableArray*)remove:(AddKQXX*)model {
    
    AddKQXXDAO *dao = [AddKQXXDAO sharedManager];
    [dao remove:model];
    
    return [dao findAll];
}

#pragma mark - 查询所用数据方法

- (NSMutableArray*)findAll {
    
    AddKQXXDAO *dao = [AddKQXXDAO sharedManager];
    return [dao findAll];
}
@end
