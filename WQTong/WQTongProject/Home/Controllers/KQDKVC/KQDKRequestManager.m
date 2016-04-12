//
//  KQDKRequestManager.m
//  WQTong
//
//  Created by ChenBinbin on 16/3/31.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "KQDKRequestManager.h"

@implementation KQDKRequestManager

__strong static KQDKRequestManager *share = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        share = [[super allocWithZone:NULL] init];
    });
    return share;
}


#pragma mark - 保存图片至沙盒

- (BOOL)imageHasAlpha:(UIImage *)image {
    
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

#pragma mark - 图片转换成Base64Binary

- (void)image2DataURL:(UIImage *)image {
    
    NSData *imageData = nil;
    NSString *mimeType = nil;
    
    if ([self imageHasAlpha: image]) {
        imageData = UIImagePNGRepresentation(image);
        mimeType = @"image/png";
    } else {
        imageData = UIImageJPEGRepresentation(image, 0.5f);
        mimeType = @"image/jpg";
    }
    self.imgBase64BinaryObject = [imageData base64EncodedStringWithOptions:0];
}

#pragma mark - 保存图片到文件

- (void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName {
    
    NSLog(@"保存图片");
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.01);
    // 获取沙盒目录
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    // 将图片写入文件
    [imageData writeToFile:fullPath atomically:NO];
    
}


#pragma mark - 上传图片

- (void)setupFJload {
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",self.imgName]];
    
    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
    
    [self image2DataURL: savedImage];
    
    self.tp = [NSString stringWithFormat:@"%@.jpg",self.imgName];
    
    NSString *strURL = [[NSString alloc] initWithFormat:webserviceURL];
    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];
    
    NSString * envelopeText = [NSString stringWithFormat:@"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                               "<soap:Body>"
                               "<FJUpload xmlns=\"http://tempuri.org/\">"
                               "<fs>%@</fs>"
                               "<fileName>%@</fileName>"
                               "</FJUpload>"
                               "</soap:Body>"
                               "</soap:Envelope>",
                               self.imgBase64BinaryObject,
                               self.tp];
    
    NSData *envelope = [envelopeText dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:envelope];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[envelope length]] forHTTPHeaderField:@"Content-Length"];
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse: &response
                                      error: &error];
}

#pragma mark - 上传信息:用户名 部门 经度 纬度 位置 类型 图片

- (void)setupRequest {

    NSArray * userInformationModelArray = [UserInformationModel MR_findAllSortedBy:@"timestamp" ascending:NO];
    
    for (int i=0; i<userInformationModelArray.count; i++) {
        
        UserInformationModel *userInformationModel = [userInformationModelArray objectAtIndex:i];
        
        self.username = userInformationModel.trueName;
        self.bumen = userInformationModel.department;
    }
    
//    NSLog(@"name is %@",self.username);
//    NSLog(@"bumen is %@",self.bumen);
//    NSLog(@"poi is %@",self.poi);
//    NSLog(@"wz is %@",self.wz);
//    NSLog(@"x is %lf",self.longitudeX);
//    NSLog(@"y is %lf",self.latitudeY);
//    NSLog(@"lx is %@",self.lx);
//    NSLog(@"tp is %@",self.tp);
    
    if (self.poi == nil || [self.poi isKindOfClass:[NSNull class]]) {
        self.poi = @" ";
    }
    if (self.wz == nil || [self.wz isKindOfClass:[NSNull class]]) {
        self.wz = @" ";
    }
    if (self.tp == nil || [self.tp isKindOfClass:[NSNull class]]) {
        self.tp = @" ";
    }
    
    NSString *strURL = [[NSString alloc] initWithFormat:webserviceURL];
    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];
    
    NSString * envelopeText = [NSString stringWithFormat:@"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                               "<soap:Body>"
                               "<AddKQXX xmlns=\"http://tempuri.org/\">"
                               "<username>%@</username>"
                               "<bumen>%@</bumen>"
                               "<poi>%@</poi>"
                               "<wz>%@</wz>"
                               "<lx>%@</lx>"
                               "<x>%f</x>"
                               "<y>%f</y>"
                               "<tp>%@</tp>"
                               "</AddKQXX>"
                               "</soap:Body>"
                               "</soap:Envelope>",
                               
                               self.username,
                               self.bumen,
                               self.poi,
                               self.wz,
                               
                               self.lx,
                               self.longitudeX,
                               self.latitudeY,
                               self.tp];
    
    
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
        
//        NSLog(@"连接成功");
      
           self.isAddKQXXSuccess = YES;
    }else {
//        NSLog(@"连接失败");
            self.isAddKQXXSuccess = NO;
    }
}


@end
