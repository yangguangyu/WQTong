//
//  RequestHelper.m
//  WQTong
//
//  Created by ChenBinbin on 16/3/26.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "LaunchRequestManager.h"

@implementation LaunchRequestManager

- (void)setUpRequest {
    
    NSString *strURL = [[NSString alloc] initWithFormat:webserviceURL];
    
    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];
    
    NSString * envelopeText = [NSString stringWithFormat:@"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                               "<soap:Body>"
                               "<Login xmlns=\"http://tempuri.org/\">"
                               "<uname>%@</uname>"
                               "<pass>%@</pass>"
                               "</Login>"
                               "</soap:Body>"
                               "</soap:Envelope>",self.userName.text,self.passWord.text];
    
    NSData *envelope = [envelopeText dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:envelope];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[envelope length]] forHTTPHeaderField:@"Content-Length"];
    
    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:request delegate:self];
    
    if (connection) {
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"%@",[error localizedDescription]);
}

#pragma mark 接受到响应

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (!self.receiveData) {
        self.receiveData = [NSMutableData data];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [self.receiveData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection*) connection {
    
    NSLog(@"请求完成...");
    
    NSString *receiveString = [[NSString alloc] initWithData:self.receiveData encoding:NSUTF8StringEncoding];
    NSString *str =@"<?xml version=\"1.0\" encoding=\"utf-8\"?>""<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">""<soap:Body>""<LoginResponse xmlns=\"http://tempuri.org/\">""<LoginResult>";
    
    NSString *strhtml =[receiveString stringByReplacingOccurrencesOfString:str withString:@""];
    strhtml = [strhtml stringByReplacingOccurrencesOfString:@"</LoginResult>""</LoginResponse>""</soap:Body>""</soap:Envelope>" withString:@""];
    
    NSLog(@"string is %@", strhtml);
    
    NSError *error;
    NSData *data =[ strhtml dataUsingEncoding:NSUTF8StringEncoding];
    self.jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    if (self.jsonArray != nil && ![self.jsonArray isKindOfClass:[NSNull class]] && self.jsonArray.count != 0)
    {
        
        NSDictionary * userDict = [self.jsonArray objectAtIndex:0];
        NSLog(@"obj is %@",[self.jsonArray objectAtIndex:0]);
        
        UserInformation * userInformationObject = [[UserInformation alloc]init];
        userInformationObject.idNumber  =  [userDict objectForKey:@"ID"];
        userInformationObject.userName  =  [userDict objectForKey:@"UserName"];
        userInformationObject.userPwd   =  [userDict objectForKey:@"UserPwd"];
        userInformationObject.trueName  =  [userDict objectForKey:@"TrueName"];
        userInformationObject.serils    =  [userDict objectForKey:@"Serils"];
        
        userInformationObject.department = [userDict objectForKey:@"Department"];
        userInformationObject.jiaoSe     = [userDict objectForKey:@"JiaoSe"];
        userInformationObject.groupName  = [userDict objectForKey:@"GroupName"];
        // userInformationObject.activeTime = [userDict objectForKey:@"ActiveTime"];
        userInformationObject.zhiWei     = [userDict objectForKey:@"ZhiWei"];
        
        userInformationObject.zaiGang   = [userDict objectForKey:@"ZaiGang"];
        userInformationObject.emailsStr = [userDict objectForKey:@"EmailStr"];
        userInformationObject.wzCJJG    = [userDict objectForKey:@"WZCJJG"];
        userInformationObject.poiFW     = [userDict objectForKey:@"POIFW"];
        userInformationObject.efence    = [userDict objectForKey:@"eFence"];
        userInformationObject.timestamp = [NSDate date];
        
        UserInformationBL *userInformationBL = [[UserInformationBL alloc]init];
        [userInformationBL createUserInformation:userInformationObject];
        
        NSMutableArray *listData = [[NSMutableArray alloc]init];
        listData = [userInformationBL findAll];
        
        NSLog(@"listData is %@",listData);
    }

}

@end
