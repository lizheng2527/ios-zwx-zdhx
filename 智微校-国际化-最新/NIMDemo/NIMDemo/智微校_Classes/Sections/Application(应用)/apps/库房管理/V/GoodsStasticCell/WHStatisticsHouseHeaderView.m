//
//  WHStatisticsHouseHeaderView.m
//  TYHxiaoxin
//
//  Created by 中电和讯 on 17/2/8.
//  Copyright © 2017年 Lanxum. All rights reserved.
//

#import "WHStatisticsHouseHeaderView.h"
#import "TYHWarehouseDefine.h"

@implementation WHStatisticsHouseHeaderView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        [self initCellContentView];
    }
    return self;
}

-(void)initCellContentView
{
    self.backgroundColor = [UIColor WarehouseStatisticsColor];
    
    _itemNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH / 4, 44)];
    _itemNameLabel.textColor = [UIColor darkGrayColor];
    _itemNameLabel.text = NSLocalizedString(@"APP_wareHouse_schoolArea", nil);
    _itemNameLabel.font = [UIFont boldSystemFontOfSize:15];
    _itemNameLabel.textAlignment = NSTextAlignmentCenter;
    _itemNameLabel.numberOfLines = 0;
    [self addSubview:_itemNameLabel];
    
    _itemCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 4, 0, SCREEN_WIDTH / 4, 44)];
    _itemCountLabel.textColor = [UIColor darkGrayColor];
    _itemCountLabel.text = NSLocalizedString(@"APP_wareHouse_WH", nil);
    _itemCountLabel.font = [UIFont boldSystemFontOfSize:15];
    _itemCountLabel.textAlignment = NSTextAlignmentCenter;
    _itemCountLabel.numberOfLines = 0;
    [self addSubview:_itemCountLabel];
    
    _itemInHouseLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 2, 0, SCREEN_WIDTH / 4, 44)];
    _itemInHouseLabel.textColor = [UIColor darkGrayColor];
    _itemInHouseLabel.text = NSLocalizedString(@"APP_wareHouse_remianCount", nil);
    _itemInHouseLabel.font = [UIFont boldSystemFontOfSize:15];
    _itemInHouseLabel.textAlignment = NSTextAlignmentCenter;
    _itemInHouseLabel.numberOfLines = 0;
    [self addSubview:_itemInHouseLabel];
    
    _itemOutHouseLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 4 * 3, 0, SCREEN_WIDTH / 4, 44)];
    _itemOutHouseLabel.textColor = [UIColor darkGrayColor];
    _itemOutHouseLabel.text = NSLocalizedString(@"APP_wareHouse_price", nil);
    _itemOutHouseLabel.font = [UIFont boldSystemFontOfSize:15];
    _itemOutHouseLabel.textAlignment = NSTextAlignmentCenter;
    _itemOutHouseLabel.numberOfLines = 0;
    [self addSubview:_itemOutHouseLabel];
    
    UIView *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 4, 0, .5f, 44)];
    lineView1.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:lineView1];
    
    UIView *lineView2 = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 2, 0, .5f, 44)];
    lineView2.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:lineView2];
    
    UIView *lineView3 = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 4 * 3, 0, .5f, 44)];
    lineView3.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:lineView3];
    
    UIView *lineViewBottom = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5f, SCREEN_WIDTH, .5f)];
    lineViewBottom.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:lineViewBottom];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
