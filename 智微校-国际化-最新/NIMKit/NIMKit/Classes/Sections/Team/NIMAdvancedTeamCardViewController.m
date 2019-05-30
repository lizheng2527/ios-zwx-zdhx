//
//  NIMAdvancedTeamCardViewController.m
//  NIM
//
//  Created by chris on 15/3/25.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMAdvancedTeamCardViewController.h"
#import "NIMTeamCardRowItem.h"
#import "UIView+NIM.h"
#import "UIImage+NIMKit.h"
#import "NIMKitColorButtonCell.h"
#import "NIMAdvancedTeamMemberCell.h"
#import "NIMKitDependency.h"
#import "NIMTeamMemberCardViewController.h"
#import "NIMCardMemberItem.h"
#import "NIMContactSelectViewController.h"
#import "NIMGroupedUsrInfo.h"
#import "NIMTeamMemberListViewController.h"
#import "NIMTeamAnnouncementListViewController.h"
#import "NIMKitUtil.h"
#import "NIMTeamSwitchTableViewCell.h"
#import "NIMAvatarImageView.h"
#import "NIMKitProgressHUD.h"
#import "NIMTeamNotifyUpdateViewController.h"


#pragma mark - Team Header View
#define CardHeaderHeight 89

@protocol NIMAdvancedTeamCardHeaderViewDelegate <NSObject>

- (void)onTouchAvatar:(id)sender;

@end

@interface NIMAdvancedTeamCardHeaderView : UIView

@property (nonatomic,strong) NIMAvatarImageView *avatar;

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) UILabel *numberLabel;

@property (nonatomic,strong) UILabel *createTimeLabel;

@property (nonatomic,strong) NIMTeam *team;

@property (nonatomic,weak) id<NIMAdvancedTeamCardHeaderViewDelegate> delegate;

- (void)refresh;

@end

@implementation NIMAdvancedTeamCardHeaderView

- (instancetype)initWithTeam:(NIMTeam*)team{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _team = [[NIMSDK sharedSDK].teamManager teamById:team.teamId];
        _avatar  = [[NIMAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [_avatar addTarget:self action:@selector(onTouchAvatar:) forControlEvents:UIControlEventTouchUpInside];
        _titleLabel                      = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.backgroundColor      = [UIColor clearColor];
        _titleLabel.font                 = [UIFont systemFontOfSize:17.f];
        _titleLabel.textColor            = NIMKit_UIColorFromRGB(0x333333);
        _numberLabel                     = [[UILabel alloc]initWithFrame:CGRectZero];
        _numberLabel.backgroundColor     = [UIColor clearColor];
        _numberLabel.font                = [UIFont systemFontOfSize:14.f];
        _numberLabel.textColor           = NIMKit_UIColorFromRGB(0x999999);
        _createTimeLabel                 = [[UILabel alloc]initWithFrame:CGRectZero];
        _createTimeLabel.backgroundColor = [UIColor clearColor];
        _createTimeLabel.font            = [UIFont systemFontOfSize:14.f];
        _createTimeLabel.textColor       = NIMKit_UIColorFromRGB(0x999999);
        [self addSubview:_avatar];
        [self addSubview:_titleLabel];
        [self addSubview:_numberLabel];
        [self addSubview:_createTimeLabel];
        
        self.backgroundColor = NIMKit_UIColorFromRGB(0xecf1f5);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self refresh];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake(size.width, CardHeaderHeight);
}

- (void)refresh
{
    // team 缓存可能发生改变，需要重新从 SDK 里拿一遍
    _team = [[NIMSDK sharedSDK].teamManager teamById:_team.teamId];
//    NSURL *avatarUrl = _team.thumbAvatarUrl.length? [NSURL URLWithString:_team.thumbAvatarUrl] : nil;
    //    使用自己服务器的头像
    NSURL *avatarUrl = _team.thumbAvatarUrl.length? [NSURL URLWithString:_team.avatarUrl] : nil;
    [_avatar nim_setImageWithURL:avatarUrl placeholderImage:[UIImage nim_imageInKit:@"avatar_team"]];
}

- (NSString*)formartCreateTime{
    NSTimeInterval timestamp = self.team.createTime;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp]];
    if (!dateString.length) {
        return NSLocalizedString(@"APP_YUNXIN_unknowTimeCreate", nil);
    }
    return [NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"APP_YUNXIN_createYU", nil),dateString,NSLocalizedString(@"APP_YUNXIN_Create", nil)];
}

- (void)onTouchAvatar:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onTouchAvatar:)]) {
        [self.delegate onTouchAvatar:sender];
    }
}

