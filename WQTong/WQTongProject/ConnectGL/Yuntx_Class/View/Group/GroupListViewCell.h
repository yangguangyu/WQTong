//
//  GroupListViewCell.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupListViewCell : UITableViewCell

-(void)setTableViewCellNameLabel:(NSString *)name andNumberLabel:(NSString *)number andIsJoin:(BOOL)isJoin andMemberNumber:(NSInteger)memberNum;
@property (nonatomic, assign) BOOL isDiscuss;

@end
