//
//  NIMUtil.m
//  NIMKit
//
//  Created by chris on 15/8/10.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NIMKitUtil.h"
#import "NIMKit.h"
#import "NIMKitInfoFetchOption.h"

@implementation NIMKitUtil

+ (NSString *)genFilenameWithExt:(NSString *)ext
{
    CFUUIDRef uuid = CFUUIDCreate(nil);
    NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuid);
    CFRelease(uuid);
    NSString *uuidStr = [[uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    NSString *name = [NSString stringWithFormat:@"%@",uuidStr];
    return [ext length] ? [NSString stringWithFormat:@"%@.%@",name,ext]:name;
}

+ (NSString *)showNick:(NSString*)uid inMessage:(NIMMessage*)message
{
    if (!uid.length) {
        return nil;
    }
    NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
    option.message = message;
    if (message.messageType == NIMMessageTypeRobot)
    {
        NIMRobotObject *object = (NIMRobotObject *)message.messageObject;
        if (object.isFromRobot) {
            return [[NIMKit sharedKit] infoByUser:object.robotId option:option].showName;
        }
    }
    return [[NIMKit sharedKit] infoByUser:uid option:option].showName;
}

+ (NSString *)showNick:(NSString*)uid inSession:(NIMSession*)session{
    if (!uid.length) {
        return nil;
    }
    NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
    option.session = session;
    return [[NIMKit sharedKit] infoByUser:uid option:option].showName;
}


+ (NSString*)showTime:(NSTimeInterval) msglastTime showDetail:(BOOL)showDetail
{
    //今天的时间
    NSDate * nowDate = [NSDate date];
    NSDate * msgDate = [NSDate dateWithTimeIntervalSince1970:msglastTime];
    NSString *result = nil;
    NSCalendarUnit components = (NSCalendarUnit)(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour | NSCalendarUnitMinute);
    NSDateComponents *nowDateComponents = [[NSCalendar currentCalendar] components:components fromDate:nowDate];
    NSDateComponents *msgDateComponents = [[NSCalendar currentCalendar] components:components fromDate:msgDate];
    
    NSInteger hour = msgDateComponents.hour;
    double OnedayTimeIntervalValue = 24*60*60;  //一天的秒数

    result = [NIMKitUtil getPeriodOfTime:hour withMinute:msgDateComponents.minute];
    if (hour > 12)
    {
        hour = hour - 12;
    }
    
    BOOL isSameMonth = (nowDateComponents.year == msgDateComponents.year) && (nowDateComponents.month == msgDateComponents.month);
    
    if(isSameMonth && (nowDateComponents.day == msgDateComponents.day)) //同一天,显示时间
    {
        result = [[NSString alloc] initWithFormat:@"%@ %zd:%02d",result,hour,(int)msgDateComponents.minute];
    }
    else if(isSameMonth && (nowDateComponents.day == (msgDateComponents.day+1)))//昨天
    {
        result = showDetail?  [[NSString alloc] initWithFormat:@"%@%@ %zd:%02d",NSLocalizedString(@"APP_YUNXIN_yesTerday", nil),result,hour,(int)msgDateComponents.minute] : NSLocalizedString(@"APP_YUNXIN_yesTerday", nil);
    }
    else if(isSameMonth && (nowDateComponents.day == (msgDateComponents.day+2))) //前天
    {
        result = showDetail? [[NSString alloc] initWithFormat:@"%@%@ %zd:%02d",NSLocalizedString(@"APP_YUNXIN_qiantian", nil),result,hour,(int)msgDateComponents.minute] : NSLocalizedString(@"APP_YUNXIN_qiantian", nil);
    }
    else if([nowDate timeIntervalSinceDate:msgDate] < 7 * OnedayTimeIntervalValue)//一周内
    {
        NSString *weekDay = [NIMKitUtil weekdayStr:msgDateComponents.weekday];
        result = showDetail? [weekDay stringByAppendingFormat:@"%@ %zd:%02d",result,hour,(int)msgDateComponents.minute] : weekDay;
    }
    else//显示日期
    {
        NSString *day = [NSString stringWithFormat:@"%zd-%zd-%zd", msgDateComponents.year, msgDateComponents.month, msgDateComponents.day];
        result = showDetail? [day stringByAppendingFormat:@"%@ %zd:%02d",result,hour,(int)msgDateComponents.minute]:day;
    }
    return result;
}

#pragma mark - Private

+ (NSString *)getPeriodOfTime:(NSInteger)time withMinute:(NSInteger)minute
{
    NSInteger totalMin = time *60 + minute;
    NSString *showPeriodOfTime = @"";
    if (totalMin > 0 && totalMin <= 5 * 60)
    {
        showPeriodOfTime = NSLocalizedString(@"APP_YUNXIN_midnight", nil);
    }
    else if (totalMin > 5 * 60 && totalMin < 12 * 60)
    {
        showPeriodOfTime = NSLocalizedString(@"APP_YUNXIN_morning", nil);
    }
    else if (totalMin >= 12 * 60 && totalMin <= 18 * 60)
    {
        showPeriodOfTime = NSLocalizedString(@"APP_YUNXIN_afternoon", nil);
    }
    else if ((totalMin > 18 * 60 && totalMin <= (23 * 60 + 59)) || totalMin == 0)
    {
        showPeriodOfTime = NSLocalizedString(@"APP_YUNXIN_evening", nil);
    }
    return showPeriodOfTime;
}

+(NSString*)weekdayStr:(NSInteger)dayOfWeek
{
    static NSDictionary *daysOfWeekDict = nil;
    daysOfWeekDict = @{@(1):NSLocalizedString(@"APP_MyHomeWork_Sunday", nil),
                       @(2):NSLocalizedString(@"APP_MyHomeWork_Mon", nil),
                       @(3):NSLocalizedString(@"APP_MyHomeWork_Tus", nil),
                       @(4):NSLocalizedString(@"APP_MyHomeWork_wens", nil),
                       @(5):NSLocalizedString(@"APP_MyHomeWork_Ths", nil),
                       @(6):NSLocalizedString(@"APP_MyHomeWork_fri", nil),
                       @(7):NSLocalizedString(@"APP_MyHomeWork_sat", nil),};
    
    return [daysOfWeekDict objectForKey:@(dayOfWeek)];
}


+ (NSString *)messageTipContent:(NIMMessage *)message{
    
    NSString *text = nil;
    
    if (text == nil) {
        switch (message.messageType) {
            case NIMMessageTypeNotification:
                text =  [NIMKitUtil notificationMessage:message];
                break;
            case NIMMessageTypeTip:
                text = message.text;
                break;
            default:
                break;
        }
    }
    return text;
}


+ (NSString *)notificationMessage:(NIMMessage *)message{
    NIMNotificationObject *object = message.messageObject;
    switch (object.notificationType) {
        case NIMNotificationTypeTeam:{
            return [NIMKitUtil teamNotificationFormatedMessage:message];
        }
        case NIMNotificationTypeNetCall:{
            return [NIMKitUtil netcallNotificationFormatedMessage:message];
        }
        case NIMNotificationTypeChatroom:{
            return [NIMKitUtil chatroomNotificationFormatedMessage:message];
        }
        default:
            return @"";
    }
}


+ (NSString*)teamNotificationFormatedMessage:(NIMMessage *)message{
    NSString *formatedMessage = @"";
    NIMNotificationObject *object = message.messageObject;
    if (object.notificationType == NIMNotificationTypeTeam)
    {
        NIMTeamNotificationContent *content = (NIMTeamNotificationContent*)object.content;
        NSString *source = [NIMKitUtil teamNotificationSourceName:message];
        NSArray *targets = [NIMKitUtil teamNotificationTargetNames:message];
        NSString *targetText = [targets count] > 1 ? [targets componentsJoinedByString:@","] : [targets firstObject];
        NSString *teamName = [NIMKitUtil teamNotificationTeamShowName:message];
        
        switch (content.operationType) {
            case NIMTeamOperationTypeInvite:{
                NSString *str = [NSString stringWithFormat:@"%@%@%@",source,NSLocalizedString(@"APP_YUNXIN_invite", nil) ,targets.firstObject];
                if (targets.count>1) {
                    str = [str stringByAppendingFormat:@"等%zd人",targets.count];
                }
                str = [str stringByAppendingFormat:@"%@%@",NSLocalizedString(@"APP_YUNXIN_tip_jinrule", nil),teamName];
                formatedMessage = str;
            }
                break;
            case NIMTeamOperationTypeDismiss:
                formatedMessage = [NSString stringWithFormat:@"%@%@%@",source,NSLocalizedString(@"APP_YUNXIN_tip_jielanle", nil),teamName];
                break;
            case NIMTeamOperationTypeKick:{
                NSString *str = [NSString stringWithFormat:@"%@将%@",source,targets.firstObject];
                if (targets.count>1) {
                    str = [str stringByAppendingFormat:@"等%zd人",targets.count];
                }
                str = [str stringByAppendingFormat:@"%@%@",NSLocalizedString(@"APP_YUNXIN_tip_yichule", nil) ,teamName];
                formatedMessage = str;
            }
                break;
            case NIMTeamOperationTypeUpdate:
            {
                
                id attachment = [content attachment];
                if ([attachment isKindOfClass:[NIMUpdateTeamInfoAttachment class]]) {
                    NIMUpdateTeamInfoAttachment *teamAttachment = (NIMUpdateTeamInfoAttachment *)attachment;
                    formatedMessage = [NSString stringWithFormat:@"%@%@%@%@",source,NSLocalizedString(@"APP_YUNXIN_tip_gengxinle", nil),teamName,NSLocalizedString(@"APP_YUNXIN_tip_info", nil)];
                    //如果只是单个项目项被修改则显示具体的修改项
                    if ([teamAttachment.values count] == 1) {
                        NIMTeamUpdateTag tag = [[[teamAttachment.values allKeys] firstObject] integerValue];
                        switch (tag) {
                            case NIMTeamUpdateTagName:
                                formatedMessage = [NSString stringWithFormat:@"%@%@%@",source,NSLocalizedString(@"APP_YUNXIN_tip_gengxinle", nil),teamName,NSLocalizedString(@"APP_YUNXIN_tip_name", nil)];
                                break;
                            case NIMTeamUpdateTagIntro:
                                formatedMessage = [NSString stringWithFormat:@"%@%@%@%@",source,NSLocalizedString(@"APP_YUNXIN_tip_gengxinle", nil),teamName,NSLocalizedString(@"APP_YUNXIN_tip_des", nil)];
                                break;
                            case NIMTeamUpdateTagAnouncement:
                                formatedMessage = [NSString stringWithFormat:@"%@%@%@%@",source,NSLocalizedString(@"APP_YUNXIN_tip_gengxinle", nil),teamName,NSLocalizedString(@"APP_YUNXIN_tip_note", nil)];
                                break;
                            case NIMTeamUpdateTagJoinMode:
                                formatedMessage = [NSString stringWithFormat:@"%@%@%@%@",source,NSLocalizedString(@"APP_YUNXIN_tip_gengxinle", nil),teamName,NSLocalizedString(@"APP_YUNXIN_tip_ajaxWays", nil)];
                                break;
                            case NIMTeamUpdateTagAvatar:
                                formatedMessage = [NSString stringWithFormat:@"%@%@%@",source,NSLocalizedString(@"APP_YUNXIN_tip_gengxinle", nil),teamName,NSLocalizedString(@"APP_YUNXIN_tip_headImage", nil)];
                                break;
                            case NIMTeamUpdateTagInviteMode:
                                formatedMessage = [NSString stringWithFormat:@"%@%@",source,NSLocalizedString(@"APP_YUNXIN_tip_gengxinleInviteLimit", nil)];
                                break;
                            case NIMTeamUpdateTagBeInviteMode:
                                formatedMessage = [NSString stringWithFormat:@"%@%@",source,NSLocalizedString(@"APP_YUNXIN_tip_gengxinleBeiInviteLimit", nil)];
                                break;
                            case NIMTeamUpdateTagUpdateInfoMode:
                                formatedMessage = [NSString stringWithFormat:@"%@%@",source,NSLocalizedString(@"APP_YUNXIN_UpdategroupInfoChangeLiimt", nil)];
                                break;
                            case NIMTeamUpdateTagMuteMode:{
                                NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:message.session.sessionId];
                                BOOL inAllMuteMode = [team inAllMuteMode];
                                formatedMessage = inAllMuteMode? [NSString stringWithFormat:@"%@%@",source,NSLocalizedString(@"APP_YUNXIN_tip_setAllJInYan", nil) ]: [NSString stringWithFormat:@"%@%@",source,NSLocalizedString(@"APP_YUNXIN_tip_cancelAllJInYan", nil)];
                                break;
                            }
                            default:
                                break;
                                
                        }
                    }
                }
                
                if (formatedMessage == nil){
                    formatedMessage = [NSString stringWithFormat:@"%@%@%@%@",source,NSLocalizedString(@"APP_YUNXIN_tip_gengxinle", nil) ,teamName,NSLocalizedString(@"APP_YUNXIN_tip_info", nil)];
                }
            }
                break;
            case NIMTeamOperationTypeLeave:
                formatedMessage = [NSString stringWithFormat:@"%@%@%@",source, NSLocalizedString(@"APP_YUNXIN_tip_laikaile", nil),teamName];
                break;
            case NIMTeamOperationTypeApplyPass:{
                if ([source isEqualToString:targetText]) {
                    //说明是以不需要验证的方式进入
                    formatedMessage = [NSString stringWithFormat:@"%@%@%@",source,NSLocalizedString(@"APP_YUNXIN_tip_jinrule", nil),teamName];
                }else{
                    
                    formatedMessage = [NSString stringWithFormat:@"%@%@%@的%@",source,NSLocalizedString(@"APP_YUNXIN_tip_tongguole", nil) ,targetText,NSLocalizedString(@"APP_YUNXIN_tip_invitation", nil)];
                }
            }
                break;
            case NIMTeamOperationTypeTransferOwner:
                formatedMessage = [NSString stringWithFormat:@"%@%@%@",source,NSLocalizedString(@"APP_YUNXIN_tip_zhuanyiAdminTo", nil) ,targetText];
                break;
            case NIMTeamOperationTypeAddManager:
                formatedMessage = [NSString stringWithFormat:@"%@%@",targetText,NSLocalizedString(@"APP_YUNXIN_tip_addToAdmin", nil)];
                break;
            case NIMTeamOperationTypeRemoveManager:
                formatedMessage = [NSString stringWithFormat:@"%@%@",targetText,NSLocalizedString(@"APP_YUNXIN_tip_removeAdmin", nil)];
                break;
            case NIMTeamOperationTypeAcceptInvitation:
                formatedMessage = [NSString stringWithFormat:@"%@%@%@%@",source,NSLocalizedString(@"APP_YUNXIN_tip_accept", nil) ,targetText,NSLocalizedString(@"APP_YUNXIN_tip_deyaoqing", nil) ];
                break;
            case NIMTeamOperationTypeMute:{
                id attachment = [content attachment];
                if ([attachment isKindOfClass:[NIMMuteTeamMemberAttachment class]])
                {
                    BOOL mute = [(NIMMuteTeamMemberAttachment *)attachment flag];
                    NSString *muteStr = mute? NSLocalizedString(@"APP_YUNXIN_tip_JInyan", nil) : NSLocalizedString(@"APP_YUNXIN_tip_jiechuDanrenJInyan", nil);
                    NSString *str = [targets componentsJoinedByString:@","];
                    formatedMessage = [NSString stringWithFormat:@"%@%@%@%@",str,NSLocalizedString(@"APP_YUNXIN_tip_Be", nil) ,source,muteStr];
                }
            }
                break;
            default:
                break;
        }
        
    }
    if (!formatedMessage.length) {
        formatedMessage = [NSString stringWithFormat:NSLocalizedString(@"APP_YUNXIN_tip_unknowSysMessage", nil)];
    }
    return formatedMessage;
}


