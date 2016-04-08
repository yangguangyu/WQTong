//
//  AppDelegate+Map.m
//  WQTong
//
//  Created by ChenBinbin on 16/3/25.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "AppDelegate+Map.h"

@implementation AppDelegate (Map)

- (void)configureAPIKey {
    
    [MAMapServices sharedServices].apiKey = (NSString *)APIKey;//地图
    [AMapLocationServices sharedServices].apiKey = (NSString *)APIKey;//定位
    [AMapSearchServices sharedServices].apiKey   = (NSString *)APIKey;//搜索
    
}

- (void)initMapService:(UIApplication *)application WithOption:(NSDictionary *)launchOptions {
    
    [self configureAPIKey];//配置高德地图APIKey
    [self configureSQL];//配置数据库
    [self mapLocationNotification];//添加定位监听
}

//创建MagicalRecord外勤通数据库
- (void)configureSQL {
    
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"WQTong.sqlite"];
}

//添加定时上传位置监听
- (void)mapLocationNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupLocation:)
                                                 name:@"setupLocationNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopLocation:)
                                                 name:@"stopLocationNotification"
                                               object:nil];
    //禁止自动休眠可以通过这一句话搞定
    [UIApplication sharedApplication].idleTimerDisabled=YES;

}

#pragma mark - 处理开启定位通知

- (void)setupLocation:(NSNotification *)notification {
    NSLog(@"定时器开启定位");
    
    self.amaplocationManager = [[AMapLocationManager alloc] init]; //初始化持续定位
    self.amaplocationManager.delegate = self;
    [self.amaplocationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters]; //精确度100米
    [self.amaplocationManager setPausesLocationUpdatesAutomatically:NO]; //后台不停止更新位置
    [self.amaplocationManager setAllowsBackgroundLocationUpdates:YES]; //适配iOS9要加上这句
    [self.amaplocationManager startUpdatingLocation];// 开启持续定位

    //初始化检索对象
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;

    self.timer = [NSTimer scheduledTimerWithTimeInterval:(20.0) target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
}

#pragma mark - 处理停止定位通知

- (void)stopLocation:(NSNotification *)notification {
    NSLog(@"stop定位");
    [self.amaplocationManager stopUpdatingLocation];
    
    [self.timer invalidate];
    self.timer = nil;
    [self saveUploadDataAction];
}


#pragma mark - 定时器执行方法,发起逆地理编码

- (void)timerAction {
    
    //[self AddWZCJLocation];
    [self saveNowDate];//记录当前时间
    
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location = [AMapGeoPoint locationWithLatitude:self.searchLatitude longitude:self.searchLongitude];
    
    regeo.requireExtension = YES;
    
    regeo.radius = 10000;
    
    //添加保存坐标
    [self.timeLocationsArray addObject:regeo.location];
    
    //发起逆地理编码
    [self.search AMapReGoecodeSearch:regeo];
    
}

#pragma mark - 逆地理编码,获取定时上传的坐标点,用户当前位置

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    __weak AppDelegate *wAppself = self;
    
    if (response.regeocode != nil)
    {
        self.wz = response.regeocode.formattedAddress;
        NSLog(@"self.wz is %@",self.wz);
    }
    
    [wAppself uploadRecordLocation];
//    NSLog(@"111111111111111");
}

#pragma mark - MALocationManager Delegate

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location {
    
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    self.searchLatitude  = location.coordinate.latitude;
    self.searchLongitude = location.coordinate.longitude;
    self.tempLatitude  =  [NSNumber numberWithDouble:location.coordinate.latitude];
    self.tempLongitude =  [NSNumber numberWithDouble:location.coordinate.longitude];
}

#pragma mark - 上传信息:用户名 部门 经度 纬度 位置 时间

