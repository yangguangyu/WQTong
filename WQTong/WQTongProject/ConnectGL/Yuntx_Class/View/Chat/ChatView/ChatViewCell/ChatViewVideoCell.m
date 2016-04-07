//
//  ChatViewVideoCell.m
//  ECSDKDemo_OC
//
//  Created by lrn on 14/12/30.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ChatViewVideoCell.h"
#import "UIImageView+WebCache.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
NSString *const KResponderCustomChatViewVideoCellBubbleViewEvent = @"KResponderCustomChatViewVideoCellBubbleViewEvent";
@implementation ChatViewVideoCell {
    UIImageView* _displayImage;
    UIButton * _playBtn;
    UILabel *fileSizeLabel;
}

-(instancetype) initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        
        _displayImage = [[UIImageView alloc] init];
        _displayImage.contentMode = UIViewContentModeScaleAspectFill;
        _displayImage.clipsToBounds = YES;
        _playBtn = [[UIButton alloc]init];
        [_playBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
        [_playBtn setImage:[UIImage imageNamed:@"video_button_play_normal"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"video_button_play_pressed"] forState:UIControlStateHighlighted];
        
        fileSizeLabel = [[UILabel alloc] init];
        fileSizeLabel.textColor = [UIColor whiteColor];
        fileSizeLabel.font = [UIFont systemFontOfSize:12.0f];
        if (self.isSender) {
            
            _displayImage.frame = CGRectMake(5, 5, 90.0f, 120.0f);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-120.0f, self.portraitImg.frame.origin.y-5, 110.0f, 130.0f);
            
        } else {
            
            _displayImage.frame = CGRectMake(15, 5, 90.0f, 120.0f);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10.0f+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 110.0f, 130.0f);
            fileSizeLabel.frame = CGRectMake(15.0f, self.bubbleView.frame.size.height-20.0f, 50.0f, 15.0f);
        }
        
        _playBtn.frame = CGRectMake(_displayImage.frame.origin.x+27.0f, _displayImage.frame.origin.y+42.0f, 35.0f, 35.0f);
        
        [self.bubbleView addSubview:_displayImage];
        [self.bubbleView addSubview:_playBtn];
        [self.bubbleView addSubview:fileSizeLabel];
    }
    return self;
}

+(CGFloat)getHightOfCellViewWith:(ECMessageBody *)message {
    return 150.0f;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    ECMessage *message = self.displayMessage;
    ECVideoMessageBody *mediaBody = (ECVideoMessageBody*)message.messageBody;
    
    if (mediaBody.localPath.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:mediaBody.localPath] && (mediaBody.mediaDownloadStatus==ECMediaDownloadSuccessed || message.messageState != ECMessageState_Receive)) {
        
        UIImage *image = [self getVideoImage:[mediaBody.localPath copy]];
        
        if (image) {
            _displayImage.image = image;
        }
        fileSizeLabel.text = nil;
        
    } else if (mediaBody.thumbnailRemotePath.length>0){
        
        [_displayImage sd_setImageWithURL:[NSURL URLWithString:mediaBody.thumbnailRemotePath] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            if (image) {
                _displayImage.image = image;
            }
            if (mediaBody.fileLength) {
                fileSizeLabel.text = [NSString stringWithFormat:@"%.1fM",(float)(mediaBody.fileLength/1024)/1024];
            }
        }];
    }
    
    [super updateMessageSendStatus:self.displayMessage.messageState];
}

-(void)bubbleViewTapGesture:(id)sender {
    
}

-(void)playVideo {
    [self dispatchCustomEventWithName:KResponderCustomChatViewVideoCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage}];
}

-(UIImage *)getVideoImage:(NSString *)videoURL
{
    NSString* fileNoExtStr = [videoURL stringByDeletingPathExtension];
    NSString* imagePath = [NSString stringWithFormat:@"%@.jpg", fileNoExtStr];
    UIImage *returnImage = [[UIImage alloc] initWithContentsOfFile:imagePath] ;
    if (returnImage){
        return returnImage;
    }
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:opts] ;
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset] ;
    gen.appliesPreferredTrackTransform = YES;
    gen.maximumSize = CGSizeMake(360.0f, 480.0f);
    NSError *error = nil;
    CGImageRef image = [gen copyCGImageAtTime: CMTimeMake(1, 1) actualTime:NULL error:&error];
    returnImage = [[UIImage alloc] initWithCGImage:image] ;
    CGImageRelease(image);
    [UIImageJPEGRepresentation(returnImage, 0.6) writeToFile:imagePath atomically:YES];
    if (returnImage) {
        return returnImage;
    }
    
    return nil;
}

@end
