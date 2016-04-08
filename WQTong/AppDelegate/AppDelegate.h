//
//  AppDelegate.h
//  WQTong
//
//  Created by ChenBinbin on 16/3/24.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "MainViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,MAMapViewDelegate,AMapSearchDelegate,AMapLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

//AppDelegate+RLYunService属性
@property (strong, nonatomic) NSString *callid;//容联


//AppDelegate+Map属性
@property (strong, nonatomic) AMapLocationManager *amaplocationManager;//高德地图定位管理对象
@property (strong, nonatomic) AMapSearchAPI *search;//高德地图搜索对象
@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) NSMutableArray *timeLocationsArray; //保存定时上传的经纬度到数组
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (assign, nonatomic) BOOL isNetworkConnnect;

@property (strong, nonatomic) NSNumber *tempLatitude; //定时上传的经纬度,数字类型用于后面历史轨迹查询
@property (strong, nonatomic) NSNumber *tempLongitude;

@property (assign, nonatomic) CGFloat searchLatitude; //定时上传的经纬度
@property (assign, nonatomic) CGFloat searchLongitude;

@property (strong, nonatomic) NSString *userName;//用户名
@property (strong, nonatomic) NSString *bumen;//部门
@property (strong, nonatomic) NSString *wz;//位置

@property (strong, nonatomic) NSArray *userInfoArray;
@property (assign, nonatomic) Boolean isUploadSuccess;

@end

