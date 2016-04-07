//
//  ECLocationViewController.m
//  ECSDKDemo_OC
//
//  Created by admin on 15/12/15.
//  Copyright © 2015年 ronglian. All rights reserved.
//

#import "ECLocationViewController.h"
#import <MapKit/MapKit.h>

@interface ECLocationViewController ()<MKMapViewDelegate,CLLocationManagerDelegate,UIActionSheetDelegate>
@property(nonatomic, strong) MKMapView *mapView;
@property(nonatomic,strong) CLLocationManager *locationManager;
@property(nonatomic,strong) ECLocationPoint *locationPoint;
@property(nonatomic,strong) CLGeocoder * geoCoder;
@end

@implementation ECLocationViewController
{
    BOOL  _updateLocation;
    BOOL  _isHiddenBtn;
    BOOL  _isOpenAppleBtn;

}

- (instancetype)initWithLocationPoint:(ECLocationPoint*)locationPoint{
    self = [super init];
    if (self) {
        _locationPoint = locationPoint;
        _isOpenAppleBtn = YES;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    _geoCoder = [[CLGeocoder alloc] init];
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"位置";
    
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(popToBackClicked)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popToBackClicked)];
    }
    self.navigationItem.leftBarButtonItem = leftItem;

    
    if (self.locationPoint) {
        [self.mapView addAnnotation:self.locationPoint];
        [self setRegion:self.locationPoint.coordinate];
    } else {
        _isHiddenBtn = YES;
        self.locationPoint   = [[ECLocationPoint alloc] init];
        if ([CLLocationManager locationServicesEnabled]) {
            if ([UIDevice currentDevice].systemVersion.integerValue>=8.0) {
                [_locationManager requestAlwaysAuthorization];
            }
            CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
            if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
                [self showToast:@"请在设置-隐私里允许程序使用地理位置服务"];
            }else{
                self.mapView.showsUserLocation = YES;
            }
        }else{
            [self showToast:@"请打开地理位置服务"];
        }
    }
}

-(void)showToast:(NSString*)str {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:str delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)popToBackClicked {
    [self.navigationController popToViewController:self.backView animated:YES];
}

- (void)sendLocation {
    if (self.locationPoint == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未定位到位置，请等待" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alert show];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSendUserLocation:)] && self.locationPoint) {
        [self popToBackClicked];
        [self.delegate onSendUserLocation:self.locationPoint];
    }
}

- (void)setRightItem {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(sendLocation)];
    [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark 设置区域
- (void)setRegion:(CLLocationCoordinate2D)coordinate {
    MKCoordinateRegion theRegion;
    theRegion.center = coordinate;
    theRegion.span.longitudeDelta = 0.01f;
    theRegion.span.latitudeDelta = 0.01f;
    [_mapView setRegion:theRegion animated:NO];
}
#pragma mark - MKMapView 代理
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if (!_updateLocation) {
        return;
    }
    CLLocationCoordinate2D centerCoordinate = mapView.region.center;
    [self reverseGeoLocation:centerCoordinate];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    if (!_updateLocation) {
        return;
    }
    [_mapView removeAnnotations:_mapView.annotations];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    _updateLocation = YES;
    [self setRegion:userLocation.coordinate];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    static NSString *reusePin = @"PinAnnotation";
    MKPinAnnotationView * pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:reusePin];
    if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reusePin];
    }
    if (_isOpenAppleBtn == YES) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"location_GPS"] forState:UIControlStateNormal];
        [button sizeToFit];
        pin.rightCalloutAccessoryView = button;
    }
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.locationPoint.title;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [titleLabel sizeToFit];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    pin.detailCalloutAccessoryView = titleLabel;
    
    pin.canShowCallout	= YES;
    pin.animatesDrop = YES;
    pin.selected = YES;
    return pin;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    [self.mapView addAnnotation:self.locationPoint];
    [_mapView selectAnnotation:self.locationPoint animated:YES];
    UIView * view = [mapView viewForAnnotation:self.mapView.userLocation];
    view.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    UIActionSheet *action = [[UIActionSheet alloc] init];
    [action addButtonWithTitle:@"苹果地图导航"];
    [action addButtonWithTitle:@"取消"];
    action.delegate = self;
    action.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [action showInView:self.view];
}
#pragma mark - reverseGeoLocation
- (void)reverseGeoLocation:(CLLocationCoordinate2D)locationCoordinate2D{
    if (self.geoCoder.isGeocoding) {
        [self.geoCoder cancelGeocode];
    }
    CLLocation *location = [[CLLocation alloc] initWithLatitude:locationCoordinate2D.latitude longitude:locationCoordinate2D.longitude];
    __weak typeof(self) weakSelf = self;
    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error == nil) {
            CLPlacemark *mark = [placemarks firstObject];
            NSString * title  = mark.name;
            ECLocationPoint *ponit = [[ECLocationPoint alloc] initWithCoordinate:locationCoordinate2D andTitle:title];
            strongSelf.locationPoint = ponit;
            [strongSelf.mapView addAnnotation:ponit];
            [strongSelf setRightItem];
        } else {
            strongSelf.locationPoint = nil;
        }
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==0) {
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.locationPoint.coordinate addressDictionary:@{@"title":self.locationPoint.title}];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:placemark];
        toLocation.name = self.locationPoint.title;
        
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
    }
}
@end
