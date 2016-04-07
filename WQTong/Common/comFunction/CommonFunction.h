//
//  CommonFunction.h
//  WQTong
//
//  Created by ChenBinbin on 16/3/25.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonFunction : NSObject

+ (instancetype)sharedInstance;

//输入日期对象，根据格式返回日期字符串; strFormat,"yyyy-MM-dd HH:mm:ss"
+ (NSString *)stringFromDate:(NSDate *)date format:(NSString*)strFormat;

//时间拼成数字形式：20151116170511 2015-11-16 17:05:11
- (NSString *)timeStringRecord;

@end
