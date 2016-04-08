//
//  KQXXView.m
//  WQTong
//
//  Created by ChenBinbin on 16/3/28.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "KQXXView.h"

@implementation KQXXView

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
       if (self) {
        
           //1.考勤打卡
           UIView *subView1 = [[UIView alloc]initWithFrame:(CGRect){0,0,screenWidth/3,screenWidth/3}];
           UIImageView *subImgView1 = [[UIImageView alloc]initWithFrame:(CGRect){30*scaleModulus,20,44,44}];
           subImgView1.image =[IconFont imageWithIcon:[IconFont icon:@"fa_map_marker" fromFont:fontAwesome] fontName:fontAwesome iconColor:themeColor iconSize:24.0f];
           [subView1 addSubview:subImgView1];
           UITapGestureRecognizer* singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(subView1Action:)];
           [subView1 addGestureRecognizer:singleTap1];
           [self addSubview:subView1];
           
           UILabel *label1 = [[UILabel alloc]initWithFrame:(CGRect){subImgView1.frame.origin.x-8,subImgView1.frame.size.height+subImgView1.frame.origin.y+5,100,44}];
           label1.text = @"考勤打卡";
           label1.font = [UIFont fontWithName:@"Helvetica" size:15];
           [subView1 addSubview:label1];
           
           UIView *lineView1 = [[UIView alloc]initWithFrame:(CGRect){subView1.frame.size.width+1,0,1,screenWidth/3+1}];
           lineView1.backgroundColor = color_gray_light2;
           [self addSubview:lineView1];
           

           //2.考勤查询
           UIView *subView2 = [[UIView alloc]initWithFrame:(CGRect){subView1.frame.size.width+subView1.frame.origin.x+2,0,screenWidth/3,screenWidth/3}];
           UIImageView *subImgView2 = [[UIImageView alloc]initWithFrame:(CGRect){35*scaleModulus,20,44,44}];
           subImgView2.image =[IconFont imageWithIcon:[IconFont icon:@"fa_tags" fromFont:fontAwesome] fontName:fontAwesome iconColor:UIRGBColor(243,81,4,1) iconSize:24.0f];
           [subView2 addSubview:subImgView2];
           UITapGestureRecognizer* singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(subView2Action:)];
           [subView2 addGestureRecognizer:singleTap2];
           [self addSubview:subView2];
           
           UILabel *label2 = [[UILabel alloc]initWithFrame:(CGRect){subImgView2.frame.origin.x-8,subImgView2.frame.size.height+subImgView2.frame.origin.y+5,100,44}];
           label2.text = @"考勤查询";
           label2.font = [UIFont fontWithName:@"Helvetica" size:15];
           [subView2 addSubview:label2];
           
           
           UIView *lineView2 = [[UIView alloc]initWithFrame:(CGRect){subView2.frame.size.width+subView2.frame.origin.x+1,0,1,screenWidth/3+1}];
           lineView2.backgroundColor = color_gray_light2;
           [self addSubview:lineView2];
           
           
           
           //3.历史轨迹
           UIView *subView3 = [[UIView alloc]initWithFrame:(CGRect){subView2.frame.size.width+subView2.frame.origin.x+2,0,screenWidth/3,screenWidth/3}];
           UIImageView *subImgView3 = [[UIImageView alloc]initWithFrame:(CGRect){30*scaleModulus,20,44,44}];
           subImgView3.image =[IconFont imageWithIcon:[IconFont icon:@"fa_location_arrow" fromFont:fontAwesome] fontName:fontAwesome iconColor:UIRGBColor(139,0,139,1) iconSize:24.0f];
           [subView3 addSubview:subImgView3];
           UITapGestureRecognizer* singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(subView3Action:)];
           [subView3 addGestureRecognizer:singleTap3];
           [self addSubview:subView3];
           
           UILabel *label3 = [[UILabel alloc]initWithFrame:(CGRect){subImgView3.frame.origin.x-8,subImgView3.frame.size.height+subImgView3.frame.origin.y+5,100,44}];
           label3.text = @"历史轨迹";
           label3.font = [UIFont fontWithName:@"Helvetica" size:15];
           [subView3 addSubview:label3];
     
           UIView *lineView3 = [[UIView alloc]initWithFrame:(CGRect){0,subView3.frame.size.height+1,screenWidth,1}];
           lineView3.backgroundColor = color_gray_light2;
           [self addSubview:lineView3];
           
           
           
           //4.通讯录
           UIView *subView4 = [[UIView alloc]initWithFrame:(CGRect){0,subView1.frame.origin.y+subView1.frame.size.height+2,screenWidth/3,screenWidth/3}];
           UIImageView *subImgView4 = [[UIImageView alloc]initWithFrame:(CGRect){30*scaleModulus,20,44,44}];
           subImgView4.image =[IconFont imageWithIcon:[IconFont icon:@"fa_phone" fromFont:fontAwesome] fontName:fontAwesome iconColor:UIRGBColor(27,239,4,1) iconSize:24.0f];
           [subView4 addSubview:subImgView4];
           UITapGestureRecognizer* singleTap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(subView4Action:)];
           [subView4 addGestureRecognizer:singleTap4];
           [self addSubview:subView4];
           
           UILabel *label4 = [[UILabel alloc]initWithFrame:(CGRect){subImgView1.frame.origin.x+4,subImgView1.frame.size.height+subImgView1.frame.origin.y+5,100,44}];
           label4.text = @"通讯录";
           label4.font = [UIFont fontWithName:@"Helvetica" size:15];
           [subView4 addSubview:label4];
           
           //横线
           UIView *lineView4 = [[UIView alloc]initWithFrame:(CGRect){0,subView1.frame.size.height+subView4.frame.size.height+1,screenWidth/3+1,1}];
           lineView4.backgroundColor = color_gray_light2;
           [self addSubview:lineView4];
           
           //竖线
           UIView *lineView5 = [[UIView alloc]initWithFrame:(CGRect){subView4.frame.size.width+subView4.frame.origin.x+1,subView1.frame.size.height+1,1,screenWidth/3}];
           lineView5.backgroundColor = color_gray_light2;
           [self addSubview:lineView5];

           
           
           //5.定时上传记录
           UIView *subView5 = [[UIView alloc]initWithFrame:(CGRect){subView1.frame.size.width+subView1.frame.origin.x+2,subView1.frame.origin.y+subView1.frame.size.height+2,screenWidth/3,screenWidth/3}];
           UIImageView *subImgView5 = [[UIImageView alloc]initWithFrame:(CGRect){30*scaleModulus+5,20,44,44}];
           subImgView5.image =[IconFont imageWithIcon:[IconFont icon:@"fa_clock_o" fromFont:fontAwesome] fontName:fontAwesome iconColor:UIRGBColor(0,101,229,1) iconSize:24.0f];
           [subView5 addSubview:subImgView5];
           UITapGestureRecognizer* singleTap5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(subView5Action:)];
           [subView5 addGestureRecognizer:singleTap5];
           [self addSubview:subView5];
           
           UILabel *label5 = [[UILabel alloc]initWithFrame:(CGRect){subImgView5.frame.origin.x-20,subImgView5.frame.size.height+subImgView5.frame.origin.y+5,100,44}];
           label5.text = @"定时上传记录";
           label5.font = [UIFont fontWithName:@"Helvetica" size:15];
           [subView5 addSubview:label5];
           
           //横线
           UIView *lineView6 = [[UIView alloc]initWithFrame:(CGRect){subView4.frame.size.width+subView4.frame.origin.x+1,subView1.frame.size.height+subView5.frame.size.height+1,screenWidth/3+2,1}];
           lineView6.backgroundColor = color_gray_light2;
           [self addSubview:lineView6];
           
           //竖线
           UIView *lineView7 = [[UIView alloc]initWithFrame:(CGRect){subView5.frame.size.width+subView5.frame.origin.x+1,subView1.frame.size.height+1,1,screenWidth/3}];
           lineView7.backgroundColor = color_gray_light2;
           [self addSubview:lineView7];
           
       }
    
    return self;
}

- (void)subView1Action:(id)sender {
    
    [self.delegate viewAction:@"subView1"];
}

- (void)subView2Action:(id)sender {
  
    [self.delegate viewAction:@"subView2"];
}

- (void)subView3Action:(id)sender {
  
    [self.delegate viewAction:@"subView3"];
}

- (void)subView4Action:(id)sender {
    
    [self.delegate viewAction:@"subView4"];
}

- (void)subView5Action:(id)sender {
    
    [self.delegate viewAction:@"subView5"];
}

@end
