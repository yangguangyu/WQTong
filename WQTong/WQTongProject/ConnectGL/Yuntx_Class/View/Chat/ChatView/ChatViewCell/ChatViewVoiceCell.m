//
//  ChatViewVoiceCell.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/11.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ChatViewVoiceCell.h"
#import <objc/runtime.h>

NSString *const KResponderCustomChatViewVoiceCellBubbleViewEvent = @"KResponderCustomChatViewVoiceCellBubbleViewEvent";

const char KVoiceIsPlayKey;

@interface ChatViewVoiceCell()
@property (nonatomic, strong) UIImageView *voicePlayImgView;
@end

@implementation ChatViewVoiceCell {
    UILabel *_lengthLabel;
    UIImageView *_downloadingImg;
}
-(instancetype) initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        
        _lengthLabel = [[UILabel alloc] init];
        _lengthLabel.textColor = [UIColor grayColor];
        _lengthLabel.backgroundColor = self.backgroundColor;
        _lengthLabel.font = [UIFont systemFontOfSize:13.0f];
        if (self.isSender) {
            
            self.voicePlayImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playback_right_icon_01"]];
            _voicePlayImgView.frame = CGRectMake(self.bubbleView.frame.size.width-26.0f-10.0f-10.0f, 8.0f, 26.0f, 29.0f);
            [self.bubbleView addSubview:_voicePlayImgView];
            _voicePlayImgView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"playback_right_icon_02"], [UIImage imageNamed:@"playback_right_icon_03"], [UIImage imageNamed:@"playback_right_icon_02"],[UIImage imageNamed:@"playback_right_icon_01"], nil];
            _lengthLabel.textAlignment = NSTextAlignmentRight;
            
        } else {
            
            self.voicePlayImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playback_left_icon_01"]];
            _voicePlayImgView.frame = CGRectMake(10.0f+10.0f, 8.0f, 26.0f, 29.0f);
            [self.bubbleView addSubview:_voicePlayImgView];
            _voicePlayImgView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"playback_left_icon_02"],[UIImage imageNamed:@"playback_left_icon_03"], [UIImage imageNamed:@"playback_left_icon_02"], [UIImage imageNamed:@"playback_left_icon_01"], nil];
            _lengthLabel.textAlignment = NSTextAlignmentLeft;
            
            _downloadingImg = (UIImageView*)[self.bubbleView viewWithTag:1000];
            _downloadingImg.animationDuration = 1.0;
            _downloadingImg.animationImages = @[[[UIImage imageNamed:@"chat_receiver_bg_on"] stretchableImageWithLeftCapWidth:33.0f topCapHeight:33.0f],[[UIImage imageNamed:@"chat_receiver_bg"] stretchableImageWithLeftCapWidth:33.0f topCapHeight:33.0f]];
        }
        _voicePlayImgView.animationDuration = 1;

        [self.contentView addSubview:_lengthLabel];
    }
    return self;
}

-(void)bubbleViewTapGesture:(id)sender{
    
    [self dispatchCustomEventWithName:KResponderCustomChatViewVoiceCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage}];
}

-(void)bubbleViewWithData:(ECMessage*) message{
    [super bubbleViewWithData:message];
    
    NSNumber *isplay = objc_getAssociatedObject(message, &KVoiceIsPlayKey);
    if (isplay && isplay.boolValue) {
        [_voicePlayImgView startAnimating];
    } else {
        [_voicePlayImgView stopAnimating];
    }
}

+(CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    
    return 65.0f;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    ECVoiceMessageBody *mediaBody = (ECVoiceMessageBody*)self.displayMessage.messageBody;
    if ([[NSFileManager defaultManager] fileExistsAtPath:mediaBody.localPath] && (mediaBody.mediaDownloadStatus==ECMediaDownloadSuccessed || self.displayMessage.messageState != ECMessageState_Receive))
    {
        unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:mediaBody.localPath error:nil] fileSize];
        mediaBody.duration = (int)(fileSize/650);
        if (mediaBody.duration == 0) {
            mediaBody.duration = 1;
        }
        _lengthLabel.text = [NSString stringWithFormat:@"%d″",(int)mediaBody.duration];
        _lengthLabel.hidden = NO;
    } else {
        mediaBody.duration = 0;
        _lengthLabel.hidden = YES;
    }
    
    CGFloat width = [self getWidthWithTime:mediaBody.duration];
    
    if (self.isSender) {
        
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-width-10.0f, self.portraitImg.frame.origin.y, width, 45.0f);
        
        self.voicePlayImgView.frame = CGRectMake(self.bubbleView.frame.size.width-26.0f-10.0f-10.0f, 8.0f, 26.0f, 29.0f);
        
        _lengthLabel.frame = CGRectMake(self.bubbleView.frame.origin.x-30.0f, self.bubbleView.frame.origin.y+15.0f, 30.0f, 15.0f);
        
    } else {
        
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10.0f+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, width, 45.0f);
        
        self.voicePlayImgView.frame = CGRectMake(10.0f+10.0f, 8.0f, 26.0f, 29.0f);
        
        _lengthLabel.frame = CGRectMake(self.bubbleView.frame.origin.x+self.bubbleView.frame.size.width+3.0f, self.bubbleView.frame.origin.y+15.0f, 30.0f, 15.0f);
        
        self.voicePlayImgView.hidden = _lengthLabel.hidden;
        if (_lengthLabel.hidden) {
            [_downloadingImg startAnimating];
        } else {
            [_downloadingImg stopAnimating];
        }
    }
    
    [super updateMessageSendStatus:self.displayMessage.messageState];
    
    CGRect frame = _lengthLabel.frame;
    frame.origin.y = self.bubbleView.frame.origin.y+15.0f;
    _lengthLabel.frame = frame;
}

-(CGFloat)getWidthWithTime:(NSInteger)time {
    if (time <= 0)
        return 140.0f;
    else if (time <= 2)
        return 80.0f;
    else if (time < 10)
        return (80.0f + 9.0f * (time - 2));
    else if (time < 60)
        return (80.0f + 9.0f * (7 + time / 10));
    return 200.0f;
}
@end
