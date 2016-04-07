//
//  BBTableEmptyTipView.m
//  WQTong
//
//  Created by WuYongmin on 16/3/25.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "BBTableEmptyTipView.h"

@implementation BBTableEmptyTipView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self initData];
        [self initUI];
    }
    
    return self;
}

- (void)initData {
    
}

- (void)initUI {
    UIImage *tipImg = [UIImage imageNamed:@"Other_jiwangbingshi"];
    
    UIImageView *tipImgView = [[UIImageView alloc] initWithFrame:(CGRect) {self.frame.size.width/2.0f - tipImg.size.width/2.0f, self.frame.size.height/2.0f - tipImg.size.height, tipImg.size}];
    tipImgView.image = tipImg;
    [self addSubview:tipImgView];
    
//    HCUILabel *tipLabel = [[HCUILabel alloc] initWithFrame:(CGRect) {0, CGRectGetMaxY(tipImgView.frame) + margins_vert12, self.frame.size.width, height_64}];
//    tipLabel.font = [UIFont systemFontOfSize:14.0];
//    tipLabel.textColor = color_bbbbbb;
//    tipLabel.textAlignment = NSTextAlignmentCenter;
//    tipLabel.text = @"暂无数据";
//    tipLabel.numberOfLines = 0;
//    [self addSubview:tipLabel];
}


@end
