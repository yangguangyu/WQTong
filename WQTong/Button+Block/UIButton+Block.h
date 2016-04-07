//
//  UIButton+Block.h
//  ZQYTNApp
//
//  Created by chen qixiao on 14-3-10.
//  Copyright (c) 2014年 qqc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>


typedef void (^ActionBlock)();

@interface UIButton(Block)

@property (readonly) NSMutableDictionary *event;

- (void) handleControlEvent:(UIControlEvents)controlEvent withBlock:(ActionBlock)action;

@end
