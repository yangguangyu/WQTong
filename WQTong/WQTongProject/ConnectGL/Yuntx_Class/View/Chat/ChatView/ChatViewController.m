//
//  ChatViewController.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

#import "ChatViewController.h"
#import "ChatViewCell.h"
#import "ChatViewTextCell.h"
#import "ChatViewFileCell.h"
#import "ChatViewVoiceCell.h"
#import "ChatViewImageCell.h"
#import "ChatViewVideoCell.h"
#import "ChatViewCallTextCell.h"
#import "DetailsViewController.h"
#import "ContactDetailViewController.h"
#import "ChatViewLocationCell.h"

#import "HPGrowingTextView.h"
#import "CommonTools.h"

#import "MWPhotoBrowser.h"
#import "MWPhoto.h"

#import "CustomEmojiView.h"
#import "VoipCallController.h"
#import "VideoViewController.h"

#import "ECMessage.h"
#import "ECDevice.h"
#import "ECFileMessageBody.h"
#import "ECVideoMessageBody.h"
#import "ECVoiceMessageBody.h"
#import "ECImageMessageBody.h"

#import "GroupMembersViewController.h"
#import "NSString+containsString.h"
#import "ECDeviceVoiceRecordView.h"

#import "ECLocationViewController.h"
#import "SettingViewController.h"

#define ToolbarInputViewHeight 43.0f
#define ToolbarMoreViewHeight 120.0f
#define ToolbarMoreViewHeight1 163.0f
#define ToolbarDefaultTotalHeigth 163.0f //ToolbarInputViewHeight+ToolbarEmojiViewHeight
#define ToolbarRecordViewHeight 163.0f

#define Alert_ResendMessage_Tag 1500


#define KNOTIFICATION_ScrollTable       @"KNOTIFICATION_ScrollTable"
#define KNOTIFICATION_RefreshMoreData   @"KNOTIFICATION_RefreshMoreData"

#define MessagePageSize 15
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

typedef enum {
    ToolbarDisplay_None=0,
    ToolbarDisplay_Emoji,
    ToolbarDisplay_More,
    ToolbarDisplay_Record
}ToolbarDisplay;

@interface ChatViewController()<UITableViewDataSource, UITableViewDelegate,HPGrowingTextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MWPhotoBrowserDelegate,CustomEmojiViewDelegate,UIActionSheetDelegate,ECDeviceVoiceRecordViewDelegate,ECLocationViewControllerDelegate> {
    BOOL isGroup;
    dispatch_once_t emojiCreateOnce;
    dispatch_once_t scrollBTMOnce;
    NSIndexPath* _longPressIndexPath;
    UIMenuController*  _menuController;
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    CGFloat viewHeight;
    BOOL isScrollToButtom;
    BOOL isOpenMembersList;
    NSInteger arrowLocation;
    BOOL _isOpenSavePhoto;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString* sessionId;
@property (nonatomic, strong) NSMutableArray* messageArray;
@property (strong, nonatomic) NSMutableArray *photos;

#warning 录音效果页面
@property (nonatomic, strong) UIImageView *amplitudeImageView;
@property (nonatomic, strong) UILabel *recordInfoLabel;
@property (nonatomic, strong) ECMessage *playVoiceMessage;
@property (nonatomic, strong) UIView *amplitudeSuperView;

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *stateLabel;
//群组还是讨论组
@property (nonatomic, copy) NSString *isDiscussOrGroupName;

@end

const char KAlertResendMessage;

@implementation ChatViewController{
    
#warning 切换工具栏显示
    UIView* _containerView;
    UIImageView *_inputMaskImage;
    HPGrowingTextView *_inputTextView;
    ToolbarDisplay toolbarDisplay;
    BOOL _isDisplayKeyborad;
    CGFloat _oldInputHeight;
    UIView* _inputView;
    UIView *_moreView;
#warning 语音页面
    ECDeviceVoiceRecordView *_recordView;

#warning 变声页面
    UIView *_changeVoiceView;
    UIView *_footView;
    BOOL _isStartRecord;
#warning 表情页面
    UIButton *_emojiBtn;
    UIButton *_switchVoiceBtn;
    UIButton *_moreBtn;
    CustomEmojiView *_emojiView;
    NSString *_GroupMemberNickName;
    
    BOOL isReadDeleteMessage;
}

- (instancetype)init {
    NSAssert(NO, @"ChatViewController: use +initWithSessionId");
    return nil;
}

-(instancetype)initWithSessionId:(NSString*)aSessionId {
    if (self = [super init]) {
        self.sessionId = aSessionId;
        isGroup = [aSessionId hasPrefix:@"g"];
    }
    return self;
}

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
    [DeviceDelegateHelper sharedInstance].sessionId = self.sessionId;
    
    viewHeight = [UIScreen mainScreen].bounds.size.height-64.0f;
    
    
    self.view.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    self.messageArray = [NSMutableArray array];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width,self.view.frame.size.height-ToolbarInputViewHeight-64.0f) style:UITableViewStylePlain];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.tableView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width,self.view.frame.size.height-ToolbarInputViewHeight-64.0f);
    } else {
        self.tableView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width,self.view.frame.size.height-ToolbarInputViewHeight-44.0f);
    }
    self.tableView.scrollsToTop = YES;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    isScrollToButtom = YES;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewWillBeginDragging:)];
    [self.tableView addGestureRecognizer:tap];

    [self.view addSubview:self.tableView];
    
    UIView *titleview = [[UIView alloc] initWithFrame:CGRectMake(160.0f*scaleModulus, 0.0f, 120.0f, 44.0f)];
    titleview.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleview;
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 120.0f, 30.0f)];
    _titleLabel = titleLabel;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.backgroundColor = [UIColor clearColor];
    [titleview addSubview:_titleLabel];
    if ([[DemoGlobalClass sharedInstance] getOtherNameWithPhone:self.sessionId]) {
        
        _titleLabel.text = [[DemoGlobalClass sharedInstance] getOtherNameWithPhone:self.sessionId];
    }
    
    UILabel* stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 30.0f, 120.0f, 10.0f)];
    _stateLabel = stateLabel;
    _stateLabel.font = [UIFont systemFontOfSize:11.0f];
    _stateLabel.textAlignment = NSTextAlignmentCenter;
    _stateLabel.textColor = [UIColor whiteColor];
    _stateLabel.backgroundColor = [UIColor clearColor];
    [titleview addSubview:_stateLabel];
    self.navigationItem.titleView = titleview;
    
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7){
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(popViewController:)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popViewController:)];
    }
    
    self.navigationItem.leftBarButtonItem =leftItem;
    
    if (isGroup) {
        
        if ([[DemoGlobalClass sharedInstance] isDiscussGroupOfId:self.sessionId]) {
            self.isDiscussOrGroupName = @"讨论组";
        } else {
            self.isDiscussOrGroupName = @"群组";
        }

        UIBarButtonItem * rigthItem = nil;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7){
            rigthItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_more"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(navRightBarItemTap:)];
        }else{
            rigthItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_more"] style:UIBarButtonItemStyleDone target:self action:@selector(navRightBarItemTap:)];
        }
        self.navigationItem.rightBarButtonItem = rigthItem;
    } else {
        UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStyleDone target:self action:@selector(clearBtnClicked)];
        [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
        [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem =rightItem;
        
        __weak __typeof(self)weakSelf = self;
        [[ECDevice sharedInstance] getUserState:self.sessionId completion:^(ECError *error, ECUserState *state) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([strongSelf.sessionId isEqualToString:state.userAcc]) {
                if (state.isOnline) {
                    _stateLabel.text = [NSString stringWithFormat:@"%@-%@", [strongSelf getDeviceWithType:state.deviceType], [strongSelf getNetWorkWithType:state.network]];
                } else {
                    _stateLabel.text = @"对方不在线";
                }
            }
        }];
    }
    
    [self createToolBarView];
    
    [self refreshTableView:nil];
}

-(NSString*)getDeviceWithType:(ECDeviceType)type{
    switch (type) {
        case ECDeviceType_AndroidPhone:
            return @"Android手机";
            
        case ECDeviceType_iPhone:
            return @"iPhone手机";
            
        case ECDeviceType_iPad:
            return @"iPad平板";
            
        case ECDeviceType_AndroidPad:
            return @"Android平板";
            
        case ECDeviceType_PC:
            return @"PC";
            
        case ECDeviceType_Web:
            return @"Web";
            
        case ECDeviceType_Mac:
            return @"Mac";
            
        default:
            return @"未知";
    }
}

-(NSString*)getNetWorkWithType:(ECNetworkType)type{
    switch (type) {
        case ECNetworkType_WIFI:
            return @"wifi";
            
        case ECNetworkType_4G:
            return @"4G";
            
        case ECNetworkType_3G:
            return @"3G";
            
        case ECNetworkType_GPRS:
            return @"GRPS";
            
        case ECNetworkType_LAN:
            return @"Internet";
        default:
            return @"其他";
    }
}

//获取会话消息里面为图片消息的路径数组
- (NSArray *)getImageMessageLocalPath
{
   NSArray *imageMessage = [[DeviceDBHelper sharedInstance] getAllTypeMessageLocalPathOfSessionId:self.sessionId type:MessageBodyType_Image];
    NSMutableArray *localPathArray = [NSMutableArray array];
    NSString *localPath = [NSString string];
    for (int index = 0; index < imageMessage.count; index++) {
        localPath = [[imageMessage objectAtIndex:index] localPath];
        if (localPath) {//图片路径
            localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:localPath.lastPathComponent];
            [localPathArray addObject:localPath];
        }
    }
    return localPathArray;
}

// 返回点击图片的索引号
- (NSInteger)getImageMessageIndex:(ECImageMessageBody *)mediaBody
{
    NSArray *array = [self getImageMessageLocalPath];
    NSInteger index = 0;
    for (int i= 0;i<array.count;i++) {
        
        if ([[array objectAtIndex:i] isEqualToString:mediaBody.localPath]) {
            index = i;
        }
    }
    return index;
}