- (void)uploadRecordLocation {
    
    //查询用户信息
    self.userInfoArray = [UserInformationModel MR_findAllSortedBy:@"timestamp" ascending:NO];
    
    if (self.userInfoArray != nil && ![self.userInfoArray isKindOfClass:[NSNull class]] && self.userInfoArray.count != 0) {
        
        UserInformationModel * userObject = [UserInformationModel MR_findFirst];
        self.userName = userObject.userName;
        self.bumen = userObject.department;
    }
//    NSLog(@"uploadwz is %@",self.wz);
//    NSLog(@"upload userName is %@",self.userName);
//    NSLog(@"upload bumen is %@",self.bumen);
    
    NSString *strURL = [[NSString alloc] initWithFormat:webserviceURL];
    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];
    
    NSString * envelopeText = [NSString stringWithFormat:@"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                               "<soap:Body>"
                               "<AddWZCJLoc xmlns=\"http://tempuri.org/\">"
                               "<username>%@</username>"
                               "<bumen>%@</bumen>"
                               "<x>%@</x>"
                               "<y>%@</y>"
                               "<wz>%@</wz>"
                               "<jq>%@</jq>"
                               "</AddWZCJLoc>"
                               "</soap:Body>"
                               "</soap:Envelope>",
                               
                               self.userName,
                               self.bumen,
                               self.tempLongitude,
                               self.tempLatitude,
                               self.wz,
                               [self.datePicker date]
                               ];
    
    NSData *envelope = [envelopeText dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:envelope];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[envelope length]] forHTTPHeaderField:@"Content-Length"];
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    if (data) {
        
        NSLog(@"定时连接成功");
        self.isUploadSuccess = YES;
        
    }else {
        
        NSLog(@"定时连接失败");
        self.isUploadSuccess = NO;
    }
    
    TimerUploadModel *timerUploadModel = [TimerUploadModel MR_createEntity];
    
    timerUploadModel.userName  = self.userName;
    timerUploadModel.bumen     = self.bumen;
    timerUploadModel.x         = self.tempLongitude;
    timerUploadModel.y         = self.tempLatitude;
    timerUploadModel.wz        = self.wz;
    timerUploadModel.timestamp = [self.datePicker date];
    timerUploadModel.isupload  = [NSNumber numberWithBool:self.isUploadSuccess];
    
    [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    
}

#pragma mark - 点击下班时候,保存定时上传的全部数据:经纬度数组,是否上传标志,所在位置,保存时间,用于历史轨迹查询

- (void)saveUploadDataAction {
    
    WzcLocObjectModel *newRun = [WzcLocObjectModel MR_createEntity];
    
    newRun.userName = self.userName;
    newRun.bumen = self.bumen;
    newRun.wz = self.wz;
    
    newRun.timestamp  =  [self.datePicker date];

    newRun.timestring =  [[CommonFunction sharedInstance]timeStringRecord];
    
    NSMutableArray *locationArray = [NSMutableArray array];
    
    if (self.timeLocationsArray != nil && ![self.timeLocationsArray isKindOfClass:[NSNull class]] && self.timeLocationsArray.count != 0)
    {
        for (CLLocation *location in self.timeLocationsArray) {
            
            WzcLocationModel *locationObject = [WzcLocationModel MR_createEntity];
            locationObject.timestamp = [self.datePicker date];
            locationObject.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
            locationObject.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
            [locationArray addObject:locationObject];
            
            //            NSLog(@"latitudeapp is %@",locationObject.latitude);
            //            NSLog(@"longgggeapp is %@",locationObject.longitude);
        }
        newRun.locations = [NSOrderedSet orderedSetWithArray:locationArray];
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        
    }
    NSLog(@"app newRun is %@",newRun);
}

#pragma mark - 设置当前时间

- (void)saveNowDate {
    
    NSTimeZone *zone = [NSTimeZone defaultTimeZone];//获得当前应用程序默认的时区
    NSInteger interval = [zone secondsFromGMTForDate:[NSDate date]];//以秒为单位返回当前应用程序与世界标准时间（格林威尼时间）的时差
    NSDate *date=[NSDate dateWithTimeIntervalSinceNow:interval];
    
    self.datePicker=[[UIDatePicker alloc] init];
    [self.datePicker setDate:date];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    [[NSNotificationCenter defaultCenter] removeObserver:@"setupLocationNotification"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"stopLocationNotification"];
}

@end
