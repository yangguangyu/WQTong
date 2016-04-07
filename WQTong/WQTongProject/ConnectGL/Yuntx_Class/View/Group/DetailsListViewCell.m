//
//  DetailsListViewCell.m
//  ECSDKDemo_OC
//
//  Created by lrn on 14/12/12.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "DetailsListViewCell.h"

@implementation DetailsListViewCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        _headImage = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 10.0f, 45.0f, 45.0f)];
        _headImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_headImage];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0f, 10.0f, self.frame.size.width-70.0f-65.0f, 25.0f)];
        _nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _nameLabel.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_nameLabel];
        
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y+_nameLabel.frame.size.height, _nameLabel.frame.size.width, 15.0f)];
        _numberLabel.font = [UIFont systemFontOfSize:13.0f];
        _numberLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _numberLabel.textColor = [UIColor grayColor];
        _numberLabel.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_numberLabel];
        
        _forbidBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _forbidBtn.frame = CGRectMake(self.contentView.frame.size.width-65.0f, 5.0f, 60.0f, 25.0f);
        _forbidBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_forbidBtn setBackgroundImage:[[UIImage imageNamed:@"button_white"] stretchableImageWithLeftCapWidth:5 topCapHeight:9] forState:UIControlStateNormal];
        [_forbidBtn setTitle:@"禁言" forState:UIControlStateNormal];
        [_forbidBtn setTitleColor:[UIColor colorWithRed:0.04f green:0.75f blue:0.40f alpha:1.00f] forState:UIControlStateNormal];
        _forbidBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_forbidBtn];

        _removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _removeBtn.frame = CGRectMake(_forbidBtn.frame.origin.x, 35.0f, _forbidBtn.frame.size.width, _forbidBtn.frame.size.height);
        _removeBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_removeBtn setBackgroundImage:[[UIImage imageNamed:@"button_white"] stretchableImageWithLeftCapWidth:5 topCapHeight:9] forState:UIControlStateNormal];
        [_removeBtn setTitle:@"踢出" forState:UIControlStateNormal];
        [_removeBtn setTitleColor:[UIColor colorWithRed:0.04f green:0.75f blue:0.40f alpha:1.00f] forState:UIControlStateNormal];
        _removeBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_removeBtn];
        
    }
    return self;
}
@end
