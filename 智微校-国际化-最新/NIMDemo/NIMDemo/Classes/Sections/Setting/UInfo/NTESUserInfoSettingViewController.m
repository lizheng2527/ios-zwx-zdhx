//
//  NTESUserInfoSettingViewController.m
//  NIM
//
//  Created by chris on 15/9/17.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESUserInfoSettingViewController.h"
#import "NIMCommonTableData.h"
#import "NIMCommonTableDelegate.h"
#import "NTESNickNameSettingViewController.h"
#import "NTESGenderSettingViewController.h"
#import "NTESBirthSettingViewController.h"
#import "NTESMobileSettingViewController.h"
#import "NTESEmailSettingViewController.h"
#import "NTESSignSettingViewController.h"
#import "NTESUserUtil.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "UIActionSheet+NTESBlock.h"
#import "UIImage+NTES.h"
#import "NTESFileLocationHelper.h"
#import "SDWebImageManager.h"


#import "TYHChangePwdViewController.h"
#import <AFNetworking.h>

@interface NTESUserInfoSettingViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,NIMUserManagerDelegate>

@property (nonatomic,strong) NIMCommonTableDelegate *delegator;

@property (nonatomic,copy)   NSArray *data;

@end

@implementation NTESUserInfoSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"APP_YUNXIN_PersonalInfo", nil);
    [self buildData];
    __weak typeof(self) wself = self;
    self.delegator = [[NIMCommonTableDelegate alloc] initWithTableData:^NSArray *{
        return wself.data;
    }];
    self.tableView.delegate   = self.delegator;
    self.tableView.dataSource = self.delegator;
    
    [[NIMSDK sharedSDK].userManager addDelegate:self];
}

- (void)dealloc{
    [[NIMSDK sharedSDK].userManager removeDelegate:self];
}

- (void)buildData{
    NIMUser *me = [[NIMSDK sharedSDK].userManager userInfo:[[NIMSDK sharedSDK].loginManager currentAccount]];
    NSArray *data = @[
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                  @{
                                      ExtraInfo     : me.userId ? me.userId : [NSNull null],
                                      CellClass     : @"NTESSettingPortraitCell",
                                      RowHeight     : @(60),
                                      CellAction    : @"onTouchPortrait:",
                                      ShowAccessory : @(YES)
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
//                                  @{
//                                      Title      : @"昵称",
//                                      DetailTitle: me.userInfo.nickName.length ? me.userInfo.nickName : NSLocalizedString(@"APP_YUNXIN_notSet", nil),
//                                      CellAction : @"onTouchNickSetting:",
//                                      RowHeight     : @(50),
//                                      ShowAccessory : @(YES),
//                                      },
                                  @{
                                      Title      : NSLocalizedString(@"APP_YUNXIN_sex", nil),
                                      DetailTitle: [NTESUserUtil genderString:me.userInfo.gender],
                                      CellAction : @"onTouchGenderSetting:",
                                      RowHeight     : @(50),
                                      ShowAccessory : @(YES)
                                      },
                                  @{
                                      Title       : NSLocalizedString(@"APP_YUNXIN_birthday", nil),
                                      DetailTitle : me.userInfo.birth.length ? me.userInfo.birth : NSLocalizedString(@"APP_YUNXIN_notSet", nil),
                                      CellAction  : @"onTouchBirthSetting:",
                                      RowHeight     : @(50),
                                      ShowAccessory : @(YES)
                                      },
                                  @{
                                      Title      :NSLocalizedString(@"APP_YUNXIN_phoneNum", nil),
                                      DetailTitle:me.userInfo.mobile.length ? me.userInfo.mobile : NSLocalizedString(@"APP_YUNXIN_notSet", nil),
                                      CellAction :@"onTouchTelSetting:",
                                      RowHeight     : @(50),
                                      ShowAccessory : @(YES)
                                      },
                                  @{
                                      Title      :NSLocalizedString(@"APP_YUNXIN_email", nil),
                                      DetailTitle:me.userInfo.email.length ? me.userInfo.email : NSLocalizedString(@"APP_YUNXIN_notSet", nil),
                                      CellAction :@"onTouchEmailSetting:",
                                      RowHeight     : @(50),
                                      ShowAccessory : @(YES)
                                      },
                                  @{
                                      Title      :NSLocalizedString(@"APP_YUNXIN_Sign", nil),
                                      DetailTitle:me.userInfo.sign.length ? me.userInfo.sign : NSLocalizedString(@"APP_YUNXIN_notSet", nil),
                                      CellAction :@"onTouchSignSetting:",
                                      RowHeight     : @(50),
                                      ShowAccessory : @(YES)
                                      },
                                  @{
                                      Title      :NSLocalizedString(@"APP_YUNXIN_changePassword", nil),
                                      CellAction :@"onTouchChangePWSetting:",
                                      RowHeight     : @(50),
                                      ShowAccessory : @(YES)
                                      }
                                  ],
                          FooterTitle:@""
                          },
                      ];
    self.data = [NIMCommonTableSection sectionsWithData:data];
}


- (void)refresh{
    [self buildData];
    [self.tableView reloadData];
}

