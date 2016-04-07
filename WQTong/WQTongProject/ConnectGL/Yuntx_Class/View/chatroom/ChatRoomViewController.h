/*
 *  Copyright (c) 2013 The CCP project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a Beijing Speedtong Information Technology Co.,Ltd license
 *  that can be found in the LICENSE file in the root of the web site.
 *
 *                    http://www.yuntongxun.com
 *
 *  An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */


@interface ChatRoomViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>
@property (nonatomic, assign) UIViewController *backView;
@property (nonatomic, strong) NSString* curChatroomId;
@property (nonatomic, strong) NSString* roomname;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *timerNetworkStatistic;
@property (nonatomic, assign) BOOL isCreator;

@property (nonatomic, assign) BOOL isJoin;

-(void)createChatroomWithChatroomName:(NSString*)chatroomName andPassword:(NSString *)roomPwd andSquare:(NSInteger)square andKeywords:(NSString *)keywords andIsAutoClose:(BOOL)isAutoClose andVoiceMod:(NSInteger) voiceMod andAutoDelete:(BOOL) autoDelete andIsAutoJoin:(BOOL) isAutoJoin;
- (void) joinChatroomInRoom:(NSString *)roomNo andPwd:(NSString *)pwd;
@end
