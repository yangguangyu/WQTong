//
//  ChatViewImageCell.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/16.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ChatViewImageCell.h"
#import "UIImageView+WebCache.h"
#import "UIImage+MultiFormat.h"
#import "CommonTools.h"
#import "NSString+containsString.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
#define kCGImageAlphaPremultipliedLast  (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast)
#else
#define kCGImageAlphaPremultipliedLast  kCGImageAlphaPremultipliedLast
#endif

NSString *const KResponderCustomChatViewImageCellBubbleViewEvent = @"KResponderCustomChatViewImageCellBubbleViewEvent";

@implementation ChatViewImageCell{
    UIImageView* _displayImage;
    UIImageView* _gifFlagImage;
    BOOL isAllowClickReadDeleteMessage;
}

-(instancetype) initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        
        _displayImage = [[UIImageView alloc] init];
        _displayImage.contentMode = UIViewContentModeScaleAspectFill;
        _displayImage.clipsToBounds = YES;
        
        if (self.isSender) {
            _displayImage.frame = CGRectMake(5, 5, 110.0f, 120.0f);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-140.0f, self.portraitImg.frame.origin.y, 130.0f, 130.0f);
            
        } else {
            _displayImage.frame = CGRectMake(15, 5, 110.0f, 120.0f);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10.0f+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 130.0f, 130.0f);
        }
        [self.bubbleView addSubview:_displayImage];
        
        _gifFlagImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 50.0f, 50.0f)];
        _gifFlagImage.center = CGPointMake(_displayImage.frame.size.width*0.5, _displayImage.frame.size.height*0.5);
        _gifFlagImage.image = [UIImage imageNamed:@"chat_play_gif"];
        _gifFlagImage.hidden = YES;
        [_displayImage addSubview:_gifFlagImage];
    }
    return self;
}

-(void)bubbleViewTapGesture:(id)sender {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@",self.displayMessage.messageId]] == NO) {

        [self dispatchCustomEventWithName:KResponderCustomChatViewImageCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage}];
        isAllowClickReadDeleteMessage = ([self.displayMessage.userData myContainsString:@"fireMessage"] && !self.isSender);
        
        [[NSUserDefaults standardUserDefaults] setBool:isAllowClickReadDeleteMessage forKey:[NSString stringWithFormat:@"%@",self.displayMessage.messageId]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@",self.displayMessage.messageId]]==YES) {
            
            [[ECDevice sharedInstance].messageManager deleteMessage:self.displayMessage completion:^(ECError *error, ECMessage *message) {
                
                [[IMMsgDBAccess sharedInstance] updateMessageLocalPath:message.messageId withPath:@"" withDownloadState:ECMediaDownloadSuccessed andSession:message.sessionId];
            }];
        }
    }

}

+(CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    return 150.0f;
}

-(void)getImageWithwidth:(CGFloat)width andgetImageWithhight:(CGFloat)hight {
    
    CGFloat newWidth = 120*width/hight;
    if (newWidth > 200) {
        newWidth = 200;
    } else if (newWidth < 70) {
        newWidth = 70;
    }
    if (self.isSender) {
        _displayImage.frame = CGRectMake(5, 5, newWidth, 120.0f);
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-newWidth-30, self.portraitImg.frame.origin.y, newWidth+20, 130.0f);
        
    } else {
        _displayImage.frame = CGRectMake(15, 5, newWidth, 120.0f);
        
        CGFloat imageFrameY = self.portraitImg.frame.origin.y;
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10.0f+self.portraitImg.frame.size.width, imageFrameY, newWidth+20, 130.0f);
    }
    
    ECMessage *message = self.displayMessage;
    ECImageMessageBody *mediaBody = (ECImageMessageBody*)message.messageBody;
    if ([@"gif" isEqualToString:mediaBody.localPath.pathExtension.lowercaseString]) {
        _gifFlagImage.hidden = NO;
        _gifFlagImage.center = CGPointMake(_displayImage.frame.size.width*0.5, _displayImage.frame.size.height*0.5);
    } else {
        _gifFlagImage.hidden = YES;
    }
    
    [super updateMessageSendStatus:self.displayMessage.messageState];
}

-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    ECMessage *message = self.displayMessage;
    ECImageMessageBody *mediaBody = (ECImageMessageBody*)message.messageBody;
    
    UIImage* defaultimg = [UIImage imageNamed:@"chat_placeholder_image"];
    _displayImage.image = defaultimg;
    
    [self getImageWithwidth:defaultimg.size.width andgetImageWithhight:defaultimg.size.height];
        
    if ([message.userData myContainsString:@"fireMessage"] && !self.isSender) {
        
        _displayImage.image = [UIImage imageNamed:@"chat_snapchat_unread"];
        [self getImageWithwidth:defaultimg.size.width andgetImageWithhight:defaultimg.size.height];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@",self.displayMessage.messageId]] == YES){
            _displayImage.image = [UIImage imageNamed:@"chat_snapchat_readed"];
            [self getImageWithwidth:defaultimg.size.width andgetImageWithhight:defaultimg.size.height];
        }
        
    } else {
        
        __weak __typeof(self)weakSelf = self;
        if (mediaBody.localPath.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:mediaBody.localPath] && (mediaBody.mediaDownloadStatus==ECMediaDownloadSuccessed || message.messageState != ECMessageState_Receive)) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @autoreleasepool {
                    UIImage *image = [UIImage imageWithContentsOfFile:mediaBody.localPath];
                    if (image==nil) {
                        return;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _displayImage.image = image;
                        [weakSelf getImageWithwidth:image.size.width andgetImageWithhight:image.size.height];
                    });
                }
            });
        } else if (message.messageState == ECMessageState_Receive && mediaBody.thumbnailRemotePath.length>0) {
            [_displayImage sd_setImageWithURL:[NSURL URLWithString:mediaBody.thumbnailRemotePath] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                if (image) {
                    _displayImage.image = image;
                    [weakSelf getImageWithwidth:image.size.width andgetImageWithhight:image.size.height];
                }
            }];
        } else {
            _displayImage.image = [UIImage imageNamed:@"chat_snapchat_readed"];
            [self getImageWithwidth:defaultimg.size.width andgetImageWithhight:defaultimg.size.height];
        }
    }
}
@end
