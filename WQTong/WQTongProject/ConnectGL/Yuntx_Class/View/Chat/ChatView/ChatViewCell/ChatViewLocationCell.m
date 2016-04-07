//
//  chatViewLocationCell.m
//  ECSDKDemo_OC
//
//  Created by admin on 15/12/16.
//  Copyright © 2015年 ronglian. All rights reserved.
//

#import "ChatViewLocationCell.h"

NSString *const KResponderCustomChatViewLocationCellBubbleViewEvent = @"KResponderCustomChatViewLocationCellBubbleViewEvent";

@implementation ChatViewLocationCell
{
    UIImageView* _displayImage;
    UIImageView* _gifFlagImage;
    UILabel* _locationLabel;
}
-(instancetype) initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        
        _displayImage = [[UIImageView alloc] init];
        _displayImage.contentMode = UIViewContentModeScaleAspectFill;
        _displayImage.clipsToBounds = YES;
        
        _locationLabel = [[UILabel alloc] init];
        _locationLabel.textColor = [UIColor whiteColor];
        _locationLabel.font = [UIFont systemFontOfSize:12.0f];
        _locationLabel.textAlignment = NSTextAlignmentCenter;
        _locationLabel.numberOfLines = 0;
        
        if (self.isSender) {
            _displayImage.frame = CGRectMake(5, 5, 110.0f, 120.0f);
            _locationLabel.frame = CGRectMake(5, 85.0f, 110.0f, 40.0f);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-140.0f, self.portraitImg.frame.origin.y, 130.0f, 130.0f);
        } else {
            _displayImage.frame = CGRectMake(15, 5, 110.0f, 120.0f);
            _locationLabel.frame = CGRectMake(15, 85.0f, 110.0f, 40.0f);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10.0f+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 130.0f, 130.0f);
        }
        [self.bubbleView addSubview:_displayImage];
        [self.bubbleView addSubview:_locationLabel];
    }
    return self;
}

-(void)bubbleViewTapGesture:(id)sender{
    
    [self dispatchCustomEventWithName:KResponderCustomChatViewLocationCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage}];
}

+(CGFloat)getHightOfCellViewWith:(ECMessageBody *)message {
    return 140.0f;
}

-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    ECMessage *message = self.displayMessage;
    ECLocationMessageBody *locationBody = (ECLocationMessageBody*)message.messageBody;
    _locationLabel.text = locationBody.title;
    [_locationLabel sizeToFit];
    _displayImage.image = [UIImage imageNamed:@"chatView_location_map"];
    
    [super updateMessageSendStatus:self.displayMessage.messageState];
}
@end
