//
//  AppDelegate.m
//  WQTong
//
//  Created by ChenBinbin on 16/3/24.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "AppDelegate+RLYunService.h"
#import "ECDeviceHeaders.h"
#import "DemoGlobalClass.h"
#import "AddressBookManager.h"
#import "CustomEmojiView.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import "WXApi.h"

#define LOG_OPEN 0

@implementation AppDelegate (RLYunService)

//- (void)redirectNSLogToDocumentFolder {
//    
//#if LOG_OPEN
//    if(isatty(STDOUT_FILENO)){
//        return;
//    }
//    
//    UIDevice *device = [UIDevice currentDevice];
//    if([[device model] hasSuffix:@"Simulator"]){ //在模拟器不保存到文件中
//        return;
//    }
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *fileName =[NSString stringWithFormat:@"%@.log", [self.dataformater stringFromDate:[NSDate date]]];
//    NSString *logFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
//    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
//#endif
//    
//}

- (void)initRLYunService:(UIApplication *)application WithOption:(NSDictionary *)launchOptions {

    NSLog(@"RLYunService");
    
    [CustomEmojiView shardInstance];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
//#if !TARGET_IPHONE_SIMULATOR
//    self.dataformater = [[NSDateFormatter alloc] init];
//    [self.dataformater setDateFormat:@"yyyyMMddHH"];
//    
//    //iOS8 注册APNS
//    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
//        
//        UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
//        action.title = @"查看消息";
//        action.identifier = @"action1";
//        action.activationMode = UIUserNotificationActivationModeForeground;
//        
//        UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
//        category.identifier = @"alert";
//        [category setActions:@[action] forContext:UIUserNotificationActionContextDefault];
//        
//        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
//        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:[NSSet setWithObjects:category, nil]];
//        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//        
//    } else {
//        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
//        UIRemoteNotificationTypeSound |
//        UIRemoteNotificationTypeAlert;
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
//    }
//    
//#endif
//     [self redirectNSLogToDocumentFolder];
//    
    
}

//微信分享WXApi
- (void)shareSDK {
    [ShareSDK registerApp:@"1036529846b88" activePlatforms:@[@(SSDKPlatformTypeWechat)] onImport:^(SSDKPlatformType platformType) {
        switch (platformType) {
            case SSDKPlatformTypeWechat:
                [ShareSDKConnector connectWeChat:[WXApi class]];
                break;
            default:
                break;
        }
    } onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
        switch (platformType) {
            case SSDKPlatformTypeWechat:
                [appInfo SSDKSetupWeChatByAppId:@"wx4868b35061f87885"
                                      appSecret:@"64020361b8ec4c99936c0e3999a9f249"];
                break;
            default:
                break;
        }
    }];
}

-(void)toast:(NSString*)message {
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

-(void)updateSoftAlertViewShow:(NSString*)message isForceUpdate:(BOOL)isForce {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新版本发布" message:message delegate:self cancelButtonTitle:isForce?nil:@"下次更新" otherButtonTitles:@"更新", nil];
    alert.tag = 100;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == 100) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://dwz.cn/F8pPd"]];
            exit(0);
        }
    }
}

+ (AppDelegate*)shareInstance {
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
//    NSLog(@"推送的内容：%@",notificationSettings);
//    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
 
//    self.callid = nil;
//    NSString *userdata = [userInfo objectForKey:@"c"];
//    NSLog(@"远程推送userdata:%@",userdata);
//    if (userdata) {
//        NSDictionary*callidobj = [NSJSONSerialization JSONObjectWithData:[userdata dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
//        NSLog(@"远程推送callidobj:%@",callidobj);
//        if ([callidobj isKindOfClass:[NSDictionary class]]) {
//            self.callid = [callidobj objectForKey:@"callid"];
//        }
//    }
//    
//    NSLog(@"远程推送 callid=%@",self.callid);
}

#pragma mark - 将得到的deviceToken传给SDK

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
#pragma mark - 将获取到的token传给SDK，用于苹果推送消息使用
    
    [[ECDevice sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

#pragma mark - 注册deviceToken失败；此处失败，与SDK无关，一般是您的环境配置或者证书配置有误

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.failToRegisterApns", Fail to register apns)
//                                                    message:error.description
//                                                   delegate:nil
//                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
//                                          otherButtonTitles:nil];
//    [alert show];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
//    UINavigationController * rootView = (UINavigationController*)self.window.rootViewController;
//    if ([rootView.viewControllers[0] isKindOfClass:[MainViewController class]]) {
//        NSInteger count = [[IMMsgDBAccess sharedInstance] getUnreadMessageCountFromSession];
//        application.applicationIconBadgeNumber = count;
//    } else {
//        application.applicationIconBadgeNumber = 0;
//    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [DeviceDelegateHelper sharedInstance].isB2F = YES;
    [DeviceDelegateHelper sharedInstance].preDate = nil;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  
    [DeviceDelegateHelper sharedInstance].preDate = [NSDate date];
   
}

@end
