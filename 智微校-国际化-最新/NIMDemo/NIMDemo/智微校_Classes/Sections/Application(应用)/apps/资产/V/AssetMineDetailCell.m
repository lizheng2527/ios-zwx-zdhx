//
//  AssetMineDetailCell.m
//  TYHxiaoxin
//
//  Created by 中电和讯 on 16/8/24.
//  Copyright © 2016年 Lanxum. All rights reserved.
//

#import "AssetMineDetailCell.h"
#import "TYHAssetModel.h"

@implementation AssetMineDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initCellView];
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
    }
    return self;
}

-(void)setModel:(AssetMineDetailModel *)model
{
    _assetNameLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"APP_assets_assetName", nil),model.name];
    _assetTypeLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"APP_assets_assetTyoe", nil),model.assetKindName];
    _assetCodeLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"APP_assets_assetcode", nil),model.code];
    _assetDateLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"APP_assets_borrowDate", nil),model.registrationDate];
    _assetGuiGeLabel.text =[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"APP_assets_guige", nil),model.patternName];
}


-(void)initCellView
{
    _assetCheckBtn.layer.masksToBounds = YES;
    _assetCheckBtn.layer.cornerRadius = 3.0f;
    _assetCheckBtn.layer.borderWidth = 0.5f;
    _assetCheckBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    _assetAddBtn.layer.masksToBounds = YES;
    _assetAddBtn.layer.cornerRadius = 3.0f;
    _assetAddBtn.layer.borderWidth = 0.5f;
    _assetAddBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [_assetAddBtn addTarget:self action:@selector(assetAddAction:) forControlEvents:UIControlEventTouchUpInside];
}


-(void)assetAddAction:(id)sender
{
    UIButton *button = sender;
    
    [self.delegate assetAddBtnClickkkkk:self];
//    if ([self.assetAddBtn.titleLabel.text isEqualToString:NSLocalizedString(@"APP_assets_Add", nil)]) {
        [button setTitle:NSLocalizedString(@"APP_assets_Remove", nil) forState:UIControlStateNormal];
//    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
