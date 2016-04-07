//
//  SessionViewCell.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "SessionViewCell.h"

@implementation SessionViewCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _portraitImg = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f*scaleModulus, 10.0f, 45.0f, 45.0f)];
        _portraitImg.contentMode = UIViewContentModeScaleAspectFit;
        _portraitImg.image = [UIImage imageNamed:@"personal_portrait"];
        [self.contentView addSubview:_portraitImg];
        
        
        _dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(210.0f*scaleModulus, 5.0f, 100.0f, 20.0f)];
        _dateLabel.textColor = [UIColor colorWithRed:0.80f green:0.80f blue:0.80f alpha:1.00f];
        _dateLabel.font = [UIFont systemFontOfSize:13];
        _dateLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_dateLabel];
        
        _unReadLabel = [[UILabel alloc]initWithFrame:CGRectMake(280.0f*scaleModulus, 35.0f, 25.0f, 20.0f)];
        _unReadLabel.backgroundColor = [UIColor redColor];
        _unReadLabel.textColor = [UIColor whiteColor];
        _unReadLabel.font = [UIFont systemFontOfSize:13];
        _unReadLabel.layer.cornerRadius =10;
        _unReadLabel.layer.masksToBounds = YES;
        
        _unReadLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_unReadLabel];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0f*scaleModulus, 10.0f, _dateLabel.frame.origin.x-70.0f, 25.0f)];
        _nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_nameLabel];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y+_nameLabel.frame.size.height, screenWidth-140.0f, 15.0f)];
        _contentLabel.font = [UIFont systemFontOfSize:13.0f];
        _contentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _contentLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_contentLabel];
        
        _noPushImg = [[UIImageView alloc] initWithFrame:CGRectMake(290.0f*scaleModulus, 37.0f, 15.0f, 15.0f)];
        _noPushImg.image = [UIImage imageNamed:@"chat_group_notpush"];
        [self.contentView addSubview:_noPushImg];
    }
    
    return self;
}

@end
