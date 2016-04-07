//
//  DetailsListViewCell.h
//  ECSDKDemo_OC
//
//  Created by lrn on 14/12/12.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsListViewCell : UITableViewCell

@property (nonatomic, strong) ECGroupMember* member;
@property (nonatomic, strong) UIImageView *headImage;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) NSString * memberId;
@property (nonatomic, strong) UIButton *removeBtn;
@property (nonatomic, strong) UIButton *forbidBtn;

@end
