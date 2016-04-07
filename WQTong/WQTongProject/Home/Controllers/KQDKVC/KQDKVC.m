//
//  KQDKVC.m
//  WQTong
//
//  Created by ChenBinbin on 16/3/29.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "KQDKVC.h"
#import "KQDKRequestManager.h"

@interface KQDKVC ()

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapLocationManager *addKQDKAMapLocationManager;

@property (nonatomic, assign) double longitudeX; //经度
@property (nonatomic, assign) double latitudeY;  //纬度

@property (nonatomic, strong) UIButton *reportButton;//签到按钮

@property (nonatomic, strong) NSString *poi;           //位置
@property (nonatomic, strong) NSString *wz;            //位置
@property (nonatomic, strong) NSString *imgName; //拍照图片


@end

@implementation KQDKVC

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self initMapView];
    [self mapViewLocation];

    //self.mapView.centerCoordinate = self.mapView.userLocation.location.coordinate;
    NSLog(@"self.mapView.centerCoordinate is %f",self.mapView.centerCoordinate.latitude);
    NSLog(@"self.mapView.centerCoordinate is %f",self.mapView.centerCoordinate.longitude);
    
}


- (void) textFieldWzNotification:(NSNotification*) notification
{
    UILabel * wzLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, 80, 250, 30)];
    [self.view addSubview:wzLabel];
}

- (void)initUI {
    
    self.reportButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.reportButton.frame = CGRectMake(15 ,460, screenWidth-30, 44);
    [self.reportButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.reportButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    self.reportButton.backgroundColor = themeColor;
    self.reportButton.layer.borderWidth = 2;
    self.reportButton.layer.borderColor = (__bridge CGColorRef _Nullable)(themeColor);
    self.reportButton.layer.masksToBounds = YES;
    [self.reportButton setTitle:@"打卡" forState:UIControlStateNormal];

    UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect: self.reportButton.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
    maskLayer2.frame =   self.reportButton.bounds;
    maskLayer2.path = maskPath2.CGPath;
    self.reportButton.layer.mask = maskLayer2;
    
    [self.reportButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"外勤通"
                                                        message:[NSString stringWithFormat:@"签到时间:%@",[CommonFunction stringFromDate:[NSDate date] format:@"yyyy-MM-dd HH:mm:ss"]]
                                                       delegate:self
                                              cancelButtonTitle:@"下班打卡"
                                              otherButtonTitles:@"上班打卡",nil];
    alert.delegate = self;
    //这个属性继承自UIView，当一个视图中有多个AlertView时，可以用这个属性来区分
    alert.tag = 1;
    [alert show];
    
    }];
    [self.view addSubview:self.reportButton];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"clickButtonAtIndex:%d",buttonIndex);
    
    if (alertView.tag == 1) {
        
        if (buttonIndex == 0) {
            
            NSLog(@"结束定位");
            [KQDKRequestManager sharedInstance].lx = @"下班";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stopLocationNotification" object:self userInfo:nil];
            [self.view makeToast:@"打卡成功" duration:1.0 position:@"center"];

            
        }else if (buttonIndex == 1)
        {
            NSLog(@"开始定位");
            [KQDKRequestManager sharedInstance].lx = @"上班";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"setupLocationNotification" object:self userInfo:nil];
           
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请选择"
                                                            message:@"上传图片"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定",nil];
            alert.delegate = self;
            //这个属性继承自UIView，当一个视图中有多个AlertView时，可以用这个属性来区分
            alert.tag = 2;
            [alert show];

        }
    }
    if (alertView.tag == 2) {
        
        if (buttonIndex == 0) {
            
            NSLog(@"直接上传");
            //上传数据
            [[KQDKRequestManager sharedInstance]setupRequest];
            [self saveAddKQXXDataAction];
            [self.view makeToast:@"打卡成功" duration:1.0 position:@"center"];
             
        }
        else if (buttonIndex == 1) {
            
            NSLog(@"打开相机");
            
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = YES;
            //UIImagePickerControllerSourceTypePhotoLibrary UIImagePickerControllerSourceTypeCamera
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController:imagePickerController animated:YES completion:^{}];
        }
    }

    
}

#pragma mark - 选择图片delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    self.imgName = [[CommonFunction sharedInstance]timeStringRecord];
    [KQDKRequestManager sharedInstance].imgName = self.imgName;
    
     //保存图片至本地，方法见下文
    [[KQDKRequestManager sharedInstance]saveImage:image withName:[NSString stringWithFormat:@"%@.jpg",self.imgName]];

    //上传图片
    [[KQDKRequestManager sharedInstance] setupFJload];
    
    //上传定位数据
    [[KQDKRequestManager sharedInstance] setupRequest];
    
    //保存定位数据
    [self saveAddKQXXDataAction];
}

#pragma mark - 取消选择图片delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)initMapView {
    
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(15, 80, screenWidth-30, 330)];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;//YES 为打开定位，NO为关闭定位
    [self.view addSubview:self.mapView];
    
    self.mapView.pausesLocationUpdatesAutomatically = NO;//开启后台定位
    self.mapView.allowsBackgroundLocationUpdates = YES;//iOS9以上系统必须配置
    self.mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
    [self.mapView setZoomLevel:16.1 animated:YES];
}

- (void)clearMapView {
    
    self.mapView.showsUserLocation = NO;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    self.mapView.delegate = nil;
}

#pragma mark - 调用单次定位

