//
//  GlobalResource.h
//  Movie
//
//  Created by Apple on 10/15/15.
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

//@property (strong, nonatomic) NSString * wz;

////每15分钟的位置的经纬度
//@property (nonatomic, assign) CGFloat searchLatitude;
//@property (nonatomic, assign) CGFloat searchLongitude;
//
////上下班打卡经纬度
//@property (nonatomic, assign) NSNumber *reportlongitudeX; //经度
//@property (nonatomic, assign) NSNumber *reportLatitudeY;  //纬度

@end