- (void)scrollViewToBottom:(BOOL)animated {
    if (self.tableView && self.tableView.contentSize.height > self.tableView.frame.size.height) {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:YES];
    }
}

//view出现时触发
-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    [self.tableView reloadData];
    
    dispatch_once(&scrollBTMOnce , ^{
        [self scrollViewToBottom:YES];
    });
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView:) name:KNOTIFICATION_onMesssageChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordingAmplitude:) name:KNOTIFICATION_onRecordingAmplitude object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessageCompletion:) name:KNOTIFICATION_SendMessageCompletion object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearMessageArray:) name:KNotification_DeleteLocalSessionMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadMediaAttachFileCompletion:) name:KNOTIFICATION_DownloadMessageCompletion object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReceiveMessageDelete:) name:KNOTIFICATION_ReceiveMessageDelete object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollTableView) name:KNOTIFICATION_ScrollTable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMoreMessage) name:KNOTIFICATION_RefreshMoreData object:nil];
    
    _GroupMemberNickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"GroupMemberNickName"];
    
    if (_isStartRecord) {
        _footView.hidden = NO;
    }
}

//view出现后触发
-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    extern NSString *const Notification_ChangeMainDisplay;
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_ChangeMainDisplay object:@0];
    
    dispatch_once(&emojiCreateOnce, ^{
        _emojiView = [CustomEmojiView shardInstance];
        _emojiView.delegate = self;
        _emojiView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.0f);
    });
    
    BOOL isHas = NO;
    for (UIView* view in self.view.subviews) {
        if (view == _emojiView) {
            isHas = YES;
            break;
        }
    }
    if (!isHas) {
        [self.view addSubview:_emojiView];
    }
    
    [[DeviceDBHelper sharedInstance] markMessagesAsReadOfSession:self.sessionId];
}

//view消失时触发
-(void)viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNOTIFICATION_onRecordingAmplitude object:nil];
    
    if (self.playVoiceMessage) {
        //如果前一个在播放
        objc_setAssociatedObject(self.playVoiceMessage, &KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
    }
    
    self.playVoiceMessage = nil;
    
    [super viewWillDisappear:animated];
    _footView.hidden = YES;
}

-(void)dealloc {
    [self.tableView.layer removeAllAnimations];
    self.tableView = nil;
    [DeviceDelegateHelper sharedInstance].sessionId = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - private method
-(void)loadMoreMessage {
    
    ECMessage *message = [self.messageArray objectAtIndex:1];
    NSArray * array = [[DeviceDBHelper sharedInstance] getMessageOfSessionId:self.sessionId beforeTime:message.timestamp andPageSize:MessagePageSize];
    
    CGFloat offsetOfButtom = self.tableView.contentSize.height-self.tableView.contentOffset.y;
    
    NSInteger arraycount = array.count;
    if (array.count == 0) {
        [self.messageArray removeObjectAtIndex:0];
    } else {
        NSIndexSet *indexset = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, arraycount)];
        [self.messageArray insertObjects:array atIndexes:indexset];
        if (array.count < MessagePageSize) {
            [self.messageArray removeObjectAtIndex:0];
        }
    }
    [self.tableView reloadData];
    self.tableView.contentOffset = CGPointMake(0.0f, self.tableView.contentSize.height-offsetOfButtom);

//    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:arraycount inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

//清空聊天记录
-(void)clearBtnClicked {
    [self endOperation];
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if ([[DeviceDBHelper sharedInstance] getAllMessagesOfSessionId:self.sessionId].count == 0) {
        hud.labelText = @"没有内容可以清除";
    } else {
        hud.labelText = @"正在清除聊天内容";
    }
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [self performSelectorOnMainThread:@selector(clearTableView) withObject:nil waitUntilDone:[NSThread isMainThread]];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[DeviceDBHelper sharedInstance] deleteAllMessageSaveSessionOfSession:self.sessionId];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"mainviewdidappear" object:nil];
            [hud hide:YES afterDelay:1.0];
        });
    });
}

//导航栏的右按钮
-(void)navRightBarItemTap:(id)sender {
    
    DetailsViewController *groupDetailView = [[DetailsViewController alloc] init];
    groupDetailView.groupId = self.sessionId;
    groupDetailView.isDiscussOrGroupName = self.isDiscussOrGroupName;
    [self.navigationController pushViewController:groupDetailView animated:YES];
}

//返回上一层
-(void)popViewController:(id)sender {
    
    if ([self.sessionId isEqualToString:KDeskNumber]) {
        [[ECDevice sharedInstance].messageManager finishConsultationWithAgent:KDeskNumber completion:^(ECError *error, NSString *agent) {
            
        }];
    }
    
    isScrollToButtom = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNOTIFICATION_ScrollTable object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNOTIFICATION_RefreshMoreData object:nil];
    [[DeviceDBHelper sharedInstance] markMessagesAsReadOfSession:self.sessionId];
    [self.view.layer removeAllAnimations];
    [self.tableView.layer removeAllAnimations];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)showMenuViewController:(UIView *)showInView messageType:(MessageBodyType)messageType {
    
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMenuAction:)];
    }
    
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMenuAction:)];
    }
    
    if (messageType == MessageBodyType_Text) {
        [_menuController setMenuItems:@[_copyMenuItem, _deleteMenuItem]];
    } else {
        [_menuController setMenuItems:@[_deleteMenuItem]];
    }
    
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}

#pragma mark - notification method

-(void)clearMessageArray:(NSNotification*)notification{
    NSString *session = (NSString*)notification.object;
    if ([session isEqualToString:self.sessionId]) {
        [self performSelectorOnMainThread:@selector(clearTableView) withObject:nil waitUntilDone:[NSThread isMainThread]];
    }
}

-(void)clearTableView {
    [self.messageArray removeAllObjects];
    [self.tableView reloadData];
}

-(void)refreshTableView:(NSNotification*)notification {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if (notification == nil) {
        
        [self.messageArray removeAllObjects];
        
        NSArray* message = [[DeviceDBHelper sharedInstance] getLatestHundredMessageOfSessionId:self.sessionId andSize:MessagePageSize];
        if (message.count == MessagePageSize) {
            [self.messageArray addObject:[NSNull null]];
        }
        [self.messageArray addObjectsFromArray:message];
        [self.tableView reloadData];
        
    } else {
        
        ECMessage *message = (ECMessage*)notification.object;
        if (![message.sessionId isEqualToString:self.sessionId]) {
            return;
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:@"mainviewdidappear" object:nil];
        [self.messageArray addObject:message];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }

    if (self.messageArray.count>0){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_ScrollTable object:nil];
        });
    }
}

-(void)scrollTableView {
    if (self && self.tableView && self.messageArray.count>0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void)scrollViewtobottom{
    [self scrollViewToBottom:YES];
}

/**
 *@brief 键盘的frame更改监听函数
 */
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat frameY = self.view.frame.size.height-ToolbarInputViewHeight;
    CGRect frame = _containerView.frame;
    
    if (beginFrame.origin.y == [[UIScreen mainScreen] bounds].size.height) {
        //显示键盘
        toolbarDisplay = ToolbarDisplay_None;
        _isDisplayKeyborad = YES;
        
        //只显示输入view
        frameY = endFrame.origin.y-_containerView.frame.size.height+ToolbarMoreViewHeight;
    } else if (endFrame.origin.y == [[UIScreen mainScreen] bounds].size.height) {
        
        //隐藏键盘
        _isDisplayKeyborad = NO;
        
        //根据不同的类型显示toolbar
        switch (toolbarDisplay) {
            case ToolbarDisplay_Emoji: {
                __weak __typeof(self)weakSelf = self;
                frameY = endFrame.origin.y-frame.size.height-93.0f;
                void(^animations)() = ^{
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    if (strongSelf) {
                        CGRect frame = _emojiView.frame;
                        frame.origin.y = viewHeight-_emojiView.frame.size.height;
                        _emojiView.frame=frame;
                    }
                };

                [UIView animateWithDuration:0.25 delay:0.1f options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:nil];
            }
                break;
                
            case ToolbarDisplay_Record:
                frameY = endFrame.origin.y-frame.size.height-ToolbarInputViewHeight;
                break;
                
            case ToolbarDisplay_More:
                frameY = endFrame.origin.y-frame.size.height-ToolbarInputViewHeight;
                break;
                
            default:
                frameY = endFrame.origin.y-frame.size.height+ToolbarMoreViewHeight;
                break;
        }
    } else {
        frameY = endFrame.origin.y-frame.size.height+ToolbarMoreViewHeight;
    }
    
    frameY -= 64.0f;
    [self toolbarDisplayChangedToFrameY:frameY andDuration:duration];
    
}

#pragma mark - UITableViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"scrollViewWillBeginDragging");
    [_footView removeFromSuperview];
    _footView = nil;
    isScrollToButtom = NO;