+ (NSString *)netcallNotificationFormatedMessage:(NIMMessage *)message{
    NIMNotificationObject *object = message.messageObject;
    NIMNetCallNotificationContent *content = (NIMNetCallNotificationContent *)object.content;
    NSString *text = @"";
    NSString *currentAccount = [[NIMSDK sharedSDK].loginManager currentAccount];
    switch (content.eventType) {
        case NIMNetCallEventTypeMiss:{
            text = @"未接听";
            break;
        }
        case NIMNetCallEventTypeBill:{
            text =  ([object.message.from isEqualToString:currentAccount])? @"通话拨打时长 " : @"通话接听时长 ";
            NSTimeInterval duration = content.duration;
            NSString *durationDesc = [NSString stringWithFormat:@"%02d:%02d",(int)duration/60,(int)duration%60];
            text = [text stringByAppendingString:durationDesc];
            break;
        }
        case NIMNetCallEventTypeReject:{
            text = ([object.message.from isEqualToString:currentAccount])? @"对方正忙" : @"已拒绝";
            break;
        }
        case NIMNetCallEventTypeNoResponse:{
            text = @"未接通，已取消";
            break;
        }
        default:
            break;
    }
    return text;
}


+ (NSString *)chatroomNotificationFormatedMessage:(NIMMessage *)message{
    NIMNotificationObject *object = message.messageObject;
    NIMChatroomNotificationContent *content = (NIMChatroomNotificationContent *)object.content;
    NSMutableArray *targetNicks = [[NSMutableArray alloc] init];
    for (NIMChatroomNotificationMember *memebr in content.targets) {
        if ([memebr.userId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]]) {
           [targetNicks addObject:NSLocalizedString(@"APP_YUNXIN_tip_chatRomU", nil)];
        }else{
           [targetNicks addObject:memebr.nick];
        }

    }
    NSString *targetText =[targetNicks componentsJoinedByString:@","];
    switch (content.eventType) {
        case NIMChatroomEventTypeEnter:
        {
            return [NSString stringWithFormat:@"欢迎%@进入直播间",targetText];
        }
        case NIMChatroomEventTypeAddBlack:
        {
            return [NSString stringWithFormat:@"%@被管理员拉入黑名单",targetText];
        }
        case NIMChatroomEventTypeRemoveBlack:
        {
            return [NSString stringWithFormat:@"%@被管理员解除拉黑",targetText];
        }
        case NIMChatroomEventTypeAddMute:
        {
            if (content.targets.count == 1 && [[content.targets.firstObject userId] isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]])
            {
                return NSLocalizedString(@"APP_YUNXIN_tip_UbeiJInyan", nil);
            }
            else
            {
                return [NSString stringWithFormat:@"%@被管理员禁言",targetText];
            }
        }
        case NIMChatroomEventTypeRemoveMute:
        {
            return [NSString stringWithFormat:@"%@被管理员解除禁言",targetText];
        }
        case NIMChatroomEventTypeAddManager:
        {
            return [NSString stringWithFormat:@"%@被任命管理员身份",targetText];
        }
        case NIMChatroomEventTypeRemoveManager:
        {
            return [NSString stringWithFormat:@"%@被解除管理员身份",targetText];
        }
        case NIMChatroomEventTypeRemoveCommon:
        {
            return [NSString stringWithFormat:@"%@被解除直播室成员身份",targetText];
        }
        case NIMChatroomEventTypeAddCommon:
        {
            return [NSString stringWithFormat:@"%@被添加为直播室成员身份",targetText];
        }
        case NIMChatroomEventTypeInfoUpdated:
        {
            return [NSString stringWithFormat:@"直播间公告已更新"];
        }
        case NIMChatroomEventTypeKicked:
        {
            return [NSString stringWithFormat:@"%@被管理员移出直播间",targetText];
        }
        case NIMChatroomEventTypeExit:
        {
            return [NSString stringWithFormat:@"%@离开了直播间",targetText];
        }
        case NIMChatroomEventTypeClosed:
        {
            return [NSString stringWithFormat:@"直播间已关闭"];
        }
        case NIMChatroomEventTypeAddMuteTemporarily:
        {
            if (content.targets.count == 1 && [[content.targets.firstObject userId] isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]])
            {
                return NSLocalizedString(@"APP_YUNXIN_tip_UbeiJInyan", nil);
            }
            else
            {
                return [NSString stringWithFormat:@"%@%@",targetText,NSLocalizedString(@"APP_YUNXIN_tip_beiJInyan", nil)];
            }
        }
        case NIMChatroomEventTypeRemoveMuteTemporarily:
        {
            return [NSString stringWithFormat:@"%@%@",targetText,NSLocalizedString(@"APP_YUNXIN_tip_linshiJInyan", nil)];
        }
        case NIMChatroomEventTypeMemberUpdateInfo:
        {
            return [NSString stringWithFormat:@"%@%@",targetText,NSLocalizedString(@"APP_YUNXIN_tip_updateUserInfo", nil)];
        }
        case NIMChatroomEventTypeRoomMuted:
        {
            return NSLocalizedString(@"APP_YUNXIN_tip_jinYanButAdmin", nil);
        }
        case NIMChatroomEventTypeRoomUnMuted:
        {
            return NSLocalizedString(@"APP_YUNXIN_tip_jiechuJinYan", nil);
        }
        default:
            break;
    }
    return @"";
}