#define AvatarLeft 20
#define AvatarTop  25
#define TitleAndAvatarSpacing 10
#define NumberAndTimeSpacing  10
#define MaxTitleLabelWidth 200
- (void)layoutSubviews{
    [super layoutSubviews];
    _titleLabel.text  = self.team.teamName;
    _numberLabel.text = self.team.teamId;
    _createTimeLabel.text  = [self formartCreateTime];
    [_titleLabel sizeToFit];
    [_createTimeLabel sizeToFit];
    [_numberLabel sizeToFit];

    self.titleLabel.nim_width = self.titleLabel.nim_width > MaxTitleLabelWidth ? MaxTitleLabelWidth : self.titleLabel.nim_width;
    self.avatar.nim_left = AvatarLeft;
    self.avatar.nim_top  = AvatarTop;
    self.titleLabel.nim_left = self.avatar.nim_right + TitleAndAvatarSpacing;
    self.titleLabel.nim_top  = self.avatar.nim_top;
    self.numberLabel.nim_left   = self.titleLabel.nim_left;
    self.numberLabel.nim_bottom = self.avatar.nim_bottom;
    self.createTimeLabel.nim_left   = self.numberLabel.nim_right + NumberAndTimeSpacing;
    self.createTimeLabel.nim_bottom = self.numberLabel.nim_bottom;
}

@end

#pragma mark - Card VC
#define TableCellReuseId        @"tableCell"
#define TableButtonCellReuseId  @"tableButtonCell"
#define TableMemberCellReuseId  @"tableMemberCell"
#define TableSwitchReuseId      @"tableSwitchCell"

@interface NIMAdvancedTeamCardViewController ()<NIMAdvancedTeamMemberCellActionDelegate,NIMContactSelectDelegate,NIMTeamSwitchProtocol,NIMAdvancedTeamCardHeaderViewDelegate,NIMTeamManagerDelegate,UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    
    UIAlertView *_updateTeamNameAlertView;
    UIAlertView *_updateTeamNickAlertView;
    UIAlertView *_updateTeamIntroAlertView;
    UIAlertView *_quitTeamAlertView;
    UIAlertView *_dismissTeamAlertView;
    
    UIActionSheet *_moreActionSheet;
    UIActionSheet *_authActionSheet;
    UIActionSheet *_inviteActionSheet;
    UIActionSheet *_beInviteActionSheet;
    UIActionSheet *_updateInfoActionSheet;
    UIActionSheet *_avatarActionSheet;

}

@property (nonatomic,strong) UITableView *tableView;

@property(nonatomic,strong) NIMTeam *team;

@property(nonatomic,strong) NIMTeamMember *myTeamInfo;

@property(nonatomic,copy) NSArray *bodyData;

@property(nonatomic,copy) NSArray *memberData;

@end

@implementation NIMAdvancedTeamCardViewController

- (instancetype)initWithTeam:(NIMTeam *)team{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _team = team;
    }
    return self;
}