//    _footView.hidden = YES;
    if (_isDisplayKeyborad) {
        [self.view endEditing:YES];
    } else {
        [self toolbarDisplayChangedToFrameY:viewHeight-_containerView.frame.size.height+ToolbarMoreViewHeight andDuration:0.25];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    id content = [self.messageArray objectAtIndex:indexPath.row];
    if ([content isKindOfClass:[NSNull class]]) {
        return 44.0f;
    }
    
    ECMessage *message = (ECMessage*)content;
    
#warning 判断Cell是否显示时间
    BOOL isShow = NO;
    if (indexPath.row == 0) {
        isShow = YES;
    } else {
        id preMessagecontent = [self.messageArray objectAtIndex:indexPath.row-1];
        if ([preMessagecontent isKindOfClass:[NSNull class]]) {
            isShow = YES;
        } else {
            
            NSNumber *isShowNumber = objc_getAssociatedObject(message, &KTimeIsShowKey);
            if (isShowNumber) {
                isShow = isShowNumber.boolValue;
            } else {
                ECMessage *preMessage = (ECMessage*)preMessagecontent;
                long long timestamp = message.timestamp.longLongValue;
                long long pretimestamp = preMessage.timestamp.longLongValue;
                isShow = ((timestamp-pretimestamp)>180000); //与前一条消息比较大于3分钟显示
            }
        }
    }
    objc_setAssociatedObject(message, &KTimeIsShowKey, @(isShow), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    //根据cell内容获取高度
    CGFloat height = 0.0f;
    switch (message.messageBody.messageBodyType) {
        case MessageBodyType_Text:
            height = [ChatViewTextCell getHightOfCellViewWith:message.messageBody];
            break;
        case MessageBodyType_Voice:
        case MessageBodyType_Video:
        case MessageBodyType_Image:
        case MessageBodyType_File: {
#warning 根据文件的后缀名来获取多媒体消息的类型 麻烦 缺少displayName
            ECFileMessageBody *body = (ECFileMessageBody *)message.messageBody;
            if (body.localPath.length > 0) {
                body.localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:body.localPath.lastPathComponent];
            }
            
            if (body.displayName.length==0) {
                if (body.localPath.length > 0) {
                    body.displayName = body.localPath.lastPathComponent;
                } else if (body.remotePath.length>0) {
                    body.displayName = body.remotePath.lastPathComponent;
                } else {
                    body.displayName = @"无名字";
                }
            }
            
            switch (message.messageBody.messageBodyType) {
                case MessageBodyType_Voice:
                    height = [ChatViewVoiceCell getHightOfCellViewWith:body];
                    break;
                case MessageBodyType_Image:
                    height = [ChatViewImageCell getHightOfCellViewWith:body];
                    break;
                    
                case MessageBodyType_Video:
                    height = [ChatViewVideoCell getHightOfCellViewWith:body];
                    break;
                    
                default:
                    height = [ChatViewFileCell getHightOfCellViewWith:body];
                    break;
            }
        }
            break;
        case MessageBodyType_Call:
            height = [ChatViewCallTextCell getHightOfCellViewWith:message.messageBody];
            break;
        case MessageBodyType_Location:
            height = [ChatViewLocationCell getHightOfCellViewWith:message.messageBody];
            break;
        default: {
            ECFileMessageBody *body = (ECFileMessageBody *)message.messageBody;
            body.displayName = body.remotePath.lastPathComponent;
            height = [ChatViewFileCell getHightOfCellViewWith:body];
            break;
        }
    }
    
    CGFloat addHeight = 0.0f;
    BOOL isSender = (message.messageState==ECMessageState_Receive?NO:YES);
    if (!isSender && message.isGroup) {
        addHeight = 15.0f;
    }
#warning 显示的时间高度为30.0f
    return height+(isShow?30.0f:0.0f)+addHeight;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    id cellContent = [self.messageArray objectAtIndex:indexPath.row];
    
    if ([cellContent isKindOfClass:[NSNull class]]) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellrefresscellid"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellrefresscellid"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
            UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityView.tag = 100;
            activityView.center = cell.contentView.center;
            [cell.contentView addSubview:activityView];
        }
        UIActivityIndicatorView * activityView = (UIActivityIndicatorView *)[cell.contentView viewWithTag:100];
        [activityView startAnimating];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_RefreshMoreData object:nil];
        });
        return cell;
    }
    
    ECMessage *message = (ECMessage*)cellContent;
    BOOL isSender = (message.messageState==ECMessageState_Receive?NO:YES);
    
    NSInteger fileType = message.messageBody.messageBodyType;
    
    NSString *cellidentifier = [NSString stringWithFormat:@"%@_%@_%d", isSender?@"issender":@"isreceiver",NSStringFromClass([message.messageBody class]),(int)fileType];
    
    ChatViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
    if (cell == nil) {
        switch (message.messageBody.messageBodyType) {
                
            case MessageBodyType_Text:
                cell = [[ChatViewTextCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                break;
            case MessageBodyType_Voice:
                cell = [[ChatViewVoiceCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                break;
            case MessageBodyType_Video:
                cell = [[ChatViewVideoCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                break;
            case MessageBodyType_Image:
                cell = [[ChatViewImageCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                break;
            case MessageBodyType_Call:
                cell = [[ChatViewCallTextCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                break;
            case MessageBodyType_Location:
                cell = [[ChatViewLocationCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                break;
            default:
                cell = [[ChatViewFileCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
                break;
        }
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellHandleLongPress:)];
        [cell.bubbleView addGestureRecognizer:longPress];
    }
    
    [cell bubbleViewWithData:[self.messageArray objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - GestureRecognizer

//点击tableview，结束输入操作
-(void)endOperation{
    if (toolbarDisplay == ToolbarDisplay_Record) {
        return;
    }
    toolbarDisplay = ToolbarDisplay_None;
    if (_isDisplayKeyborad) {
        [self.view endEditing:YES];
    } else {
        [self toolbarDisplayChangedToFrameY:viewHeight-_containerView.frame.size.height+ToolbarMoreViewHeight andDuration:0.25];
    }
}

-(void)cellHandleLongPress:(UILongPressGestureRecognizer * )longPress{
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        CGPoint point = [longPress locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
        if(indexPath == nil) return;
        
        id tableviewcell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([tableviewcell isKindOfClass:[ChatViewCell class]]) {
            ChatViewCell *cell = (ChatViewCell *)tableviewcell;
            [cell becomeFirstResponder];
            _longPressIndexPath = indexPath;
            [self showMenuViewController:cell.bubbleView messageType:cell.displayMessage.messageBody.messageBodyType];
        }
    }
}

#pragma mark - MenuItem actions

- (void)copyMenuAction:(id)sender {
    [_menuController setMenuItems:nil];
    //复制
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (_longPressIndexPath.row < self.messageArray.count) {
        ECMessage *message = [self.messageArray objectAtIndex:_longPressIndexPath.row];
        ECTextMessageBody *body = (ECTextMessageBody*)message.messageBody;
        pasteboard.string = body.text;
    }
    _longPressIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender {
    [_menuController setMenuItems:nil];
    if (_longPressIndexPath && _longPressIndexPath.row >= 0) {
        ECMessage *message = [self.messageArray objectAtIndex:_longPressIndexPath.row];
        NSNumber* isplay = objc_getAssociatedObject(message, &KVoiceIsPlayKey);
        if (isplay.boolValue) {
            objc_setAssociatedObject(self.playVoiceMessage, &KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
            self.playVoiceMessage = nil;
        }
        
        if (message==self.messageArray.lastObject) {
            //删除最后消息才需要刷新session
            if (message==self.messageArray.firstObject) {
                //如果删除的也是唯一一个消息，删除session
                [[DeviceDBHelper sharedInstance] deleteMessage:message andPre:nil];
            } else {
                //使用前一个消息刷新session
                [[DeviceDBHelper sharedInstance] deleteMessage:message andPre:[self.messageArray objectAtIndex:_longPressIndexPath.row-1]];
            }
        } else {
            [[IMMsgDBAccess sharedInstance] deleteMessage:message.messageId andSession:self.sessionId];
        }
        
        [self.messageArray removeObject:message];
        [self.tableView deleteRowsAtIndexPaths:@[_longPressIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    _longPressIndexPath = nil;
}

#pragma mark - UIResponder custom
- (void)dispatchCustomEventWithName:(NSString *)name userInfo:(NSDictionary *)userInfo {
    ECMessage * message = [userInfo objectForKey:KResponderCustomECMessageKey];
    if ([name isEqualToString:KResponderCustomChatViewFileCellBubbleViewEvent]) {
        [self fileCellBubbleViewTap:message];
    } else if ([name isEqualToString:KResponderCustomChatViewImageCellBubbleViewEvent]) {
        [self imageCellBubbleViewTap:message];
    } else if ([name isEqualToString:KResponderCustomChatViewVoiceCellBubbleViewEvent]) {
        [self voiceCellBubbleViewTap:message];
    } else if ([name isEqualToString:KResponderCustomChatViewVideoCellBubbleViewEvent]) {
        [self videoCellPlayVideoTap:message];
    } else if ([name isEqualToString:KResponderCustomChatViewCellResendEvent]) {
        ChatViewCell *resendCell = [userInfo objectForKey:KResponderCustomTableCellKey];
        ECMessage *message = resendCell.displayMessage;

        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"重发该消息？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重发",nil];
        objc_setAssociatedObject(alertView, &KAlertResendMessage, message, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        alertView.tag = Alert_ResendMessage_Tag;
        [alertView show];
    } else if ([name isEqualToString:KResponderCustomECMessagePortraitImgKey]){
        NSString *sendPhone = message.from;
        if ([sendPhone isEqualToString:[DemoGlobalClass sharedInstance].userName]) {
            SettingViewController *setVc = [[SettingViewController alloc] init];
            setVc.userName = [DemoGlobalClass sharedInstance].userName;
            setVc.backView = self;
            [self.navigationController pushViewController:setVc animated:YES];

        } else {
            ContactDetailViewController *contactVC = [[ContactDetailViewController alloc] init];
            contactVC.dict = @{nameKey:[[DemoGlobalClass sharedInstance] getOtherNameWithPhone:sendPhone],phoneKey:sendPhone,imageKey:[[DemoGlobalClass sharedInstance] getOtherImageWithPhone:sendPhone]};
            [self.navigationController pushViewController:contactVC animated:YES];
        }
    } else if ([name isEqualToString:KResponderCustomChatViewLocationCellBubbleViewEvent]){
        
        ECLocationMessageBody *msgBody = (ECLocationMessageBody*)message.messageBody;
        ECLocationPoint *point = [[ECLocationPoint alloc] initWithCoordinate:msgBody.coordinate andTitle:msgBody.title];
        ECLocationViewController *locationVC = [[ECLocationViewController alloc] initWithLocationPoint:point];
        locationVC.backView = self;
        [self.navigationController pushViewController:locationVC animated:NO];
    }
}

-(void)videoCellPlayVideoTap:(ECMessage*)message {
    
    ECVideoMessageBody *mediaBody = (ECVideoMessageBody*)message.messageBody;

    if (message.messageState != ECMessageState_Receive && mediaBody.localPath.length>0) {
        [self createMPPlayerController:mediaBody.localPath];
        return;
    }
    
    if (mediaBody.mediaDownloadStatus != ECMediaDownloadSuccessed || mediaBody.localPath.length == 0) {
        
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.removeFromSuperViewOnHide = YES;
        hud.labelText = @"正在加载视频，请稍后";
        
        __weak typeof(self) weakSelf = self;
        [[DeviceChatHelper sharedInstance] downloadMediaMessage:message andCompletion:^(ECError *error, ECMessage *message) {
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            if (error.errorCode == ECErrorType_NoError) {

                [strongSelf createMPPlayerController:mediaBody.localPath];
                NSLog(@"%@",[NSString stringWithFormat:@"file://localhost%@", mediaBody.localPath]);
            }
        }];
    } else {
        [self createMPPlayerController:mediaBody.localPath];
    }
}

- (void)createMPPlayerController:(NSString *)fileNamePath {
    
    MPMoviePlayerViewController* playerView = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://localhost%@", fileNamePath]]];
    
    playerView.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    [playerView.view setBackgroundColor:[UIColor clearColor]];
    [playerView.view setFrame:self.view.bounds];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:playerView.moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieStateChangeCallback:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:playerView.moviePlayer];
    
    [self presentViewController:playerView animated:NO completion:nil];
}

-(void)movieStateChangeCallback:(NSNotification*)notify  {
    
    //点击播放器中的播放/ 暂停按钮响应的通知
    MPMoviePlayerController *playerView = notify.object;
    MPMoviePlaybackState state = playerView.playbackState;
    switch (state) {
        case MPMoviePlaybackStatePlaying:
            NSLog(@"正在播放...");
            break;
        case MPMoviePlaybackStatePaused:
            NSLog(@"暂停播放.");
            break;
        case MPMoviePlaybackStateSeekingForward:
            NSLog(@"快进");
            break;
        case MPMoviePlaybackStateSeekingBackward:
            NSLog(@"快退");
            break;
        case MPMoviePlaybackStateInterrupted:
            NSLog(@"打断");
            break;
        case MPMoviePlaybackStateStopped:
            NSLog(@"停止播放.");
            break;
        default:
            NSLog(@"播放状态:%li",state);
            break;
    }
}

-(void)movieFinishedCallback:(NSNotification*)notify{
    
    // 视频播放完或者在presentMoviePlayerViewControllerAnimated下的Done按钮被点击响应的通知。
    MPMoviePlayerController* theMovie = [notify object];
    [theMovie stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
}

-(void)fileCellBubbleViewTap:(ECMessage*)message {
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"无法打开该文件";
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

-(void)playVoiceMessage:(ECMessage*)message {
    
    NSNumber* isplay = objc_getAssociatedObject(message, &KVoiceIsPlayKey);
    if (isplay == nil) {
        //首次点击
        isplay = @YES;
    } else {
        isplay = @(!isplay.boolValue);
    }
    
    if (self.playVoiceMessage) {
        //如果前一个在播放
        objc_setAssociatedObject(self.playVoiceMessage, &KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.messageArray indexOfObject:self.playVoiceMessage] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        self.playVoiceMessage = nil;
    }

    __weak __typeof(self) weakSelf = self;
    if (isplay.boolValue) {
        self.playVoiceMessage = message;
        objc_setAssociatedObject(message, &KVoiceIsPlayKey, isplay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if ([DemoGlobalClass sharedInstance].isPlayEar) {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        } else {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        }
        
        [[ECDevice sharedInstance].messageManager playVoiceMessage:(ECVoiceMessageBody*)message.messageBody completion:^(ECError *error) {
            if (weakSelf) {
                objc_setAssociatedObject(weakSelf.playVoiceMessage, &KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                weakSelf.playVoiceMessage = nil;
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.messageArray indexOfObject:self.playVoiceMessage] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf.tableView endUpdates];
            }
        }];
        
        [weakSelf.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.messageArray indexOfObject:self.playVoiceMessage] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf.tableView endUpdates];
    }
}

-(void)voiceCellBubbleViewTap:(ECMessage*)message{
    
    ECVoiceMessageBody* mediaBody = (ECVoiceMessageBody*)message.messageBody;
    if (mediaBody.localPath.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:mediaBody.localPath]) {
         [self playVoiceMessage:message];
    } else if (message.messageState == ECMessageState_Receive && mediaBody.remotePath.length>0){
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"正在获取文件";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        
        __weak __typeof(self)weakSelf = self;
        [[DeviceChatHelper sharedInstance] downloadMediaMessage:message andCompletion:^(ECError *error, ECMessage *message) {
            
            if (weakSelf == nil) {
                return;
            }
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            if (error.errorCode != ECErrorType_NoError) {
                MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"获取文件失败";
                hud.margin = 10.f;
                hud.removeFromSuperViewOnHide = YES;
                [hud hide:YES afterDelay:2];
            }
        }];
    }
}

-(void)imageCellBubbleViewTap:(ECMessage*)message{
        
    if (message.messageBody.messageBodyType >= MessageBodyType_Voice) {
        ECImageMessageBody *mediaBody = (ECImageMessageBody*)message.messageBody;
        
        if (mediaBody.localPath.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:mediaBody.localPath]) {
            
            _isOpenSavePhoto = ![message.userData myContainsString:@"fireMessage"];
            [self showPhotoBrowser:[self getImageMessageLocalPath] index:[self getImageMessageIndex:mediaBody]];
            
        } else if (message.messageState == ECMessageState_Receive && mediaBody.remotePath.length>0 && ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@",message.messageId]]==NO)) {
            
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"正在获取文件";
            hud.removeFromSuperViewOnHide = YES;
            
            __weak __typeof(self)weakSelf = self;
            
            [[DeviceChatHelper sharedInstance] downloadMediaMessage:message andCompletion:^(ECError *error, ECMessage *message) {
                
                if (weakSelf == nil) {
                    return ;
                }
                
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                if (error.errorCode == ECErrorType_NoError) {
                    if ([mediaBody.localPath hasSuffix:@".jpg"] || [mediaBody.localPath hasSuffix:@".png"]) {
                        
                        [strongSelf showPhotoBrowser:[self getImageMessageLocalPath] index:[self getImageMessageIndex:mediaBody]];
                    }
                } else {
                    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"获取文件失败";
                    hud.margin = 10.f;
                    hud.removeFromSuperViewOnHide = YES;
                    [hud hide:YES afterDelay:2];
                }
            }];
        }
    }
}

#pragma mark - UIAlertViewDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == Alert_ResendMessage_Tag) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            ECMessage *message = objc_getAssociatedObject(alertView, &KAlertResendMessage);
            [self.messageArray removeObject:message];
            [[DeviceChatHelper sharedInstance] resendMessage:message];
            [self.messageArray addObject:message];
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Photo browser
-(void)showPhotoBrowser:(NSArray*)imageArray index:(NSInteger)currentIndex{
    if (imageArray && [imageArray count] > 0) {
        NSMutableArray *photoArray = [NSMutableArray array];
        for (id object in imageArray) {
            MWPhoto *photo;
            if ([object isKindOfClass:[UIImage class]]) {
                photo = [MWPhoto photoWithImage:object];
            } else if ([object isKindOfClass:[NSURL class]]) {
                photo = [MWPhoto photoWithURL:object];
            } else if ([object isKindOfClass:[NSString class]]) {
                photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:object]];
            }
            [photoArray addObject:photo];
        }
        
        self.photos = photoArray;
    }

    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    photoBrowser.displayActionButton = YES;
    photoBrowser.displayNavArrows = NO;
    photoBrowser.displaySelectionButtons = NO;
    photoBrowser.alwaysShowControls = NO;
    photoBrowser.zoomPhotosToFill = YES;
    photoBrowser.enableGrid = NO;
    photoBrowser.startOnGrid = NO;
    photoBrowser.enableSwipeToDismiss = NO;
    photoBrowser.isOpen = _isOpenSavePhoto;
    [photoBrowser setCurrentPhotoIndex:currentIndex];

    [self.navigationController pushViewController:photoBrowser animated:YES];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return self.photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    if (index < self.photos.count) {
        return self.photos[index];
    }
    return nil;
}

#pragma mark - 创建工具栏和布局变化操作

/**
 *@brief 生成工具栏
 */
-(void)createToolBarView {
    
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.tableView.frame.origin.y+self.tableView.frame.size.height, self.view.frame.size.width, ToolbarDefaultTotalHeigth)];
    _containerView.backgroundColor = [UIColor colorWithRed:225.0f/255.0f green:225.0f/255.0f blue:225.0f/255.0f alpha:1.0f];
    [self.view addSubview:_containerView];
    _oldInputHeight = ToolbarDefaultTotalHeigth;
    
    //聊天的基础功能
    _switchVoiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _switchVoiceBtn.tag = ToolbarDisplay_Record;
    [_switchVoiceBtn addTarget:self action:@selector(switchToolbarDisplay:) forControlEvents:UIControlEventTouchUpInside];
    [_switchVoiceBtn setImage:[UIImage imageNamed:@"voice_icon"] forState:UIControlStateNormal];
    [_switchVoiceBtn setImage:[UIImage imageNamed:@"voice_icon_on"] forState:UIControlStateHighlighted];
    _switchVoiceBtn.frame = CGRectMake(5.0f, 5.0f, 31.0f, 31.0f);
    _switchVoiceBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _containerView.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
    [_containerView addSubview:_switchVoiceBtn];
    
    _inputTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(40.0f, 7.0f, 183.0f, 25.0f)];
    _inputTextView.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
    _inputTextView.contentInset = UIEdgeInsetsMake(5, 5, 3, 5);
    _inputTextView.minNumberOfLines = 1;
    _inputTextView.maxNumberOfLines = 4;
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.font = [UIFont systemFontOfSize:16.0f];
    _inputTextView.delegate = self;
//    _inputTextView.placeholder = @"添加文本";
    _inputTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _inputMaskImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"input_box"] stretchableImageWithLeftCapWidth:95.0f topCapHeight:16.0f]];
    _inputMaskImage.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _inputMaskImage.center = _inputTextView.center;
    
    _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_moreBtn addTarget:self action:@selector(switchToolbarDisplay:) forControlEvents:UIControlEventTouchUpInside];
    [_moreBtn setImage:[UIImage imageNamed:@"add_icon"] forState:UIControlStateNormal];
    [_moreBtn setImage:[UIImage imageNamed:@"add_icon_on"] forState:UIControlStateHighlighted];
    _moreBtn.frame = CGRectMake(_containerView.frame.size.width-36.0f, 5.0f, 31.0f, 31.0f);
    _moreBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _moreBtn.tag = ToolbarDisplay_More;
    [_containerView addSubview:_moreBtn];
    
    _emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _emojiBtn.tag = ToolbarDisplay_Emoji;
    [_emojiBtn addTarget:self action:@selector(switchToolbarDisplay:) forControlEvents:UIControlEventTouchUpInside];
    [_emojiBtn setImage:[UIImage imageNamed:@"facial_expression_icon"] forState:UIControlStateNormal];
    [_emojiBtn setImage:[UIImage imageNamed:@"facial_expression_icon_on"] forState:UIControlStateHighlighted];
    _emojiBtn.frame = CGRectMake(_moreBtn.frame.origin.x-36.0f, 5.0f, 31.0f, 31.0f);
    _emojiBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [_containerView addSubview:_emojiBtn];
    
    CGFloat frame_x = _switchVoiceBtn.frame.origin.x+_switchVoiceBtn.frame.size.width+5.0f;
    _inputTextView.frame = CGRectMake(0, 7.0f, _emojiBtn.frame.origin.x-frame_x-5.0f, 25.0f);
    _inputMaskImage.frame = CGRectMake(0, 5.0f, _emojiBtn.frame.origin.x-frame_x-5.0f, 31.0f);
    _inputView = [[UIView alloc] initWithFrame:CGRectMake(frame_x, 0.0f, _emojiBtn.frame.origin.x-frame_x-5.0f, 43.0f)];
    _inputView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [_inputView addSubview:_inputTextView];
    [_inputView addSubview:_inputMaskImage];
    [_containerView addSubview:_inputView];
    
    //发送语音和变声
    [self createVoiceView];
    
    //更多的附加功能
    [self createMoreView];
}

-(void)createVoiceView
{
    _recordView = [[ECDeviceVoiceRecordView alloc] initWithFrame:CGRectMake(0.0f, ToolbarInputViewHeight, _containerView.frame.size.width, ToolbarRecordViewHeight) imageItems:@[@"press_talk_icon",@"voiceChange_icon"] HightImageItems:@[@"press_talk_icon_on",@"voiceChange_icon"] titleLabel:@[@"按住说话",@"按住录音"]];
    _recordView.delegate = self;
    [_containerView addSubview:_recordView];
}

-(void)createChangeVoiceView
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"changeVoice_file"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _recordView.hidden = YES;
    _changeVoiceView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, ToolbarInputViewHeight, _containerView.frame.size.width, ToolbarMoreViewHeight1-33.0f)];
    _changeVoiceView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _changeVoiceView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
    [_containerView addSubview:_changeVoiceView];
    
    NSArray *imagesArr = @[@"voiceChange_0",@"voiceChange_1",@"voiceChange_2",@"voiceChange_3",@"voiceChange_4",@"voiceChange_5"];
    NSArray *textArr = @[@"原声",@"萝莉",@"大叔",@"惊悚",@"搞怪",@"空灵"];
    NSArray *selectorArr = @[@"sourceVoice",@"petiteVoice",@"uncleVoice",@"thrillerVoice",@"parodyVoice",@"spaciousVoice"];
    
    for (NSInteger index = 0; index<imagesArr.count; index++) {
        
        NSString *imageLight = [NSString stringWithFormat:@"%@_on",imagesArr[index]];
        UIButton *extenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        extenBtn.frame = CGRectMake(50.0f+(50.0+40.0f)*(index%3), 10.0f+ (40.0+20)*(index/3), 40.0f, 40.0f);
        SEL selector = NSSelectorFromString(selectorArr[index]);
        [extenBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        [extenBtn setImage:[UIImage imageNamed:imagesArr[index]] forState:UIControlStateNormal];
        [extenBtn setImage:[UIImage imageNamed:imageLight] forState:UIControlStateHighlighted];
        [_changeVoiceView addSubview:extenBtn];
        
        UILabel *btnLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(extenBtn.frame)-10.0f,CGRectGetMaxY(extenBtn.frame)+5.0f, 60.0f, 15.0f)];
        btnLabel.font = [UIFont systemFontOfSize:14.0f];
        btnLabel.textAlignment = NSTextAlignmentCenter;
        [_changeVoiceView addSubview:btnLabel];
        btnLabel.text = textArr[index];
    }
    [self createFootView];
}

-(void)createFootView {
    _footView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-33.0f, kScreenWidth, 33.0f)];
    _footView.backgroundColor = [UIColor whiteColor];
    [[AppDelegate shareInstance].window addSubview:_footView];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, 0,kScreenWidth/2-0.5, 33.0f);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [cancelBtn addTarget:self action:@selector(cancelChangeVoiceView) forControlEvents:UIControlEventTouchUpInside];
    [_footView addSubview:cancelBtn];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2-0.5, 0, 1.0f, 33.0f)];
    label.backgroundColor = [UIColor grayColor];
    [_footView addSubview:label];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(kScreenWidth/2+0.5, 0,kScreenWidth/2-0.5, 33.0f);
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    sendBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [sendBtn addTarget:self action:@selector(sendChangeVoice) forControlEvents:UIControlEventTouchUpInside];
    [_footView addSubview:sendBtn];
}

