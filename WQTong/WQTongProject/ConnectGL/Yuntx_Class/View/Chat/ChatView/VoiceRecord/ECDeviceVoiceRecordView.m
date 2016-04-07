//
//  ECDeviceScrollView.m
//  ECSDKDemo_OC
//
//  Created by admin on 15/11/25.
//  Copyright © 2015年 ronglian. All rights reserved.
//

#import "ECDeviceVoiceRecordView.h"

#define PAGECONTROL_jx  5  //缩略点之间的间隙
@implementation ECDeviceVoiceRecordView
{
    UIScrollView* myscrollview;
    
    UIView* pagecontrolview;
    
    NSMutableArray* markimgs;
    
    UIView* pagebgview;
    UIImageView* moveMark;
    
    NSInteger _num;
    UILabel *_Label;
    UILabel *_Label2;
}
- (instancetype)initWithFrame:(CGRect)frame imageItems:(NSArray*)imageItems HightImageItems:(NSArray*)HightImageItems titleLabel:(NSArray*)titleArray
{
    self = [super initWithFrame:frame];
    if (self) {
        //
        _num = imageItems.count;
        myscrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0.0f, frame.size.width, frame.size.height)];
        myscrollview.backgroundColor = [UIColor whiteColor];
        myscrollview.scrollsToTop = NO;
        myscrollview.showsHorizontalScrollIndicator = NO;
        myscrollview.delegate = self;
        myscrollview.pagingEnabled = YES;
        [self addSubview:myscrollview];
        
        for (int i = 0; i<imageItems.count; i++) {
            
            //状态
            _Label = [[UILabel alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-200)/2+i *[UIScreen mainScreen].bounds.size.width, 5.0f, 200, 17.0f)];
            _Label.backgroundColor = [UIColor clearColor];
            _Label.textAlignment = NSTextAlignmentCenter;
            _Label.text=titleArray[i];
            _Label.textColor = [UIColor blackColor];
            _Label.font = [UIFont systemFontOfSize:15.0f];
            [myscrollview addSubview:_Label];
            
            UIButton* _imgviewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _imgviewBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-100)/2 +i *[UIScreen mainScreen].bounds.size.width, CGRectGetMaxY(_Label.frame)+5, 100, 100);
            _imgviewBtn.contentMode = UIViewContentModeScaleAspectFill;
            _imgviewBtn.userInteractionEnabled = YES;
            _imgviewBtn.backgroundColor = [UIColor clearColor];
            [_imgviewBtn setBackgroundImage:[UIImage imageNamed:imageItems[i]] forState:UIControlStateNormal];
            [_imgviewBtn setBackgroundImage:[UIImage imageNamed:HightImageItems[i]] forState:UIControlStateHighlighted];
            
            [_imgviewBtn addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
            [_imgviewBtn addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
            [_imgviewBtn addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
            [_imgviewBtn addTarget:self action:@selector(recordDragOutside) forControlEvents:UIControlEventTouchDragOutside];
            [_imgviewBtn addTarget:self action:@selector(recordDragInside) forControlEvents:UIControlEventTouchDragInside];
            [myscrollview addSubview:_imgviewBtn];
        }
        myscrollview.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width*_num, myscrollview.bounds.size.height);
        
        //page control view
        
        markimgs = [NSMutableArray array];
        
        pagecontrolview = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-20, self.frame.size.width, 20)];
        [self addSubview:pagecontrolview];
        
        //tb3 tb4 jx10
        
        pagebgview = [[UIView alloc] initWithFrame:CGRectZero];
        [pagecontrolview addSubview:pagebgview];
        
        [self loadPageControlSubViews];
        
    }
    return self;
}

- (void)recordButtonTouchDown {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordButtonTouchDown)]) {
        [self.delegate recordButtonTouchDown];
    }
}

- (void)recordButtonTouchUpInside {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordButtonTouchUpInside)]) {
        [self.delegate recordButtonTouchUpInside];
    }
}

- (void)recordButtonTouchUpOutside {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordButtonTouchUpOutside)]) {
        [self.delegate recordButtonTouchUpOutside];
    }
}

- (void)recordDragOutside {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordDragOutside)]) {
        [self.delegate recordDragOutside];
    }
}

- (void)recordDragInside {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordDragInside)]) {
        [self.delegate recordDragInside];
    }
}

