//
//  WHOutResignController.m
//  NIM
//
//  Created by 中电和讯 on 2017/4/12.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "WHOutResignController.h"
#import "NSString+Empty.h"
#import "WHOutModel.h"
#import "WHNetHelper.h"
#import "AssetDiliverFooterView.h"
#import "AssetDrawController.h"

@interface WHOutResignController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,retain)WHOutResignModel *mainModel;
@end

@implementation WHOutResignController
{
    NSInteger footerViewHeight;
    
    UIButton *addPicBtn;
    AssetDiliverFooterView *footView;
}

#pragma mark - viewDidLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"APP_assets_RESIGN", nil);
    [self initView];
    [self createBarItem];
    
    [self requestData];
    
    footerViewHeight = 120;
    _mainTableView.sectionFooterHeight = footerViewHeight;
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"tmpImageDataa"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    NSData *imageData = [[NSUserDefaults standardUserDefaults]objectForKey:@"tmpImageDataa"];
    if (imageData) {
        [addPicBtn setBackgroundImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
        addPicBtn.frame = CGRectMake(0, 40, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height);
        footerViewHeight = [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height + 40;
        footView.frame = CGRectMake(footView.frame.origin.x, footView.frame.origin.y, [UIScreen mainScreen].bounds.size.width, footerViewHeight);
    }
    [_mainTableView reloadData];
}

#pragma mark - initData
-(void)requestData
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelFont = [UIFont systemFontOfSize:12];
    hud.labelText = NSLocalizedString(@"APP_General_GettingData", nil);
    
    WHNetHelper *helper = [WHNetHelper new];
    
    [helper getResignDetailWithOutID:self.outID.length?self.outID:@"" andStatus:^(BOOL successful, WHOutResignModel *model) {
        self.mainModel = [WHOutResignModel new];
        self.mainModel = model;
        
        self.ApplicationUserLabel.text = model.userName;
        self.diliverTimeLabel.text = model.grantTime;
        [_mainTableView reloadData];
        [hud removeFromSuperview];
        
    } failure:^(NSError *error) {
        [hud removeFromSuperview];
        [self.view makeToast:NSLocalizedString(@"APP_General_serverFailure", nil) duration:1.5 position:CSToastPositionCenter];

    }];
}

#pragma mark - initView

-(void)initView
{
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.rowHeight = 40;
    _mainTableView.bounces = NO;
    _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
}


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
    rightItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"APP_General_Submit", nil) style:UIBarButtonItemStyleDone target:self
                                               action:@selector(submitAction:)];
    
    self.navigationItem.leftBarButtonItem =leftItem;
    self.navigationItem.rightBarButtonItem =rightItem;
}


#pragma mark - tableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mainModel.goodsListModelArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"celll"];
    WHOutGoodsListModel *detailModel = [self.mainModel.goodsListModelArray objectAtIndex:indexPath.row];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"celll"];
        cell.textLabel.text = [NSString stringWithFormat:@"%ld.%@",(long)indexPath.row + 1,detailModel.goodsName];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//自定义footView
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
        footView = [AssetDiliverFooterView new];
        footView.userInteractionEnabled = YES;
        footView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, footerViewHeight);
        footView.backgroundColor = [UIColor whiteColor];
        [self initFootView];
        
        NSData *imageData = [[NSUserDefaults standardUserDefaults]objectForKey:@"tmpImageDataa"];
        if (imageData) {
            [addPicBtn setBackgroundImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
            addPicBtn.frame = CGRectMake(0, 8, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height);
            footerViewHeight = [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height + 8;
            footView.frame = CGRectMake(footView.frame.origin.x, footView.frame.origin.y, [UIScreen mainScreen].bounds.size.width, footerViewHeight);
        }
        return footView;
}

-(void)initFootView
{
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 8, .5f)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [footView addSubview:lineView];
    
    addPicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addPicBtn.frame = CGRectMake(30, 8, 70, 70);
    [addPicBtn setBackgroundImage:[UIImage imageNamed:@"AlbumAddBtnHL@2x"] forState:UIControlStateNormal];
    [addPicBtn addTarget:self action:@selector(AddPicAction:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:addPicBtn];
 
}



-(void)AddPicAction:(id)sender
{
    AssetDrawController *drawView = [AssetDrawController new];
    drawView.type = 1;
    [self presentViewController:drawView animated:YES completion:nil];
}


#pragma mark - Actions
-(void)returnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)submitAction:(id)sender
{
    WHNetHelper *helper = [WHNetHelper new];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelFont = [UIFont systemFontOfSize:12];
    hud.labelText = NSLocalizedString(@"APP_wareHouse_submiting", nil);
    
    [helper saveResignImageWitjOutID:self.outID.length?self.outID:@"" andStatus:^(BOOL successful, NSMutableArray *dataSource) {
        
        [hud removeFromSuperview];
        [self.view makeToast:NSLocalizedString(@"APP_wareHouse_reSignSuccess", nil) duration:1.5 position:CSToastPositionCenter];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    } failure:^(NSError *error) {
        [hud removeFromSuperview];
        [self.view makeToast:NSLocalizedString(@"APP_wareHouse_reSignFailed", nil) duration:1.5 position:CSToastPositionCenter];
    }];
    
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