-(void)createMoreView {
    
    _moreView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, ToolbarInputViewHeight, _containerView.frame.size.width, ToolbarMoreViewHeight1)];
    _moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _moreView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
    [_containerView addSubview:_moreView];
    NSArray *imagesArr = [NSArray array];
    NSArray *textArr = [NSArray array];
    NSArray *selectorArr = [NSArray array];
    
    if (![DemoGlobalClass sharedInstance].isSDKSupportVoIP) {
        
        imagesArr = @[@"dialogue_image_icon",@"dialogue_camera_icon",@"dialogue_snap_icon",@"chat_location_normal"];
        textArr = @[@"图片",@"拍摄",@"阅后即焚",@"位置"];
        selectorArr = @[@"pictureBtnTap:",@"cameraBtnTap:",@"snapFireBtnTap:",@"locationBtnTap:"];
        
    } else {
        
        if ([self.sessionId hasPrefix:@"g"]) {
            imagesArr = @[@"dialogue_image_icon",@"dialogue_camera_icon",@"chat_location_normal"];
            textArr = @[@"图片",@"拍摄",@"位置"];
            selectorArr = @[@"pictureBtnTap:",@"cameraBtnTap:",@"locationBtnTap:"];
            
        } else {
            if ( ![self.sessionId isEqualToString:[DemoGlobalClass sharedInstance].userName]) {
                
                imagesArr = @[@"dialogue_image_icon",@"dialogue_camera_icon",@"dialogue_phone_icon",@"dialogue_video_icon",@"dialogue_snap_icon",@"chat_location_normal"];
                textArr = @[@"图片",@"拍摄",@"音频",@"视频",@"阅后即焚",@"位置"];
                selectorArr = @[@"pictureBtnTap:",@"cameraBtnTap:",@"voiceCallBtnTap:",@"videoCallBtnTap:",@"snapFireBtnTap:",@"locationBtnTap:"];
            } else {
                imagesArr = @[@"dialogue_image_icon",@"dialogue_camera_icon",@"dialogue_snap_icon",@"chat_location_normal"];
                textArr = @[@"图片",@"拍摄",@"阅后即焚",@"位置"];
                selectorArr = @[@"pictureBtnTap:",@"cameraBtnTap:",@"snapFireBtnTap:",@"locationBtnTap:"];
            }
        }
    }
    
    CGFloat buttonW = 60.0f;
    CGFloat buttonH = 50.0f;
    CGFloat buttonX;
    CGFloat buttonY;
    CGFloat marginHorizontal = (kScreenWidth -4*buttonW)/(4+1);
    CGFloat labelW = buttonW;
    CGFloat labelH = 15.0f;
    CGFloat labelX;
    CGFloat labelY;
    CGFloat marginVerticality = (ToolbarMoreViewHeight1 - (buttonH+labelH+5.0f)*2)/3;
    NSInteger rowIndex;
    NSInteger coloumnIndex;
    for (NSInteger index = 0; index<imagesArr.count; index++) {
        
        rowIndex = index / 4;
        coloumnIndex = index % 4;
        
        NSString *imageLight = [NSString stringWithFormat:@"%@_on",imagesArr[index]];
        UIButton *extenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        SEL selector = NSSelectorFromString(selectorArr[index]);
        [extenBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        [extenBtn setImage:[UIImage imageNamed:imagesArr[index]] forState:UIControlStateNormal];
        [extenBtn setImage:[UIImage imageNamed:imageLight] forState:UIControlStateHighlighted];

        buttonX = marginHorizontal*(coloumnIndex+1) + buttonW*coloumnIndex;
        buttonY = marginVerticality*(rowIndex+1) + (buttonH+labelH)*rowIndex;
        
        extenBtn.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        [_moreView addSubview:extenBtn];
        
        UILabel *btnLabel = [[UILabel alloc] init];
        btnLabel.font = [UIFont systemFontOfSize:13.0f];
        btnLabel.textAlignment = NSTextAlignmentCenter;
        labelX = marginHorizontal*(coloumnIndex+1) + buttonW*coloumnIndex;
        labelY = marginVerticality*(rowIndex+1) + (buttonH+labelH)*rowIndex+buttonH;
        btnLabel.frame = CGRectMake(labelX, labelY, labelW, labelH);
        [_moreView addSubview:btnLabel];
        btnLabel.text = textArr[index];
    }
}