#pragma mark - Private
+ (NSString *)teamNotificationSourceName:(NIMMessage *)message{
    NSString *source;
    NIMNotificationObject *object = message.messageObject;
    NIMTeamNotificationContent *content = (NIMTeamNotificationContent*)object.content;
    NSString *currentAccount = [[NIMSDK sharedSDK].loginManager currentAccount];
    if ([content.sourceID isEqualToString:currentAccount]) {
        source = NSLocalizedString(@"APP_YUNXIN_tip_U", nil);
    }else{
        source = [NIMKitUtil showNick:content.sourceID inSession:message.session];
    }
    return source;
}

+ (NSArray *)teamNotificationTargetNames:(NIMMessage *)message{
    NSMutableArray *targets = [[NSMutableArray alloc] init];
    NIMNotificationObject *object = message.messageObject;
    NIMTeamNotificationContent *content = (NIMTeamNotificationContent*)object.content;
    NSString *currentAccount = [[NIMSDK sharedSDK].loginManager currentAccount];
    for (NSString *item in content.targetIDs) {
        if ([item isEqualToString:currentAccount]) {
            [targets addObject:NSLocalizedString(@"APP_YUNXIN_tip_U", nil)];
        }else{
            NSString *targetShowName = [NIMKitUtil showNick:item inSession:message.session];
            [targets addObject:targetShowName];
        }
    }
    return targets;
}


