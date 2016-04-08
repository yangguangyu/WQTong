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
    

    self.locationResultsArray = [AddKQXXModel MR_findAllSortedBy:@"timestamp" ascending:NO];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshTableView)];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshTableView)];
}

#pragma mark - 刷新列表 先查询有没有上传失败的数据,有的话,全部找出来,然后上传,上传成功后修改标志。

-(void)refreshTableView {
    
    NSPredicate *addKQXXModelFilter = [NSPredicate predicateWithFormat:@"isAddKQXXSuccess=%@",@NO];
    NSFetchRequest *addKQXXModelRequest = [AddKQXXModel MR_requestAllWithPredicate:addKQXXModelFilter];
    [addKQXXModelRequest setReturnsDistinctResults:NO];
    
    NSArray *addKQXXModel = [AddKQXXModel MR_executeFetchRequest:addKQXXModelRequest];
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    
    for (AddKQXXModel *addKQXXModelId in addKQXXModel){
        
        [self setupRequestContext:defaultContext andAddKQXXModel:addKQXXModelId];
        [self.tableView reloadData];
        
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
    
    
    [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
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
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClick)];
    self.navigationItem.leftBarButtonItem = item;


//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新"
//                                                                              style: UIBarButtonItemStylePlain
//                                                                             target:self
//                                                                             action:@selector(refreshTableView)];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[IconFont imageWithIcon:[IconFont icon:@"fa_repeat" fromFont:fontAwesome] fontName:fontAwesome iconColor:UIRGBColor(0,101,229,1) iconSize:24.0f] style:UIBarButtonItemStyleDone target:self action:@selector(refreshTableView)];
    self.navigationItem.rightBarButtonItem = rightItem;

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

@end
