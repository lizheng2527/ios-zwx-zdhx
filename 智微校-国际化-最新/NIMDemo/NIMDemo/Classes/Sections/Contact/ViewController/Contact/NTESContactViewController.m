//
//  NTESContactViewController.m
//  NIMDemo
//
//  Created by chris on 15/2/2.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESContactViewController.h"
#import "NTESSessionUtil.h"
#import "NTESSessionViewController.h"
#import "NTESContactUtilItem.h"
#import "NTESContactDefines.h"
#import "NTESGroupedContacts.h"
#import "UIView+Toast.h"
#import "NTESCustomNotificationDB.h"
#import "NTESNotificationCenter.h"
#import "UIActionSheet+NTESBlock.h"
#import "NTESSearchTeamViewController.h"
#import "NTESContactAddFriendViewController.h"
#import "NTESPersonalCardViewController.h"
#import "UIAlertView+NTESBlock.h"
#import "SVProgressHUD.h"
#import "NTESContactUtilCell.h"
#import "NTESContactDataCell.h"
#import "NIMContactSelectViewController.h"
#import "NTESUserUtil.h"

#import "TYHContacterListController.h"
#import "TYHAddFriendViewController.h"
#import "TYHHttpTool.h"
#import "NTESSettingViewController.h"
#import <UIButton+WebCache.h>
#import "NTESLoginManager.h"

@interface NTESContactViewController ()<NIMUserManagerDelegate,
NIMSystemNotificationManagerDelegate,
NTESContactUtilCellDelegate,
NIMContactDataCellDelegate,
NIMLoginManagerDelegate,
NIMEventSubscribeManagerDelegate> {
    UIRefreshControl *_refreshControl;
    NTESGroupedContacts *_contacts;
}

@property (nonatomic,strong) NSArray * datas;

@end

@implementation NTESContactViewController
{
    BOOL isTeacherOrAdmin;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NIMSDK sharedSDK].systemNotificationManager removeDelegate:self];
    [[NIMSDK sharedSDK].loginManager removeDelegate:self];
    [[NIMSDK sharedSDK].userManager removeDelegate:self];
    [[NIMSDK sharedSDK].subscribeManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *kindString = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_KIND];
    if ([kindString isEqualToString:@"1"] || [kindString isEqualToString:@"2"] || [kindString isEqualToString:@"4"]) {
        isTeacherOrAdmin = NO;
    }
    else isTeacherOrAdmin = YES;
    
    self.tableView.delegate       = self;
    self.tableView.dataSource     = self;
    UIEdgeInsets separatorInset   = self.tableView.separatorInset;
    separatorInset.right          = 0;
    self.tableView.separatorInset = separatorInset;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
     self.tableView.sectionIndexColor = [UIColor colorWithRed:24 / 255.0 green:171 / 255.0 blue:142/ 255.0 alpha:1.0];
    [self prepareData];
    
    [[NIMSDK sharedSDK].systemNotificationManager addDelegate:self];
    [[NIMSDK sharedSDK].loginManager addDelegate:self];
    [[NIMSDK sharedSDK].userManager addDelegate:self];
    [[NIMSDK sharedSDK].subscribeManager addDelegate:self];
}

- (void)setUpNavItem{
    UIButton *teamBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [teamBtn addTarget:self action:@selector(onOpera:) forControlEvents:UIControlEventTouchUpInside];
    [teamBtn setImage:[UIImage imageNamed:@"icon_tinfo_normal"] forState:UIControlStateNormal];
    [teamBtn setImage:[UIImage imageNamed:@"icon_tinfo_pressed"] forState:UIControlStateHighlighted];
    [teamBtn sizeToFit];
    UIBarButtonItem *teamItem = [[UIBarButtonItem alloc] initWithCustomView:teamBtn];
    self.navigationItem.rightBarButtonItem = teamItem;
}

