//
//  KQXXView.h
//  WQTong
//
//  Created by ChenBinbin on 16/3/28.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KQXXViewDelegate <NSObject>

- (void)viewAction:(NSString *)subViewIndex;

@end

@interface KQXXView : UIView<UIGestureRecognizerDelegate>

@property (weak,nonatomic) id<KQXXViewDelegate> delegate;

@end
