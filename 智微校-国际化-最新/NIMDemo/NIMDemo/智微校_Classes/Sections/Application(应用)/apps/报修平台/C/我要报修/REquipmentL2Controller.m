//
//  REquipmentL2Controller.m
//  NIM
//
//  Created by 中电和讯 on 17/3/13.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "REquipmentL2Controller.h"
#import "UIView+SDAutoLayout.h"
#import <Reachability.h>
#import "TYHRepairDefine.h"
#import "TYHRepairMainHeaderView.h"
#import "UIButton+Extention.h"
#import "REquipmentTypeL2Cell.h"

#import "TYHNewRepairController.h"
#import "TYHRepairMainModel.h"
#import "TYHRepairNetRequestHelper.h"
#import "RRepairSubmitListController.h"
@interface REquipmentL2Controller ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView * collectionView;
@property(nonatomic,retain)NSMutableArray *itemArray;

@end

@implementation REquipmentL2Controller


#pragma mark - viewDiaLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"APP_repair_deviceSep", nil);
    
    [self setUpCollectionView];
    [self createBarItem];
    [self getNewData];
}



#pragma mark - initData
- (void)getNewData {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"APP_repair_getDeviceList", nil)];
    TYHRepairNetRequestHelper *helper = [TYHRepairNetRequestHelper new];
    [helper getRepairEquipmentTypeLvTwoListWithLvOneID:_equipmentTypeID andStatus:^(BOOL successful, NSMutableArray *dataSource) {
        _itemArray = [NSMutableArray arrayWithArray:dataSource];
        [self shouldCreateNoData:dataSource];
        [_collectionView reloadData];
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self.view makeToast:NSLocalizedString(@"APP_repair_getDeviceListFailed", nil) duration:1.5 position:CSToastPositionCenter];
    }];
}

#pragma mark - initView

- (void)setUpCollectionView {
    self.view.backgroundColor = [UIColor RepairBGColor];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    flowLayout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width / 2 - 20, 120);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 5; //调节Cell间距
    flowLayout.sectionInset = UIEdgeInsetsMake(7,7,7,7);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) collectionViewLayout:flowLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.bounces = NO;
    
    [collectionView registerNib:[UINib nibWithNibName:@"REquipmentTypeL2Cell" bundle:nil] forCellWithReuseIdentifier:@"REquipmentTypeL2Cell"];
    // 注册headView
    
    collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView = collectionView;
    [self.view addSubview:collectionView];
    
}

-(void)shouldCreateNoData:(NSMutableArray *)array
{
    UILabel *noDatalabel = [[UILabel alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height / 2 - 80, [UIScreen mainScreen].bounds.size.width, 40)];
    noDatalabel.text = NSLocalizedString(@"APP_General_noData", nil);
    CGPoint centerPoint = CGPointMake(self.collectionView.center.x, self.collectionView.center.y - 68);
    noDatalabel.center = centerPoint;
    noDatalabel.textColor = [UIColor grayColor];
    noDatalabel.textAlignment = NSTextAlignmentCenter;
    noDatalabel.font = [UIFont boldSystemFontOfSize:17];
    if (!noDatalabel.superview && !array.count) {
        [self.view addSubview:noDatalabel];
    }
    else [noDatalabel removeFromSuperview];
}


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


#pragma mark - Collection View Data Source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _itemArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    REquipmentTypeL2Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"REquipmentTypeL2Cell" forIndexPath:indexPath];
    cell.model = _itemArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    repairEquipmentTypeModel *model = _itemArray[indexPath.item];
    RRepairSubmitListController *listView = [RRepairSubmitListController new];
    listView.goodsID = model.itemID;
    listView.typeName = model.name;
    listView.groupID = self.groupID;
    [self.navigationController pushViewController:listView animated:YES];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width / 2 - 10 , 120);
    return itemSize;
}


// collectionView header 的高度设置
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(0, 20);
}

#pragma mark - Action
- (void)toReserveCar {
    TYHNewRepairController *applyView = [TYHNewRepairController new];
    [self.navigationController pushViewController:applyView animated:YES];
}

-(void)returnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Other
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor TabBarColorRepair]];
    //    [self getNewData];
    [self.view endEditing:YES];
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
