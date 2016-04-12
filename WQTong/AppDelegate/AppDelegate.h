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

@property (nonatomic, strong) UIWindow *window;

//AppDelegate+RLYunService属性
@property (nonatomic, strong) NSString *callid;//容联


//AppDelegate+Map属性
@property (nonatomic, strong) AMapLocationManager *amaplocationManager;//高德地图定位管理对象
@property (nonatomic, strong) AMapSearchAPI *search;//高德地图搜索对象
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSMutableArray *timeLocationsArray; //保存定时上传的经纬度到数组
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, assign) BOOL isNetworkConnnect;

@property (nonatomic, strong) NSNumber *tempLatitude; //定时上传的经纬度,数字类型用于后面历史轨迹查询
@property (nonatomic, strong) NSNumber *tempLongitude;

@property (nonatomic, assign) CGFloat searchLatitude; //定时上传的经纬度
@property (nonatomic, assign) CGFloat searchLongitude;

@property (nonatomic, strong) NSString *userName;//用户名
@property (nonatomic, strong) NSString *bumen;//部门
@property (nonatomic, strong) NSString *wz;//位置

@property (nonatomic, strong) NSArray *userInfoArray;
@property (nonatomic, assign) Boolean isUploadSuccess;

@end

