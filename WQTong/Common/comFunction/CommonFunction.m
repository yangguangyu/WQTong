//
//  CommonFunction.m
//  WQTong
//
//  Created by ChenBinbin on 16/3/25.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "CommonFunction.h"

@implementation CommonFunction

__strong static CommonFunction *share = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        share = [[super allocWithZone:NULL] init];
    });
    return share;
}

//输入日期对象，根据格式返回日期字符串; strFormat,"yyyy-MM-dd HH:mm:ss"
+ (NSString *)stringFromDate:(NSDate *)date format:(NSString*)strFormat;
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:strFormat];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;
}

//时间拼成数字形式：201504061705 2015-04-06 17:05
- (NSString *)timeStringRecord {
    
    NSDate *dateNow;
    dateNow=[NSDate dateWithTimeIntervalSinceNow:0];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//设置成中国阳历
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear  | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ;
    comps = [calendar components:unitFlags fromDate:dateNow];
    
    NSString * yearString   = [NSString stringWithFormat:@"%ld",(long)[comps year]];
    
    NSString * monthString;
    if ((long)[comps month]<9) {
        
        monthString = [NSString stringWithFormat:@"0%ld",(long)[comps month]];
        
    }
    else {
        
        monthString = [NSString stringWithFormat:@"%ld",(long)[comps month]];
        
    }

     NSString * dayString;
    if ((long)[comps month]<9) {
        
        dayString = [NSString stringWithFormat:@"0%ld",(long)[comps day]];
        
    }
    else {
        
        dayString = [NSString stringWithFormat:@"%ld",(long)[comps day]];
        
    }
    
    NSString * hourString;
    if ((long)[comps hour]<9) {
        
        hourString = [NSString stringWithFormat:@"0%ld",(long)[comps hour]];
        
    }
    else {
        
        hourString = [NSString stringWithFormat:@"%ld",(long)[comps hour]];

    }
    
    NSString * minuteString;
    if ((long)[comps minute]<9) {
        
        minuteString = [NSString stringWithFormat:@"0%ld",(long)[comps minute]];
        
    }
    else {
        
        minuteString = [NSString stringWithFormat:@"%ld",(long)[comps minute]];
        
    }
    
//    NSString * secondString = [NSString stringWithFormat:@"%ld",(long)[comps second]];
    
    //时间拼成数字形式：20151116170511 2015-11-16 17:05:11
//    NSString * timeNumberString = [[[[[yearString stringByAppendingString:monthString]stringByAppendingString: dayString]stringByAppendingString: hourString]stringByAppendingString:minuteString]stringByAppendingString: secondString];
    
    NSString * timeNumberString = [[[[yearString stringByAppendingString:monthString]stringByAppendingString: dayString]stringByAppendingString: hourString]stringByAppendingString:minuteString];
    return timeNumberString ;
}

@end
