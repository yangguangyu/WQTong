//
//  TimerUploadTableViewController.m
//  waiqintong
//
//  Created by Apple on 11/21/15.
//  Copyright © 2015 cnbin. All rights reserved.
//

#import "TimerUploadTableViewController.h"
#import "TimerUploadModel.h"

@interface TimerUploadTableViewController ()

@property (nonatomic, strong) NSArray *timerResultsArray;

@end

@implementation TimerUploadTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"定时上传";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClick)];
    self.navigationItem.leftBarButtonItem = item;

    self.timerResultsArray = [TimerUploadModel MR_findAllSortedBy:@"timestamp" ascending:NO];
}

- (void)returnClick {
    
    if ([[self.navigationController viewControllers] count] ==1) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.timerResultsArray != nil && ![self.timerResultsArray isKindOfClass:[NSNull class]] && self.timerResultsArray.count != 0) {
        
        return self.timerResultsArray.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    if (self.timerResultsArray!= nil && ![self.timerResultsArray isKindOfClass:[NSNull class]] &&  self.timerResultsArray.count != 0)
    {
        TimerUploadModel * timerUploadModel= [self.timerResultsArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [[NSString stringWithFormat:@"上传时间:%@",timerUploadModel.timestamp]substringToIndex:24];
        if (timerUploadModel.isupload) {
            
            cell.accessoryType =  UITableViewCellAccessoryCheckmark;
        }
        return cell;
    }
        return nil;
}

@end
