//
//  ContactListViewController.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ContactListViewController.h"
#import "ContactListViewCell.h"
#import "ContactDetailViewController.h"
#import "ChatViewController.h"

#import "AddressBookManager.h"

#import "SRRefreshView.h"

extern CGFloat NavAndBarHeight;

@interface ContactListViewController()<SRRefreshDelegate>
@property (nonatomic, strong) NSMutableDictionary *localAddressBook;
@property (nonatomic, strong) NSArray *allAddressKeys;
@property (nonatomic, strong) SRRefreshView *refreshView;
@end

@implementation ContactListViewController

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, -44.0f,self.view.frame.size.width,self.view.frame.size.height-NavAndBarHeight+44.0f) style:UITableViewStylePlain];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.sectionIndexColor = themeColor;
    [self.view addSubview:self.tableView];
    
    self.refreshView = [[SRRefreshView alloc] initWithFrame:CGRectMake(0, -44.0f, self.view.frame.size.width, 44.0f)];
    self.refreshView.delegate = self;
    self.refreshView.upInset=44;
    [self.tableView addSubview:self.refreshView];
    
    self.localAddressBook = [[AddressBookManager sharedInstance] NewallContactsBySorted];
    [self.localAddressBook setObject:@[[NSNull null]] forKey:@" "];
    self.allAddressKeys = [self.localAddressBook.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *letter1 = obj1;
        NSString *letter2 = obj2;
        if (KCNSSTRING_ISEMPTY(letter2)) {
            return NSOrderedDescending;
        }else if ([letter1 characterAtIndex:0] < [letter2 characterAtIndex:0]) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
}

-(void)prepareDisplay{
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.refreshView) {
        [self.refreshView scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.refreshView) {
        [self.refreshView scrollViewDidEndDraging];
    }
}

#pragma mark - SRRefreshDelegate
- (void)slimeRefreshStartRefresh:(SRRefreshView*)refreshView {
    [[AddressBookManager sharedInstance] clearAllData];
    self.localAddressBook = [[AddressBookManager sharedInstance] NewallContactsBySorted];
    [self.localAddressBook setObject:@[[NSNull null]] forKey:@" "];
    self.allAddressKeys = [self.localAddressBook.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *letter1 = obj1;
        NSString *letter2 = obj2;
        if (KCNSSTRING_ISEMPTY(letter2)) {
            return NSOrderedDescending;
        }else if ([letter1 characterAtIndex:0] < [letter2 characterAtIndex:0]) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    [self.tableView reloadData];
    [refreshView endRefresh];
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section==0) {
        return nil;
    }
    //UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 20)];

    headView.backgroundColor = [UIColor whiteColor];
    
    // 文字
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 305, 20)];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor darkGrayColor];
    [headView addSubview:label];
    label.text = self.allAddressKeys[section];
    
    // line
   // UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, 19, 305, 0.5)];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, 19, screenWidth, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [headView addSubview:lineView];
    
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section==0) {
        return 1;
    }
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AddressBook *book = [self.localAddressBook[self.allAddressKeys[indexPath.section]] objectAtIndex:indexPath.row];
    if ([book isKindOfClass:[NSNull class]]) {
        UIAlertView *alertView = alertView = [[UIAlertView alloc] initWithTitle:nil message:@"输入你想要联系的用户账号" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alertView textFieldAtIndex:0];
        textField.keyboardType = UIKeyboardTypeASCIICapable;
        alertView.tag = 100;
        [alertView show];
        return;
    }
    
    NSString* phone = [book.phones allValues].firstObject;
    if (KCNSSTRING_ISEMPTY(phone)) {
        UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该联系人无电话号码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        alerview.tag = 50;
        [alerview show];
    } else {
        ContactDetailViewController *contactDetail = [[ContactDetailViewController alloc] init];
        contactDetail.dict = @{nameKey:book.name,phoneKey:[book.phones allValues].firstObject,imageKey:book.head};
        [self.mainView pushViewController:contactDetail animated:YES];
    }
}

#pragma mark - UITableViewDataSource
//创建右侧索引表，返回需要显示的索引表数组
- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.allAddressKeys;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.allAddressKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(NSArray*)self.localAddressBook[self.allAddressKeys[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id addressbook = [self.localAddressBook[self.allAddressKeys[indexPath.section]] objectAtIndex:indexPath.row];
    if ([addressbook isKindOfClass:[NSNull class]]) {
        static NSString *nullcontactlistcellid = @"ContactListViewnullCellidentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nullcontactlistcellid];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nullcontactlistcellid];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 25.0f, screenWidth, 20.0f)];
            [cell.contentView addSubview:textLabel];
            textLabel.backgroundColor = [UIColor clearColor];
            textLabel.text = @"输入联系人账号";
            textLabel.font = [UIFont systemFontOfSize:17.0f];
            textLabel.textAlignment = NSTextAlignmentCenter;
            textLabel.userInteractionEnabled = NO;
        }
        return cell;
    } else {
        static NSString *contactlistcellid = @"ContactListViewCellidentifier";
        ContactListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactlistcellid];
        if (cell == nil) {
            cell = [[ContactListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contactlistcellid];
        }
        AddressBook *book = addressbook;
        cell.portraitImg.image = book.head;
        cell.nameLabel.text = book.name;
        NSString* phone = [book.phones allValues].firstObject;
        cell.numberLabel.text = phone?phone:@"无号码";
        return cell;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.cancelButtonIndex!=buttonIndex && alertView.tag==100) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *cleanString = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (cleanString.length>0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                ContactDetailViewController *contactDetail = [[ContactDetailViewController alloc] init];
                contactDetail.dict = @{nameKey:[[DemoGlobalClass sharedInstance] getOtherNameWithPhone:cleanString],phoneKey:cleanString,imageKey:[UIImage imageNamed:@"chatui_head_bg"]};
                [self.mainView pushViewController:contactDetail animated:YES];
            });
        }
    }
}
@end
