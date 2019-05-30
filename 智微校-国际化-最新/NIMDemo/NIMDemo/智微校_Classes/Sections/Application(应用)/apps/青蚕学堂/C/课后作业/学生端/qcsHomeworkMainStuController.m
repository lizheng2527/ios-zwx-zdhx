//
//  qcsHomeworkMainStuController.m
//  NIM
//
//  Created by 中电和讯 on 2018/12/26.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "qcsHomeworkMainStuController.h"

#import "qcsHomeworkReleaseController.h"
#import "qcsHomeworkSearchStuController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "QCSNetHelper.h"
#import "qcsHomeworkModel.h"
#import "qcsHomeworkMainCell.h"
#import "QCSchoolDefine.h"
#import <MJRefresh.h>

@interface qcsHomeworkMainStuController ()<UITableViewDelegate,UITableViewDataSource,qcsHomeworkMainCellDelegate>

@property(nonatomic,retain)NSMutableArray *itemArray;

@property(nonatomic,copy)NSString *currentTime;

@property(nonatomic,assign)NSInteger pageNum;
@end

@implementation qcsHomeworkMainStuController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"课后作业";
    self.view.backgroundColor = [UIColor QCSBackgroundColor];
    [self createSearchNavBarItem];
    [self tableViewConfig];
    
    [self requestData];
    
}



-(void)requestData
{
    _currentTime = [QCSSourceHandler getDateTodayWIthSecond];
    
    _pageNum = 1;
    
    _itemArray = [NSMutableArray array];
    [SVProgressHUD showWithStatus:@"获取数据中"];
    QCSNetHelper *helper = [QCSNetHelper new];
    
    [helper getHomeWorkPageListWithPageNum:@"1" eclassIds:_eclassID idGrade:_idGrade idCourses:_idCourses startTime:_startTime endTime:_endTime type:_type isStudent:YES andStatus:^(BOOL successful, NSMutableArray *dataSource) {
        
        _itemArray = dataSource;
        [_mainTableView reloadData];
        [_mainTableView.mj_header endRefreshing];
        
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [_mainTableView.mj_header endRefreshing];
        [self.view makeToast:@"获取数据失败" duration:1.5 position:CSToastPositionCenter];
        
    }];
    
}

-(void)loadMoreData
{
    _pageNum ++;
    __weak typeof(self) weakSelf = self;
    
    QCSNetHelper *helper = [QCSNetHelper new];
    [helper getHomeWorkPageListWithPageNum:[NSString stringWithFormat:@"%ld",_pageNum] eclassIds:_eclassID idGrade:_idGrade idCourses:_idCourses startTime:_startTime endTime:_endTime type:_type isStudent:YES andStatus:^(BOOL successful, NSMutableArray *dataSource) {
        if (!dataSource.count) {
            _pageNum--;
            [weakSelf.mainTableView.mj_footer endRefreshing];
            [self.parentViewController.view makeToast:@"暂无更多数据了" duration:1.5 position:CSToastPositionBottom];
        }
        else
        {
            [weakSelf.mainTableView.mj_footer endRefreshing];
            [_itemArray addObjectsFromArray:dataSource];
            [_mainTableView reloadData];
        }
        
    } failure:^(NSError *error) {
        [weakSelf.mainTableView.mj_footer endRefreshing];
        _pageNum--;
    }];
}



#pragma mark - tableviewDatasource && Delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *iden1 = @"qcsHomeworkMainCell";
//    qcsHomeworkMainCell *cell = [tableView dequeueReusableCellWithIdentifier:iden1 forIndexPath:indexPath];
    qcsHomeworkMainCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[NSBundle mainBundle]loadNibNamed:@"qcsHomeworkMainCell" owner:self options:nil].firstObject;
    }
    cell.delegate = self;
    cell.model = _itemArray[indexPath.row];
    cell.currentTime = _currentTime;
    cell.isStu = YES;
    
//    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(globalQueue, ^{
//        //子线程异步执行下载任务，防止主线程卡顿
//
//    });
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:@"qcsHomeworkMainCell" cacheByIndexPath:indexPath configuration:^(qcsHomeworkMainCell *cell) {
        // 配置 cell 的数据源，和 "cellForRow" 干的事一致，比如：
        cell.model = _itemArray[indexPath.row];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _itemArray.count;
}


#pragma mark - qcsHomeworkMainCellDelegate

-(void)didClickSubmitButtonInCell:(qcsHomeworkMainCell *)cell
{
    
    qcsHomeworkReleaseController *qcView = [[qcsHomeworkReleaseController alloc]init];
    qcView.isStudent = YES;
    qcView.bgViewType.hidden = YES;
    qcView.bgvViewObj.hidden = YES;
    qcView.bgViewFinishTime.hidden = YES;
    qcView.homeworkID = cell.model.id;
    qcView.studentHasSubmit = [cell.model.stuFinishFlag integerValue];
    qcView.studentFinishTimeLimitDate = cell.model.dateEnd;
    [self.navigationController pushViewController:qcView animated:YES];
    
}




#pragma mark - ButtonClicked

-(void)searchAction:(id)sender
{
    qcsHomeworkSearchStuController *searchView = [qcsHomeworkSearchStuController new];
    searchView.studentCourseArray = [NSMutableArray arrayWithArray:self.studentCourseArray];
    [self.navigationController pushViewController:searchView animated:YES];
}


#pragma mark - ViewConfig
-(void)createSearchNavBarItem
{
    UIBarButtonItem * rightItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        rightItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"btn_query"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(searchAction:)];
    } else {
        rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_query"] style:UIBarButtonItemStyleDone target:self action:@selector(searchAction:)];
    }
    self.navigationItem.rightBarButtonItem = rightItem;
}


-(void)tableViewConfig
{
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.tableFooterView = [UIView new];
    _mainTableView.separatorStyle = NO;
    if (@available(iOS 11.0, *)) {
        self.mainTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    _mainTableView.backgroundColor = [UIColor QCSBackgroundColor];
    self.view.backgroundColor = [UIColor QCSBackgroundColor];
    
    [_mainTableView registerNib:[UINib nibWithNibName:@"qcsHomeworkMainCell" bundle:nil] forCellReuseIdentifier:@"qcsHomeworkMainCell"];
    
    
    self.mainTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    _mainTableView.ly_emptyView = [LYEmptyView emptyViewWithImageStr:@"noData"
                                                            titleStr:@"暂无数据"
                                                           detailStr:@""];
    
    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestData)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
