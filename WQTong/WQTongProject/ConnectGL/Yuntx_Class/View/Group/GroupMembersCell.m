//
//  GroupMembersCell.m
//  ECSDKDemo_OC
//
//  Created by admin on 15/10/26.
//  Copyright © 2015年 ronglian. All rights reserved.
//

#import "GroupMembersCell.h"

@implementation GroupMembersCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        _headImage = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 10.0f, 45.0f, 45.0f)];
        _headImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_headImage];
        
        _role = [[UILabel alloc] initWithFrame:CGRectMake(70.0f, _headImage.bounds.size.height/2, 30.0f, 25.0f)];
        _role.font = [UIFont systemFontOfSize:13.0f];
        _role.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _role.textColor = [UIColor grayColor];
        _role.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_role];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_role.frame)+_role.bounds.size.width+10.0f, _headImage.bounds.size.height/2, 200.0f, 25.0f)];
        _nameLabel.font = [UIFont systemFontOfSize:13.0f];
        _nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _nameLabel.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_nameLabel];
    }
    return self;
}
@end
