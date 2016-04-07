//
//  DemoGlobalClass.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECEnumDefs.h"
#import "DeviceChatHelper.h"
#import "DeviceDBHelper.h"
#import "AddressBookManager.h"

#define nameKey @"contact_nameKey"
#define phoneKey @"contact_phoneKey"
#define imageKey @"contact_imageKey"

#define KNotice_ReloadSessionGroup  @"KNotice_ReloadSessionGroup"

#define KDeskNumber @"KF4008818600668603"

#define kSofeVer @"5.2.0r"

@class ECLoginInfo;

@interface DemoGlobalClass : NSObject
/**
 *@brief 获取DemoGlobalClass单例句柄
 */
+(DemoGlobalClass*)sharedInstance;


/**
 *@brief 主账号信息
 */
@property (nonatomic, strong) NSMutableDictionary* mainAccontDictionary;

@property (nonatomic, strong) NSMutableDictionary* allSessions;

@property (nonatomic, readonly) NSString* appKey;

@property (nonatomic, readonly) NSString* appToken;

@property (nonatomic, copy) NSString* userName;

@property (nonatomic, copy) NSString* userPassword;

@property (nonatomic, assign) LoginAuthType loginAuthType;

@property (nonatomic, copy) NSString* nickName;

@property (nonatomic, assign) ECSexType sex;

@property (nonatomic, copy) NSString *birth;

@property (nonatomic, copy) NSString *sign;

@property (nonatomic, assign) unsigned long long dataVersion;

//是否已经登录
@property (nonatomic, assign) BOOL isAutoLogin;

@property (nonatomic, assign) BOOL isLogin;

@property (nonatomic, assign) BOOL isHiddenLoginError;//是否已经发起登录请求

@property (nonatomic, assign) ECNetworkType netType;

@property (nonatomic, assign) BOOL isNeedSetData;

@property (nonatomic, assign) BOOL isNeedUpdate;

@property (nonatomic, assign) BOOL isMessageSound;

@property (nonatomic, assign) BOOL isMessageShake;

@property (nonatomic, assign) BOOL isPlayEar;

@property (nonatomic, strong) NSMutableArray *interphoneArray;

@property (nonatomic, strong) NSString *curinterphoneid;

@property (nonatomic, assign) BOOL isCallBusy;

@property (nonatomic, strong) NSMutableData* receiveData;

/**
 *@brief 根据电话获取联系人姓名
 *@param phone 联系人电话
 */
-(NSString*)getOtherNameWithPhone:(NSString*)phone;


/**
 *@brief 根据电话获取联系人头像
 *@param phone 联系人电话、群组id
 */
-(UIImage*)getOtherImageWithPhone:(NSString*)phone;

/**
 *@brief 判断SDK是否支持VoIP
 *@return YES:支持 NO:不支持
 */
-(BOOL)isSDKSupportVoIP;

/**
 *  判断是否群组和讨论组
 @brief 群组id
 @brief 0 群组 101 讨论组
 */
-(BOOL)isDiscussGroupOfId:(NSString *)groupId;

- (void)setAppKey:(NSString *)appKey AndAppToken:(NSString*)apptoken;
- (void)setConfigData:(NSString*)CIP :(NSString*)CPORT :(NSString*)LIP :(NSString*)LPORT :(NSString*)FIP :(NSString*)FPORT;
- (void)resetResourceServer;
@end