- (void)loadPageControlSubViews{
    
    //def
    for (int i = 0; i<_num; i++) {
        UIImageView* imgv = [[UIImageView alloc] initWithFrame:CGRectZero];
        imgv.backgroundColor = [UIColor lightGrayColor];
        [pagebgview addSubview:imgv];
        [markimgs addObject:imgv];
        imgv.image = _defaultPageIndicatorImage;
        
        if (_defaultPageIndicatorImage) {
            imgv.backgroundColor = [UIColor clearColor];
        }
        
    }
    
    //cur
    moveMark = [[UIImageView alloc] initWithFrame:CGRectZero];
    moveMark.backgroundColor = [UIColor greenColor];
    moveMark.image = _currentPageIndicatorImage;
    
    if (_currentPageIndicatorImage) {
        moveMark.backgroundColor = [UIColor clearColor];
    }
    [pagebgview addSubview:moveMark];
    
    [self reloadPageViewSize];
}

- (void)reloadPageViewSize{
    CGSize pageSize_def = CGSizeMake(12, 12);
    CGSize pageSize_cur = CGSizeMake(12, 12);
    
    if (_defaultPageIndicatorImage) {
        pageSize_def = _defaultPageIndicatorImage.size;
        
    }
    if (_currentPageIndicatorImage) {
        pageSize_cur = _currentPageIndicatorImage.size;
    }
    
    CGFloat bg_w = pageSize_def.width*0.5*_num+PAGECONTROL_jx*(_num-1);
    CGFloat bg_h = pageSize_def.height*0.5;
    
    pagebgview.frame = CGRectMake(CGRectGetMidX(pagecontrolview.frame)-bg_w*0.5, CGRectGetMidY(pagecontrolview.bounds)-bg_h*0.5, bg_w, bg_h);
    
    for (int i = 0; i<markimgs.count; i++) {
        UIImageView* imgv = (UIImageView*)markimgs[i];
        imgv.frame = CGRectMake(i*(pageSize_def.width*0.5+PAGECONTROL_jx), 0, pageSize_def.width*0.5, pageSize_def.height*0.5);
    }
    
    moveMark.frame = CGRectMake(0, 0, pageSize_cur.width*0.5, pageSize_cur.height*0.5);
}

#pragma mark - SET

- (void)setPages:(NSInteger)pages{
    //未实现
    _num = pages;
    
    [markimgs removeAllObjects];
    
    for (UIView* obj in pagebgview.subviews) {
        [obj removeFromSuperview];
    }
    
    [self loadPageControlSubViews];
}

- (void)setPagingEnabled:(BOOL)pagingEnabled{
    _pagingEnabled = pagingEnabled;
    myscrollview.pagingEnabled = _pagingEnabled;
}
- (void)setHiddenPageControl:(BOOL)hiddenPageControl{
    _hiddenPageControl = hiddenPageControl;
    pagecontrolview.hidden = _hiddenPageControl;
    
}

- (void)setDefaultPageIndicatorImage:(UIImage *)defaultPageIndicatorImage{
    _defaultPageIndicatorImage = defaultPageIndicatorImage;
    for (UIImageView* imgv in markimgs) {
        //
        imgv.image = defaultPageIndicatorImage;
        imgv.backgroundColor = [UIColor clearColor];
    }
    [self reloadPageViewSize];
}
- (void)setCurrentPageIndicatorImage:(UIImage *)currentPageIndicatorImage{
    
    _currentPageIndicatorImage = currentPageIndicatorImage;
    moveMark.image = currentPageIndicatorImage;
    moveMark.backgroundColor = [UIColor clearColor];
    [self reloadPageViewSize];
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //
    CGFloat scroll_content_w = myscrollview.contentSize.width-myscrollview.bounds.size.width;
    CGFloat scroll_curr_x = scrollView.contentOffset.x;
    _isChangeVoice = scroll_curr_x == 320?YES:NO;
    CGFloat move_content_w = moveMark.superview.bounds.size.width-moveMark.bounds.size.width;
    
    //求当前滑块的x坐标
    CGFloat move_curr_x = move_content_w*scroll_curr_x/scroll_content_w;
    
    moveMark.frame = CGRectMake(move_curr_x, 0, moveMark.frame.size.width, moveMark.frame.size.height);
    
}
@end
