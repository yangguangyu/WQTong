//
//  SelectListViewCell.m
//  ECSDKDemo_OC
//
//  Created by lrn on 14/12/15.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "SelectListViewCell.h"

@implementation SelectListViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _portraitImg = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 10.0f, 45.0f, 45.0f)];
        _portraitImg.contentMode = UIViewContentModeScaleAspectFit;
        _portraitImg.image = [UIImage imageNamed:@"personal_portrait"];
        [self.contentView addSubview:_portraitImg];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0f, 10.0f, self.frame.size.width-80.0f, 25.0f)];
        _nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_nameLabel];
        
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y+_nameLabel.frame.size.height, _nameLabel.frame.size.width, 15.0f)];
        _numberLabel.font = [UIFont systemFontOfSize:13.0f];
        _numberLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _numberLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_numberLabel];
        
        _selecImage = [[UIImageView alloc]initWithFrame:CGRectMake(285.0f, 20.0f, 24.5f, 24.5f)];
        _selecImage.image =[UIImage imageNamed:@"select_account_list_unchecked"];
        
        [self.contentView addSubview:_selecImage];
        
    }
    return self;
}

@end
