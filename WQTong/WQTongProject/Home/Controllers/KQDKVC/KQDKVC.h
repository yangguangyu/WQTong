//
//  KQDKVC.h
//  WQTong
//
//  Created by ChenBinbin on 16/3/29.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddKQXXModel.h"

@interface KQDKVC : ComFatherViewController<NSXMLParserDelegate,NSURLConnectionDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,MAMapViewDelegate,AMapLocationManagerDelegate>

@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, assign) Boolean isAddKQXXSuccess;

@end
