//
//  TYHFindPasswordController.m
//  TYHxiaoxin
//
//  Created by 中电和讯 on 16/11/10.
//  Copyright © 2016年 Lanxum. All rights reserved.
//

#import "TYHFindPasswordController.h"
#import "TYHFindPasswordCell.h"
#import <UIView+Toast.h>
#import "TYHHttpTool.h"
#import <CZPicker.h>
#import "NSString+NTES.h"
#import "TYHLoginInfoModel.h"

@interface TYHFindPasswordController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,FindPasswordCellDelegate,CZPickerViewDataSource,CZPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *titleBgView;
@property (nonatomic,retain)CZPickerView *picker;
@end

@implementation TYHFindPasswordController
{
    NSMutableArray *itemArray;
    NSMutableArray *itemDetailArray;
    NSMutableArray *origranizationArray;
    NSString *organizationId;
    
    NSString *ajaxCode;
    NSString *userID;
    
    UIButton *tmpBtn;
    NSTimer *timer;
    NSInteger btnSecond;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initData];
    [self initTableView];
    self.title = NSLocalizedString(@"APP_LoginPW_findPasswordBack", nil);
    btnSecond = 60;
}

#pragma mark - initData
-(void)initData
{
    itemArray = [NSMutableArray arrayWithObjects:NSLocalizedString(@"APP_LoginPW_SchoolName", nil),NSLocalizedString(@"APP_LoginPW_userName", nil),NSLocalizedString(@"APP_LoginPW_PhoneNum", nil),NSLocalizedString(@"APP_LoginPW_ajaxNum", nil),NSLocalizedString(@"APP_LoginPW_Newpassword", nil),NSLocalizedString(@"APP_LoginPW_repeatPassword", nil), nil];
    itemDetailArray = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"", nil];
    if (![NSString isBlankString:[[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULT_LOGINNAME]]) {
        [itemDetailArray replaceObjectAtIndex:1 withObject:[[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULT_LOGINNAME]];
    }
    if (![NSString isBlankString:[[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULT_ORIGANIZATION_NAME]]) {
        [itemDetailArray replaceObjectAtIndex:0 withObject:[[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULT_ORIGANIZATION_NAME]];
        organizationId = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULT_ORIGANIZATION_ID];
    }
    origranizationArray = [NSMutableArray array];
    [_mainTableView reloadData];
}

#pragma mark - initView
-(void)initTableView
{
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.tableFooterView = [UIView new];
    _mainTableView.rowHeight = 50;
    [_mainTableView setDelaysContentTouches:NO];
    
    _titleBgView.backgroundColor = [UIColor TabBarColorGreen];
}


#pragma mark - tableView datasource & delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *iden = @"cell";
    TYHFindPasswordCell *cell = [[NSBundle mainBundle]loadNibNamed:@"TYHFindPasswordCell" owner:self options:nil].firstObject;
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:iden];
    }
    cell.delegate = self;
    cell.itemNameLabel.text = [NSString stringWithFormat:@"%@",itemArray[indexPath.row]];
    cell.inputTextField.tag = indexPath.row + 10000;
    cell.inputTextField.delegate = self;
    cell.inputTextField.text = [NSString stringWithFormat:@"%@",itemDetailArray[indexPath.row]];
    if (indexPath.row == 2) {
        cell.getCodeBtn.hidden = NO;
    }
    for (UIView *v in _mainTableView.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)v).delaysContentTouches = NO;
        }
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self.view endEditing:YES];
    }
}
#pragma mark -cellDelegate
-(void)getAjaxCodeAction:(TYHFindPasswordCell *)cell
{
    tmpBtn = cell.getCodeBtn;
    if (![NSString isMobileNumber:itemDetailArray[2]]) {
        [self.view makeToast:NSLocalizedString(@"APP_LoginPW_InputTruePhoneNum", nil) duration:1.5 position:CSToastPositionCenter];
            return;
    }
    else if
        ([NSString isBlankString:organizationId]) {
            [self.view makeToast:NSLocalizedString(@"APP_LoginPW_chooseSchool", nil) duration:1.5 position:CSToastPositionCenter];
            return;
        }
    else if
        ([NSString isBlankString:itemDetailArray[1]]) {
            [self.view makeToast:NSLocalizedString(@"APP_LoginPW_inputName", nil) duration:1.5 position:CSToastPositionCenter];
            return;
        }
    
    [self.view endEditing:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelFont = [UIFont systemFontOfSize:12];
    hud.labelText = NSLocalizedString(@"APP_LoginPW_GettingAjaxNum", nil);
    
        NSString *requestURL = [NSString stringWithFormat:@"%@%@",BaseURL,@"/bd/verify/validataMoblieNum"];
        NSString *loginName = [NSString stringWithFormat:@"%@",itemDetailArray[1]];
        NSString *mobileNum = [NSString stringWithFormat:@"%@",itemDetailArray[2]];
        NSDictionary *dic = @{@"loginName":loginName,@"mobileNum":mobileNum,@"organizationId":organizationId};
    
        [TYHHttpTool get:requestURL params:dic success:^(id json) {
            if ([[json objectForKey:@"successStatus"] isEqualToString:@"0"]) {
                [self.view makeToast:[NSString stringWithFormat:@"%@",[json objectForKey:@"errorMsg"]] duration:1.5 position:CSToastPositionCenter];
            }
            else
            {
                [self initTimer];
                userID = [NSString stringWithFormat:@"%@",[json objectForKey:@"userId"]];
                [self.view makeToast:[NSString stringWithFormat:@"%@",NSLocalizedString(@"APP_LoginPW_GettingAjaxNumSuccess", nil)] duration:1.5 position:CSToastPositionCenter];
            }
            [hud removeFromSuperview];
        } failure:^(NSError *error) {
            [self.view makeToast:NSLocalizedString(@"APP_LoginPW_serverError", nil) duration:1.5 position:CSToastPositionCenter];
            [hud removeFromSuperview];
        }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ClickAction
- (IBAction)backToLoginView:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submitAction:(id)sender {
    [self.view endEditing:YES];
    //验证是否为空
    for (int i = 0; i < itemDetailArray.count; i ++) {
         if ([NSString isBlankString:(NSString *)itemDetailArray[i]])
         {
             [self.view makeToast:[self returnToastStringWithNum:i] duration:1.5 position:CSToastPositionCenter];
             return;
         }
    }
    //验证密码和重复密码是否一致
    if (![itemDetailArray[5] isEqual: itemDetailArray[4]]) {
        [self.view makeToast:NSLocalizedString(@"APP_LoginPW_passWordNotSame", nil) duration:1.5 position:CSToastPositionCenter];
    }
    else if(![NSString isMobileNumber:[NSString stringWithFormat:@"%@",itemDetailArray[2]]])
    {
        [itemDetailArray replaceObjectAtIndex:2 withObject:@""];
        [_mainTableView reloadData];
        [self.view makeToast:NSLocalizedString(@"APP_LoginPW_InputTruePhoneNum", nil) duration:1.5 position:CSToastPositionCenter];
    }
    else
    {
        if([NSString isBlankString:userID])
        {
            userID = @"";
        }
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelFont = [UIFont systemFontOfSize:12];
        hud.labelText = NSLocalizedString(@"APP_LoginPW_isSubmiting", nil);
        
        
            NSString *requestURL = [NSString stringWithFormat:@"%@%@",BaseURL,@"/bd/verify/modifyUserPswByCode"];
            NSString *newPassword = [NSString stringWithFormat:@"%@",itemDetailArray[5]];
            ajaxCode = itemDetailArray[3];
            NSDictionary *dic = @{@"userId":userID,@"newPassword":newPassword,@"code":ajaxCode};
            [TYHHttpTool get:requestURL params:dic success:^(id json) {
                NSLog(@"===%@",json);
                if ([[json objectForKey:@"successStatus"] isEqualToString:@"1"]) {
                    [self.view makeToast:NSLocalizedString(@"APP_LoginPW_findPasswordBackSuccess", nil) duration:1.5 position:CSToastPositionCenter];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self backToLoginView:nil];
                    });
                }
                else
                {
                    [self.view makeToast:[NSString stringWithFormat:@"%@",[json objectForKey:@"errorMsg"]] duration:1.5 position:CSToastPositionCenter];
                }
                [hud removeFromSuperview];
            } failure:^(NSError *error) {
                [self.view makeToast:NSLocalizedString(@"APP_LoginPW_serverError", nil) duration:1.5 position:CSToastPositionCenter];
                [hud removeFromSuperview];
            }];
        }
}