- (void)createAmplitudeImageView {

    _amplitudeSuperView = [[UIView alloc] initWithFrame:CGRectMake(0,0 , kScreenWidth, [UIScreen mainScreen].bounds.size.height-ToolbarRecordViewHeight)];
    _amplitudeSuperView.backgroundColor = [UIColor grayColor];
    _amplitudeSuperView.alpha = 0.8;
    [self.tableView setUserInteractionEnabled:NO];
    [[UIApplication sharedApplication].keyWindow addSubview:_amplitudeSuperView];
    
    self.amplitudeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"press_speak_icon_07"]];
    _amplitudeImageView.center = CGPointMake(kScreenWidth/2, self.view.bounds.size.height/2-40.0f);
    self.recordInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, _amplitudeImageView.frame.size.height-40.0f, _amplitudeImageView.frame.size.width, 30.0f)];
    _recordInfoLabel.backgroundColor = [UIColor clearColor];
    _recordInfoLabel.textAlignment = NSTextAlignmentCenter;
    _recordInfoLabel.textColor = [UIColor whiteColor];
    _recordInfoLabel.font = [UIFont systemFontOfSize:13.0f];
    
    [_amplitudeImageView addSubview:_recordInfoLabel];
    [_amplitudeSuperView addSubview:_amplitudeImageView];
}

