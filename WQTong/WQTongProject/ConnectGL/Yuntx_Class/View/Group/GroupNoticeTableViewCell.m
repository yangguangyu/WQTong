//
//  GroupNoticeTableViewCell.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 15/3/26.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "GroupNoticeTableViewCell.h"

@implementation GroupNoticeTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _portraitImg = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 10.0f, 45.0f, 45.0f)];
        _portraitImg.contentMode = UIViewContentModeScaleAspectFit;
        _portraitImg.image = [UIImage imageNamed:@"personal_portrait"];
        [self.contentView addSubview:_portraitImg];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0f, 5.0f, self.frame.size.width-150.0f, 55.0f)];
        _contentLabel.font = [UIFont systemFontOfSize:13.0f];
        _contentLabel.numberOfLines = 0;
        _contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _contentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _contentLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_contentLabel];
        
        _confirmLabel = [[UILabel alloc] initWithFrame:CGRectMake(_contentLabel.frame.origin.x+_contentLabel.frame.size.width+10.0f,20.0f,60.0f, 25.0f)];
        _confirmLabel.font = [UIFont systemFontOfSize:13.0f];
        _confirmLabel.numberOfLines = 1;
        _confirmLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _confirmLabel.textColor = [UIColor blueColor];
        [self.contentView addSubview:_confirmLabel];
    }
    return self;
}

-(void)setCellConfirm:(NSInteger)cellConfirm {
    
    CGRect frame = _contentLabel.frame;
    frame.size.width = self.frame.size.width-150.0f;
    _contentLabel.frame = frame;
    
    _confirmLabel.hidden = NO;
    
    _cellConfirm = cellConfirm;
    switch (cellConfirm) {
        case 0:
            _confirmLabel.text=nil;
            _confirmLabel.hidden = YES;
            
            frame.size.width = self.frame.size.width-90.0f;
            _contentLabel.frame = frame;
            break;
            case 2:
            _confirmLabel.text=@"已处理";
            break;
        default:
            _confirmLabel.text=@"点击查看";
            break;
    }
}
@end