- (void)dealloc
{
    [[NIMSDK sharedSDK].teamManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NIMAdvancedTeamCardHeaderView *headerView = [[NIMAdvancedTeamCardHeaderView alloc] initWithTeam:self.team];

    headerView.delegate = self;
    headerView.nim_size = [headerView sizeThatFits:self.view.nim_size];
    self.navigationItem.title = self.team.teamName;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = NIMKit_UIColorFromRGB(0xecf1f5);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    __weak typeof(self) wself = self;
    [self requestData:^(NSError *error) {
        if (!error) {
            [wself reloadData];
        }
    }];
    
    [[NIMSDK sharedSDK].teamManager addDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)reloadData{
    self.myTeamInfo = [[NIMSDK sharedSDK].teamManager teamMember:self.myTeamInfo.userId inTeam:self.myTeamInfo.teamId];
    [self buildBodyData];
    [self.tableView reloadData];
    NIMAdvancedTeamCardHeaderView *headerView = (NIMAdvancedTeamCardHeaderView*)self.tableView.tableHeaderView;
    headerView.titleLabel.text = self.team.teamName;;
    self.navigationItem.title  = self.team.teamName;
    if (self.myTeamInfo.type == NIMTeamMemberTypeOwner) {
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onMore:)];
        self.navigationItem.rightBarButtonItem = buttonItem;
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)requestData:(void(^)(NSError *error)) handler{
    __weak typeof(self) wself = self;
    [[NIMSDK sharedSDK].teamManager fetchTeamMembers:self.team.teamId completion:^(NSError *error, NSArray *members) {
        if (!error) {
            for (NIMTeamMember *member in members) {
                if ([member.userId isEqualToString:[NIMSDK sharedSDK].loginManager.currentAccount]) {
                    wself.myTeamInfo = member;
                    break;
                }
            }
            wself.memberData = members;
        }else if(error.code == NIMRemoteErrorCodeTeamNotMember){
            [wself.view makeToast:NSLocalizedString(@"APP_YUNXIN_UnotInGroup", nil) duration:2
                                position:CSToastPositionCenter];
        }else{
            [wself.view makeToast:[NSString stringWithFormat:@"%@ error: %zd",NSLocalizedString(@"APP_YUNXIN_inviteJoinFriendFailed", nil),error.code] duration:2
                                position:CSToastPositionCenter];
        }
        handler(error);
    }];
}

- (void)buildBodyData{
    BOOL canEdit = [NIMKitUtil canEditTeamInfo:self.myTeamInfo];
    BOOL isOwner    = self.myTeamInfo.type == NIMTeamMemberTypeOwner;
    BOOL isManager  = self.myTeamInfo.type == NIMTeamMemberTypeManager;
    
    NIMTeamCardRowItem *teamMember = [[NIMTeamCardRowItem alloc] init];
    teamMember.title  = NSLocalizedString(@"APP_YUNXIN_groupMember", nil);
    teamMember.rowHeight = 111.f;
    teamMember.action = @selector(enterMemberCard);
    teamMember.type   = TeamCardRowItemTypeTeamMember;
    
    NIMTeamCardRowItem *teamName = [[NIMTeamCardRowItem alloc] init];
    teamName.title = NSLocalizedString(@"APP_YUNXIN_groupName", nil);
    teamName.subTitle = self.team.teamName;
    teamName.action = @selector(updateTeamName);
    teamName.rowHeight = 50.f;
    teamName.type   = TeamCardRowItemTypeCommon;
    teamName.actionDisabled = !canEdit;
    
    NIMTeamCardRowItem *teamNick = [[NIMTeamCardRowItem alloc] init];
    teamNick.title = NSLocalizedString(@"APP_YUNXIN_groupNickName", nil);
    teamNick.subTitle = self.myTeamInfo.nickname;
    teamNick.action = @selector(updateTeamNick);
    teamNick.rowHeight = 50.f;
    teamNick.type   = TeamCardRowItemTypeCommon;

    
    NIMTeamCardRowItem *teamIntro = [[NIMTeamCardRowItem alloc] init];
    teamIntro.title = NSLocalizedString(@"APP_YUNXIN_GroupDes", nil);
    teamIntro.subTitle = self.team.intro.length ? self.team.intro : (canEdit ? NSLocalizedString(@"APP_YUNXIN_tapInputGroupDes", nil) : @"");
    teamIntro.action = @selector(updateTeamIntro);
    teamIntro.rowHeight = 50.f;
    teamIntro.type   = TeamCardRowItemTypeCommon;
    teamIntro.actionDisabled = !canEdit;
    
    NIMTeamCardRowItem *teamAnnouncement = [[NIMTeamCardRowItem alloc] init];
    teamAnnouncement.title = NSLocalizedString(@"APP_YUNXIN_GroupNote", nil);
    teamAnnouncement.subTitle = NSLocalizedString(@"APP_YUNXIN_tapInputGroupNote", nil);//self.team.announcement.length ? self.team.announcement : (isManager ? @"点击填写群公告" : @"");
    teamAnnouncement.action = @selector(updateTeamAnnouncement);
    teamAnnouncement.rowHeight = 50.f;
    teamAnnouncement.type   = TeamCardRowItemTypeCommon;
    
    
    NIMTeamCardRowItem *teamNotify = [[NIMTeamCardRowItem alloc] init];
    teamNotify.title  = NSLocalizedString(@"APP_YUNXIN_messageNotifacation", nil);
    teamNotify.action = @selector(updateTeamNotify);
    teamNotify.rowHeight = 50.f;
    teamNotify.type   = TeamCardRowItemTypeCommon;

    NIMTeamCardRowItem *itemQuit = [[NIMTeamCardRowItem alloc] init];
    itemQuit.title = NSLocalizedString(@"APP_YUNXIN_outAdvGroup", nil);
    itemQuit.action = @selector(quitTeam);
    itemQuit.rowHeight = 60.f;
    itemQuit.type   = TeamCardRowItemTypeRedButton;
    
    NIMTeamCardRowItem *itemDismiss = [[NIMTeamCardRowItem alloc] init];
    itemDismiss.title  = NSLocalizedString(@"APP_YUNXIN_disBandGroupTalk", nil);
    itemDismiss.action = @selector(dismissTeam);
    itemDismiss.rowHeight = 60.f;
    itemDismiss.type   = TeamCardRowItemTypeRedButton;
    
    
    NIMTeamCardRowItem *itemAuth = [[NIMTeamCardRowItem alloc] init];
    itemAuth.title  = NSLocalizedString(@"APP_YUNXIN_indentifyAjax", nil);
    itemAuth.subTitle = [self joinModeText:self.team.joinMode];
    itemAuth.action = @selector(changeAuthMode);
    itemAuth.actionDisabled = !canEdit;
    itemAuth.rowHeight = 60.f;
    itemAuth.type   = TeamCardRowItemTypeCommon;
    
    NIMTeamCardRowItem *itemInvite = [[NIMTeamCardRowItem alloc] init];
    itemInvite.title  = NSLocalizedString(@"APP_YUNXIN_inviteOtherLimit", nil);
    itemInvite.subTitle = [self inviteModeText:self.team.inviteMode];
    itemInvite.action = @selector(changeInviteMode);
    itemInvite.actionDisabled = !canEdit;
    itemInvite.rowHeight = 60.f;
    itemInvite.type   = TeamCardRowItemTypeCommon;
    
    NIMTeamCardRowItem *itemUpdateInfo = [[NIMTeamCardRowItem alloc] init];
    itemUpdateInfo.title  = NSLocalizedString(@"APP_YUNXIN_groupInfoChangeLiimt", nil);
    itemUpdateInfo.subTitle = [self updateInfoModeText:self.team.updateInfoMode];
    itemUpdateInfo.action = @selector(changeUpdateInfoMode);
    itemUpdateInfo.actionDisabled = !canEdit;
    itemUpdateInfo.rowHeight = 60.f;
    itemUpdateInfo.type   = TeamCardRowItemTypeCommon;
    
    NIMTeamCardRowItem *itemBeInvite = [[NIMTeamCardRowItem alloc] init];
    itemBeInvite.title  = NSLocalizedString(@"APP_YUNXIN_invitedpersonAjax", nil);
    itemBeInvite.subTitle = [self beInviteModeText:self.team.beInviteMode];
    itemBeInvite.action = @selector(changeBeInviteMode);
    itemBeInvite.actionDisabled = !canEdit;
    itemBeInvite.rowHeight = 60.f;
    itemBeInvite.type   = TeamCardRowItemTypeCommon;
    

    
    if (isOwner) {
        self.bodyData = @[
                  @[teamMember],
                  @[teamName,teamNick,teamIntro,teamAnnouncement,teamNotify],
                  @[itemAuth],
                  @[itemInvite,itemUpdateInfo,itemBeInvite],
                  @[itemDismiss],
                 ];
    }else if(isManager){
        self.bodyData = @[
                 @[teamMember],
                 @[teamName,teamNick,teamIntro,teamAnnouncement,teamNotify],
                 @[itemAuth],
                 @[itemInvite,itemUpdateInfo,itemBeInvite],
                 @[itemQuit],
                 ];
    }else{
        self.bodyData = @[
                          @[teamMember],
                          @[teamName,teamNick,teamIntro,teamAnnouncement,teamNotify],
                          @[itemQuit],
                          ];
    }
}

- (id<NTESCardBodyData>)bodyDataAtIndexPath:(NSIndexPath*)indexpath{
    NSArray *sectionData = self.bodyData[indexpath.section];
    return sectionData[indexpath.row];
}

- (NSIndexPath *)cellIndexPathByTitle:(NSString *)title {
    __block NSInteger section = 0;
    __block NSInteger row = 0;
    [self.bodyData enumerateObjectsUsingBlock:^(NSArray *rows, NSUInteger s, BOOL *stop) {
        __block BOOL stopped = NO;
        [rows enumerateObjectsUsingBlock:^(NIMTeamCardRowItem *item, NSUInteger r, BOOL *stop) {
            if([item.title isEqualToString:title]) {
                section = s;
                row = r;
                *stop = YES;
                stopped = YES;
            }
        }];
        *stop = stopped;
    }];
    return [NSIndexPath indexPathForRow:row inSection:section];
}

#pragma mark - NIMTeamManagerDelegate
- (void)onTeamMemberChanged:(NIMTeam *)team
{
    __weak typeof(self) weakSelf = self;
    [self requestData:^(NSError *error) {
        [weakSelf reloadData];
    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    id<NTESCardBodyData> bodyData = [self bodyDataAtIndexPath:indexPath];
    if ([bodyData respondsToSelector:@selector(actionDisabled)] && bodyData.actionDisabled) {
        return;
    }
    if ([bodyData respondsToSelector:@selector(action)]) {
        if (bodyData.action) {
            NIMKit_SuppressPerformSelectorLeakWarning([self performSelector:bodyData.action]);
        }
    }
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id<NTESCardBodyData> bodyData = [self bodyDataAtIndexPath:indexPath];
    return bodyData.rowHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.bodyData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *sectionData = self.bodyData[section];
    return sectionData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id<NTESCardBodyData> bodyData = [self bodyDataAtIndexPath:indexPath];
    UITableViewCell * cell;
    NIMKitTeamCardRowItemType type = bodyData.type;
    switch (type) {
        case TeamCardRowItemTypeCommon:
            cell = [self builidCommonCell:bodyData];
            break;
        case TeamCardRowItemTypeRedButton:
            cell = [self builidRedButtonCell:bodyData];
            break;
        case TeamCardRowItemTypeTeamMember:
            cell = [self builidTeamMemberCell:bodyData];
            break;
        case TeamCardRowItemTypeSwitch:
            cell = [self buildTeamSwitchCell:bodyData];
            break;
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.0f;
    }
    return 20.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = NIMKit_UIColorFromRGB(0xecf1f5);
    return view;
}


- (UITableViewCell*)builidCommonCell:(id<NTESCardBodyData>) bodyData{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:TableCellReuseId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TableCellReuseId];
        CGFloat left = 15.f;
        UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(left, cell.nim_height-1, cell.nim_width, 1.f)];
        sep.backgroundColor = NIMKit_UIColorFromRGB(0xebebeb);
        [cell addSubview:sep];
        sep.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    cell.textLabel.text = bodyData.title;
    if ([bodyData respondsToSelector:@selector(subTitle)]) {
        cell.detailTextLabel.text = bodyData.subTitle;
    }
    
    if ([bodyData respondsToSelector:@selector(actionDisabled)] && bodyData.actionDisabled) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
    
}

- (UITableViewCell*)builidRedButtonCell:(id<NTESCardBodyData>) bodyData{
    NIMKitColorButtonCell * cell = [self.tableView dequeueReusableCellWithIdentifier:TableButtonCellReuseId];
    if (!cell) {
        cell = [[NIMKitColorButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableButtonCellReuseId];
    }
    cell.button.style = NIMKitColorButtonCellStyleRed;
    [cell.button setTitle:bodyData.title forState:UIControlStateNormal];
    return cell;
}

- (UITableViewCell*)builidTeamMemberCell:(id<NTESCardBodyData>) bodyData{
    NIMAdvancedTeamMemberCell * cell = [self.tableView dequeueReusableCellWithIdentifier:TableMemberCellReuseId];
    if (!cell) {
        cell = [[NIMAdvancedTeamMemberCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TableMemberCellReuseId];
        cell.delegate = self;
    }
    [cell rereshWithTeam:self.team members:self.memberData width:self.tableView.nim_width];
    cell.textLabel.text = bodyData.title;
    cell.detailTextLabel.text = bodyData.subTitle;
    if ([bodyData respondsToSelector:@selector(actionDisabled)] && bodyData.actionDisabled) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (UITableViewCell *)buildTeamSwitchCell:(id<NTESCardBodyData>)bodyData
{
    NIMTeamSwitchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TableSwitchReuseId];
    if (!cell) {
        cell = [[NIMTeamSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NIMTeamSwitchTableViewCell"];
    }
    cell.textLabel.text = bodyData.title;
    cell.switcher.on = bodyData.switchOn;
    cell.switchDelegate = self;
    
    return cell;
}

#pragma mark - Action
- (void)onMore:(id)sender{
    _moreActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"APP_YUNXIN_PlzOperation", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"APP_YUNXIN_zhuanrangGroup", nil),NSLocalizedString(@"APP_YUNXIN_zhuanrangGroupOut", nil),nil];
    [_moreActionSheet showInView:self.view];
}

- (void)onTouchAvatar:(id)sender{
    if([NIMKitUtil canEditTeamInfo:self.myTeamInfo])
    {
        _avatarActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"APP_YUNXIN_setGroupImage", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"APP_YUNXIN_takePic", nil),NSLocalizedString(@"APP_YUNXIN_fromAlbum", nil), nil];
        [_avatarActionSheet showInView:self.view];
    }
}

- (void)updateTeamName{
    _updateTeamNameAlertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"APP_YUNXIN_setGroupName", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) otherButtonTitles:NSLocalizedString(@"APP_General_Confirm", nil), nil];
    _updateTeamNameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [_updateTeamNameAlertView show];
}

