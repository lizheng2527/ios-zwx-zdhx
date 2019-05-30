//
//  WHStatisticsCountHeaderView.m
//  TYHxiaoxin
//
//  Created by 中电和讯 on 17/2/8.
//  Copyright © 2017年 Lanxum. All rights reserved.
//

#import "WHStatisticsCountHeaderView.h"
#import "TYHWarehouseDefine.h"

@implementation WHStatisticsCountHeaderView
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
    
    _itemSchoolLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH / 3, 44)];
    _itemSchoolLabel.textColor = [UIColor darkGrayColor];
    _itemSchoolLabel.text = NSLocalizedString(@"APP_wareHouse_schoolArea", nil);
    _itemSchoolLabel.font = [UIFont boldSystemFontOfSize:15];
    _itemSchoolLabel.textAlignment = NSTextAlignmentCenter;
    _itemSchoolLabel.numberOfLines = 0;
    [self addSubview:_itemSchoolLabel];
    
    _itemStoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 3 , 0, SCREEN_WIDTH / 3, 44)];
    _itemStoreLabel.textColor = [UIColor darkGrayColor];
    _itemStoreLabel.text = NSLocalizedString(@"APP_wareHouse_WH", nil);
    _itemStoreLabel.font = [UIFont boldSystemFontOfSize:15];
    _itemStoreLabel.textAlignment = NSTextAlignmentCenter;
    _itemStoreLabel.numberOfLines = 0;
    [self addSubview:_itemStoreLabel];
    
    _itemCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 3 * 2, 0, SCREEN_WIDTH / 3, 44)];
    _itemCountLabel.textColor = [UIColor darkGrayColor];
    _itemCountLabel.text = NSLocalizedString(@"APP_wareHouse_remianCount", nil);
    _itemCountLabel.font = [UIFont boldSystemFontOfSize:15];
    _itemCountLabel.textAlignment = NSTextAlignmentCenter;
    _itemCountLabel.numberOfLines = 0;
    [self addSubview:_itemCountLabel];
    

    UIView *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 3, 0, .5f, 44)];
    lineView1.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:lineView1];
    
    UIView *lineView2 = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 3 * 2, 0, .5f, 44)];
    lineView2.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:lineView2];
    
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
