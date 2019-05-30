//
//  AssetMineApplyCell.m
//  TYHxiaoxin
//
//  Created by 中电和讯 on 16/8/24.
//  Copyright © 2016年 Lanxum. All rights reserved.
//

#import "AssetMineApplyCell.h"
#import "TYHAssetModel.h"

@implementation AssetMineApplyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initCellView];
    
    
}


-(void)setModel:(AssetMineApplyModel *)model
{
    _assetTypeLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"APP_assets_assetTyoe", nil),model.assetKindName];
    _assetCheckLabel.text = model.checkStatusView;
    _assetBumenLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"APP_assets_applyORG", nil),model.departmentName];
    _assetDateLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"APP_assets_applyDate", nil),model.applyDate];
}


-(void)initCellView
{
    _assetCheckBtn.layer.masksToBounds = YES;
    _assetCheckBtn.layer.cornerRadius = 3.0f;
    _assetCheckBtn.layer.borderWidth = 0.5f;
    _assetCheckBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