- (void)updateTeamNick{
    _updateTeamNickAlertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"APP_YUNXIN_changeGroupNickName", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) otherButtonTitles:NSLocalizedString(@"APP_General_Confirm", nil), nil];
    _updateTeamNickAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [_updateTeamNickAlertView show];
}

- (void)updateTeamNotify
{
    NIMTeamNotifyUpdateViewController *vc = [[NIMTeamNotifyUpdateViewController alloc] initTeam:self.team];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)updateTeamIntro{
    _updateTeamIntroAlertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"APP_YUNXIN_changeGroupInfooo", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) otherButtonTitles:NSLocalizedString(@"APP_General_Confirm", nil), nil];
    _updateTeamIntroAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [_updateTeamIntroAlertView show];
}

- (void)updateTeamAnnouncement{
    NIMTeamAnnouncementListViewController *vc = [[NIMTeamAnnouncementListViewController alloc] initWithNibName:nil bundle:nil];
    vc.team = self.team;
    vc.canCreateAnnouncement = [NIMKitUtil canEditTeamInfo:self.myTeamInfo];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)quitTeam{
    _quitTeamAlertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"APP_YUNXIN_sureToOutGroupTalk", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) otherButtonTitles:NSLocalizedString(@"APP_General_Confirm", nil), nil];
    [_quitTeamAlertView show];
}

