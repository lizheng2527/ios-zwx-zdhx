//
//  NTESSystemNotificationCell.m
//  NIM
//
//  Created by amao on 3/17/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NTESSystemNotificationCell.h"
#import "NTESSessionUtil.h"
#import "UIView+NTES.h"
#import "NIMAvatarImageView.h"

@interface NTESSystemNotificationCell ()
@property (nonatomic,strong) IBOutlet UILabel *messageLabel;
@property (nonatomic,strong) NIMSystemNotification *notification;
@property (nonatomic,strong) IBOutlet NIMAvatarImageView *avatarImageView;
@end

@implementation NTESSystemNotificationCell

- (void)awakeFromNib{
    [super awakeFromNib];
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.avatarImageView = [[NIMAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self addSubview:self.avatarImageView];
}

- (void)update:(NIMSystemNotification *)notification{
    self.notification = notification;
    [self updateUI];
}

- (void)updateUI{
    BOOL hideActionButton = [self shouldHideActionButton];

    [self.acceptButton setHidden:hideActionButton];
    [self.refuseButton setHidden:hideActionButton];
    if(hideActionButton) {
        self.handleInfoLabel.hidden = NO;
        switch (self.notification.handleStatus) {
            case NotificationHandleTypeOk:
                 self.handleInfoLabel.text = NSLocalizedString(@"APP_YUNXIN_haveAgree", nil);
                break;
            case NotificationHandleTypeNo:
                self.handleInfoLabel.text = NSLocalizedString(@"APP_YUNXIN_haveRefuse", nil);
                break;
            case NotificationHandleTypeOutOfDate:
                self.handleInfoLabel.text = NSLocalizedString(@"APP_MyHomeWork_HasExpired", nil);
                break;
            default:
                self.handleInfoLabel.text = nil;
                break;
        }
    } else {
        self.handleInfoLabel.hidden = YES;
    }


    NSString *sourceID = self.notification.sourceID;
    NIMKitInfo *sourceMember = [[NIMKit sharedKit] infoByUser:sourceID option:nil];
    [self updateSourceMember:sourceMember];
}

- (void)updateSourceMember:(NIMKitInfo *)sourceMember{
    NIMSystemNotificationType type = self.notification.type;
    NSString *avatarUrlString = sourceMember.avatarUrlString;
    NSURL *url;
    if (avatarUrlString.length) {
        url = [NSURL URLWithString:avatarUrlString];
    }
    [self.avatarImageView nim_setImageWithURL:url placeholderImage:sourceMember.avatarImage options:SDWebImageRetryFailed];
    self.textLabel.text        = sourceMember.showName;
    [self.textLabel sizeToFit];
    switch (type) {
        case NIMSystemNotificationTypeTeamApply:
        {
            NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:self.notification.targetID];
            self.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"APP_YUNXIN_tip_applyUJoin", nil) ,team.teamName];
        }
            break;
        case NIMSystemNotificationTypeTeamApplyReject:
        {
            NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:self.notification.targetID];
            
            self.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ ",NSLocalizedString(@"APP_YUNXIN_Contact_group", nil), team.teamName,NSLocalizedString(@"APP_YUNXIN_tip_refuseUjoin", nil)];
        }
            break;
        case NIMSystemNotificationTypeTeamInvite:
        {
            NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:self.notification.targetID];
            self.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"APP_YUNXIN_Contact_group", nil),team.teamName,NSLocalizedString(@"APP_YUNXIN_tip_inviteUjoin", nil)];
        }
            break;
        case NIMSystemNotificationTypeTeamIviteReject:
        {
            NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:self.notification.targetID];
            self.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ %@",NSLocalizedString(@"APP_YUNXIN_tip_refuseGroup", nil), team.teamName,NSLocalizedString(@"APP_YUNXIN_tip_invitationnn", nil) ];
        }
            break;
        case NIMSystemNotificationTypeFriendAdd:
        {
            NSString *text = NSLocalizedString(@"APP_YUNXIN_tip_unknowMessageRequest", nil);
            id object = self.notification.attachment;
            if ([object isKindOfClass:[NIMUserAddAttachment class]]) {
                NIMUserOperation operation = [(NIMUserAddAttachment *)object operationType];
                switch (operation) {
                    case NIMUserOperationAdd:
                        text = NSLocalizedString(@"APP_YUNXIN_tip_hasAddFried", nil);
                        break;
                    case NIMUserOperationRequest:
                        text = NSLocalizedString(@"APP_YUNXIN_tip_requestAddFriend", nil);
                        break;
                    case NIMUserOperationVerify:
                        text = NSLocalizedString(@"APP_YUNXIN_tip_passFriend", nil);
                        break;
                    case NIMUserOperationReject:
                        text = NSLocalizedString(@"APP_YUNXIN_tip_refuseFriend", nil);
                        break;
                    default:
                        break;
                }
            }
            self.detailTextLabel.text = text;
        }
            break;
        default:
            break;
    }
    [self.detailTextLabel sizeToFit];
    self.messageLabel.text = self.notification.postscript;
    [self.messageLabel sizeToFit];
    [self setNeedsLayout];
}

- (IBAction)onAccept:(id)sender {
    if (_actionDelegate && [_actionDelegate respondsToSelector:@selector(onAccept:)]){
        [_actionDelegate onAccept:self.notification];
    }
}
- (IBAction)onRefuse:(id)sender {
    if (_actionDelegate && [_actionDelegate respondsToSelector:@selector(onRefuse:)]){
        [_actionDelegate onRefuse:self.notification];
    }
}

- (BOOL)shouldHideActionButton
{
    NIMSystemNotificationType type = self.notification.type;
    BOOL handled = self.notification.handleStatus != 0;
    BOOL needHandle = NO;
    if (type == NIMSystemNotificationTypeTeamApply ||
        type == NIMSystemNotificationTypeTeamInvite) {
        needHandle = YES;
    }
    if (type == NIMSystemNotificationTypeFriendAdd) {
        id object = self.notification.attachment;
        if ([object isKindOfClass:[NIMUserAddAttachment class]]) {
            NIMUserOperation operation = [(NIMUserAddAttachment *)object operationType];
            needHandle = operation == NIMUserOperationRequest;
        }
    }
    return !(!handled && needHandle);
    
}

#define MaxTextLabelWidth 120.0 * UISreenWidthScale
#define MaxDetailLabelWidth 160.0 * UISreenWidthScale
#define MaxMessageLabelWidth 150.0 * UISreenWidthScale
#define TextLabelAndMessageLabelSpacing 20.f
#define AvatarImageViewLeft 15.f
#define MessageAndAvatarSpacing 15.f
- (void)layoutSubviews{
    [super layoutSubviews];
    self.avatarImageView.centerY = self.height * .5f;
    self.avatarImageView.left = AvatarImageViewLeft;
    if (self.textLabel.width > MaxTextLabelWidth) {
        self.textLabel.width = MaxTextLabelWidth;
    }
    if (self.detailTextLabel.width > MaxDetailLabelWidth) {
        self.detailTextLabel.width = MaxDetailLabelWidth;
    }
    self.textLabel.left = self.avatarImageView.right + MessageAndAvatarSpacing;
    self.detailTextLabel.left = self.textLabel.left;
    self.detailTextLabel.bottom = self.avatarImageView.bottom;
    
    if (self.messageLabel.width > MaxMessageLabelWidth) {
        self.messageLabel.width = MaxMessageLabelWidth;
    }
    self.messageLabel.left = self.textLabel.right + TextLabelAndMessageLabelSpacing;

}

@end
