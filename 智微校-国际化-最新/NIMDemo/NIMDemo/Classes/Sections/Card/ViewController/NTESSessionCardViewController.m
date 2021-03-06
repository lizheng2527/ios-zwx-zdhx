//
//  NTESSessionCardViewController.m
//  NIM
//
//  Created by chris on 15/10/20.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import "NTESSessionCardViewController.h"
#import "NIMCommonTableDelegate.h"
#import "NIMCommonTableData.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "NIMMemberGroupView.h"
#import "UIView+NTES.h"
#import "NIMContactSelectConfig.h"
#import "NIMContactSelectViewController.h"
#import "NTESSessionViewController.h"

@interface NTESSessionCardViewController ()<NIMMemberGroupViewDelegate,NIMContactSelectDelegate>

@property (nonatomic,strong) NIMCommonTableDelegate *delegator;

@property (nonatomic,copy  ) NSArray                 *data;

@property (nonatomic,strong) NIMSession *session;

@property (nonatomic,strong) NIMMemberGroupView *headerView;

@end

@implementation NTESSessionCardViewController

- (instancetype)initWithSession:(NIMSession *)session{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _session = session;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"APP_YUNXIN_talkInfo", nil);
    __weak typeof(self) wself = self;
    self.delegator = [[NIMCommonTableDelegate alloc] initWithTableData:^NSArray *{
        return wself.data;
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:241.0/255.0 blue:245.0/255.0 alpha:1];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate   = self.delegator;
    self.tableView.dataSource = self.delegator;
    [self.view addSubview:self.tableView];
    
    [self refresh];
}

- (void)refresh{
    [self buildData];
    [self bulidTableHeader:self.view.width];
    [self.tableView reloadData];
}

- (void)buildData{
    BOOL needNotify    = [[NIMSDK sharedSDK].userManager notifyForNewMsg:self.session.sessionId];
    NSArray *data = @[
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                  @{
                                      Title         : NSLocalizedString(@"APP_YUNXIN_messageNotifacation", nil),
                                      CellClass     : @"NTESSettingSwitcherCell",
                                      RowHeight     : @(50),
                                      CellAction    : @"onActionNeedNotifyValueChange:",
                                      ExtraInfo     : @(needNotify),
                                      ForbidSelect  : @(YES)
                                      },
                                  ],
                          },
                      ];
    self.data = [NIMCommonTableSection sectionsWithData:data];
}


- (void)bulidTableHeader:(CGFloat)width{
    self.headerView = [[NIMMemberGroupView alloc] initWithFrame:CGRectZero];
    self.headerView.delegate = self;
    [self.headerView refreshUids:@[self.session.sessionId] operators:CardHeaderOpeatorAdd];
    [self.headerView setTitle:NSLocalizedString(@"APP_YUNXIN_creatTalkGroup", nil) forOperator:CardHeaderOpeatorAdd];
    
    CGSize size = [self.headerView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    self.headerView.size = size;
    self.tableView.tableHeaderView = self.headerView;
}


- (void)onActionNeedNotifyValueChange:(id)sender{
    UISwitch *switcher = sender;
    [SVProgressHUD show];
    __weak typeof(self) wself = self;
    [[NIMSDK sharedSDK].userManager updateNotifyState:switcher.on forUser:self.session.sessionId completion:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:NSLocalizedString(@"APP_note_operationFailed", nil) duration:2.0f position:CSToastPositionCenter];
            [wself refresh];
        }
    }];
}


- (void)didSelectOperator:(NIMKitCardHeaderOpeator )opera{
    if (opera == CardHeaderOpeatorAdd) {
        NSMutableArray *users = [[NSMutableArray alloc] init];
        NSString *currentUserID = [[[NIMSDK sharedSDK] loginManager] currentAccount];
        [users addObject:currentUserID];
        NIMContactFriendSelectConfig *config = [[NIMContactFriendSelectConfig alloc] init];
        config.filterIds = users;
        config.needMutiSelected = YES;
        config.alreadySelectedMemberId = @[self.session.sessionId];
        NIMContactSelectViewController *vc = [[NIMContactSelectViewController alloc] initWithConfig:config];
        vc.delegate = self;
        [vc show];

    }
}


#pragma mark - ContactSelectDelegate

- (void)didFinishedSelect:(NSArray *)selectedContacts{
    if (!selectedContacts.count) {
        return;
    }
    NSString *uid = [[NIMSDK sharedSDK].loginManager currentAccount];
    NSArray *users = [@[uid] arrayByAddingObjectsFromArray:selectedContacts];
    NIMCreateTeamOption *option = [[NIMCreateTeamOption alloc] init];
    option.name = NSLocalizedString(@"APP_YUNXIN_Contact_taolunzu", nil);
    option.type = NIMTeamTypeNormal;
    __weak typeof(self) wself = self;
    [SVProgressHUD show];
    [[NIMSDK sharedSDK].teamManager createTeam:option
                                         users:users
                                    completion:^(NSError * _Nullable error, NSString * _Nullable teamId, NSArray<NSString *> * _Nullable failedUserIds){
                                    
                                        [SVProgressHUD dismiss];
                                        if (!error) {
                                            NIMSession *session = [NIMSession session:teamId type:NIMSessionTypeTeam];
                                            UINavigationController *nav = wself.navigationController;
                                            [nav popToRootViewControllerAnimated:NO];
                                            NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:session];
                                            [nav pushViewController:vc animated:YES];
                                        }else{
                                            [wself.view makeToast:NSLocalizedString(@"APP_YUNXIN_creatTalkGroupFailed", nil) duration:2.0 position:CSToastPositionCenter];
                                        }
                                    }];
}
@end
