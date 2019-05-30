//
//  NTESSettingViewController.m
//  NIM
//
//  Created by chris on 15/6/25.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import "NTESSettingViewController.h"
#import "NIMCommonTableData.h"
#import "NIMCommonTableDelegate.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "UIView+NTES.h"
#import "NTESBundleSetting.h"
#import "UIActionSheet+NTESBlock.h"
#import "UIAlertView+NTESBlock.h"
#import "NTESNotificationCenter.h"
#import "NTESCustomNotificationDB.h"
#import "NTESCustomSysNotificationViewController.h"
#import "NTESNoDisturbSettingViewController.h"
#import "NTESLogManager.h"
#import "NTESColorButtonCell.h"
#import "NTESAboutViewController.h"
#import "NTESUserInfoSettingViewController.h"
#import "NTESBlackListViewController.h"
#import "NTESUserUtil.h"
#import "NTESLogUploader.h"
#import "NTESNetDetectViewController.h"
#import "NTESSessionUtil.h"

#import "TYHAboutViewController.h"
#import "TYHAppLoadSharedInstance.h"


@interface NTESSettingViewController ()<NIMUserManagerDelegate>

@property (nonatomic,strong) NSArray *data;
@property (nonatomic,strong) NTESLogUploader *logUploader;
@property (nonatomic,strong) NIMCommonTableDelegate *delegator;

@end

@implementation NTESSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"APP_YUNXIN_Setting", nil);
    NSString *versionStr = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *sdkVersion = [NIMSDK sharedSDK].sdkVersion;
    self.versionLabel.text = [NSString stringWithFormat:@"版本号:%@  SDK版本:%@",versionStr,sdkVersion];
    [self buildData];
    __weak typeof(self) wself = self;
    self.delegator = [[NIMCommonTableDelegate alloc] initWithTableData:^NSArray *{
        return wself.data;
    }];
    self.tableView.delegate   = self.delegator;
    self.tableView.dataSource = self.delegator;
    
    extern NSString *NTESCustomNotificationCountChanged;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCustomNotifyChanged:) name:NTESCustomNotificationCountChanged object:nil];
    [[NIMSDK sharedSDK].userManager addDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NIMSDK sharedSDK].userManager removeDelegate:self];
}

- (void)buildData{
    BOOL disableRemoteNotification = [UIApplication sharedApplication].currentUserNotificationSettings.types == UIUserNotificationTypeNone;
    
    NIMPushNotificationSetting *setting = [[NIMSDK sharedSDK].apnsManager currentSetting];
    BOOL enableNoDisturbing     = setting.noDisturbing;
    NSString *noDisturbingStart = [NSString stringWithFormat:@"%02zd:%02zd",setting.noDisturbingStartH,setting.noDisturbingStartM];
    NSString *noDisturbingEnd   = [NSString stringWithFormat:@"%02zd:%02zd",setting.noDisturbingEndH,setting.noDisturbingEndM];
    
    NSInteger customNotifyCount = [[NTESCustomNotificationDB sharedInstance] unreadCount];
    NSString *customNotifyText  = [NSString stringWithFormat:@"自定义系统通知 (%zd)",customNotifyCount];

    NSString *uid = [[NIMSDK sharedSDK].loginManager currentAccount];
    NSArray *data = @[
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                        @{
                                            ExtraInfo     : uid.length ? uid : [NSNull null],
                                            CellClass     : @"NTESSettingPortraitCell",
                                            RowHeight     : @(60),
                                            CellAction    : @"onActionTouchPortrait:",
                                            ShowAccessory : @(YES)
                                         },
                                       ],
                          FooterTitle:@""
                       },
//                      @{
//                          HeaderTitle:@"",
//                          RowContent :@[
//                                  @{
//                                      Title         : @"我的钱包",
//                                      CellAction    : @"onTouchMyWallet:",
//                                      ShowAccessory : @(YES),
//                                      },
//                                  ],
//                          },
                       @{
                          HeaderTitle:@"",
                          RowContent :@[
                                           @{
                                              Title      :NSLocalizedString(@"APP_YUNXIN_messageNotifacation", nil),
                                              DetailTitle:disableRemoteNotification ? NSLocalizedString(@"APP_YUNXIN_notOpen", nil) : NSLocalizedString(@"APP_YUNXIN_hasOpen", nil),
                                            },
                                        ],
                          FooterTitle:NSLocalizedString(@"APP_YUNXIN_changeNotiSetting", nil)
                        },
                       @{
                          HeaderTitle:@"",
                          RowContent :@[
                                       @{
                                          Title      :NSLocalizedString(@"APP_YUNXIN_noDisturb", nil),
                                          DetailTitle:enableNoDisturbing ? [NSString stringWithFormat:@"%@ ~ %@",noDisturbingStart,noDisturbingEnd] : NSLocalizedString(@"APP_YUNXIN_notOpen", nil),
                                          CellAction :@"onActionNoDisturbingSetting:",
                                          ShowAccessory : @(YES)
                                        },
                                  ],
                          FooterTitle:@""
                        },
                       @{
                          HeaderTitle:@"",
                          RowContent :@[
//                                        @{
//                                          Title      :@"查看日志",
//                                          CellAction :@"onTouchShowLog:",
//                                          },
//                                        @{
//                                            Title      :@"上传日志",
//                                            CellAction :@"onTouchUploadLog:",
//                                            },
//                                        @{
//                                            Title      :customNotifyText,
//                                            CellAction :@"onTouchCustomNotify:",
//                                          },
//                                        @{
//                                            Title      :@"音视频网络探测",
//                                            CellAction :@"onTouchNetDetect:",
//                                            },
                                        @{
                                            Title      :NSLocalizedString(@"APP_YUNXIN_about", nil),
                                            CellAction :@"onTouchAbout:",
                                          },
                                      ],
                          FooterTitle:@""
                        },
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                          @{
                                              Title        : NSLocalizedString(@"APP_YUNXIN_logout", nil),
                                              CellClass    : @"NTESColorButtonCell",
                                              CellAction   : @"logoutCurrentAccount:",
                                              ExtraInfo    : @(ColorButtonCellStyleRed),
                                              ForbidSelect : @(YES)
                                            },
                                       ],
                          FooterTitle:@"",
                          },
                    ];
    self.data = [NIMCommonTableSection sectionsWithData:data];
}

