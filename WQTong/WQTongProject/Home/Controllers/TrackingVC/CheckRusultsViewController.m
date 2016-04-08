//
//  CheckRusultsViewController.m
//  waiqintong
//
//  Created by Apple on 11/14/15.
//  Copyright © 2015 cnbin. All rights reserved.
//

#import "CheckRusultsViewController.h"
#import "OldTrackingViewController.h"

static float const mapPadding = 1.1f;

@interface CheckRusultsViewController ()

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) Tracking *tracking;
@property (nonatomic, strong) MAPointAnnotation *startPointAnnotation;
@property (nonatomic, strong) MAPointAnnotation *endPointAnnotation;
@property (nonatomic, strong) NSMutableArray *annotations;

@property (nonatomic, strong) NSArray *trackingArray;
@property (nonatomic, strong) NSOrderedSet *locations;

@property (nonatomic, strong) WzcLocObjectModel *run;
@property (nonatomic, strong) UIButton * rePlayButton;

@end

@implementation CheckRusultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"轨迹查询";
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                              style: UIBarButtonItemStylePlain
                                                                             target:self
                                                                            action:@selector(dismissAction:)];
    
    self.rePlayButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-120 ,screenHeiht-250,60, 40)];
    
    self.rePlayButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    self.rePlayButton.backgroundColor = themeColor;
    self.rePlayButton.layer.borderWidth = 2;
    self.rePlayButton.layer.borderColor = (__bridge CGColorRef _Nullable)(themeColor);
    self.rePlayButton.layer.masksToBounds = YES;
    
    UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect:self.rePlayButton.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
    maskLayer2.frame = self.rePlayButton.bounds;
    maskLayer2.path = maskPath2.CGPath;
    self.rePlayButton.layer.mask = maskLayer2;

    [self.rePlayButton setTitle:@"回放" forState:UIControlStateNormal];
    [self.rePlayButton addTarget:self action:@selector(handleRunAction) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:self.rePlayButton];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.run = [GlobalResource sharedInstance].resultRunObject;
    
    NSMutableArray * latitudeArray =  [[NSMutableArray alloc]init];
    NSMutableArray * longitudeArray = [[NSMutableArray alloc]init];
    
    for (WzcLocationModel * location in self.run.locations.array) {
        
        [latitudeArray addObject:location.latitude];
        [longitudeArray addObject:location.longitude];
    }
    
    CLLocationCoordinate2D commuterLotCoords[self.run.locations.array.count];
    
    for (int i=0; i<self.run.locations.array.count; i++)
    {
        commuterLotCoords[i].latitude =[[latitudeArray objectAtIndex:i]doubleValue];
        commuterLotCoords[i].longitude =[[longitudeArray objectAtIndex:i]doubleValue];
    }
    
    self.tracking = [[Tracking alloc] initWithCoordinates:commuterLotCoords count:self.run.locations.array.count];
    
    [self.mapView addOverlay:self.tracking.polyline];
    
    self.startPointAnnotation = [[FindStartAnnotation alloc]init];
    self.startPointAnnotation.coordinate =  commuterLotCoords[0];
    [self.mapView addAnnotation: self.startPointAnnotation];
    
    self.endPointAnnotation = [[FindEndAnnotation alloc] init];
    self.endPointAnnotation.coordinate =  commuterLotCoords[self.run.locations.array.count-1];
    [self.mapView addAnnotation: self.endPointAnnotation];
    
    self.annotations = [NSMutableArray array];
    [self.annotations addObject:self.startPointAnnotation];
    [self.annotations addObject:self.endPointAnnotation];
    [self.mapView showAnnotations:self.annotations edgePadding:UIEdgeInsetsMake(20, 20, 20, 80) animated:YES];
    
}

- (void)dismissAction:(UIButton *)button {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Handle Action

- (void)handleRunAction {
    self.mapView.showsUserLocation = NO;
    self.tracking.delegate = self;
    self.tracking.mapView  = self.mapView;
    self.tracking.duration = 5.f;
    self.tracking.edgeInsets = UIEdgeInsetsMake(50, 50, 50, 50);
    [self.mapView setRegion:[self mapRegion]];
    [self.tracking execute];
}

#pragma mark - MAMapViewDelegate

- (MACoordinateRegion)mapRegion {
    MACoordinateRegion region;
    WzcLocationModel *initialLoc = self.locations.firstObject;
    
    float minLat = initialLoc.latitude.floatValue;
    float minLng = initialLoc.longitude.floatValue;
    float maxLat = initialLoc.latitude.floatValue;
    float maxLng = initialLoc.longitude.floatValue;
    
    for (WzcLocationModel *location in self.locations) {
        if (location.latitude.floatValue < minLat) {
            minLat = location.latitude.floatValue;
        }
        if (location.longitude.floatValue < minLng) {
            minLng = location.longitude.floatValue;
        }
        if (location.latitude.floatValue > maxLat) {
            maxLat = location.latitude.floatValue;
        }
        if (location.longitude.floatValue > maxLng) {
            maxLng = location.longitude.floatValue;
        }
    }
    
    region.center.latitude = (minLat + maxLat) / 2.0f;
    region.center.longitude = (minLng + maxLng) / 2.0f;
    
    region.span.latitudeDelta = (maxLat - minLat) * mapPadding;
    region.span.longitudeDelta = (maxLng - minLng) * mapPadding;
    
    return region;
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineView = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        
        polylineView.lineWidth   = 4.f;
        polylineView.strokeColor = [UIColor redColor];
        return  polylineView;
    }
    
    return nil;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if (annotation == self.tracking.annotation)
    {
        static NSString *trackingReuseIndetifier = @"trackingReuseIndetifier";
        
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:trackingReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:trackingReuseIndetifier];
        }
        
        annotationView.canShowCallout = NO;
        
        return annotationView;
    }
    
    if ([annotation isKindOfClass:[FindStartAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"findStartReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.image = [UIImage imageNamed:@"start"];
        return annotationView;
    }
    
    if ([annotation isKindOfClass:[FindEndAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"findEndReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.image = [UIImage imageNamed:@"end"];
        return annotationView;
    }
    
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
