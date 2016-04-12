//
//  PersonVC.m
//  WQTong
//
//  Created by ChenBinbin on 16/4/9.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "PersonVC.h"

@interface PersonVC ()

@end

@implementation PersonVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的";

    self.userInfoArray = [UserInformationModel MR_findAllSortedBy:@"timestamp" ascending:NO];
    
    if (self.userInfoArray != nil && ![self.userInfoArray isKindOfClass:[NSNull class]] && self.userInfoArray.count != 0) {
        
        UserInformationModel * userObject = [UserInformationModel MR_findFirst];

        self.userArray = [NSMutableArray arrayWithObjects:userObject.trueName,userObject.department,userObject.idNumber,nil];
    
        self.infoArray = [NSMutableArray arrayWithObjects:@"用户名",@"部门",@"ID号",nil];
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

    return self.userArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@:%@",[self.infoArray objectAtIndex:indexPath.row],[self.userArray objectAtIndex:indexPath.row]];
    
    return cell;
}

@end
