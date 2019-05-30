//
//  homeworkListCell.m
//  TYHxiaoxin
//
//  Created by 大存神 on 16/6/27.
//  Copyright © 2016年 Lanxum. All rights reserved.
//

#define myCyanColor colorWithRed:54/255.0 green:191/255.0 blue:181/255.0 alpha:1

#import "homeworkListCell.h"
#import "UIView+SDAutoLayout.h"

@implementation homeworkListCell
#pragma mark - 赋予数据
-(void)setModel:(HWListModel *)model
{
    _nameLabel.text = model.courseName;
    
    _FinishLabel.attributedText = [self dealWithFinishLabel:model.statusName];
    
    _DetailLabel.text = model.title;
    
    _endLabel.attributedText = [self dealEndTimeString:[NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"APP_MyHomeWork_Submitted_until", nil),model.endTime]];
    
    _mutableTimeLabel_Left.text = [self dealDateWithSrting:model.setTime];
    
    _mutableTimeLabel_Right.attributedText = [self dealWithDayTimeLabel_Right:[NSString stringWithFormat:@"%@\n%@",[self dealMonthWithSrting:model.setTime],[self dealTimeWithSrting:model.setTime]]] ;
    [self createLayout];
}

#pragma mark - 约束
-(void)createLayout
{
#define BGView self.contentView
#define borderView    self.backgroundView
    [BGView addSubview:_myBackgroundView];
    [BGView addSubview:_FinishLabel];
    [BGView addSubview:_arrowImageView];

    _myBackgroundView.sd_layout.leftSpaceToView(BGView,90).topSpaceToView(BGView,5).rightSpaceToView(BGView,5).bottomSpaceToView(BGView,5);
    
    _FinishLabel.sd_layout.rightSpaceToView(BGView,20).topSpaceToView(BGView,5).bottomSpaceToView(BGView,50).widthIs(50);
    _arrowImageView.sd_layout.rightSpaceToView(BGView,10).topSpaceToView(BGView,37).bottomSpaceToView(BGView,37).widthIs(5);
    
}

#pragma mark - 字符串处理方法
//结束时间加入橙色
-(NSMutableAttributedString *)dealEndTimeString:(NSString *)srting
{
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:srting];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor]
                          range:NSMakeRange(0, 6)];
    
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *language = [languages objectAtIndex:0];
    if (![language hasPrefix:@"zh"]) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor]
                                 range:NSMakeRange(0, 15)];
    }
    return attributedString;
    
}
//完成状态label颜色判定
-(NSMutableAttributedString *)dealWithFinishLabel:(NSString *)string
{
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    if ([string isEqualToString:NSLocalizedString(@"APP_MyHomeWork_hasFinished", nil)] || [string isEqualToString:@"已完成"]) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor myCyanColor]
                                 range:NSMakeRange(0, 3)];
    }
    else if ([string isEqualToString:NSLocalizedString(@"APP_MyHomeWork_unFinished", nil)]|| [string isEqualToString:@"未完成"]) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor]
                                 range:NSMakeRange(0, 3)];
    }
    else if ([string isEqualToString:NSLocalizedString(@"APP_MyHomeWork_HasExpired", nil)]|| [string isEqualToString:@"已过期"])
    {
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor]
                                 range:NSMakeRange(0, 3)];
    }
    return attributedString;
}

-(NSMutableAttributedString *)dealWithDayTimeLabel_Right:(NSString *)string
{
    
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:string];
        
        if ([string hasPrefix:@"10"] || [string hasPrefix:@"11"] || [string hasPrefix:@"12"] ) {
            [attributedString addAttribute:NSFontAttributeName value:[UIFont  systemFontOfSize:13.0] range:NSMakeRange(3, 4)];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor myCyanColor]
                                     range:NSMakeRange(3, 4)];
        }else
        {
            [attributedString addAttribute:NSFontAttributeName value:[UIFont  systemFontOfSize:13.0] range:NSMakeRange(2, 4)];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor myCyanColor]
                                     range:NSMakeRange(2, 4)];
        }
    
    
    
    
    NSDictionary *dic = @{@"1":@"Jan",@"2":@"Feb",@"3":@"Mar",@"4":@"Apr",@"5":@"May",@"6":@"Jun",@"7":@"Jul",@"8":@"Aug",@"9":@"Sep",@"10":@"Oct",@"11":@"Nov",@"12":@"Dec"};
    NSString *str1 = @"";

    if (string.length) {
        NSArray *array = [string componentsSeparatedByString:@"月"];
        str1 = array[0];
    }

    NSString *needAddString = [dic objectForKey:[NSString stringWithFormat:@"%@",str1]];
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *language = [languages objectAtIndex:0];
        if (![language hasPrefix:@"zh"]) {
            //检测开头匹配，是否为中文
            if ([string hasPrefix:@"10"] || [string hasPrefix:@"11"] || [string hasPrefix:@"12"] ) {
                [attributedString replaceCharactersInRange:NSMakeRange(0, 3) withString:needAddString];
            }else
                [attributedString replaceCharactersInRange:NSMakeRange(0, 2) withString:needAddString];
        }
    
//    if ([string hasPrefix:@"10"] || [string hasPrefix:@"11"] || [string hasPrefix:@"12"] ) {
//        [attributedString addAttribute:NSFontAttributeName value:[UIFont  systemFontOfSize:13.0] range:NSMakeRange(3, 4)];
//        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor myCyanColor]
//                                 range:NSMakeRange(3, 4)];
//    }else
//    {
//        [attributedString addAttribute:NSFontAttributeName value:[UIFont  systemFontOfSize:13.0] range:NSMakeRange(2, 4)];
//        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor myCyanColor]
//                                 range:NSMakeRange(2, 4)];
//    }
    return attributedString;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _myBackgroundView.layer.masksToBounds = YES;
    _myBackgroundView.layer.borderWidth = 0.3f;
    _myBackgroundView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

#pragma mark - 日期字符串处理

-(NSString *)dealDateWithSrting:(NSString *)string
{
    NSString *needDealString =[string substringWithRange:NSMakeRange(8, 2)];
    return needDealString;
}

-(NSString *)dealTimeWithSrting:(NSString *)string
{
    NSString *needDealString = [self weekdayStringFromDate:[self dateFromString:string]];
    return needDealString;
}


-(NSString *)dealMonthWithSrting:(NSString *)string
{
    
    NSString *needDealString =[string substringWithRange:NSMakeRange(5, 2)];
    if ([needDealString integerValue] >0 && [needDealString integerValue] <13 ) {
        needDealString = [NSString stringWithFormat:@"%ld月",(long)[needDealString integerValue]];
    }
    return needDealString;
}



- (NSString*)weekdayStringFromDate:(NSDate*)inputDate {
    
//    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], NSLocalizedString(@"APP_MyHomeWork_Sunday", nil), NSLocalizedString(@"APP_MyHomeWork_Mon", nil), NSLocalizedString(@"APP_MyHomeWork_Tus", nil), NSLocalizedString(@"APP_MyHomeWork_wens", nil), NSLocalizedString(@"APP_MyHomeWork_Ths", nil), NSLocalizedString(@"APP_MyHomeWork_fri", nil), NSLocalizedString(@"APP_MyHomeWork_sat", nil), nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSWeekdayCalendarUnit;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    
    return [weekdays objectAtIndex:theComponents.weekday];
    
}

- (NSDate *)dateFromString:(NSString *)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    return destDate;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