- (void)dismissTeam{
    _dismissTeamAlertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"APP_YUNXIN_sureToDisbandGroupTalk", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) otherButtonTitles:NSLocalizedString(@"APP_General_Confirm", nil), nil];
    [_dismissTeamAlertView show];
}


- (void)changeAuthMode{
    _authActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"APP_YUNXIN_changelimitWays", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"APP_YUNXIN_limitAllPerson", nil),NSLocalizedString(@"APP_YUNXIN_NeedYanzheng", nil),NSLocalizedString(@"APP_YUNXIN_refuseAllPerson", nil), nil];
    [_authActionSheet showInView:self.view];
}

- (void)changeInviteMode{
    _inviteActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"APP_YUNXIN_groupInviteJoin", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"APP_YUNXIN_groupAdminInvite", nil),NSLocalizedString(@"APP_YUNXIN_groupNormalInvite", nil), nil];
    [_inviteActionSheet showInView:self.view];
}

- (void)changeUpdateInfoMode{
    _updateInfoActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"APP_YUNXIN_groupInfoChangeLiimt", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"APP_YUNXIN_groupInfoAdminChange", nil),NSLocalizedString(@"APP_YUNXIN_groupInfoAllChange", nil), nil];
    [_updateInfoActionSheet showInView:self.view];
}

- (void)changeBeInviteMode{
    _beInviteActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"APP_YUNXIN_invitedpersonAjax", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"APP_YUNXIN_NeedYanzheng", nil),NSLocalizedString(@"APP_YUNXIN_notNeedYanzheng", nil), nil];
    [_beInviteActionSheet showInView:self.view];
}


