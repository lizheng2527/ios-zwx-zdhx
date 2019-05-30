//
//  NTESContactDataCell.m
//  NIM
//
//  Created by chris on 2017/4/7.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESContactDataCell.h"
#import "NTESSessionUtil.h"
@implementation NTESContactDataCell

- (void)refreshUser:(id<NIMGroupMemberProtocol>)member
{
    [super refreshUser:member];
    NSString *state = [NTESSessionUtil onlineState:self.memberId detail:NO];
    NSString *title = @"";
    if (state.length)
    {
        title = [NSString stringWithFormat:@"[%@] %@",state,member.showName];
        
        //在线
        if ([state hasSuffix:NSLocalizedString(@"APP_General_onLine", nil)]) {
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:title];
            
            NSArray *languages = [NSLocale preferredLanguages];
            NSString *language = [languages objectAtIndex:0];
            if ([language hasPrefix:@"zh"]) {//检测开头匹配，是否为中文
                [attrStr addAttribute:NSFontAttributeName
                                value:[UIFont boldSystemFontOfSize:15.0f]
                                range:NSMakeRange(0, state.length + 2)];
                // 添加文字颜色
                [attrStr addAttribute:NSForegroundColorAttributeName
                                value:[UIColor TabBarColorGreen]
                                range:NSMakeRange(0, state.length + 2)];
            }else{//其他语言
                [attrStr addAttribute:NSFontAttributeName
                                value:[UIFont boldSystemFontOfSize:15.0f]
                                range:NSMakeRange(0, state.length + 2)];
                // 添加文字颜色
                [attrStr addAttribute:NSForegroundColorAttributeName
                                value:[UIColor TabBarColorGreen]
                                range:NSMakeRange(0, state.length + 2)];
            }
            
            // 设置字体和设置字体的范围
            
            
            
            self.textLabel.attributedText = attrStr;
        }
        //离线
        else if ([state hasSuffix:NSLocalizedString(@"APP_General_offLine", nil)]) {
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:title];
            
            NSArray *languages = [NSLocale preferredLanguages];
            NSString *language = [languages objectAtIndex:0];
            if ([language hasPrefix:@"zh"]) {//检测开头匹配，是否为中文
                [attrStr addAttribute:NSFontAttributeName
                                value:[UIFont boldSystemFontOfSize:15.0f]
                                range:NSMakeRange(0, state.length + 2)];
                // 添加文字颜色
                [attrStr addAttribute:NSForegroundColorAttributeName
                                value:[UIColor TabBarColorGreen]
                                range:NSMakeRange(0, state.length + 2)];
            }else{//其他语言
                [attrStr addAttribute:NSFontAttributeName
                                value:[UIFont boldSystemFontOfSize:15.0f]
                                range:NSMakeRange(0, state.length + 2)];
                // 添加文字颜色
                [attrStr addAttribute:NSForegroundColorAttributeName
                                value:[UIColor TabBarColorGreen]
                                range:NSMakeRange(0, state.length + 2)];
            }
            
            self.textLabel.attributedText = attrStr;
        }
    }
    else
    {
        title = [NSString stringWithFormat:@"%@",member.showName];
    }
    
    self.textLabel.text = title;
}


@end