- (void)onTouchPortrait:(id)sender{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"APP_YUNXIN_setHeadImage", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"APP_YUNXIN_takePic", nil),NSLocalizedString(@"APP_YUNXIN_fromAlbum", nil), nil];
        [sheet showInView:self.view completionHandler:^(NSInteger index) {
            switch (index) {
                case 0:
                    [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
                    break;
                case 1:
                    [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
                    break;
                default:
                    break;
            }
        }];
    }else{
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"APP_YUNXIN_setHeadImage", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"APP_YUNXIN_fromAlbum", nil), nil];
        [sheet showInView:self.view completionHandler:^(NSInteger index) {
            switch (index) {
                case 0:
                    [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
                    break;
                default:
                    break;
            }
        }];
    }
}

- (void)showImagePicker:(UIImagePickerControllerSourceType)type{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate      = self;
    picker.sourceType    = type;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)onTouchNickSetting:(id)sender{
    NTESNickNameSettingViewController *vc = [[NTESNickNameSettingViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onTouchGenderSetting:(id)sender{
    NTESGenderSettingViewController *vc = [[NTESGenderSettingViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onTouchBirthSetting:(id)sender{
    NTESBirthSettingViewController *vc = [[NTESBirthSettingViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onTouchTelSetting:(id)sender{
    NTESMobileSettingViewController *vc = [[NTESMobileSettingViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onTouchEmailSetting:(id)sender{
    NTESEmailSettingViewController *vc = [[NTESEmailSettingViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onTouchSignSetting:(id)sender{
    NTESSignSettingViewController *vc = [[NTESSignSettingViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)onTouchChangePWSetting:(id)sender
    {
        TYHChangePwdViewController *changeView = [TYHChangePwdViewController new];
        [self.navigationController pushViewController:changeView animated:YES];
    }


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self uploadImage:image];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - NIMUserManagerDelagate
- (void)onUserInfoChanged:(NIMUser *)user
{
    if ([user.userId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]]) {
        [self refresh];
    }
}


#pragma mark - Private
- (void)uploadImage:(UIImage *)image{
    UIImage *imageForAvatarUpload = [image imageForAvatarUpload];
    NSString *fileName = [NTESFileLocationHelper genFilenameWithExt:@"jpg"];
    NSString *filePath = [[NTESFileLocationHelper getAppDocumentPath] stringByAppendingPathComponent:fileName];
    NSData *data = UIImageJPEGRepresentation(imageForAvatarUpload, 1.0);
    BOOL success = data && [data writeToFile:filePath atomically:YES];
    __weak typeof(self) wself = self;
    if (success) {
        [SVProgressHUD show];
        [[NIMSDK sharedSDK].resourceManager upload:filePath progress:nil completion:^(NSString *urlString, NSError *error) {
            [SVProgressHUD dismiss];
            if (!error && wself) {
                [[NIMSDK sharedSDK].userManager updateMyUserInfo:@{@(NIMUserInfoUpdateTagAvatar):urlString} completion:^(NSError *error) {
                    if (!error) {
                        [[SDWebImageManager sharedManager] saveImageToCache:imageForAvatarUpload forURL:[NSURL URLWithString:urlString]];
                        
                        NSString *userName = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_LOGINNAME];
                        NSString *password = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_V3PWD];
                        NSString *organizationID = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_ORIGANIZATION_ID];
                        NSString *userID = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_V3ID];
                        
                        
                        NSData *data = UIImageJPEGRepresentation(imageForAvatarUpload,0.1);
                        
                        NSString *string = [NSString stringWithFormat:@"%@/bd/user/saveHeadPortrait",BaseURL];
                        NSMutableDictionary * params = [NSMutableDictionary dictionary];
                        params[@"sys_username"] = [NSString stringWithFormat:@"%@%@%@," ,userName,@"%2C",organizationID];
                        params[@"sys_auto_authenticate"]= @"true";
                        params[@"id"]= [NSString stringWithFormat:@"%@",userID];
                        params[@"sys_password"]= [NSString stringWithFormat:@"%@",password];
                        params[@"uploadFileNames"] = @"image0.png";
                        
                        AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
                        manager.requestSerializer = [AFJSONRequestSerializer serializer];
                        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                        
                        [manager POST:string parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                            
                            [formData appendPartWithFileData:data name:@"uploadFiles" fileName:@"image0.png" mimeType:@"image/png"];
                        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            
                            [self.view makeToast:NSLocalizedString(@"APP_YUNXIN_setHeadImageSuccess", nil) duration:1 position:nil];
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            [self.view makeToast:NSLocalizedString(@"APP_YUNXIN_setHeadImageFailure", nil) duration:1 position:nil];
                        }];
                        
                        [[SDWebImageManager sharedManager] saveImageToCache:imageForAvatarUpload forURL:[NSURL URLWithString:urlString]];
                        [wself refresh];
                        
                        [wself refresh];
                    }else{
                        [wself.view makeToast:NSLocalizedString(@"APP_YUNXIN_setHeadImageFailure_pleaseTryAgagin", nil)
                                     duration:2
                                     position:CSToastPositionCenter];
                    }
                }];
            }else{
                [wself.view makeToast:NSLocalizedString(@"APP_YUNXIN_uploadHeadImageFailure_pleaseTryAgagin", nil)
                             duration:2
                             position:CSToastPositionCenter];
            }
        }];
    }else{
        [self.view makeToast:NSLocalizedString(@"APP_YUNXIN_saveHeadImageFailure_pleaseTryAgagin", nil)
                    duration:2
                    position:CSToastPositionCenter];
    }
}

#pragma mark - 旋转处理 (iOS7)
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}

@end
