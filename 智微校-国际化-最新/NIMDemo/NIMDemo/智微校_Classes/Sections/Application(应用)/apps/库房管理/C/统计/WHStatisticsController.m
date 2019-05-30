//
//  WHStatisticsController.m
//  TYHxiaoxin
//
//  Created by 中电和讯 on 17/1/18.
//  Copyright © 2017年 Lanxum. All rights reserved.
//

#import "WHStatisticsController.h"
#import "WHStatisticsCell.h"
#import "WHStatisticsHeaderView.h"
#import "TYHWarehouseDefine.h"
#import "WHStatisticsHouseController.h"
#import "WHStatisticsCountController.h"
#import "WHNetHelper.h"
#import "WHGoodsStasticsModel.h"

#import <UIView+Toast.h>

@interface WHStatisticsController ()<UITableViewDataSource,UITableViewDelegate,WHStatisticsCellDelegate>
@property(nonatomic,retain)NSMutableArray *dataArray;
@end

@implementation WHStatisticsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initView];
    [self createBarItem];
    [self requestData];
}

#pragma mark - DataRequest
-(void)requestData
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelFont = [UIFont systemFontOfSize:12];
    hud.labelText = NSLocalizedString(@"APP_wareHouse_nowGettingData", nil);
    
    WHNetHelper *helper = [[WHNetHelper alloc]init];
    [helper getGoodsStasticsList:^(BOOL successful, NSMutableArray *dataSource) {
        _dataArray = [NSMutableArray arrayWithArray:dataSource];
        [_mainTableView reloadData];
        [hud removeFromSuperview];
    } failure:^(NSError *error) {
        [self.view makeToast:NSLocalizedString(@"APP_General_serverFailure", nil) duration:1 position:nil];
        [hud removeFromSuperview];
    }];
    
}

#pragma mark - ViewConfig
-(void)initView
{
    self.title = NSLocalizedString(@"APP_wareHouse_goodsStastic", nil);
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.tableFooterView = [UIView new];
    _mainTableView.separatorStyle = NO;
    _mainTableView.bounces = NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview Delegate & DataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        static NSString *iden1 = @"WHStatisticsCell";
        WHStatisticsCell *cell = [tableView dequeueReusableCellWithIdentifier:iden1];
        if (!cell) {
            cell =[[WHStatisticsCell alloc]init];
        }
    cell.delegate = self;
    cell.model = _dataArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row % 2 == 1) {
        cell.backgroundColor = [UIColor WarehouseStatisticsColor];
    }
        return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
        WHStatisticsHeaderView *headView = [[WHStatisticsHeaderView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
        return headView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

#pragma mark - Other
-(void)createBarItem
{
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7){
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClick:)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClick:)];
    }
    self.navigationItem.leftBarButtonItem =leftItem;
}

-(void)returnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - WHStatisticsCellDelegate
-(void)countLabelClickWithCell:(WHGoodsStasticsModel *)model
{
    WHStatisticsCountController *countView = [[WHStatisticsCountController alloc]initWithGoodsID:model.goodsID navTitle:model.goodsInfoName];
    [self.navigationController pushViewController:countView animated:YES];
}

-(void)inHouseLabelClickwithCell:(WHGoodsStasticsModel *)model
{
    WHStatisticsHouseController *houseView = [[WHStatisticsHouseController alloc]initWithGoodsID:model.goodsID requestType:NSLocalizedString(@"APP_wareHouse_inWHDetail", nil)];
    [houseView setNavTitle:NSLocalizedString(@"APP_wareHouse_inWHDetail", nil) secondTitle:model.goodsInfoName];
    [self.navigationController pushViewController:houseView animated:YES];
}

-(void)outHouseLabelClickWithCell:(WHGoodsStasticsModel *)model
{
    WHStatisticsHouseController *houseView = [[WHStatisticsHouseController alloc]initWithGoodsID:model.goodsID requestType:NSLocalizedString(@"APP_wareHouse_outWHDetail", nil)];
    [houseView setNavTitle:NSLocalizedString(@"APP_wareHouse_outWHDetail", nil) secondTitle:model.goodsInfoName];
    [self.navigationController pushViewController:houseView animated:YES];
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