#pragma mark - 变声
-(void)cancelChangeVoiceView {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"changeVoice_MessageBody"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
    _recordView.hidden = NO;
    [_changeVoiceView removeFromSuperview];
    [_footView removeFromSuperview];
    _changeVoiceView = nil;
    _footView = nil;
}

-(void)sendChangeVoice {

    NSString *displayname = [[NSUserDefaults standardUserDefaults] objectForKey:@"changeVoice_MessageBody"];
    [self cancelChangeVoiceView];
    if (displayname.length>0) {
        
        ECVoiceMessageBody *voiceBody = [[ECVoiceMessageBody alloc] initWithFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:displayname] displayName:displayname];
        
        [self sendMediaMessage:voiceBody];
    } else {
        NSString *srcDisplayname = [[NSUserDefaults standardUserDefaults] objectForKey:@"changeVoice_file"];
        ECVoiceMessageBody * messageBody = [[ECVoiceMessageBody alloc] initWithFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:srcDisplayname] displayName:srcDisplayname];
        [self sendMediaMessage:messageBody];
    }
}

-(void)sourceVoice {
    
    [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
    NSString *displayname = [[NSUserDefaults standardUserDefaults] objectForKey:@"changeVoice_file"];
    
    BOOL isOpen = [[ECDevice sharedInstance].VoIPManager getLoudsSpeakerStatus];
    if (!isOpen) {
        [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:YES];
    }
    
    ECVoiceMessageBody * messageBody = [[ECVoiceMessageBody alloc] initWithFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:displayname] displayName:displayname];
    
    [[NSUserDefaults standardUserDefaults] setObject:messageBody.displayName forKey:@"changeVoice_MessageBody"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[ECDevice sharedInstance].messageManager playVoiceMessage:messageBody completion:^(ECError *error) {
    }];
}

-(void)petiteVoice {
    ECSountTouchConfig *config = [[ECSountTouchConfig alloc] init];
    config.pitch = 8;
    [self changeVoiceAndPlayVoice:config];
}

-(void)uncleVoice {
    ECSountTouchConfig *config = [[ECSountTouchConfig alloc] init];
    config.pitch = -4;
    config.rate = -10;
    [self changeVoiceAndPlayVoice:config];
}

-(void)thrillerVoice {
    ECSountTouchConfig *config = [[ECSountTouchConfig alloc] init];
    config.tempoChange = 0;
    config.pitch = 0;
    config.rate = -20;
    [self changeVoiceAndPlayVoice:config];
}

-(void)parodyVoice {
    ECSountTouchConfig *config = [[ECSountTouchConfig alloc] init];
    config.rate = 100;
    [self changeVoiceAndPlayVoice:config];
}

-(void)spaciousVoice {
    ECSountTouchConfig *config = [[ECSountTouchConfig alloc] init];
    config.tempoChange = 20;
    config.pitch = 0;
    [self changeVoiceAndPlayVoice:config];
}

- (void)changeVoiceAndPlayVoice:(ECSountTouchConfig*)config {
    
    [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
    NSString *srcFile = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[[NSUserDefaults standardUserDefaults] objectForKey:@"changeVoice_file"]];
    NSString *desFile = [[DeviceChatHelper sharedInstance] createSavePath];
    config.srcVoice = srcFile;
    config.dstVoice = desFile;
    
    [[ECDevice sharedInstance].messageManager changeVoiceWithSoundConfig:config completion:^(ECError *error, ECSountTouchConfig* dstSoundConfig) {
        
        if (error.errorCode == ECErrorType_NoError) {
            
            BOOL isOpen = [[ECDevice sharedInstance].VoIPManager getLoudsSpeakerStatus];
            if (!isOpen) {
                [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:YES];
            }
            
            ECVoiceMessageBody * messageBody = [[ECVoiceMessageBody alloc] initWithFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[dstSoundConfig.dstVoice lastPathComponent]] displayName:[dstSoundConfig.dstVoice lastPathComponent]];
            
            [[NSUserDefaults standardUserDefaults] setObject:messageBody.displayName forKey:@"changeVoice_MessageBody"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[ECDevice sharedInstance].messageManager playVoiceMessage:messageBody completion:^(ECError *error) {

            }];
        }
    }];
}
#pragma mark - CustomEmojiViewDelegate
-(void)emojiBtnInput:(NSInteger)emojiTag{
    _inputTextView.text =  [_inputTextView.text stringByAppendingString:
                            [CommonTools getExpressionStrById:emojiTag]];

}

-(void)backspaceText{
    if(_inputTextView.text.length > 0) {
        [_inputTextView deleteBackward];
    }
}

-(void)emojiSendBtn:(id)sender{
    [self sendTextMessage];
    _inputTextView.text = @"";
}
/**
 *@brief 改变toolbar显示的frame Y值
 */
-(void)toolbarDisplayChangedToFrameY:(CGFloat)frame_y andDuration:(NSTimeInterval)duration{
    
    __weak __typeof(self)weakSelf = self;
    if (toolbarDisplay == ToolbarDisplay_None) {
        [_emojiBtn setImage:[UIImage imageNamed:@"facial_expression_icon"] forState:UIControlStateNormal];
        [_emojiBtn setImage:[UIImage imageNamed:@"facial_expression_icon_on"] forState:UIControlStateHighlighted];
        CGRect frame = _emojiView.frame;
        frame.origin.y = self.view.frame.size.height;
        _emojiView.frame = frame;
    }
    
    //如果只显示的toolbar是输入框，表情页消失
    if (frame_y == self.view.frame.size.height-_containerView.frame.size.height+ToolbarMoreViewHeight) {
        CGRect frame = _emojiView.frame;
        frame.origin.y = self.view.frame.size.height;
        _emojiView.frame = frame;
    }
    
    void(^animations)() = ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf && strongSelf.tableView) {
            CGRect frame = _containerView.frame;
            frame.origin.y = frame_y;
            _containerView.frame = frame;
            frame = strongSelf.tableView.frame;
            frame.size.height = _containerView.frame.origin.y-strongSelf.tableView.frame.origin.y;
            strongSelf.tableView.frame = frame;
        }
    };
    
    void(^completion)(BOOL) = nil;
    if (isScrollToButtom) {
        completion = ^(BOOL finished) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (strongSelf && strongSelf.messageArray.count>0) {
                [strongSelf scrollViewToBottom:YES];
            }
        };
    } else {
        isScrollToButtom = YES;
    }
    
    [UIView animateWithDuration:duration delay:0.0f options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:completion];
}


/**
 *@brief 根据按钮改变工具栏的显示布局
 */
-(void)switchToolbarDisplay:(id)sender {
    
    _footView.hidden = _isStartRecord;
    
    UIButton*button = (UIButton*)sender;
    
    //如果上次显示内容为录音，更改显示
    if (toolbarDisplay == ToolbarDisplay_Record) {
        _inputView.hidden = NO;
    }
    
    //如果上次显示内容为表情
    if (toolbarDisplay == ToolbarDisplay_Emoji) {
        CGRect frame = _emojiView.frame;
        frame.origin.y = self.view.frame.size.height;
        _emojiView.frame=frame;
    }
    
    __weak __typeof(self)weakSelf = self;
    //如果两次按钮的相同触发输入文本
    if (button.tag == toolbarDisplay) {
        
        toolbarDisplay = ToolbarDisplay_None;
        [_inputTextView becomeFirstResponder];
    } else {
        
        CGFloat framey = self.view.frame.size.height-ToolbarInputViewHeight;
        if (button.tag == ToolbarDisplay_More) {
            //显示出附件功能页面
            _moreView.hidden = NO;
            _changeVoiceView.hidden = YES;
            framey = viewHeight-_containerView.frame.size.height-ToolbarInputViewHeight;
        } else if (button.tag == ToolbarDisplay_Emoji) {
            //显示表情页面
            framey = viewHeight-_containerView.frame.size.height-93.0f;
            _inputTextView.selectedRange = NSMakeRange(_inputTextView.text.length,0);
            void(^animations)() = ^{
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                if (strongSelf) {
                    CGRect frame = _emojiView.frame;
                    frame.origin.y = viewHeight-_emojiView.frame.size.height;
                    _emojiView.frame=frame;
                }
            };

            [UIView animateWithDuration:0.25 delay:0.1f options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:nil];
            
        } else if (button.tag == ToolbarDisplay_Record) {
            //显示录音按钮，并返回默认的布局
            framey = viewHeight-_containerView.frame.size.height-ToolbarInputViewHeight;
            _moreView.hidden = YES;
            _changeVoiceView.hidden = YES;
            _recordView.hidden = NO;
        }
        
        toolbarDisplay = (ToolbarDisplay)button.tag;
        
        if (_isDisplayKeyborad) {
            //如果显示键盘，在keyboardWillChangeFrame中更改显示
            [self.view endEditing:YES];
        } else {
            //如果未显示键盘，更改显示
            [self toolbarDisplayChangedToFrameY:framey andDuration:0.25];
        }
    }
    
    //更换按钮上显示的图片
    if (toolbarDisplay == ToolbarDisplay_Record) {
        [_switchVoiceBtn setImage:[UIImage imageNamed:@"keyboard_icon"] forState:UIControlStateNormal];
        [_switchVoiceBtn setImage:[UIImage imageNamed:@"keyboard_icon_on"] forState:UIControlStateHighlighted];
        [_emojiBtn setImage:[UIImage imageNamed:@"facial_expression_icon"] forState:UIControlStateNormal];
        [_emojiBtn setImage:[UIImage imageNamed:@"facial_expression_icon_on"] forState:UIControlStateHighlighted];
    } else if (toolbarDisplay == ToolbarDisplay_Emoji) {
        [_switchVoiceBtn setImage:[UIImage imageNamed:@"voice_icon"] forState:UIControlStateNormal];
        [_switchVoiceBtn setImage:[UIImage imageNamed:@"voice_icon_on"] forState:UIControlStateHighlighted];
        [_emojiBtn setImage:[UIImage imageNamed:@"keyboard_icon"] forState:UIControlStateNormal];
        [_emojiBtn setImage:[UIImage imageNamed:@"keyboard_icon_on"] forState:UIControlStateHighlighted];
    } else {
        [_switchVoiceBtn setImage:[UIImage imageNamed:@"voice_icon"] forState:UIControlStateNormal];
        [_switchVoiceBtn setImage:[UIImage imageNamed:@"voice_icon_on"] forState:UIControlStateHighlighted];
        [_emojiBtn setImage:[UIImage imageNamed:@"facial_expression_icon"] forState:UIControlStateNormal];
        [_emojiBtn setImage:[UIImage imageNamed:@"facial_expression_icon_on"] forState:UIControlStateHighlighted];
    }
}