- (NSString*)joinModeText:(NIMTeamJoinMode)mode{
    switch (mode) {
        case NIMTeamJoinModeNoAuth:
            return NSLocalizedString(@"APP_YUNXIN_limitAllPerson", nil);
        case NIMTeamJoinModeNeedAuth:
            return NSLocalizedString(@"APP_YUNXIN_NeedYanzheng", nil);
        case NIMTeamJoinModeRejectAll:
            return NSLocalizedString(@"APP_YUNXIN_refuseAllPerson", nil);
        default:
            break;
    }
}

- (NSString*)inviteModeText:(NIMTeamInviteMode)mode{
    switch (mode) {
        case NIMTeamInviteModeManager:
            return NSLocalizedString(@"APP_YUNXIN_groupAdmin", nil);
        case NIMTeamInviteModeAll:
            return NSLocalizedString(@"APP_YUNXIN_AllofPerson", nil);
        default:
            return NSLocalizedString(@"APP_YUNXIN_unKnowLimit", nil);
    }
}

- (NSString*)updateInfoModeText:(NIMTeamUpdateInfoMode)mode{
    switch (mode) {
        case NIMTeamUpdateInfoModeManager:
            return NSLocalizedString(@"APP_YUNXIN_groupAdmin", nil);
        case NIMTeamUpdateInfoModeAll:
            return NSLocalizedString(@"APP_YUNXIN_AllofPerson", nil);
        default:
            return NSLocalizedString(@"APP_YUNXIN_unKnowLimit", nil);
    }
}

- (NSString*)beInviteModeText:(NIMTeamBeInviteMode)mode{
    switch (mode) {
        case NIMTeamBeInviteModeNeedAuth:
            return NSLocalizedString(@"APP_YUNXIN_NeedYanzheng", nil);
        case NIMTeamBeInviteModeNoAuth:
            return NSLocalizedString(@"APP_YUNXIN_notNeedYanzheng", nil);
        default:
            return NSLocalizedString(@"APP_YUNXIN_unKnow", nil);
    }
}


- (void)enterMemberCard{
    NIMTeamMemberListViewController *vc = [[NIMTeamMemberListViewController alloc] initTeam:self.team members:self.memberData];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onStateChanged:(BOOL)on
{
    __weak typeof(self) weakSelf = self;
    [[[NIMSDK sharedSDK] teamManager] updateNotifyState:on
                                                 inTeam:[self.team teamId]
                                             completion:^(NSError *error) {
                                                 if (error) {
                                                     [weakSelf.view makeToast:[NSString stringWithFormat:@"Error  error:%zd",error.code]
                                                                            duration:2
                                                                            position:CSToastPositionCenter];
                                                 }
                                                 [weakSelf reloadData];
                                             }];
}


#pragma mark - NIMAdvancedTeamMemberCellActionDelegate

- (void)didSelectAddOpeartor{
    NSMutableArray *users = [[NSMutableArray alloc] init];
    for (NIMTeamMember *member in self.memberData) {
        [users addObject:member.userId];
    }
    NSString *currentUserID = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    [users addObject:currentUserID];
    
    NIMContactFriendSelectConfig *config = [[NIMContactFriendSelectConfig alloc] init];
    config.filterIds = users;
    config.needMutiSelected = YES;
    NIMContactSelectViewController *vc = [[NIMContactSelectViewController alloc] initWithConfig:config];
    vc.delegate = self;
    [vc show];
}


#pragma mark - ContactSelectDelegate
- (void)didFinishedSelect:(NSArray *)selectedContacts{
    if (!selectedContacts.count) {
        return;
    }
    NSString *postscript = NSLocalizedString(@"APP_YUNXIN_Contact_inviteUjoinInTheGroup", nil);
    [[NIMSDK sharedSDK].teamManager addUsers:selectedContacts toTeam:self.team.teamId postscript:postscript completion:^(NSError *error, NSArray *members) {
        if (!error) {
            [self.view makeToast:NSLocalizedString(@"APP_YUNXIN_groupInviteSuccess", nil)
                               duration:2
                               position:CSToastPositionCenter];
        }else{
            [self.view makeToast:[NSString stringWithFormat:@"%@ code:%zd",NSLocalizedString(@"APP_YUNXIN_groupInviteFailed", nil),error.code]
                               duration:2
                               position:CSToastPositionCenter];
        }
    }];
}

- (void)didCancelledSelect{
    
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView == _updateTeamNameAlertView) {
        [self updateTeamNameAlert:buttonIndex];
    }
    else if (alertView == _updateTeamNickAlertView) {
        [self updateTeamNickAlert:buttonIndex];
    }
    else if (alertView == _updateTeamIntroAlertView) {
        [self updateTeamIntroAlert:buttonIndex];
    }
    else if (alertView == _quitTeamAlertView) {
        [self quitTeamAlert:buttonIndex];
    }
    else if (alertView == _dismissTeamAlertView) {
        [self dismissTeamAlert:buttonIndex];
    }
}