#pragma mark - textField Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 10000) {
        [textField resignFirstResponder];
        [self.view endEditing:YES];
        //带确认和离开的FooterView
        _picker = [[CZPickerView alloc] initWithHeaderTitle:NSLocalizedString(@"APP_LoginPW_chooseSchool", nil) cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) confirmButtonTitle:NSLocalizedString(@"APP_General_Confirm", nil)];
        _picker.delegate = self;
        _picker.dataSource = self;
        _picker.needFooterView = YES;
        [_picker show];
    }
    else
    {
        
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    //    [textField resignFirstResponder];
    for (int i = 0; i < itemArray.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        NSInteger tag = indexPath.row + 10000;
        if (tag == textField.tag) {
            NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
            [itemDetailArray replaceObjectAtIndex:indexPath.row withObject:toBeString];
        }
    }
    return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


#pragma mark - 逻辑方法

-(NSString *)returnToastStringWithNum:(NSInteger )num
{
    switch (num) {
        case 0:
            return NSLocalizedString(@"APP_LoginPW_chooseSchool", nil);
            break;
        case 1:
            return NSLocalizedString(@"APP_LoginPW_inputName", nil);
            break;
        case 2:
            return NSLocalizedString(@"APP_LoginPW_inputPhoneNum", nil);
            break;
        case 3:
            return NSLocalizedString(@"APP_LoginPW_inputAjaxNum", nil);
            break;
        case 4:
            return NSLocalizedString(@"APP_LoginPW_inputNewPassword", nil);
            break;
        case 5:
            return NSLocalizedString(@"APP_LoginPW_inputRepeatPassword", nil);
            break;
        default:
            return @"";
            break;
    }
}


#pragma mark - CZPicker
- (NSAttributedString *)czpickerView:(CZPickerView *)pickerView
               attributedTitleForRow:(NSInteger)row{
    [self.view endEditing:YES];
    NSAttributedString *att = [[NSAttributedString alloc]
                               initWithString:[(TYHOranizationModel *)_orgaArray[row] organizationName]
                               attributes:@{
                                            NSFontAttributeName:[UIFont fontWithName:@"Avenir-Light" size:15.0]
                                            }];
    return att;
}
- (void)czpickerViewDidClickCancelButton:(CZPickerView *)pickerView{
    NSLog(@"Canceled.");
}


- (NSString *)czpickerView:(CZPickerView *)pickerView
               titleForRow:(NSInteger)row{
    TYHOranizationModel *oraModel = _orgaArray[row];
    return oraModel.organizationName;
}


- (NSInteger)numberOfRowsInPickerView:(CZPickerView *)pickerView{
    return _orgaArray.count;
}

- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemAtRow:(NSInteger)row{
    [itemDetailArray replaceObjectAtIndex:0 withObject:[(TYHOranizationModel *)_orgaArray[row] organizationName]];
    organizationId = [(TYHOranizationModel *)_orgaArray[row] organizationID];
    [_mainTableView reloadData];
}


#pragma mark - chageBtnState
-(void)initTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(changeBtnState:)
                                           userInfo:nil
                                            repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)changeBtnState:(id)sender
{
    btnSecond -= 1;
    [tmpBtn setTitle:[NSString stringWithFormat:@"%@%ld%@",NSLocalizedString(@"APP_LoginPW_haisheng", nil),(long)btnSecond,NSLocalizedString(@"APP_LoginPW_second", nil)] forState:UIControlStateNormal];
    tmpBtn.userInteractionEnabled = NO;
    [tmpBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    tmpBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    if (btnSecond == 0) {
        tmpBtn.userInteractionEnabled = YES;
        [tmpBtn setTitleColor:[UIColor TabBarColorGreen] forState:UIControlStateNormal];
        tmpBtn.layer.borderColor = [UIColor TabBarColorGreen].CGColor;
        [tmpBtn setTitle:NSLocalizedString(@"APP_LoginPW_getAjaxCode", nil) forState:UIControlStateNormal];
        [timer invalidate];
        btnSecond = 60;
        
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController.navigationBar setHidden:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor TabBarColorGreen]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self.navigationController.navigationBar setHidden:YES];
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
