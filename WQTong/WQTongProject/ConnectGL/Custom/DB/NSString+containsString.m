//
//  NSString+containsString.m
//  ECSDKDemo_OC
//
//  Created by admin on 15/11/5.
//  Copyright © 2015年 ronglian. All rights reserved.
//

#import "NSString+containsString.h"

@implementation NSString (containsString)

- (BOOL)myContainsString:(NSString*)other {
    
    if ([[UIDevice currentDevice].systemVersion integerValue] >7) {
        return [self containsString:other];
    }
    NSRange range = [self rangeOfString:other];
    return (range.location == NSNotFound?NO:YES);
}

@end
