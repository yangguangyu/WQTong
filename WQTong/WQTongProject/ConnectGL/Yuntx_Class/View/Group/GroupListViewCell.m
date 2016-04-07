//
//  GroupListViewCell.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "GroupListViewCell.h"

@implementation GroupListViewCell
{
    UIImageView *_headImage;
    UILabel *_nameLabel;
    UILabel *_numberLabel;
    UILabel *_joinLabel;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _headImage = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 10.0f, 45.0f, 45.0f)];
        _headImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_headImage];
        _headImage.image = [UIImage imageNamed:@"group_head"];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0f, 10.0f, screenWidth-70.0f-60.0f, 25.0f)];
        _nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_nameLabel];
        
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y+_nameLabel.frame.size.height, _nameLabel.frame.size.width, 15.0f)];
        _numberLabel.font = [UIFont systemFontOfSize:13.0f];
        _numberLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _numberLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_numberLabel];
        
        _joinLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-60.0f, 17.5f, 60.0f, 30.0f)];
        _joinLabel.text = @"已创建";
        _joinLabel.textAlignment = NSTextAlignmentCenter;
        _joinLabel.textColor = [UIColor colorWithRed:0.04f green:0.75f blue:0.40f alpha:1.00f];
        _joinLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_joinLabel];
    }
    return self;
}

-(void)setTableViewCellNameLabel:(NSString *)name andNumberLabel:(NSString *)number andIsJoin:(BOOL)isJoin andMemberNumber:(NSInteger)memberNum
{
    _nameLabel.text = name;
    if (_isDiscuss == NO) {
        _numberLabel.text = [NSString stringWithFormat:@"群组id:%@",number];
    } else {
        _numberLabel.text = [NSString stringWithFormat:@"讨论组id:%@",number];
    }
    _joinLabel.hidden = !isJoin;
    if (memberNum > 1) {
        _joinLabel.text = [NSString stringWithFormat:@"已加入"];
    }
}

@end