- (void)prepareData{
    _contacts = [[NTESGroupedContacts alloc] init];

    NSString *contactCellUtilIcon   = @"icon";
    NSString *contactCellUtilVC     = @"vc";
    NSString *contactCellUtilBadge  = @"badge";
    NSString *contactCellUtilTitle  = @"title";
    NSString *contactCellUtilUid    = @"uid";
    NSString *contactCellUtilSelectorName = @"selName";
//原始数据
    
    NSInteger systemCount = [[[NIMSDK sharedSDK] systemNotificationManager] allUnreadCount];
    NSMutableArray *utils =
            [@[
              @{
                  contactCellUtilIcon:@"icon_notification_normal",
                  contactCellUtilTitle:NSLocalizedString(@"APP_YUNXIN_Contact_ajaxMessage", nil),
                  contactCellUtilVC:@"NTESSystemNotificationViewController",
                  contactCellUtilBadge:@(systemCount)
               },
              @{
                  contactCellUtilIcon:@"icon_team_advance_normal",
                  contactCellUtilTitle:NSLocalizedString(@"APP_YUNXIN_Contact_advGroup", nil),
                  contactCellUtilVC:@"NTESAdvancedTeamListViewController"
               },
              @{
                  contactCellUtilIcon:@"icon_team_normal_normal",
                  contactCellUtilTitle:NSLocalizedString(@"APP_YUNXIN_Contact_taolunzu", nil),
                  contactCellUtilVC:@"NTESNormalTeamListViewController"
                },
//              @{
//                  contactCellUtilIcon:@"icon_robot_normal",
//                  contactCellUtilTitle:@"智能机器人",
//                  contactCellUtilVC:@"NTESRobotListViewController"
//                  },
              @{
                  contactCellUtilIcon:@"icon_blacklist_normal",
                  contactCellUtilTitle:NSLocalizedString(@"APP_YUNXIN_Contact_blackList", nil),
                  contactCellUtilVC:@"NTESBlackListViewController"
                  },
              @{
                  contactCellUtilIcon:@"icon_computer_normal",
                  contactCellUtilTitle:NSLocalizedString(@"APP_YUNXIN_Contact_MyComputer", nil),
                  contactCellUtilSelectorName:@"onEnterMyComputer"
                },
              ] mutableCopy];
    
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_KIND] isEqualToString:@"0"]) {
        [utils addObject:@{
                           contactCellUtilIcon:@"icon_School_70",
                           contactCellUtilTitle:NSLocalizedString(@"APP_YUNXIN_Contact_organization", nil),
                           contactCellUtilVC:@"TYHContacterListController",
                           }];
        [utils addObject:@{
                           contactCellUtilIcon:@"icon_School_70",
                           contactCellUtilTitle:NSLocalizedString(@"APP_YUNXIN_Contact_class", nil),
                           contactCellUtilVC:@"TYHContacterListController",
                           }];
    }
    else if([[[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_KIND] isEqualToString:@"1"] ||  [[[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_KIND] isEqualToString:@"2"])
    {
        [utils addObject:@{
                           contactCellUtilIcon:@"icon_School_70",
                           contactCellUtilTitle:NSLocalizedString(@"APP_YUNXIN_Contact_class", nil),
                           contactCellUtilVC:@"TYHContacterListController",
                           }];
    }
    else  if ([[[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_KIND] isEqualToString:@"3"] || [[[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_KIND] isEqualToString:@"4"]) {
        [utils addObject:@{
                           contactCellUtilIcon:@"icon_School_70",
                           contactCellUtilTitle:NSLocalizedString(@"APP_YUNXIN_Contact_organization", nil),
                           contactCellUtilVC:@"TYHContacterListController",
                           }];
    }
    
    self.navigationItem.title = NSLocalizedString(@"APP_YUNXIN_Contact_AdressBook", nil);
    [self setUpNavItem];
    
    //构造显示的数据模型
    NTESContactUtilItem *contactUtil = [[NTESContactUtilItem alloc] init];
    NSMutableArray * members = [[NSMutableArray alloc] init];
    for (NSDictionary *item in utils) {
        NTESContactUtilMember *utilItem = [[NTESContactUtilMember alloc] init];
        utilItem.nick              = item[contactCellUtilTitle];
        utilItem.icon              = [UIImage imageNamed:item[contactCellUtilIcon]];
        utilItem.vcName            = item[contactCellUtilVC];
        utilItem.badge             = [item[contactCellUtilBadge] stringValue];
        utilItem.userId            = item[contactCellUtilUid];
        utilItem.selName           = item[contactCellUtilSelectorName];
        [members addObject:utilItem];
    }
    contactUtil.members = members;
    
    [_contacts addGroupAboveWithTitle:@"" members:contactUtil.members];
}

#pragma mark - Action
- (void)onEnterMyComputer{
    NSString *uid = [[NIMSDK sharedSDK].loginManager currentAccount];
    NIMSession *session = [NIMSession session:uid type:NIMSessionTypeP2P];
    NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:session];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onOpera:(id)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"APP_YUNXIN_Contact_chooseType", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"APP_YUNXIN_Contact_AddFriend", nil),NSLocalizedString(@"APP_YUNXIN_Contact_createAdvGroup", nil),NSLocalizedString(@"APP_YUNXIN_Contact_createTTaolunzu", nil),NSLocalizedString(@"APP_YUNXIN_Contact_searchAdvGroup", nil), nil];
    __weak typeof(self) wself = self;
    NSString *currentUserId = [[NIMSDK sharedSDK].loginManager currentAccount];
    [sheet showInView:self.view completionHandler:^(NSInteger index) {
        UIViewController *vc;
        switch (index) {
            case 0:
                vc = [[TYHAddFriendViewController alloc] initWithNibName:nil bundle:nil];
                break;
            case 1:{  //创建高级群
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"APP_YUNXIN_Contact_inputGroupName", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) otherButtonTitles:NSLocalizedString(@"APP_General_Confirm", nil), nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                
                [alert showAlertWithCompletionHandler:^(NSInteger idx) {
                    if (idx == 0) {
                        return ;
                    }else
                    {
                        [wself presentMemberSelector:^(NSArray *uids) {
                            NSArray *members = [@[currentUserId] arrayByAddingObjectsFromArray:uids];
                            NIMCreateTeamOption *option = [[NIMCreateTeamOption alloc] init];
                            NSString *content = [[alert textFieldAtIndex:0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            content = [content length] ? content : NSLocalizedString(@"APP_YUNXIN_Contact_advGroup", nil);
                            option.name = content;
                            option.type       = NIMTeamTypeAdvanced;
                            option.joinMode   = NIMTeamJoinModeNoAuth;
                            option.postscript = NSLocalizedString(@"APP_YUNXIN_Contact_inviteUjoinInTheGroup", nil);
                            [SVProgressHUD show];
                            [[NIMSDK sharedSDK].teamManager createTeam:option users:members completion:^(NSError *error, NSString *teamId, NSArray<NSString *> * _Nullable failedUserIds) {
                                [SVProgressHUD dismiss];
                                if (!error) {
                                    NIMSession *session = [NIMSession session:teamId type:NIMSessionTypeTeam];
                                    NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:session];
                                    [wself.navigationController pushViewController:vc animated:YES];
                                    
                                    //特别添加 创建群组时传递ID给后台
                                    [self postTeamIDToServer:teamId];
                                    
                                }else{
                                    [wself.view makeToast:NSLocalizedString(@"APP_YUNXIN_Contact_createFailure", nil) duration:2.0 position:CSToastPositionCenter];
                                }
                            }];
                        }];
                    }
                }];
                break;
            }
            case 2:{ //创建讨论组
                [wself presentMemberSelector:^(NSArray *uids) {
                    if (!uids.count) {
                        return; //讨论组必须除自己外必须要有一个群成员
                    }
                    NSArray *members = [@[currentUserId] arrayByAddingObjectsFromArray:uids];
                    NIMCreateTeamOption *option = [[NIMCreateTeamOption alloc] init];
                    option.name       = NSLocalizedString(@"APP_YUNXIN_Contact_taolunzu", nil);
                    option.type       = NIMTeamTypeNormal;
                    [SVProgressHUD show];
                    [[NIMSDK sharedSDK].teamManager createTeam:option users:members completion:^(NSError *error, NSString *teamId, NSArray<NSString *> * _Nullable failedUserIds) {
                        [SVProgressHUD dismiss];
                        if (!error) {
                            NIMSession *session = [NIMSession session:teamId type:NIMSessionTypeTeam];
                            NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:session];
                            [wself.navigationController pushViewController:vc animated:YES];
                        }else{
                            [wself.view makeToast:NSLocalizedString(@"APP_YUNXIN_Contact_createFailure", nil) duration:2.0 position:CSToastPositionCenter];
                        }
                    }];
                }];
                break;
            }
            case 3:
                vc = [[NTESSearchTeamViewController alloc] initWithNibName:nil bundle:nil];
                break;
            default:
                break;
        }
        if (vc) {
            [wself.navigationController pushViewController:vc animated:YES];
        }
    }];
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id<NTESContactItem> contactItem = (id<NTESContactItem>)[_contacts memberOfIndex:indexPath];
    if ([contactItem respondsToSelector:@selector(selName)] && [contactItem selName].length) {
        SEL sel = NSSelectorFromString([contactItem selName]);
        SuppressPerformSelectorLeakWarning([self performSelector:sel withObject:nil]);
    }
    else if (contactItem.vcName.length) {
        Class clazz = NSClassFromString(contactItem.vcName);
        UIViewController * vc = [[clazz alloc] initWithNibName:nil bundle:nil];
        if ([vc isKindOfClass:[TYHContacterListController class]]) {
            vc.title = NSLocalizedString(@"APP_YUNXIN_Contact_Contact", nil);
            if (isTeacherOrAdmin) {
                vc = [[TYHContacterListController alloc]initWithType:0];
            }
            else vc = [[TYHContacterListController alloc]initWithType:1];
            if (indexPath.row == 6) {
                vc = [[TYHContacterListController alloc]initWithType:1];
            }
        }
        [self.navigationController pushViewController:vc animated:YES];
    }else if([contactItem respondsToSelector:@selector(userId)]){
        NSString * friendId   = contactItem.userId;
        [self enterPersonalCard:friendId];
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id<NTESContactItem> contactItem = (id<NTESContactItem>)[_contacts memberOfIndex:indexPath];
    return contactItem.uiHeight;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_contacts memberCountOfGroup:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_contacts groupCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id contactItem = [_contacts memberOfIndex:indexPath];
    NSString * cellId = [contactItem reuseId];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        Class cellClazz = NSClassFromString([contactItem cellName]);
        cell = [[cellClazz alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    if ([contactItem showAccessoryView]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([cell isKindOfClass:[NTESContactUtilCell class]]) {
        [(NTESContactUtilCell *)cell refreshWithContactItem:contactItem];
        [(NTESContactUtilCell *)cell setDelegate:self];
    }else{
        [(NTESContactDataCell *)cell refreshUser:contactItem];
        [(NTESContactDataCell *)cell setDelegate:self];
    }
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [_contacts titleOfGroup:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _contacts.sortedGroupTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index + 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    id<NTESContactItem> contactItem = (id<NTESContactItem>)[_contacts memberOfIndex:indexPath];
    return [contactItem userId].length;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"APP_YUNXIN_Contact_delFriend", nil) message:NSLocalizedString(@"APP_YUNXIN_Contact_delFriendAnddelRelationship", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) otherButtonTitles:NSLocalizedString(@"APP_General_Confirm", nil), nil];
        [alert showAlertWithCompletionHandler:^(NSInteger index) {
            if (index == 1) {
                [SVProgressHUD show];
                id<NTESContactItem,NTESGroupMemberProtocol> contactItem = (id<NTESContactItem,NTESGroupMemberProtocol>)[_contacts memberOfIndex:indexPath];
                NSString *userId = [contactItem userId];
                __weak typeof(self) wself = self;
                [[NIMSDK sharedSDK].userManager deleteFriend:userId completion:^(NSError *error) {
                    [SVProgressHUD dismiss];
                    if (!error) {
                        [_contacts removeGroupMember:contactItem];
                    }else{
                        [wself.view makeToast:NSLocalizedString(@"删除失败", nil) duration:2.0f position:CSToastPositionCenter];
                    }
                }];
            }
        }];
    }
}

#pragma mark - NIMContactDataCellDelegate
- (void)onPressAvatar:(NSString *)memberId{
    [self enterPersonalCard:memberId];
}

#pragma mark - NTESContactUtilCellDelegate
- (void)onPressUtilImage:(NSString *)content{
    [self.view makeToast:[NSString stringWithFormat:@" 我是<%@>",content] duration:2.0 position:CSToastPositionCenter];
}

#pragma mark - NIMContactSelectDelegate
- (void)didFinishedSelect:(NSArray *)selectedContacts{
    
}

#pragma mark - NIMSDK Delegate
- (void)onSystemNotificationCountChanged:(NSInteger)unreadCount
{
    [self prepareData];
    [self.tableView reloadData];
}

- (void)onLogin:(NIMLoginStep)step
{
    if (step == NIMLoginStepSyncOK) {
        if (self.isViewLoaded) {//没有加载view的话viewDidLoad里会走一遍prepareData
            [self prepareData];
            [self.tableView reloadData];
        }
    }
}

- (void)onUserInfoChanged:(NIMUser *)user
{
    [self refresh];
}

- (void)onFriendChanged:(NIMUser *)user{
    [self refresh];
}

- (void)onBlackListChanged
{
    [self refresh];
}

- (void)onMuteListChanged
{
    [self refresh];
}

- (void)refresh
{
    [self prepareData];
    [self.tableView reloadData];
}


#pragma mark - NIMEventSubscribeManagerDelegate

- (void)onRecvSubscribeEvents:(NSArray *)events
{
    NSMutableSet *ids = [[NSMutableSet alloc] init];
    for (NIMSubscribeEvent *event in events) {
        [ids addObject:event.from];
    }
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in self.tableView.indexPathsForVisibleRows) {
        
        id<NTESContactItem> contactItem = (id<NTESContactItem>)[_contacts memberOfIndex:indexPath];
        if([contactItem respondsToSelector:@selector(userId)]){
            NSString * friendId   = contactItem.userId;
            if ([ids containsObject:friendId]) {
                [indexPaths addObject:indexPath];
            }
        }
    }
    
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}



