//
//  TYHAddFriendViewController.m
//  TYHxiaoxin
//
//  Created by 大存神 on 15/9/9.
//  Copyright (c) 2015年 Lanxum. All rights reserved.
//

#import "TYHAddFriendViewController.h"
#import <UIView+Toast.h>
#import "PersonModel.h"
#import "PersonRelationshipHelper.h"
#import "SessionViewCell.h"
#import <UIImageView+WebCache.h>
#import <MBProgressHUD.h>
#import "NTESPersonalCardViewController.h"

@interface TYHAddFriendViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate,UIScrollViewDelegate>
@property(nonatomic,retain)MBProgressHUD *HUD;

@end

@implementation TYHAddFriendViewController
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = [NSMutableArray array];
        _isEdited = YES;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createLeftBar];
    //    [self createSearchTextField];
    self.title = NSLocalizedString(@"APP_YUNXIN_Contact_chooseContactOften", nil);
    [self createTableView];
}

-(void)createTableView
{
    _mainTableView = [[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.bounces = NO;
    [_mainTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:_mainTableView];
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 290)];
    view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    _textField = [[UITextField alloc]initWithFrame:CGRectMake(15, 10, self.view.frame.size.width - 30, 30)];
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    _textField.delegate = self;
    _textField.returnKeyType = UIReturnKeySearch;
    _textField.placeholder = NSLocalizedString(@"APP_YUNXIN_Contact_inputUserName", nil);
    if (_isEdited) {
        [_textField becomeFirstResponder];
    }
    _textField.text = _tempString;
    [view addSubview:_textField];
    return view;
}

- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

-(UIImage *)dealImageWIthVoipAccount:(NSString *)voipAccount
{
    UIImage *image = [[UIImage alloc]init];
    image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:voipAccount];
    if (image && ![self isBlankString:voipAccount]) {
        return image;
    }
    else
        return [UIImage imageNamed:@"defult_head_img"];
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_dataSource.count > 0 && _dataSource) {
        return _dataSource.count;
    }
    else
        return 0;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *iden = @"BiuBiu";
    SessionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (!cell) {
        cell = [[SessionViewCell alloc]init];
    }
    PersonModel *model = [[PersonModel alloc]init];
    model = _dataSource[indexPath.row];
    //    cell.portraitImg.image = [[DemoGlobalClass sharedInstance]getOtherImageWithPhone:model.voipAccount];
    
    [cell.portraitImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL,model.headPortraitUrl]] placeholderImage:[UIImage imageNamed:@"defult_head_img"]];
    
    cell.portraitImg.layer.masksToBounds = YES;
    cell.portraitImg.layer.cornerRadius = cell.portraitImg.frame.size.width / 2;
    cell.nameLabel.text = model.name;
    cell.contentLabel.text = model.voipAccount;
    cell.unReadLabel.hidden = YES;
    cell.dateLabel.hidden = YES;
    cell.noPushImg.hidden = YES;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PersonModel *model = _dataSource[indexPath.row];
    //防止崩溃
    [self addFriend:model.accId.length?model.accId:@""];
}

- (void)addFriend:(NSString *)userId{
    __weak typeof(self) wself = self;
    [SVProgressHUD show];
    [[NIMSDK sharedSDK].userManager fetchUserInfos:@[userId] completion:^(NSArray *users, NSError *error) {
        [SVProgressHUD dismiss];
        if (users.count) {
            NTESPersonalCardViewController *vc = [[NTESPersonalCardViewController alloc] initWithUserId:userId];
            [wself.navigationController pushViewController:vc animated:YES];
        }else{
            if (wself) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"APP_YUNXIN_Contact_theUserNotExist", nil) message:NSLocalizedString(@"APP_YUNXIN_Contact_checkAccountRight", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"APP_General_Confirm", nil) otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_textField resignFirstResponder];
    [self searchBtnClick:(UIButton *)self.navigationItem.rightBarButtonItem];
    return YES;
}

-(void)returnClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_textField resignFirstResponder];
    [self.view endEditing:YES];
}


-(void)createLeftBar
{
    UIBarButtonItem * leftItem = nil;
    UIBarButtonItem * rightBtn = nil;
    UIBarButtonItem *
    barItemInNavigationBarAppearanceProxy = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
    //设置字体为加粗的12号系统字，自己也可以随便设置。
    [barItemInNavigationBarAppearanceProxy
     setTitleTextAttributes:[NSDictionary
                             dictionaryWithObjectsAndKeys:[UIFont
                                                           boldSystemFontOfSize:14], NSFontAttributeName,nil] forState:UIControlStateNormal];
    
    leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    rightBtn = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"APP_General_Submit", nil) style:UIBarButtonItemStyleDone target:self action:@selector(searchBtnClick:)];
    rightBtn.width = 0.5;
    
    rightBtn.tintColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem =leftItem;
    self.navigationItem.rightBarButtonItem =rightBtn;
}
-(void)searchBtnClick:(id)sender
{
    if ([self isBlankString:_textField.text]) {
        [_textField resignFirstResponder];
        [self.view makeToast:NSLocalizedString(@"APP_YUNXIN_Contact_inputRightAccount", nil) duration:1.0f position:CSToastPositionCenter];
        return;
    }
    [self.view endEditing:YES];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"APP_General_isSearching", nil)];
    
    if (_textField.text.length > 0) {
//        NSString *keyWord = [_textField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        PersonRelationshipHelper *helper = [[PersonRelationshipHelper alloc]init];
        [helper addFriendWithKeyWord:_textField.text andDeal:^(BOOL Success, NSMutableArray *array) {
            _dataSource = array;
            if (_dataSource.count == 0) {
                [SVProgressHUD dismiss];
                [self.view makeToast:NSLocalizedString(@"APP_YUNXIN_Contact_searchWithoutContact", nil) duration:1 position:nil];
            }
            [SVProgressHUD dismiss];
            _tempString = _textField.text;
            [_mainTableView reloadData];
            _textField.text = _tempString;
        }];
        [_textField resignFirstResponder];
        _isEdited = NO;
    }
    else
    {
        [_textField resignFirstResponder];
        _isEdited = NO;
        [self.view makeToast:NSLocalizedString(@"APP_YUNXIN_Contact_inputContactAccount", nil) duration:1 position:CSToastPositionCenter];
        return;
    }
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_textField resignFirstResponder];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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

