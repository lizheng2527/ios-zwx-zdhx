//
//  qcsClassStasticInsideXTTJCell.h
//  NIM
//
//  Created by 中电和讯 on 2018/4/9.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QCSStasticModel;
@class QCSStasticComprehensiveModel;
@class qcsHomeworkSubmitListModel;

@class qcsClassStasticInsideXTTJCell;

@protocol qcsClassStasticInsideXTTJCellDelegate <NSObject>
@optional
- (void)didClickFinishLabelInCell:(qcsClassStasticInsideXTTJCell *)cell;
@end



@interface qcsClassStasticInsideXTTJCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;

@property (retain, nonatomic) UIImageView *scoreImageView;
@property(nonatomic,retain)UIView *lineView;

@property(nonatomic,retain)QCSStasticModel *model;

@property(nonatomic,retain)QCSStasticComprehensiveModel *cModel;

@property(nonatomic,retain)qcsHomeworkSubmitListModel *homeworkModel;
@property(nonatomic,copy)NSString *dateEnd;

@property (nonatomic, weak) id<qcsClassStasticInsideXTTJCellDelegate> delegate;
@end
