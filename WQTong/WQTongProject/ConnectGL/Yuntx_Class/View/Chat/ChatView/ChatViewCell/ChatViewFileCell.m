//
//  ChatViewFileCell.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/11.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ChatViewFileCell.h"

NSString *const KResponderCustomChatViewFileCellBubbleViewEvent = @"KResponderCustomChatViewFileCellBubbleViewEvent";

@implementation ChatViewFileCell
{
    UILabel *_fileNameLabel;
}
-(instancetype) initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        
        CGFloat frameX = 0.0f;
        UIImageView *fileImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"attachment_icon"]];
        if (self.isSender) {
            
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-210.0f-10.0f, self.portraitImg.frame.origin.y, 210.0f, 45.0f);
            
            fileImg.frame = CGRectMake(10.0f, 10.0f, 26.0f, 26.0f);
            [self.bubbleView addSubview:fileImg];
            
            frameX = fileImg.frame.origin.x+fileImg.frame.size.width+5.0f;
            _fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameX, 5.0f, self.bubbleView.frame.size.width-frameX-10.0f, 35.0f)];
            [self.bubbleView addSubview:_fileNameLabel];
            
        } else {
            
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10.0f+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 210.0f, 45.0f);
            
            fileImg.frame = CGRectMake(10.0f+10.0f, 10.0f, 26.0f, 26.0f);
            [self.bubbleView addSubview:fileImg];
            
            frameX = fileImg.frame.origin.x+fileImg.frame.size.width+10.0f;
            _fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameX, 5.0f, self.bubbleView.frame.size.width-frameX-5.0f, 35.0f)];
            [self.bubbleView addSubview:_fileNameLabel];
        }
        _fileNameLabel.font = [UIFont systemFontOfSize:13.0f];
        _fileNameLabel.numberOfLines = 0;
    }
    return self;
}

-(void)bubbleViewTapGesture:(id)sender{
    
    [self dispatchCustomEventWithName:KResponderCustomChatViewFileCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage}];
}

+(CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    return 65.0f;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    ECFileMessageBody *body = (ECFileMessageBody*)self.displayMessage.messageBody;
    _fileNameLabel.text = body.displayName;
    [super updateMessageSendStatus:self.displayMessage.messageState];
}
@end