- (void)mapViewLocation {
    
     __weak KQDKVC *wSelf = self;
    
    self.addKQDKAMapLocationManager= [[AMapLocationManager alloc] init];
    [self.addKQDKAMapLocationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [self.addKQDKAMapLocationManager setPausesLocationUpdatesAutomatically:NO];
    [self.addKQDKAMapLocationManager setAllowsBackgroundLocationUpdates:YES];
    
    [self.addKQDKAMapLocationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        
        if (location)
        {
            NSLog(@"location");
            MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
            [annotation setCoordinate:location.coordinate];
            
            if (regeocode)
            {
                [annotation setTitle:[NSString stringWithFormat:@"%@", regeocode.formattedAddress]];
                [annotation setSubtitle:[NSString stringWithFormat:@"%@-%@-%.2fm", regeocode.citycode, regeocode.adcode, location.horizontalAccuracy]];
            }
            else
            {
                [annotation setTitle:[NSString stringWithFormat:@"lat:%f;lon:%f;", location.coordinate.latitude, location.coordinate.longitude]];
                [annotation setSubtitle:[NSString stringWithFormat:@"accuracy:%.2fm", location.horizontalAccuracy]];
            }
            
             KQDKVC * addKQXXVSelf = wSelf;
             addKQXXVSelf.poi = [NSString stringWithFormat:@"%@", regeocode.formattedAddress];
             addKQXXVSelf.wz = [NSString stringWithFormat:@"%@", regeocode.formattedAddress];
             addKQXXVSelf.longitudeX = location.coordinate.longitude;
             addKQXXVSelf.latitudeY  = location.coordinate.latitude;
             [addKQXXVSelf addAnnotationToMapView:annotation];
            
            [KQDKRequestManager sharedInstance].poi = [NSString stringWithFormat:@"%@", regeocode.formattedAddress];
            [KQDKRequestManager sharedInstance].wz = [NSString stringWithFormat:@"%@", regeocode.formattedAddress];
            [KQDKRequestManager sharedInstance].longitudeX = location.coordinate.longitude;
            [KQDKRequestManager sharedInstance].latitudeY  = location.coordinate.latitude;
         
            
             NSLog(@"poi is %@",[NSString stringWithFormat:@"%@", regeocode.formattedAddress]);
             NSLog(@"wz is %@",[NSString stringWithFormat:@"%@", regeocode.formattedAddress]);
            
        }
        else {
            //重新定位
            [self mapViewLocation];
        }
    }];
}

#pragma mark - 添加 MAAnnotation 标注

- (void)addAnnotationToMapView:(id<MAAnnotation>)annotation {
    
    [self.mapView addAnnotation:annotation];
    [self.mapView selectAnnotation:annotation animated:YES];
    [self.mapView setZoomLevel:16.1 animated:YES];
    [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
}

#pragma mark - 保存信息到数据库：定时上传数据-经纬度，是否上传标志，所在位置，保存时间

- (void)saveAddKQXXDataAction {

     AddKQXXModel * addKQXXModelObject = [AddKQXXModel MR_createEntity];
    
     addKQXXModelObject.poi      = self.poi;
     addKQXXModelObject.wz       = self.wz;
     addKQXXModelObject.lx       = [KQDKRequestManager sharedInstance].lx;
//     NSLog(@"self.longitudeXXXX is %f",self.longitudeX);
//     NSLog(@"self.longitudeXXXX is %@",[NSNumber numberWithDouble:self.longitudeX]);

     addKQXXModelObject.x        = [NSNumber numberWithDouble:self.longitudeX];  //经度
     addKQXXModelObject.y        = [NSNumber numberWithDouble:self.latitudeY]; //纬度
     addKQXXModelObject.tp       = [KQDKRequestManager sharedInstance].tp;
    

    
    NSTimeZone *zone = [NSTimeZone defaultTimeZone];//获得当前应用程序默认的时区
    NSInteger interval = [zone secondsFromGMTForDate:[NSDate date]];//以秒为单位返回当前应用程序与世界标准时间（格林威尼时间）的时差
    NSDate *nowDate=[NSDate dateWithTimeIntervalSinceNow:interval];
    self.datePicker=[[UIDatePicker alloc] init];
    [self.datePicker setDate:nowDate];
    
    addKQXXModelObject.timestamp = [self.datePicker date];
    addKQXXModelObject.isAddKQXXSuccess = [NSNumber numberWithBool:[KQDKRequestManager sharedInstance].isAddKQXXSuccess];
    

    
    NSArray *userInformationModelArray = [UserInformationModel MR_findAllSortedBy:@"timestamp" ascending:NO];
    
    for (int i=0; i<userInformationModelArray.count; i++) {
        
        UserInformationModel *userInformationModel = [userInformationModelArray objectAtIndex:i];
        
        addKQXXModelObject.username = userInformationModel.trueName;
        addKQXXModelObject.bumen = userInformationModel.department;
    }
    
    
    NSLog(@"saveUsername is %@",addKQXXModelObject.username);
    NSLog(@"saveBumen is %@",addKQXXModelObject.bumen);
    NSLog(@"savepoi is %@",self.poi);
    NSLog(@"savewz is %@",self.wz);
    NSLog(@"savex is %@", addKQXXModelObject.x);
    NSLog(@"savey is %@",addKQXXModelObject.y);
    NSLog(@"savelx is %@",[KQDKRequestManager sharedInstance].lx);
    NSLog(@"savetp is %@",[KQDKRequestManager sharedInstance].tp);
    NSLog(@"saveisADdd is %d",[KQDKRequestManager sharedInstance].isAddKQXXSuccess);
    NSLog(@"savetime is %@",addKQXXModelObject.timestamp);
    
   [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self clearMapView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
