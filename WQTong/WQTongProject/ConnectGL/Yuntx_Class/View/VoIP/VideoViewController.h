//
//  VideoViewController.h
//  ytxVoIPDemo
//
//  Created by lrn on 15/3/10.
//  Copyright (c) 2015年 lrn. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface VideoViewController : UIViewController
{
    int hhInt;
    int mmInt;
    int ssInt;
    NSTimer *timer;
    NSInteger callStatus; //0:呼出视频 1:视频呼入 2:视频中
}

@property (nonatomic, strong) NSString *callID;
@property (nonatomic, strong) NSString *callerName;
@property (nonatomic, strong) NSString *voipNo;
@property (nonatomic, strong) UIView* bgView; //适配ios7使用
//挂断电话
@property (nonatomic, strong) UIButton *hangUpButton;
//接听
@property (nonatomic, strong) UIButton *acceptButton;
@property (nonatomic, strong) UILabel *netStatusLabel;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UILabel *p2pStatusLabel;

/*name:被叫人的姓名，用于界面的显示(自己选择)
 voipNop:被叫人的voip账号，用于网络免费电话(也可用于界面的显示,自己选择)
 type:视频类型
 */
- (id)initWithCallerName:(NSString *)name andVoipNo:(NSString *)voipNo andCallstatus:(NSInteger)type;
@end
