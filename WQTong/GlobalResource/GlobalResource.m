//
//  GlobalResource.m
//  Movie
//
//  Created by ChenBinbin on 10/15/15.
//  Copyright © 2015 cnbin. All rights reserved.
//

#import "GlobalResource.h"

@implementation GlobalResource

//一般单例模式
//__strong static GlobalResource *share = nil;
//
//+ (instancetype)sharedInstance
//{
//    static dispatch_once_t pred = 0;
//    dispatch_once(&pred, ^{
//        share = [[super allocWithZone:NULL] init];
//    });
//    return share;
//}

//严格单例模式，防止子类使用
__strong static GlobalResource *share = nil;

+ (instancetype)sharedInstance {
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        
        share = (GlobalResource *)@"GlobalResource";
        share = [[GlobalResource alloc] init];
    });
    
    // 防止子类使用
    NSString *classString = NSStringFromClass([self class]);
    if ([classString isEqualToString:@"GlobalResource"] == NO) {
        
        NSParameterAssert(nil);
    }
    
    return share;
}

- (instancetype)init {
    
    NSString *string = (NSString *)share;
    if ([string isKindOfClass:[NSString class]] == YES && [string isEqualToString:@"GlobalResource"]) {
        
        self = [super init];
        if (self) {
            
            // 防止子类使用
            NSString *classString = NSStringFromClass([self class]);
            if ([classString isEqualToString:@"GlobalResource"] == NO) {
                
                NSParameterAssert(nil);
            }
        }
        
        return self;
        
    } else {
        
        return nil;
    }
}

@end
