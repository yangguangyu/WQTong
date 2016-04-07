//
//  GroupCardViewController.h
//  ECSDKDemo_OC
//
//  Created by admin on 15/10/27.
//  Copyright © 2015年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupCardViewController : UIViewController
/**
 @method
 @brief 群组名片
 @param groupId 群组id
 */
-(GroupCardViewController *)initWithGroupID:(NSString *)groupId;
@end