+ (NSString *)teamNotificationTeamShowName:(NIMMessage *)message{
    NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:message.session.sessionId];
    NSString *teamName = team.type == NIMTeamTypeNormal ? NSLocalizedString(@"APP_YUNXIN_Contact_taolunzu", nil) : NSLocalizedString(@"APP_YUNXIN_Contact_group", nil);
    return teamName;
}

+ (BOOL)canEditTeamInfo:(NIMTeamMember *)member
{
    NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:member.teamId];
    if (team.updateInfoMode == NIMTeamUpdateInfoModeManager)
    {
        return member.type == NIMTeamMemberTypeOwner || member.type == NIMTeamMemberTypeManager;
    }
    else
    {
        return member.type == NIMTeamMemberTypeOwner || member.type == NIMTeamMemberTypeManager || member.type == NIMTeamMemberTypeNormal;
    }
}

+ (BOOL)canInviteMember:(NIMTeamMember *)member
{
    NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:member.teamId];
    if (team.inviteMode == NIMTeamInviteModeManager)
    {
        return member.type == NIMTeamMemberTypeOwner || member.type == NIMTeamMemberTypeManager;
    }
    else
    {
        return member.type == NIMTeamMemberTypeOwner || member.type == NIMTeamMemberTypeManager || member.type == NIMTeamMemberTypeNormal;
    }

}

@end