#pragma mark - 录音操作

//按下操作
-(void)recordButtonTouchDown {
    
    if (_amplitudeSuperView==nil) {
        //动态添加振幅操作
        [self createAmplitudeImageView];
    }
    
    if (self.playVoiceMessage) {
        //如果有播放停止播放语音
        objc_setAssociatedObject(self.playVoiceMessage, &KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
        [self.tableView reloadData];
        self.playVoiceMessage = nil;
    }
    
    static int seedNum = 0;
    if(seedNum >= 1000)
        seedNum = 0;
    seedNum++;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *file = [NSString stringWithFormat:@"tmp%@%03d.amr", currentDateStr, seedNum];

    ECVoiceMessageBody * messageBody = [[ECVoiceMessageBody alloc] initWithFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:file] displayName:file];

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    __weak __typeof(self)weakSelf = self;
    [[ECDevice sharedInstance].messageManager startVoiceRecording:messageBody error:^(ECError *error, ECVoiceMessageBody *messageBody) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (error.errorCode == ECErrorType_RecordTimeOut) {
            
            [strongSelf.amplitudeSuperView removeFromSuperview];
            strongSelf.amplitudeSuperView = nil;
            strongSelf.tableView.userInteractionEnabled = YES;
            
            if (_recordView.isChangeVoice) {
                _isStartRecord = YES;
                [strongSelf createChangeVoiceView];
                [[NSUserDefaults standardUserDefaults] setObject:messageBody.displayName forKey:@"changeVoice_file"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                
                [strongSelf sendMediaMessage:messageBody];
            }
        }
    }];
    
    _recordInfoLabel.text = @"手指上划,取消发送";
}

//按钮外抬起操作
-(void)recordButtonTouchUpOutside {
    
    __weak __typeof(self)weakSelf = self;
    [[ECDevice sharedInstance].messageManager stopVoiceRecording:^(ECError *error, ECVoiceMessageBody *messageBody) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.amplitudeSuperView removeFromSuperview];
        strongSelf.amplitudeSuperView = nil;
        strongSelf.tableView.userInteractionEnabled = YES;
    }];
}

//按钮内抬起操作
-(void)recordButtonTouchUpInside {
    __weak __typeof(self)weakSelf = self;
    [[ECDevice sharedInstance].messageManager stopVoiceRecording:^(ECError *error, ECVoiceMessageBody *messageBody) {
        if (weakSelf == nil) {
            return ;
        }
        __strong __typeof(weakSelf)strongSelf = weakSelf;

        [strongSelf.amplitudeSuperView removeFromSuperview];
        strongSelf.amplitudeSuperView = nil;
        strongSelf.tableView.userInteractionEnabled = YES;

        if (error.errorCode == ECErrorType_NoError) {
            if (_recordView.isChangeVoice) {
                _isStartRecord = YES;
                [self createChangeVoiceView];
                [[NSUserDefaults standardUserDefaults] setObject:messageBody.displayName forKey:@"changeVoice_file"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                [strongSelf sendMediaMessage:messageBody];
            }
        } else if  (error.errorCode == ECErrorType_RecordTimeTooShort) {
            
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.userInteractionEnabled = NO;
            hud.labelText = @"录音时间过短";
            hud.margin = 10.0f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:1.0f];
        }
    }];
}

//手指划出按钮
-(void)recordDragOutside {
    _recordInfoLabel.text = @"松开手指,取消发送";
}

//手指划入按钮
-(void)recordDragInside {
    _recordInfoLabel.text = @"手指上划,取消发送";
}

-(void)recordingAmplitude:(NSNotification*)notification {
    
    double amplitude = ((NSNumber*)notification.object).doubleValue;
    if (amplitude<0.14) {
        _amplitudeImageView.image = [UIImage imageNamed:@"press_speak_icon_07"];
    } else if (0.14<= amplitude <0.28) {
        _amplitudeImageView.image = [UIImage imageNamed:@"press_speak_icon_06"];
    } else if (0.28<= amplitude <0.42) {
        _amplitudeImageView.image = [UIImage imageNamed:@"press_speak_icon_05"];
    } else if (0.42<= amplitude <0.57) {
        _amplitudeImageView.image = [UIImage imageNamed:@"press_speak_icon_04"];
    } else if (0.57<= amplitude <0.71) {
        _amplitudeImageView.image = [UIImage imageNamed:@"press_speak_icon_03"];
    } else if (0.71<= amplitude <0.85) {
        _amplitudeImageView.image = [UIImage imageNamed:@"press_speak_icon_02"];
    } else if (0.85<= amplitude) {
        _amplitudeImageView.image = [UIImage imageNamed:@"press_speak_icon_01"];
    }
}

#pragma mark - moreview 动作
/**
 *@brief 音频通话按钮
 */
- (void)voiceCallBtnTap:(id)sender {

    [self endOperation];
    
    // 弹出VoIP音频界面
    VoipCallController * VVC = [[VoipCallController alloc] initWithCallerName:_titleLabel.text andCallerNo:self.sessionId andVoipNo:self.sessionId andCallType:1];
    [self presentViewController:VVC animated:YES completion:nil];
}

/**
 *@brief 视频通话按钮
 */
-(void)videoCallBtnTap:(id)sender {
    
    [self endOperation];
    
   // 弹出视频界面
    [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:YES];
    VideoViewController * vvc = [[VideoViewController alloc]initWithCallerName:_titleLabel.text andVoipNo:self.sessionId andCallstatus:0];
    [self presentViewController:vvc animated:YES completion:nil];
}

/**
 *@brief 视频按钮
 */
-(void)videoBtnTap:(id)sender {
    
    [self endOperation];
    // 弹出视频窗口
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypeCamera)]) {
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设备不支持摄像头" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alterView show];
    }
    imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
    
    imagePicker.videoMaximumDuration = 30;
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

/**
 *@brief 图片按钮
 */
-(void)pictureBtnTap:(id)sender {
    isReadDeleteMessage = NO;
    // 弹出照片选择
    [self popTypeOfImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)popTypeOfImagePicker:(UIImagePickerControllerSourceType)sourceType {
    
    [self endOperation];
    
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

/**
 *@brief 照相按钮
 */
-(void)cameraBtnTap:(id)sender {
    isReadDeleteMessage = NO;
    [self endOperation];
    
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;

#if 0
    //只照相
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
#else
    //支持视频功能
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
    imagePicker.videoMaximumDuration = 30;
#endif
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        //判断相机是否能够使用
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(status == AVAuthorizationStatusAuthorized) {
            // authorized
             [self presentViewController:imagePicker animated:YES completion:NULL];
        } else if(status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied){
            // restricted
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"无法使用相机" message:@"请在“设置-隐私-相机”选项中允许访问你的相机" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
            });
        } else if(status == AVAuthorizationStatusNotDetermined){
            // not determined
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){
                     [self presentViewController:imagePicker animated:YES completion:NULL];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[UIAlertView alloc] initWithTitle:@"无法使用相机" message:@"请在“设置-隐私-相机”选项中允许访问你的相机" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
                    });
                }
            }];
        }
    }
}

-(void)snapFireBtnTap:(id)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册中选取", nil];
    sheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [sheet showInView:self.view];
}

