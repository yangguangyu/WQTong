//
//  CustomEmojiView.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/18.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomEmojiViewDelegate <NSObject>

-(void)emojiBtnInput:(NSInteger)emojiTag;
-(void)backspaceText;
-(void)emojiSendBtn:(id)sender;
@end

@interface CustomEmojiView : UIView

+(CustomEmojiView*)shardInstance;

@property (nonatomic, weak) id<CustomEmojiViewDelegate> delegate;
@end
