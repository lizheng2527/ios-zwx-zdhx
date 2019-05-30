//
//  qcsHomeworkSubmitDetailController.m
//  NIM
//
//  Created by 中电和讯 on 2018/12/26.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "qcsHomeworkSubmitDetailController.h"

#import "QCSchoolDefine.h"

#import "qcsClassStasticInsideXTTJCell.h"
#import "qcsClassStasticInsideDTBCell.h"
#import "qcsClassStasticInsideXTTJHeader.h"
#import "qcsClassStasticInsideDTBHeader.h"

#import "QCSNetHelper.h"
#import "QCSStasticModel.h"
#import <MJRefresh.h>
#import "qcsHomeworkDetailController.h"
#import "qcsHomeworkModel.h"

@interface qcsHomeworkSubmitDetailController ()<UITableViewDelegate,UITableViewDataSource,qcsClassStasticInsideXTTJCellDelegate>

@property(nonatomic,retain)NSMutableArray *itemSource;

@property(nonatomic,assign)NSInteger pageNum;

@end

@implementation qcsHomeworkSubmitDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initView];
    [self getData];
    self.title = @"提交详情";
    if (@available(iOS 11.0, *)) {
        self.mainTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
     self.mainTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMoreData)];
}

#pragma mark - initView
-(void)initView
{
    self.view.backgroundColor = [UIColor QCSBackgroundColor];
    
    _mainTableView.backgroundColor = [UIColor whiteColor];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.separatorStyle = NO;
    _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    _mainTableView.delaysContentTouches =NO;
    
    _mainTableView.ly_emptyView = [LYEmptyView emptyViewWithImageStr:@"noData"
                                                            titleStr:NSLocalizedString(@"APP_General_noData", nil)
                                                           detailStr:@""];
    
}



-(void)getData{
    
    _pageNum = 1;
    _itemSource = [NSMutableArray array];

    QCSNetHelper *helper =[QCSNetHelper new];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"APP_General_GettingData", nil)];
    
    [helper getHomeworkListWithHwId:_homewordID pageNum:@"1" pageSize:@"50" status:^(NSMutableArray *dataSource) {
        _itemSource = [NSMutableArray arrayWithArray:dataSource];
        [SVProgressHUD dismiss];
        [_mainTableView reloadData];
    }];
}

-(void)getMoreData{
    
    _pageNum ++;
    QCSNetHelper *helper =[QCSNetHelper new];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"APP_General_GettingData", nil)];
    
    [helper getHomeworkListWithHwId:_homewordID pageNum:[NSString stringWithFormat:@"%lu",_pageNum] pageSize:@"50" status:^(NSMutableArray *dataSource) {
        if (dataSource.count) {
            _pageNum++;
            [_itemSource addObjectsFromArray:dataSource];
            
            [_itemSource enumerateObjectsUsingBlock:^(qcsHomeworkSubmitListModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.orderNumber = [NSString stringWithFormat:@"%lu",idx + 1];
            }];
            
            [_mainTableView reloadData];
        }
        else
        {
            [self.view makeToast:@"暂无数据" duration:1.5 position:CSToastPositionBottom];
        }
        [SVProgressHUD dismiss];
        [_mainTableView.mj_footer endRefreshing];
    }];
}


#pragma mark -tableView Datasource&Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _itemSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

            static NSString *iden1 = @"qcsClassStasticInsideXTTJCell";
            qcsClassStasticInsideXTTJCell *cell = [tableView dequeueReusableCellWithIdentifier:iden1];
            if (!cell) {
                cell = [[NSBundle mainBundle]loadNibNamed:@"qcsClassStasticInsideXTTJCell" owner:self options:nil].firstObject;
            }
            
            if (_itemSource.count) {
                cell.dateEnd = _dateEnd;
                cell.homeworkModel = _itemSource[indexPath.row];
                
            }
    //    cell.delegate = self;
    
            return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    qcsHomeworkSubmitListModel *model = _itemSource[indexPath.row];
    
    if ([model.finishFlag isEqualToString:@"1"]) {
        qcsHomeworkDetailController *qcView = [qcsHomeworkDetailController new];
        qcView.model = model;
        qcView.dateEnd = _dateEnd;
        [self.navigationController pushViewController:qcView animated:YES];
    }
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
            qcsClassStasticInsideXTTJHeader *header = [[qcsClassStasticInsideXTTJHeader alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 16, 44)];
            header.itemRankLabel.text = @"序号";
            header.itemNameLabel.text = @"姓名";
            header.itemScoreLabel.text = @"班级";
            header.itemLevelLabel.text = @"详情";
    
    header.backgroundColor = [UIColor colorWithRed:95/255.0 green:206/255.0 blue:156/255.0 alpha:0.9];
    header.itemRankLabel.textColor = [UIColor whiteColor];
    header.itemNameLabel.textColor = [UIColor whiteColor];
    header.itemScoreLabel.textColor = [UIColor whiteColor];
    header.itemLevelLabel.textColor = [UIColor whiteColor];
    
            return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}


//-(void)didClickFinishLabelInCell:(qcsClassStasticInsideXTTJCell *)cell
//{
//    qcsHomeworkDetailController *qcView = [qcsHomeworkDetailController new];
//    [self.navigationController pushViewController:qcView animated:YES];
//
//}


-(void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
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
