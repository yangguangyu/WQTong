//
//  KQCXVC.m
//  WQTong
//
//  Created by ChenBinbin on 16/3/29.
//  Copyright © 2016年 cnbin. All rights reserved.
//

#import "KQCXVC.h"
#import "MJRefresh.h"
#import "AddKQXXModel.h"

static const CGFloat MJDuration = 1.0;

@interface KQCXVC ()

@property (strong, nonatomic) AddKQXXModel *uploadManagedObject;
@property (assign, nonatomic) Boolean isUploadSuccess;
@property (strong, nonatomic) NSArray *noUploadArray;
@property (strong, nonatomic) NSArray *locationResultsArray;

@end

@implementation KQCXVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initView];
    
    AddKQXXBL *addKQXXBL = [[AddKQXXBL alloc]init];

    self.locationResultsArray = [addKQXXBL findAll];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshTableView)];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshTableView)];
}

#pragma mark - 刷新列表 先查询有没有上传失败的数据,有的话,全部找出来,然后上传,上传成功后修改标志。

-(void)refreshTableView {
    
    NSManagedObjectContext *cxt = [[AddKQXXDAO sharedManager] managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"AddKQXXModel" inManagedObjectContext:cxt];
    
     NSFetchRequest * fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entityDescription];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isAddKQXXSuccess=%@",@NO];
    fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    NSArray *addKQXXModelArray = [cxt executeFetchRequest:fetchRequest error:&error];
    
    for (AddKQXXModel *addKQXXModelId in addKQXXModelArray) {
        
        [self setupRequestContext:cxt andAddKQXXModel:addKQXXModelId];
//        [self.tableView reloadData];
        
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MJDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刷新表格
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
    });

}

#pragma mark - 后台查询和请求

- (void)setupRequestContext:(NSManagedObjectContext *)weakManageObjectContext andAddKQXXModel:(AddKQXXModel *)addKQXXModel {
    
    NSString *strURL = [[NSString alloc] initWithFormat:webserviceURL];
    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];
    
    NSString * envelopeText = [NSString stringWithFormat:@"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                               "<soap:Body>"
                               "<AddKQXX xmlns=\"http://tempuri.org/\">"
                               "<username>%@</username>"
                               "<bumen>%@</bumen>"
                               "<poi>%@</poi>"
                               "<wz>%@</wz>"
                               "<lx>%@</lx>"
                               "<x>%f</x>"
                               "<y>%f</y>"
                               "<tp>%@</tp>"
                               "</AddKQXX>"
                               "</soap:Body>"
                               "</soap:Envelope>",
                               
                               addKQXXModel.username,
                               addKQXXModel.bumen,
                               addKQXXModel.poi,
                               addKQXXModel.wz,
                               
                               addKQXXModel.lx,
                               [addKQXXModel.x doubleValue],
                               [addKQXXModel.y doubleValue],
                               addKQXXModel.tp];
    
    
    NSData *envelope = [envelopeText dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:envelope];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[envelope length]] forHTTPHeaderField:@"Content-Length"];
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    if (data) {
        
        NSLog(@"连接成功");
        addKQXXModel.isAddKQXXSuccess = @YES;
    }else {
        NSLog(@"连接失败");
        addKQXXModel.isAddKQXXSuccess = @NO;
    }
    
    
        NSError *savingError = nil;
        if ([[[AddKQXXDAO sharedManager] managedObjectContext] save:&savingError]){
    
            NSLog(@"修改数据成功");
    
        } else {
            NSLog(@"修改数据失败");
        }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.locationResultsArray != nil && ![self.locationResultsArray isKindOfClass:[NSNull class]] && self.locationResultsArray.count != 0) {
        
        return self.locationResultsArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    if (self.locationResultsArray!= nil && ![ self.locationResultsArray isKindOfClass:[NSNull class]] &&  self.locationResultsArray.count != 0)
    {
        AddKQXXModel * addKQXXModel = [self.locationResultsArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [[NSString stringWithFormat:@"打卡时间:%@",addKQXXModel.timestamp]substringToIndex:24];
        if (addKQXXModel.isAddKQXXSuccess) {
            
            cell.accessoryType =  UITableViewCellAccessoryCheckmark;
        }
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
}

- (void)dismissdAction {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initView {
    
    self.title = @"签到记录";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新"
                                                                              style: UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(refreshTableView)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

@end