- (void)refreshData{
    [self buildData];
    [self.tableView reloadData];
}


#pragma mark - Action

- (void)onActionTouchPortrait:(id)sender{
    NTESUserInfoSettingViewController *vc = [[NTESUserInfoSettingViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onActionNoDisturbingSetting:(id)sender {
    NTESNoDisturbSettingViewController *vc = [[NTESNoDisturbSettingViewController alloc] initWithNibName:nil bundle:nil];
    __weak typeof(self) wself = self;
    vc.handler = ^(){
        [wself refreshData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onTouchShowLog:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"查看日志" delegate:nil cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@"查看 DEMO 配置",@"查看 SDK 日志",@"查看网络通话日志",@"查看网络探测日志",@"查看 Demo 日志", nil];
    [actionSheet showInView:self.view completionHandler:^(NSInteger index) {
        switch (index) {
            case 0:
                [self showDemoConfig];
                break;
            case 1:
                [self showSDKLog];
                break;
            case 2:
                [self showSDKNetCallLog];
                break;
            case 3:
                [self showSDKNetDetectLog];
                break;
            case 4:
                [self showDemoLog];
                break;
            default:
                break;
        }
    }];
}

- (void)onTouchUploadLog:(id)sender{
    if (_logUploader == nil) {
        _logUploader = [[NTESLogUploader alloc] init];
    }
    
    [SVProgressHUD show];
    
    __weak typeof(self) weakSelf = self;
    [_logUploader upload:^(NSString *urlString,NSError *error) {
        [SVProgressHUD dismiss];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error == nil && urlString)
        {
            [UIPasteboard generalPasteboard].string = urlString;
            [strongSelf.view makeToast:@"上传日志成功,URL已复制到剪切板中" duration:3.0 position:CSToastPositionCenter];
        }
        else
        {
            [strongSelf.view makeToast:@"上传日志失败" duration:3.0 position:CSToastPositionCenter];
        }
    }];
}

- (void)onTouchMyWallet:(id)sender
{
    
}

- (void)onTouchCustomNotify:(id)sender{
    NTESCustomSysNotificationViewController *vc = [[NTESCustomSysNotificationViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onTouchAbout:(id)sender{
//    NTESAboutViewController *about = [[NTESAboutViewController alloc] initWithNibName:nil bundle:nil];
//    [self.navigationController pushViewController:about animated:YES];
    
    TYHAboutViewController *aboutView = [[TYHAboutViewController alloc]init];
    [self.navigationController pushViewController:aboutView animated:YES];
}

- (void)onTouchNetDetect:(id)sender {
    NTESNetDetectViewController *vc = [[NTESNetDetectViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

- (void)logoutCurrentAccount:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"APP_YUNXIN_logoutAccount", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) otherButtonTitles:NSLocalizedString(@"APP_General_Confirm", nil), nil];
    [alert showAlertWithCompletionHandler:^(NSInteger alertIndex) {
        switch (alertIndex) {
            case 1:
                [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error)
                 {
                     extern NSString *NTESNotificationLogout;
                     [[NSNotificationCenter defaultCenter] postNotificationName:NTESNotificationLogout object:nil];
                     [[TYHAppLoadSharedInstance sharedInstance]appWebViewLoadSuccessful:NO];
                 }];
                break;
            default:
                break;
        }
    }];
}

#pragma mark - Notification
- (void)onCustomNotifyChanged:(NSNotification *)notification
{
    [self buildData];
    [self.tableView reloadData];
}


#pragma mark - NIMUserManagerDelegate
- (void)onUserInfoChanged:(NIMUser *)user
{
    if ([user.userId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]]) {
        [self buildData];
        [self.tableView reloadData];
    }
}


#pragma mark - Private

- (void)showSDKLog{
    UIViewController *vc = [[NTESLogManager sharedManager] sdkLogViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

- (void)showSDKNetCallLog{
    UIViewController *vc = [[NTESLogManager sharedManager] sdkNetCallLogViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

- (void)showSDKNetDetectLog{
    UIViewController *vc = [[NTESLogManager sharedManager] sdkNetDetectLogViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}


- (void)showDemoLog{
    UIViewController *logViewController = [[NTESLogManager sharedManager] demoLogViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:logViewController];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

- (void)showDemoConfig {
    UIViewController *logViewController = [[NTESLogManager sharedManager] demoConfigViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:logViewController];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

#pragma mark - 旋转处理 (iOS7)
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}


@end