- (void)updateTeamNameAlert:(NSInteger)index{
    switch (index) {
        case 0://取消
            break;
        case 1:{
            NSString *name = [_updateTeamNameAlertView textFieldAtIndex:0].text;
            if (name.length) {
                
                [[NIMSDK sharedSDK].teamManager updateTeamName:name teamId:self.team.teamId completion:^(NSError *error) {
                    if (!error) {
                        self.team.teamName = name;
                        [self.view makeToast:NSLocalizedString(@"APP_YUNXIN_pw_changeSuccess", nil) duration:2
                                           position:CSToastPositionCenter];
                        [self reloadData];
                    }else{
                        [self.view makeToast:[NSString stringWithFormat:@"Error  code:%zd",error.code] duration:2
                                           position:CSToastPositionCenter];
                    }
                }];
            }
            break;
        }
        default:
            break;
    }
}

- (void)updateTeamNickAlert:(NSInteger)index{
    switch (index) {
        case 0://取消
            break;
        case 1:{
            NSString *name = [_updateTeamNickAlertView textFieldAtIndex:0].text;
            NSString *currentUserId = [NIMSDK sharedSDK].loginManager.currentAccount;
            [[NIMSDK sharedSDK].teamManager updateUserNick:currentUserId newNick:name inTeam:self.team.teamId completion:^(NSError *error) {
                if (!error) {
                    self.myTeamInfo.nickname = name;
                    [self.view makeToast:NSLocalizedString(@"APP_YUNXIN_pw_changeSuccess", nil)];
                    [self reloadData];
                }else{
                    [self.view makeToast:[NSString stringWithFormat:@"Error code:%zd",error.code]];
                }
            }];
            break;
        }
        default:
            break;
    }
}

- (void)updateTeamIntroAlert:(NSInteger)index{
    switch (index) {
        case 0://取消
            break;
        case 1:{
            NSString *intro = [_updateTeamIntroAlertView textFieldAtIndex:0].text;
            [[NIMSDK sharedSDK].teamManager updateTeamIntro:intro teamId:self.team.teamId completion:^(NSError *error) {
                if (!error) {
                    self.team.intro = intro;
                    [self.view makeToast:NSLocalizedString(@"APP_YUNXIN_pw_changeSuccess", nil)];
                    [self reloadData];
                }else{
                    [self.view makeToast:[NSString stringWithFormat:@"Error code:%zd",error.code]];
                }
            }];
            break;
        }
        default:
            break;
    }
}

- (void)quitTeamAlert:(NSInteger)index{
    switch (index) {
        case 0://取消
            break;
        case 1:{
            [[NIMSDK sharedSDK].teamManager quitTeam:self.team.teamId completion:^(NSError *error) {
                if (!error) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }else{
                    [self.view makeToast:[NSString stringWithFormat:@"Error code:%zd",error.code]];
                }
            }];
            break;
        }
        default:
            break;
    }

}

- (void)dismissTeamAlert:(NSInteger)index{
    switch (index) {
        case 0://取消
            break;
        case 1:{
            [[NIMSDK sharedSDK].teamManager dismissTeam:self.team.teamId completion:^(NSError *error) {
                if (!error) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }else{
                    [self.view makeToast:[NSString stringWithFormat:@"Error code:%zd",error.code]];
                }
            }];
            break;
        }
        default:
            break;
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)index{
    if (actionSheet == _moreActionSheet) {
        [self ontransferActionSheet:actionSheet index:index];
    }
    else if (actionSheet == _authActionSheet) {
        [self onAuthActionSheet:actionSheet index:index];
    }
    else if (actionSheet == _inviteActionSheet) {
        [self onInviteActionSheet:actionSheet index:index];
    }
    else if (actionSheet == _updateInfoActionSheet) {
        [self onUpdateInfoActionSheet:actionSheet index:index];
    }
    else if (actionSheet == _beInviteActionSheet)
    {
        [self onBeInviteActionSheet:actionSheet index:index];
    }
    else if (actionSheet == _avatarActionSheet)
    {
        [self onAvatarActionSheet:actionSheet index:index];
    }
}

- (void)onAvatarActionSheet:(UIActionSheet *)actionSheet index:(NSInteger)index
{
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
}

- (void)showImagePicker:(UIImagePickerControllerSourceType)type{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate      = self;
    picker.sourceType    = type;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)ontransferActionSheet:(UIActionSheet *)actionSheet index:(NSInteger)index
{
    BOOL isLeave = NO;
    switch (index) {
        case 0:{
            isLeave = NO;
            break;
        case 1:
            isLeave = YES;
            break;
        }
        default:
            return;
            break;
    }
    __weak typeof(self) wself = self;
    __block ContactSelectFinishBlock finishBlock =  ^(NSArray * memeber){
        [[NIMSDK sharedSDK].teamManager transferManagerWithTeam:wself.team.teamId newOwnerId:memeber.firstObject isLeave:isLeave completion:^(NSError *error) {
            if (!error) {
                [wself.view makeToast:NSLocalizedString(@"APP_YUNXIN_tranToSuccess", nil) duration:2.0 position:CSToastPositionCenter];
                if (isLeave) {
                    [wself.navigationController popToRootViewControllerAnimated:YES];
                }else{
                    [wself reloadData];
                }
            }else{
                [wself.view makeToast:[NSString stringWithFormat:@"error ！code:%zd",error.code] duration:2.0 position:CSToastPositionCenter];
            }
        }];
    };
    NSString *currentUserID = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    NIMContactTeamMemberSelectConfig *config = [[NIMContactTeamMemberSelectConfig alloc] init];
    config.teamId = self.team.teamId;
    config.filterIds = @[currentUserID];
    NIMContactSelectViewController *vc = [[NIMContactSelectViewController alloc] initWithConfig:config];
    vc.finshBlock = finishBlock;
    [vc show];
}

