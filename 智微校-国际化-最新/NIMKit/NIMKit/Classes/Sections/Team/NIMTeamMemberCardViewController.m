//
//  TeamMemberCardViewController.m
//  NIM
//
//  Created by Xuhui on 15/3/19.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMTeamMemberCardViewController.h"
#import "NIMCommonTableData.h"
#import "NIMCommonTableDelegate.h"
#import "NIMAvatarImageView.h"
#import "NIMCardMemberItem.h"
#import "NIMUsrInfoData.h"
#import "NIMKitUtil.h"
#import "NIMKitDependency.h"
#import "NIMKit.h"
#import "UIView+NIM.h"
#import "NIMKitColorButtonCell.h"
#import "NIMKitSwitcherCell.h"

@interface NIMTeamMemberCardViewController () <UIActionSheetDelegate>{
    UIAlertView *_kickAlertView;
    UIAlertView *_updateNickAlertView;
}

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NIMUsrInfo *usrInfo;

@property (nonatomic,strong) NIMCommonTableDelegate *delegator;

@property (nonatomic,strong) NSArray *data;

@end

@implementation NIMTeamMemberCardViewController

- (instancetype)initWithUserId:(NSString *)userId team:(NSString *)teamId{
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        _member = [[NIMTeamCardMemberItem alloc] initWithMember:[[NIMSDK sharedSDK].teamManager teamMember:userId inTeam:teamId]];
        _viewer = [[NIMTeamCardMemberItem alloc] initWithMember:[[NIMSDK sharedSDK].teamManager teamMember:[NIMSDK sharedSDK].loginManager.currentAccount inTeam:teamId]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"APP_YUNXIN_groupCard", nil);
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = [UIView new];
    
    NIMUsrInfo *user = [[NIMUsrInfo alloc] init];
    user.info = [[NIMKit sharedKit] infoByUser:self.member.memberId option:nil];
    self.usrInfo = user;

    [self buildData];
    __weak typeof(self) wself = self;
    self.delegator = [[NIMCommonTableDelegate alloc] initWithTableData:^NSArray *{
        return wself.data;
    }];
    self.tableView.delegate   = self.delegator;
    self.tableView.dataSource = self.delegator;

}


- (void)buildData{
    NIMTeamMember *member = [[NIMSDK sharedSDK].teamManager teamMember:self.member.memberId inTeam:self.member.team.teamId];
    
    NSArray *data = @[
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                  @{
                                      CellClass     : @"NIMTeamMemberCardHeaderCell",
                                      RowHeight     : @(222),
                                      ExtraInfo     : @{@"user":self.usrInfo,@"team":self.member.team},
                                      SepLeftEdge   : @(SepLineLeft),
                                  },
                                  @{
                                      Title         : NSLocalizedString(@"APP_YUNXIN_groupNickName", nil),
                                      DetailTitle   : member.nickname.length? member.nickname : NSLocalizedString(@"APP_YUNXIN_notSet", nil),
                                      CellAction    : ([self isSelf] || [self canUpdateTeamMember])? @"updateTeamNick" : @"",
                                      ShowAccessory : ([self isSelf] || [self canUpdateTeamMember])? @(YES) : @(NO),
                                      RowHeight     : @(50),
                                      SepLeftEdge   : @(SepLineLeft),
                                      },
                                  @{
                                      Title         : NSLocalizedString(@"APP_YUNXIN_identityLalbel", nil),
                                      DetailTitle   : [self memberTypeString:self.member.type],
                                      CellAction    : ([self isOwner] && ![self isSelf])? @"updateTeamRole" : @"",
                                      ShowAccessory : [self isOwner] && ![self isSelf]? @(YES) : @(NO),
                                      RowHeight     : @(50),
                                      SepLeftEdge   : @(SepLineLeft),
                                    },
                                  @{
                                      Title         : NSLocalizedString(@"APP_YUNXIN_setForbiden", nil),
                                      CellClass     : @"NIMKitSwitcherCell",
                                      CellAction    : @"updateMute:",
                                      ForbidSelect  : @(YES),
                                      RowHeight     : @(50),
                                      Disable       : @(![self canUpdateTeamMember]),
                                      ExtraInfo     : @(member.isMuted),
                                      SepLeftEdge   : @(SepLineLeft),
                                    },
                                  @{
                                      Title         : NSLocalizedString(@"APP_YUNXIN_removeFromGroup", nil),
                                      CellClass     : @"NIMKitColorButtonCell",
                                      CellAction    : @"onKickBtnClick:",
                                      ExtraInfo     : @(NIMKitColorButtonCellStyleRed),
                                      RowHeight     : @(70),
                                      Disable       : @(![self canUpdateTeamMember]),
                                      SepLeftEdge   : @(0),
                                    }
                                  ],
                          FooterTitle:@""
                          },
                       ];
    self.data = [NIMCommonTableSection sectionsWithData:data];
}

- (void)refreshData{
    [self buildData];
    [self.tableView reloadData];
}


- (NSString *)memberTypeString:(NIMTeamMemberType)type {
    if(type == NIMTeamMemberTypeNormal) {
        return NSLocalizedString(@"APP_YUNXIN_groupNormalMember", nil);
    } else if (type == NIMTeamMemberTypeOwner) {
        return NSLocalizedString(@"APP_YUNXIN_groupOwner", nil);
    } else if (type == NIMTeamMemberTypeManager) {
        return NSLocalizedString(@"APP_YUNXIN_groupAdmin", nil);
    }
    return @"";
}


