//
//  CommonMarco_UIInfo.h
//  WQTong
//
//  Created by ChenBinbin on 16/3/25.
//  Copyright © 2016年 cnbin. All rights reserved.
//


#define screenWidth [[UIScreen mainScreen]bounds].size.width    //屏幕宽度
#define screenHeiht [[UIScreen mainScreen]bounds].size.height   //屏幕高度
#define themeColor [UIColor colorWithRed:0 green:162/255.0f blue:1 alpha:1]//背景色

#define interphoneImageColor [UIColor colorWithRed:60/255.0f green:179/255.0f blue:113/255.0f alpha:1]//实时对讲图片背景色
//定义颜色方法
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIRGBColor(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a/1]
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define HEXRGBColor(strHex) [CommonFunction hexString2Color:strHex]
#define HEX4Color(color) [CommonFunction changeUIColorToRGB:color]

//色值
//白
#define color_white_light       RGBCOLOR(250,253,246)
#define color_white_LBSLight    RGBCOLOR(253,255,249)

//蓝
#define color_blue_normal       UIColorFromRGB(0x00b0f6)
#define color_blue_light        UIColorFromRGB(0x5fcbef)
#define color_blue_dark         UIColorFromRGB(0x1a7fee)

//灰
#define color_gray_light        UIColorFromRGB(0xf8f8f8)
#define color_gray_light2       RGBCOLOR(231,231,231)
#define color_gray_light3       RGBCOLOR(147,147,147)
#define color_gray_normal       UIColorFromRGB(0xdedede)
#define color_gray_dark         UIColorFromRGB(0x929292)
#define color_gray_dark2        UIColorFromRGB(0xbbbbbb)
#define color_gray_dark3        RGBCOLOR(120,120,120)
#define color_gray_dark4        RGBCOLOR(73,73,73)
#define color_gray_darkAlpha    UIRGBColor(73,73,73,0.8f)
#define color_gray_bg1          UIColorFromRGB(0x787878)
#define color_gray_bg2          UIColorFromRGB(0x4c4c4c)
#define color_gray_line         UIColorFromRGB(0x5e5e5e)

//绿
#define color_green_dark        RGBCOLOR(41,41,41)
#define color_green_normal      RGBCOLOR(154,180,36)
#define color_green_light       RGBCOLOR(164,199,80)
#define color_green_light2      RGBCOLOR(234,251,212)
#define color_green_light3      RGBCOLOR(188,245,30)
#define color_green_navBar      UIColorFromRGB(0xa2ac2d)
#define color_green_btn         UIColorFromRGB(0xacc054)

//红
#define color_red_Nav          UIColorFromRGB(0xed1651)



//是否为iphone5
#define is_iphone5() (fabs((double)[[UIScreen mainScreen] bounds].size.height-(double)568 ) < DBL_EPSILON )
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

//获取当前系统版本号
#define CURRENT_IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//是否超过ios6
#define is_iosUp6 CURRENT_IOS_VERSION>=6.0 ? 1 : 0

#define IOS_7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IOS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

//判断是否为ipod
#define is_ipod() ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"])

//判断是否是retina
#define is_retina() ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#define uiimage_no_exist [UIImage imageNamed:@""]
#define uiimage_no_existHeadImg [UIImage imageNamed:@"HeadImg_Default"]

#define scaleModulus                (screenWidth / 320)         //缩放系数
#define Scale(_A_)                  (_A_ * scaleModulus)        //缩放

#pragma mark - ZQ Def
//高度定义
#define height_4        Scale(4)
#define height_8        Scale(8)
#define height_12       Scale(12)
#define height_16       Scale(16)
#define height_20       Scale(20)
#define height_24       Scale(24)
#define height_28       Scale(28)
#define height_32       Scale(32)
#define height_36       Scale(36)
#define height_44       Scale(44)
#define height_64       Scale(64)
#define height_128      Scale(128)
//...高度定义 end...

//宽度定义
#define width_4        Scale(4)
#define width_8        Scale(8)
#define width_12       Scale(12)
#define width_16       Scale(16)
#define width_20       Scale(20)
#define width_24       Scale(24)
#define width_28       Scale(28)
#define width_32       Scale(32)
#define width_36       Scale(36)
#define width_44       Scale(44)
#define width_64       Scale(64)
#define width_128      Scale(128)
//...宽度定义 end...

//字体定义
#define font_24 [UIFont systemFontOfSize:Scale(24.0)]
#define font_23 [UIFont systemFontOfSize:Scale(23.0)]
#define font_22 [UIFont systemFontOfSize:Scale(22.0)]
#define font_21 [UIFont systemFontOfSize:Scale(21.0)]
#define font_20 [UIFont systemFontOfSize:Scale(20.0)]
#define font_19 [UIFont systemFontOfSize:Scale(19.0)]
#define font_18 [UIFont systemFontOfSize:Scale(18.0)]
#define font_17 [UIFont systemFontOfSize:Scale(17.0)]
#define font_16 [UIFont systemFontOfSize:Scale(16.0)]
#define font_15 [UIFont systemFontOfSize:Scale(15.0)]
#define font_14 [UIFont systemFontOfSize:Scale(14.0)]
#define font_13 [UIFont systemFontOfSize:Scale(13.0)]
#define font_12 [UIFont systemFontOfSize:Scale(12.0)]
#define font_11 [UIFont systemFontOfSize:Scale(11.0)]
#define font_10 [UIFont systemFontOfSize:Scale(10.0)]
#define font_9  [UIFont systemFontOfSize:Scale(9.0)]
#define font_8  [UIFont systemFontOfSize:Scale(8.0)]

#define font_blod_30      [UIFont boldSystemFontOfSize:Scale(30.0)]
#define font_blod_20      [UIFont boldSystemFontOfSize:Scale(20.0)]
#define font_blod_12      [UIFont boldSystemFontOfSize:Scale(12.0)]
//...字体定义 end...

//间距定义
//上下间距尺寸间隔
#define margins_vert32 32
#define margins_vert24 24
#define margins_vert16 16
#define margins_vert12 12
#define margins_vert8  8
#define margins_vert4  4

//左右间距尺寸间隔
#define margins_hori32 32
#define margins_hori24 24
#define margins_hori16 16
#define margins_hori12 12
#define margins_hori8  8
#define margins_hori4  4
//...间距定义 end...