//
//  GlobalResource.h
//  Movie
//
//  Created by ChenBinbin on 10/15/15.
//  Copyright © 2015 cnbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WzcLocObjectModel.h"

@class WzcLocObjectModel;

@interface GlobalResource : NSObject

+ (instancetype)sharedInstance;

//点击查询到的WzcLocObjectModel
@property (strong, nonatomic) WzcLocObjectModel *resultRunObject;

//按日期查询到的WzcLocObjectModel
@property (strong, nonatomic) WzcLocObjectModel *detailResultRunObject;

@end