- (void)onAuthActionSheet:(UIActionSheet *)actionSheet index:(NSInteger)index
{
    if (index == _authActionSheet.cancelButtonIndex) {
        return;
    }
    [[NIMSDK sharedSDK].teamManager updateTeamJoinMode:index teamId:self.team.teamId completion:^(NSError *error) {
        if (!error) {
            self.team.joinMode = index;
            [self.view makeToast:NSLocalizedString(@"APP_YUNXIN_pw_changeSuccess", nil)];
            [self reloadData];
        }else{
            [self.view makeToast:[NSString stringWithFormat:@"Error code:%zd",error.code]];
        }
    }];
}

- (void)onInviteActionSheet:(UIActionSheet *)actionSheet index:(NSInteger)index
{
    NIMTeamInviteMode mode;
    switch (index) {
        case 0:
            mode = NIMTeamInviteModeManager;
            break;
        case 1:
            mode = NIMTeamInviteModeAll;
            break;
        default:
            return;
    }
    [[NIMSDK sharedSDK].teamManager updateTeamInviteMode:mode teamId:self.team.teamId completion:^(NSError *error) {
        if (!error) {
            self.team.inviteMode = mode;
            [self.view makeToast:NSLocalizedString(@"APP_YUNXIN_pw_changeSuccess", nil)];
            [self reloadData];
        }else{
            [self.view makeToast:[NSString stringWithFormat:@"Error code:%zd",error.code]];
        }
    }];
}

- (void)onUpdateInfoActionSheet:(UIActionSheet *)actionSheet index:(NSInteger)index
{
    NIMTeamUpdateInfoMode mode;
    switch (index) {
        case 0:
            mode = NIMTeamUpdateInfoModeManager;
            break;
        case 1:
            mode = NIMTeamUpdateInfoModeAll;
            break;
        default:
            return;
    }
    [[NIMSDK sharedSDK].teamManager updateTeamUpdateInfoMode:mode teamId:self.team.teamId completion:^(NSError *error) {
        if (!error) {
            self.team.updateInfoMode = mode;
            [self.view makeToast:NSLocalizedString(@"APP_YUNXIN_pw_changeSuccess", nil)];
            [self reloadData];
        }else{
            [self.view makeToast:[NSString stringWithFormat:@"Error code:%zd",error.code]];
        }
    }];
}

- (void)onBeInviteActionSheet:(UIActionSheet *)actionSheet index:(NSInteger)index
{
    NIMTeamBeInviteMode mode;
    switch (index) {
        case 0:
            mode = NIMTeamBeInviteModeNeedAuth;
            break;
        case 1:
            mode = NIMTeamBeInviteModeNoAuth;
            break;
        default:
            return;
    }
    [[NIMSDK sharedSDK].teamManager updateTeamBeInviteMode:mode teamId:self.team.teamId completion:^(NSError *error) {
        if (!error) {
            self.team.beInviteMode = mode;
            [self.view makeToast:NSLocalizedString(@"APP_YUNXIN_pw_changeSuccess", nil)];
            [self reloadData];
        }else{
            [self.view makeToast:[NSString stringWithFormat:@"Error code:%zd",error.code]];
        }
    }];
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


#pragma mark - Private
- (void)uploadImage:(UIImage *)image{
    UIImage *imageForAvatarUpload = [image nim_imageForAvatarUpload];
    NSString *fileName = [[[[NSUUID UUID] UUIDString] lowercaseString] stringByAppendingPathExtension:@"jpg"];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    NSData *data = UIImageJPEGRepresentation(imageForAvatarUpload, 1.0);
    BOOL success = data && [data writeToFile:filePath atomically:YES];
    __weak typeof(self) wself = self;
    if (success) {
        [NIMKitProgressHUD show];
        [[NIMSDK sharedSDK].resourceManager upload:filePath progress:nil completion:^(NSString *urlString, NSError *error) {
            [NIMKitProgressHUD dismiss];
            if (!error && wself) {
                [[NIMSDK sharedSDK].teamManager updateTeamAvatar:urlString teamId:wself.team.teamId completion:^(NSError *error) {
                    if (!error) {
                        wself.team.avatarUrl = urlString;
                        [[SDWebImageManager sharedManager] saveImageToCache:imageForAvatarUpload forURL:[NSURL URLWithString:urlString]];
                        NIMAdvancedTeamCardHeaderView *headerView = (NIMAdvancedTeamCardHeaderView *)wself.tableView.tableHeaderView;
                        [headerView refresh];
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
    NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[reloadIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - 旋转处理 (iOS8 or above)
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[reloadIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } completion:nil];
}



@end


