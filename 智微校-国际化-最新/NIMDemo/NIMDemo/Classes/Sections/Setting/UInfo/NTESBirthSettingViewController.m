//
//  NTESBirthSettingViewController.m
//  NIM
//
//  Created by chris on 15/9/17.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESBirthSettingViewController.h"
#import "NIMCommonTableDelegate.h"
#import "NIMCommonTableData.h"
#import "NTESBirthPickerView.h"
#import "UIView+NTES.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"

@interface NTESBirthSettingViewController ()

@property (nonatomic,strong) NIMCommonTableDelegate *delegator;

@property (nonatomic,copy  ) NSArray                 *data;

@property (nonatomic,copy)   NSString                *birth;

@end

@implementation NTESBirthSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpNav];
    NSString *userId = [[NIMSDK sharedSDK].loginManager currentAccount];
    self.birth = [[NIMSDK sharedSDK].userManager userInfo:userId].userInfo.birth;
    self.birth = self.birth? self.birth : @"";
    [self buildData];
    __weak typeof(self) wself = self;
    self.delegator = [[NIMCommonTableDelegate alloc] initWithTableData:^NSArray *{
        return wself.data;
    }];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = UIColorFromRGB(0xe3e6ea);
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate   = self.delegator;
    self.tableView.dataSource = self.delegator;
    [self.tableView reloadData];
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        for (UIView *subView in cell.subviews) {
            if ([subView isKindOfClass:[UITextField class]]) {
                [subView becomeFirstResponder];
                break;
            }
        }
    }
}

- (void)setUpNav{
    self.navigationItem.title = NSLocalizedString(@"APP_YUNXIN_birthdaySet", nil);
}

- (void)buildData{
    NSArray *data = @[
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                  @{
                                      Title         : NSLocalizedString(@"APP_YUNXIN_birthday", nil),
                                      DetailTitle   : self.birth,
                                      CellAction    : @"onTouchBirthSetting:",
                                      },
                                  ],
                          },
                      ];
    self.data = [NIMCommonTableSection sectionsWithData:data];
}

- (void)refresh{
    [self buildData];
    [self.tableView reloadData];
}

- (void)onTouchBirthSetting:(id)sender{
    NTESBirthPickerView *picker = [[NTESBirthPickerView alloc] initWithFrame:self.view.bounds];
    [picker refreshWithBrith:self.birth];
    __weak typeof(self) wself = self;
    [picker showInView:self.view onCompletion:^(NSString *birth) {
        [wself remoteUpdateBirth:birth];
    }];
}

- (void)remoteUpdateBirth:(NSString *)birth{
    [SVProgressHUD show];
    __weak typeof(self) wself = self;
    [[NIMSDK sharedSDK].userManager updateMyUserInfo:@{@(NIMUserInfoUpdateTagBirth) : birth} completion:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            [wself.navigationController.view makeToast:NSLocalizedString(@"APP_YUNXIN_birthdaySetSuccess", nil)
                                              duration:2
                                              position:CSToastPositionCenter];
            [wself.navigationController popViewControllerAnimated:YES];
        }else{
            [wself.view makeToast:NSLocalizedString(@"APP_YUNXIN_birthdaySetFailed", nil)
                         duration:2
                         position:CSToastPositionCenter];
        }
    }];
}

#pragma mark - 旋转处理 (iOS7)
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}

@end
