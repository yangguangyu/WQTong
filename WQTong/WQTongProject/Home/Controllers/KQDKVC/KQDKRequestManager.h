//
//  KQDKRequestManager.h
//  WQTong
//
//  Created by ChenBinbin on 16/3/31.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQDKRequestManager : NSObject

@property (nonatomic, strong) id imgBase64BinaryObject;
@property (nonatomic, strong) NSString *imgName; //拍照图片

@property (nonatomic, strong) NSString *username;      //姓名
@property (nonatomic, strong) NSString *bumen;         //部门
@property (nonatomic, strong) NSString *poi;           //位置
@property (nonatomic, strong) NSString *wz;            //位置
@property (nonatomic, strong) NSString *lx;            //类型
@property (nonatomic, strong) NSString *tp;            //图片

@property (nonatomic, assign) double longitudeX; //经度
@property (nonatomic, assign) double latitudeY;  //纬度

@property (assign, nonatomic) Boolean isAddKQXXSuccess;//是否上传成功


+ (instancetype)sharedInstance;

//保存图片至沙盒
- (BOOL)imageHasAlpha:(UIImage *)image;

//图片转换成Base64Binary
- (void)image2DataURL:(UIImage *)image;

//保存图片到文件
- (void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName;

//上传图片
- (void)setupFJload;

//上传信息:用户名 部门 经度 纬度 位置 类型 图片
- (void)setupRequest;

@end
