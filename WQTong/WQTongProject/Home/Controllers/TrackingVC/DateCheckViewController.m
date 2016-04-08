//
//  DateCheckViewController.m
//  waiqintong
//
//  Created by Apple on 11/11/15.
//  Copyright © 2015 cnbin. All rights reserved.
//

#import "DateCheckViewController.h"
#import "DateDetailsViewController.h"
#import "UUDatePicker.h"
#import "UUDatePicker_DateModel.h"
#import "WzcLocObjectModel.h"
#import "WzcLocationModel.h"

@interface DateCheckViewController ()

@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) NSArray *wzcLocObjectModelArray;

@end

@implementation DateCheckViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidLoad];
    self.title = @"历史记录";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                              style: UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(dateRunAction)];
    
    self.wzcLocObjectModelArray = [WzcLocObjectModel MR_findAllSortedBy:@"timestamp" ascending:NO];
    //NSLog(@"self.wzcLocObjectModelArray is %@",self.wzcLocObjectModelArray);
}

- (void)dateRunAction {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.wzcLocObjectModelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

    WzcLocObjectModel * wzcLocObjectModelCell = [self.wzcLocObjectModelArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [[NSString stringWithFormat:@"%@",wzcLocObjectModelCell.timestamp]substringToIndex:19];
    cell.accessoryType =  UITableViewCellAccessoryCheckmark;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [GlobalResource sharedInstance].detailResultRunObject = [self.wzcLocObjectModelArray objectAtIndex:indexPath.row];
    DateDetailsViewController * date = [[DateDetailsViewController alloc]init];
    [self.navigationController pushViewController:date animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

@end
