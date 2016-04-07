//
//  SearchGroupViewController.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 15/3/20.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchGroupViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
-(instancetype)initWithMode:(ECGroupSearchType)searchType;
@end