-(void)locationBtnTap:(id)sender {
    ECLocationViewController *locationVC = [[ECLocationViewController alloc] init];
    locationVC.backView = self;
    locationVC.delegate = self;
    [self.navigationController pushViewController:locationVC animated:NO];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        isReadDeleteMessage = YES;

        NSString* button = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([button isEqualToString:@"拍照"]) {
            [self popTypeOfImagePicker:UIImagePickerControllerSourceTypeCamera];
        } else if ([button isEqualToString:@"从相册中选取"]) {
            [self popTypeOfImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    }
}

#pragma mark - 发送消息操作

/**
 *@brief 发送媒体类型消息
 */
-(void)sendMediaMessage:(ECFileMessageBody*)mediaBody {
    
    ECMessage *message = [[ECMessage alloc] init];
    if (isReadDeleteMessage) {
        message = [[DeviceChatHelper sharedInstance] sendMediaMessage:mediaBody to:self.sessionId withUserData:@"fireMessage"];
    } else {
        message = [[DeviceChatHelper sharedInstance] sendMediaMessage:mediaBody to:self.sessionId];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
}

/**
 *@brief 发送文本消息
 */
-(void)sendTextMessage {

    NSString * textString = [_inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (textString.length == 0) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:@"不能发送空白消息" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    ECMessage* message = [[DeviceChatHelper sharedInstance] sendTextMessage:textString to:self.sessionId];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
}

/**
 *@brief 发送成功，消息状态更新
 */
-(void)sendMessageCompletion:(NSNotification*)notification {
    
    ECMessage* message = notification.userInfo[KMessageKey];
    __weak  __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        if ([strongSelf.sessionId isEqualToString:message.sessionId]) {
            for (int i=strongSelf.messageArray.count-1; i>=0 ; i--) {
                id content = [strongSelf.messageArray objectAtIndex:i];
                if ([content isKindOfClass:[NSNull class]]) {
                    continue;
                }
                ECMessage *currMsg = (ECMessage *)content;
                if ([message.messageId isEqualToString:currMsg.messageId]) {
                    currMsg.messageState = message.messageState;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.tableView beginUpdates];
                        [strongSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                        [strongSelf.tableView endUpdates];
                    });
                    break;
                }
            }
        }
    });
}

//下载媒体消息附件完成，状态更新
-(void)downloadMediaAttachFileCompletion:(NSNotification*)notification {
    
    ECError *error = notification.userInfo[KErrorKey];
    if (error.errorCode != ECErrorType_NoError) {
        return;
    }
    
    ECMessage* message = notification.userInfo[KMessageKey];
    __weak  __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        if ([strongSelf.sessionId isEqualToString:message.sessionId]) {
            for (NSInteger i=strongSelf.messageArray.count-1; i>=0; i--) {
                id content = [strongSelf.messageArray objectAtIndex:i];
                if ([content isKindOfClass:[NSNull class]]) {
                    continue;
                }
                ECMessage *currMsg = (ECMessage *)content;
                if ([message.messageId isEqualToString:currMsg.messageId]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.tableView beginUpdates];
                        [strongSelf.messageArray replaceObjectAtIndex:i withObject:message];
                        [strongSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                        [strongSelf.tableView endUpdates];
                    });
                    break;
                }
            }
        }
    });
}

-(void)ReceiveMessageDelete:(NSNotification*)notification {
    
    NSString *msgId = notification.userInfo[@"msgid"];
    NSString *sessionId = notification.userInfo[@"sessionid"];
    
    __weak  __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        if ([strongSelf.sessionId isEqualToString:sessionId]) {
            for (NSInteger i=strongSelf.messageArray.count-1; i>=0; i--) {
                id content = [strongSelf.messageArray objectAtIndex:i];
                if ([content isKindOfClass:[NSNull class]]) {
                    continue;
                }
                ECMessage *currMsg = (ECMessage *)content;
                if ([msgId isEqualToString:currMsg.messageId]) {
                    ECFileMessageBody* body = (ECFileMessageBody*)currMsg.messageBody;
                    body.localPath = nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.tableView beginUpdates];
                        [strongSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                        [strongSelf.tableView endUpdates];
                    });
                    break;
                }
            }
        }
    });
}

#pragma mark - 保存音视频文件
- (NSURL *)convertToMp4:(NSURL *)movUrl {
    
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];

    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPreset640x480]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset
                                                                              presetName:AVAssetExportPreset640x480];
        
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyyMMddHHmmssSSS"];
        NSString* fileName = [NSString stringWithFormat:@"%@.mp4", [formater stringFromDate:[NSDate date]]];
        NSString* path = [NSString stringWithFormat:@"file:///private%@",[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName]];
        mp4Url = [NSURL URLWithString:path];
        
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        
        if (wait) {
            wait = nil;
        }
    }
    
    return mp4Url;
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform     // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,CGImageGetBitsPerComponent(aImage.CGImage), 0,CGImageGetColorSpace(aImage.CGImage),CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
        default:              CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);              break;
    }       // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

#define DefaultThumImageHigth 90.0f
#define DefaultPressImageHigth 960.0f

-(void)saveGifToDocument:(NSURL *)srcUrl {
    
    ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *asset) {
        
        if (asset != nil) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            Byte *imageBuffer = (Byte*)malloc((unsigned long)rep.size);
            NSUInteger bufferSize = [rep getBytes:imageBuffer fromOffset:0.0 length:(unsigned long)rep.size error:nil];
            NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
            
            NSDateFormatter* formater = [[NSDateFormatter alloc] init];
            [formater setDateFormat:@"yyyyMMddHHmmssSSS"];
            NSString* fileName =[NSString stringWithFormat:@"%@.gif", [formater stringFromDate:[NSDate date]]];
            NSString* filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];

            [imageData writeToFile:filePath atomically:YES];
            
            ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:filePath displayName:filePath.lastPathComponent];
            [self sendMediaMessage:mediaBody];
        } else {
        }
    };
    
    ALAssetsLibrary* assetLibrary = [[ALAssetsLibrary alloc] init];
    [assetLibrary assetForURL:srcUrl
                  resultBlock:resultBlock
                 failureBlock:^(NSError *error){
                 }];
}

-(NSString*)saveToDocument:(UIImage*)image {
    UIImage* fixImage = [self fixOrientation:image];
    
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSString* fileName =[NSString stringWithFormat:@"%@.jpg", [formater stringFromDate:[NSDate date]]];
    
    NSString* filePath=[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    //图片按0.5的质量压缩－》转换为NSData
    CGSize pressSize = CGSizeMake((DefaultPressImageHigth/fixImage.size.height) * fixImage.size.width, DefaultPressImageHigth);
    UIImage * pressImage = [CommonTools compressImage:fixImage withSize:pressSize];
    NSData *imageData = UIImageJPEGRepresentation(pressImage, 0.5);
    [imageData writeToFile:filePath atomically:YES];
    
    CGSize thumsize = CGSizeMake((DefaultThumImageHigth/fixImage.size.height) * fixImage.size.width, DefaultThumImageHigth);
    UIImage * thumImage = [CommonTools compressImage:fixImage withSize:thumsize];
    NSData * photo = UIImageJPEGRepresentation(thumImage, 0.5);
    NSString * thumfilePath = [NSString stringWithFormat:@"%@.jpg_thum", filePath];
    [photo writeToFile:thumfilePath atomically:YES];

    return filePath;
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        [picker dismissViewControllerAnimated:YES completion:nil];

        // we will convert it to mp4 format
        NSURL *mp4 = [self convertToMp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        
        NSString *mp4Path = [mp4 relativePath];
        ECVideoMessageBody *mediaBody = [[ECVideoMessageBody alloc] initWithFile:mp4Path displayName:mp4Path.lastPathComponent];
        [self sendMediaMessage:mediaBody];
        
    } else {
        UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
        NSString* ext = imageURL.pathExtension.lowercaseString;

        if ([ext isEqualToString:@"gif"]) {
            [self saveGifToDocument:imageURL];
        } else {
            NSString *imagePath = [self saveToDocument:orgImage];
            ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:imagePath displayName:imagePath.lastPathComponent];
            [self sendMediaMessage:mediaBody];
        }
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

}

#pragma mark - HPGrowingTextViewDelegate

//根据新的高度来改变当前的页面的的布局
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    
    if (_recordView == nil) {
        [_recordView removeFromSuperview];
        _recordView = nil;
    }
    
    __weak __typeof(self)weakSelf = self;
    float diff = (growingTextView.frame.size.height - height);
    void(^animations)() = ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            CGRect r = _containerView.frame;
            r.size.height -= diff;
            r.origin.y += diff;
            _containerView.frame = r;
            
            CGRect _recordViewF = _recordView.frame;
            _recordViewF.origin.y -= diff;
            _recordView.frame = _recordViewF;
            
            CGRect tableFrame = strongSelf.tableView.frame;
            tableFrame.size.height += diff;
            strongSelf.tableView.frame = tableFrame;
        }
    };
    
    void(^completion)(BOOL) = ^(BOOL finished){
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf && strongSelf.messageArray.count>0){
            [strongSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:strongSelf.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    };

    [UIView animateWithDuration:0.1 delay:0.0f options:(UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:completion];
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [self sendTextMessage];
        growingTextView.text = @"";
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    if ([self.sessionId hasPrefix:@"g"] && [text myContainsString:@"@"]) {
        isOpenMembersList = YES;
        GroupMembersViewController *membersList = [[GroupMembersViewController alloc] init];
        membersList.groupID = self.sessionId;
        arrowLocation = range.location+1;
        dispatch_after(0.1, dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:membersList animated:YES];
        });
    }
    
    if (range.length == 1) {
        return YES;
    }
    return YES;
}

//获取焦点
- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView {
    [_menuController setMenuItems:nil];
    _inputMaskImage.image = [[UIImage imageNamed:@"input_box_on"] stretchableImageWithLeftCapWidth:95.0f topCapHeight:16.0f];
    if ([self.sessionId hasPrefix:@"g"] && [_inputTextView.text myContainsString:@"@"] && isOpenMembersList && _GroupMemberNickName.length>0) {
        isOpenMembersList = NO;
        NSMutableString * string = [NSMutableString stringWithFormat:@"%@",_inputTextView.text];
        [string insertString:[NSString stringWithFormat:@"%@ ",_GroupMemberNickName] atIndex:arrowLocation];
        
        _inputTextView.text = [NSString stringWithFormat:@"%@",string];
        _GroupMemberNickName = nil;
    }

}

//失去焦点
- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView {
    _inputMaskImage.image = [[UIImage imageNamed:@"input_box"] stretchableImageWithLeftCapWidth:95.0f topCapHeight:16.0f];
}

#pragma mark - ECLocationViewControllerDelegate
- (void)onSendUserLocation:(ECLocationPoint *)point {
    
    ECMessage* message = [[DeviceChatHelper sharedInstance] sendLocationMessage:point.coordinate andTitle:point.title to:self.sessionId];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
}
@end