- (void)onKickBtnClick:(id)sender {
    _kickAlertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"APP_YUNXIN_removeFromGroup", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) otherButtonTitles:NSLocalizedString(@"APP_General_Confirm", nil), nil];
    [_kickAlertView show];
}

- (void)updateTeamNick
{
    _updateNickAlertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"APP_YUNXIN_changeGroupNickName", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) otherButtonTitles:NSLocalizedString(@"APP_General_Confirm", nil), nil];
    _updateNickAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [_updateNickAlertView show];
}

- (void)updateTeamRole
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"APP_YUNXIN_adminOp", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) destructiveButtonTitle:nil otherButtonTitles: self.member.type == NIMTeamMemberTypeManager ? NSLocalizedString(@"APP_YUNXIN_adminOpCancel", nil) : NSLocalizedString(@"APP_YUNXIN_adminOpSet", nil), nil];
    [sheet showInView:self.view];
}

- (void)updateMute:(UISwitch *)switcher
{
    __block typeof(self) wself = self;
    BOOL mute = switcher.on;
    [[NIMSDK sharedSDK].teamManager updateMuteState:mute userId:self.member.memberId inTeam:self.member.team.teamId completion:^(NSError *error) {
        if (error) {
            [wself.view makeToast:NSLocalizedString(@"APP_YUNXIN_pw_changeFailed", nil)];
            switcher.on = !mute;
        }
    }];
}


- (void)removeManager:(NSString *)memberId{
    __block typeof(self) wself = self;
    [[NIMSDK sharedSDK].teamManager removeManagersFromTeam:self.member.team.teamId users:@[self.member.memberId] completion:^(NSError *error) {
        if (!error) {
            wself.member.type = NIMTeamMemberTypeNormal;
            [wself.view makeToast:NSLocalizedString(@"APP_YUNXIN_pw_changeSuccess", nil)];
            [wself refreshData];
            if([_delegate respondsToSelector:@selector(onTeamMemberInfoChaneged:)]) {
                [_delegate onTeamMemberInfoChaneged:wself.member];
            }
        }else{
            [wself.view makeToast:NSLocalizedString(@"APP_YUNXIN_pw_changeFailed", nil)];
        }
        
    }];
}

- (void)addManager:(NSString *)memberId{
    __block typeof(self) wself = self;
    [[NIMSDK sharedSDK].teamManager addManagersToTeam:self.member.team.teamId users:@[self.member.memberId] completion:^(NSError *error) {
        if (!error) {
            wself.member.type = NIMTeamMemberTypeManager;
            [wself.view makeToast:NSLocalizedString(@"APP_YUNXIN_pw_changeSuccess", nil)];
            [wself refreshData];
            if([_delegate respondsToSelector:@selector(onTeamMemberInfoChaneged:)]) {
                [_delegate onTeamMemberInfoChaneged:wself.member];
            }
        }else{
            [wself.view makeToast:NSLocalizedString(@"APP_YUNXIN_pw_changeFailed", nil)];
        }
    }];
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView == _kickAlertView) {
        if(alertView.cancelButtonIndex != buttonIndex) {
            [[NIMSDK sharedSDK].teamManager kickUsers:@[self.member.memberId] fromTeam:self.member.team.teamId completion:^(NSError *error) {
                if(!error) {
                    [self.view makeToast:NSLocalizedString(@"APP_YUNXIN_tiSuccess", nil)];
                    [self.navigationController popViewControllerAnimated:YES];
                    if([_delegate respondsToSelector:@selector(onTeamMemberKicked:)]) {
                        [_delegate onTeamMemberKicked:self.member];
                    }
                } else {
                    [self.view makeToast:NSLocalizedString(@"APP_YUNXIN_tiFailed", nil)];
                }
            }];
        }
    }
    if (alertView == _updateNickAlertView) {
        switch (buttonIndex) {
            case 0://取消
                break;
            case 1:{
                NSString *name = [alertView textFieldAtIndex:0].text;
                [[NIMSDK sharedSDK].teamManager updateUserNick:self.member.memberId newNick:name inTeam:self.member.team.teamId completion:^(NSError *error) {
                    if (!error) {
                        [self.view makeToast:NSLocalizedString(@"APP_YUNXIN_pw_changeSuccess", nil)];
                        [self refreshData];
                        if([_delegate respondsToSelector:@selector(onTeamMemberInfoChaneged:)]) {
                            [_delegate onTeamMemberInfoChaneged:self.member];
                        }
                    }else{
                        [self.view makeToast:NSLocalizedString(@"APP_YUNXIN_pw_changeFailed", nil)];
                    }
                }];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0) {
        if (self.member.type == NIMTeamMemberTypeManager) {
            [self removeManager:self.member.memberId];
        }else{
            [self addManager:self.member.memberId];
        }
    }
}

#pragma mark - Private

- (BOOL)isSelf
{
    return [self.viewer.memberId isEqualToString:self.member.memberId];
}

- (BOOL)isOwner
{
    return self.viewer.member.type == NIMTeamMemberTypeOwner;
}

- (BOOL)canModifyTeamInfo
{
    return [NIMKitUtil canEditTeamInfo:self.viewer.member];
}

- (BOOL)canUpdateTeamMember
{
    BOOL viewerIsOwner   = [self isOwner];
    BOOL viewerIsManager = self.viewer.member.type == NIMTeamMemberTypeManager;
    BOOL memberIsNormal  = self.member.member.type == NIMTeamMemberTypeNormal;
    if (viewerIsOwner) {
        return ![self isSelf];
    }
    if (viewerIsManager) {
        return memberIsNormal;
    }
    return NO;
}

@end


