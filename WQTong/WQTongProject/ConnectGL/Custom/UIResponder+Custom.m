//
//  UIResponder+Dispatch.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/13.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "UIResponder+Custom.h"

@implementation UIResponder (Custom)

- (void)dispatchCustomEventWithName:(NSString *)name userInfo:(NSDictionary *)userInfo
{
    [self.nextResponder dispatchCustomEventWithName:name userInfo:userInfo];
}

@end

