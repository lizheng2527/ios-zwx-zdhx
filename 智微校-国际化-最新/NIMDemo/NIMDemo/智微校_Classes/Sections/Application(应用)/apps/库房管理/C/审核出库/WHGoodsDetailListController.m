//
//  WHGoodsDetailListController.m
//  TYHxiaoxin
//
//  Created by 中电和讯 on 17/2/9.
//  Copyright © 2017年 Lanxum. All rights reserved.
//

#import "WHGoodsDetailListController.h"

#import "WHNetHelper.h"
#import "WHGoodsModel.h"

#import <UIView+Toast.h>

#import "WHApplicationController.h"

#import "WHAddApplicationDiliverController.h"

@interface WHGoodsDetailListController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,retain)NSMutableArray *dataArray;

@end

@implementation WHGoodsDetailListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initView];
    [self createBarItem];
    [self dataRequest];
}

-(void)setTmpDataArray:(NSMutableArray *)tmpDataArray
{
    if (tmpDataArray.count) {
        _tmpDataArray = [NSMutableArray arrayWithArray:tmpDataArray];
    }else _tmpDataArray = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DataRequest
-(void)dataRequest
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelFont = [UIFont systemFontOfSize:12];
    hud.labelText = NSLocalizedString(@"APP_wareHouse_nowGettingData", nil);
    
    WHNetHelper *helper = [[WHNetHelper alloc]init];
    
    [helper getGoodsDetailListWithGoodsID:_goodsID andStatus:^(BOOL successful, NSMutableArray *dataSource) {
        
        _dataArray = [NSMutableArray arrayWithArray:dataSource];
        [_mainTableView reloadData];
        [hud removeFromSuperview];
        
    } failure:^(NSError *error) {
        
        [self.view makeToast:NSLocalizedString(@"APP_General_serverFailure", nil) duration:1 position:nil];
        [hud removeFromSuperview];
        
    }];
    
}


#pragma mark - TableViewConfig
-(void)initView
{
    self.title = NSLocalizedString(@"APP_wareHouse_goodsDetail", nil);
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.tableFooterView = [UIView new];
    _mainTableView.bounces = NO;
    _mainTableView.editing = YES;
    _mainTableView.allowsMultipleSelectionDuringEditing = YES;
}


#pragma mark - tableview Delegate & DataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *iden1 = @"WHMineListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden1];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:iden1];
    }
    cell.textLabel.text = [_dataArray[indexPath.row] name];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHGoodsDetailModel *model = _dataArray[indexPath.row];
    if(![_tmpDataArray containsObject:model])
    {
        model.count = [NSString stringWithFormat:@"%d",1]; //默认为1;
        [_tmpDataArray addObject:model];
    }
    
//    for (WHGoodsDetailModel *modelInArray in _tmpDataArray) {
//        if (![modelInArray.goodsInfoName isEqualToString:model.name]) {
//            [_tmpDataArray addObject:model];
//        }
//    }
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WHGoodsDetailModel *model = _dataArray[indexPath.row];
    if([_tmpDataArray containsObject:model])
    {
        [_tmpDataArray removeObject:model];
    }
    
//    for (WHGoodsDetailModel *modelInArray in _tmpDataArray) {
//        if ([modelInArray.goodsInfoName isEqualToString:model.name]) {
//            [_tmpDataArray removeObject:modelInArray];
//        }
//    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}



#pragma mark - Other
-(void)createBarItem
{
    UIBarButtonItem *
    barItemInNavigationBarAppearanceProxy = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
    //设置字体为加粗的12号系统字，自己也可以随便设置。
    [barItemInNavigationBarAppearanceProxy
     setTitleTextAttributes:[NSDictionary
                             dictionaryWithObjectsAndKeys:[UIFont
                                                           boldSystemFontOfSize:14], NSFontAttributeName,nil] forState:UIControlStateNormal];
    
    UIBarButtonItem * leftItem = nil;
    UIBarButtonItem * rightItem = nil;
    
    leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClick:)];
    rightItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"APP_General_Confirm", nil) style:UIBarButtonItemStyleDone target:self
                                               action:@selector(diliverAction:)];
    

    self.navigationItem.leftBarButtonItem =leftItem;
    self.navigationItem.rightBarButtonItem =rightItem;
}

-(void)returnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)diliverAction:(id)sender
{
    UIViewController
    *takeView = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-3];
    if ([takeView isKindOfClass:[WHApplicationController class]]) {
        WHApplicationController *whacView = (WHApplicationController *)takeView;
        whacView.dataArray = [NSMutableArray arrayWithArray:_tmpDataArray];
        [self.navigationController
         popToViewController:whacView animated:true];
    }
    else if([takeView isKindOfClass:[WHAddApplicationDiliverController class]]) {
        WHAddApplicationDiliverController *whacView = (WHAddApplicationDiliverController *)takeView;
        whacView.dataArray = [NSMutableArray arrayWithArray:_tmpDataArray];
        [self.navigationController
         popToViewController:whacView animated:true];
    }
//    WHApplicationController
//    *takeView = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-3];
//    takeView.dataArray = [NSMutableArray arrayWithArray:_tmpDataArray];
//    [self.navigationController
//     popToViewController:takeView animated:true];
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
