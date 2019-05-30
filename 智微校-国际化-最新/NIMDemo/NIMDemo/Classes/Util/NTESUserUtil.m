//
//  NTESUserUtil.m
//  NIM
//
//  Created by chris on 15/9/17.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESUserUtil.h"
#import "NIMKitUtil.h"

@implementation NTESUserUtil

+ (NSString *)genderString:(NIMUserGender)gender{
    NSString *genderStr = @"";
    switch (gender) {
        case NIMUserGenderMale:
            genderStr = NSLocalizedString(@"APP_YUNXIN_sexMan", nil);
            break;
        case NIMUserGenderFemale:
            genderStr = NSLocalizedString(@"APP_YUNXIN_sexWomen", nil);
            break;
        case NIMUserGenderUnknown:
            genderStr = NSLocalizedString(@"APP_YUNXIN_sexOther", nil);
        default:
            break;
    }
    return genderStr;
}

@end
