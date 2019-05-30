//
//  NTESSearchTeamViewController.m
//  NIM
//
//  Created by Xuhui on 15/3/19.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESSearchTeamViewController.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "NTESJionTeamViewController.h"

@interface NTESSearchTeamViewController () <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *textField;

@end

@implementation NTESSearchTeamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = NSLocalizedString(@"APP_YUNXIN_Contact_searchGroupAndJoin", nil);
    self.textField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField endEditing:YES];
    [SVProgressHUD show];
    [[NIMSDK sharedSDK].teamManager fetchTeamInfo:textField.text completion:^(NSError *error, NIMTeam *team) {
        [SVProgressHUD dismiss];
        if(!error) {
            NTESJionTeamViewController *vc = [[NTESJionTeamViewController alloc] initWithNibName:nil bundle:nil];
            vc.joinTeam = team;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [self.view makeToast:error.localizedDescription
                        duration:2
                        position:CSToastPositionCenter];
            DDLogDebug(@"Fetch team info failed: %@", error.localizedDescription);
        }
    }];

    return YES;
}

@end