#pragma mark - Private
- (void)enterPersonalCard:(NSString *)userId{
    NTESPersonalCardViewController *vc = [[NTESPersonalCardViewController alloc] initWithUserId:userId];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)presentMemberSelector:(ContactSelectFinishBlock) block{
    NSMutableArray *users = [[NSMutableArray alloc] init];
    //使用内置的好友选择器
    NIMContactFriendSelectConfig *config = [[NIMContactFriendSelectConfig alloc] init];
    //获取自己id
    NSString *currentUserId = [[NIMSDK sharedSDK].loginManager currentAccount];
    [users addObject:currentUserId];
    //将自己的id过滤
    config.filterIds = users;
    //需要多选
    config.needMutiSelected = YES;
    //初始化联系人选择器
    NIMContactSelectViewController *vc = [[NIMContactSelectViewController alloc] initWithConfig:config];
    //回调处理
    vc.finshBlock = block;
    [vc show];
}

-(void)postTeamIDToServer:(NSString *)teamId
{
    NSString *userName = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_LOGINNAME];
    NSString *password = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_V3PWD];
    NSString *organizationID = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_ORIGANIZATION_ID];
    NSDictionary *dic = @{@"sys_auto_authenticate":@"true",@"sys_username":[NSString stringWithFormat:@"%@%@%@",userName,@"%2C",organizationID],@"sys_password":password};
    NSString *requestURL = [NSString stringWithFormat:@"%@%@?tid=%@",BaseURL,@"/bd/neteaseTeam/mobile/synchroTeam",teamId];
    
    [TYHHttpTool get:requestURL params:dic success:^(id json) {
        NSLog(@"%@",json);
    } failure:^(NSError *error) {
    }];
}

@end
