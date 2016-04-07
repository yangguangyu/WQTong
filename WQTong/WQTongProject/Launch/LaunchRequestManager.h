//
//  RequestHelper.h
//  WQTong
//
//  Created by ChenBinbin on 16/3/26.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LaunchRequestManager : NSObject<NSURLConnectionDelegate>

@property (strong, nonatomic) UITextField *userName;
@property (strong, nonatomic) UITextField *passWord;
@property (strong, nonatomic) NSMutableDictionary *dict;
@property (strong, nonatomic) NSMutableData *receiveData;
@property (strong, nonatomic) NSMutableArray *jsonArray;

- (void)setUpRequest;

@end
