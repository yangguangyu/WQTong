//
//  GroupNoticeTableViewCell.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 15/3/26.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupNoticeTableViewCell : UITableViewCell
@property (nonatomic, strong) UIImageView *portraitImg;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *confirmLabel;
@property (nonatomic, strong) id cellContentId;
@property (nonatomic, assign) NSInteger cellConfirm;
@end
