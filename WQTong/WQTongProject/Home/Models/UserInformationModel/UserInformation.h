//
//  UserInformation.h
//  WQTong
//
//  Created by WuYongmin on 16/4/9.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInformation : NSObject

@property (nullable, nonatomic, retain) NSString *activeTime;
@property (nullable, nonatomic, retain) NSString *department;
@property (nullable, nonatomic, retain) NSString *efence;
@property (nullable, nonatomic, retain) NSString *emailsStr;
@property (nullable, nonatomic, retain) NSString *groupName;

@property (nullable, nonatomic, retain) NSNumber *idNumber;
@property (nullable, nonatomic, retain) NSString *jiaoSe;
@property (nullable, nonatomic, retain) NSString *poiFW;
@property (nullable, nonatomic, retain) NSString *serils;
@property (nullable, nonatomic, retain) NSDate *timestamp;

@property (nullable, nonatomic, retain) NSString *trueName;
@property (nullable, nonatomic, retain) NSString *userName;
@property (nullable, nonatomic, retain) NSString *userPwd;
@property (nullable, nonatomic, retain) NSString *wzCJJG;
@property (nullable, nonatomic, retain) NSString *zaiGang;

@property (nullable, nonatomic, retain) NSString *zhiWei;

@end
