//
//  NTESClientUtil.m
//  NIM
//
//  Created by chris on 15/7/27.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESClientUtil.h"

@implementation NTESClientUtil

+ (NSString *)clientName:(NIMLoginClientType)clientType{
    switch (clientType) {
        case NIMLoginClientTypeAOS:
        case NIMLoginClientTypeiOS:
        case NIMLoginClientTypeWP:
            return NSLocalizedString(@"APP_General_mobileVersion", nil);
        case NIMLoginClientTypePC:
        case NIMLoginClientTypemacOS:
            return NSLocalizedString(@"APP_General_computerVersion", nil);
        case NIMLoginClientTypeWeb:
            return NSLocalizedString(@"APP_General_webVersion", nil);
        default:
            return @"";
    }
}

@end
