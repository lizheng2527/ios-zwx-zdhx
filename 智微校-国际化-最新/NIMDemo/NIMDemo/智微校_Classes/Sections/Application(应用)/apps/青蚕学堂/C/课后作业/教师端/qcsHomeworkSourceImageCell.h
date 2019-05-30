//
//  qcsHomeworkSourceImageCell.h
//  NIM
//
//  Created by 中电和讯 on 2019/1/3.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class qcsHomeworkSourceImageCell;
@class qcsHomeworkMediaModel;

@protocol qcsHomeworkSourceImageCellDelegate <NSObject>
@optional

- (void)didClickSourceImageViewInCell:(NSIndexPath *)indexPath;

@end



@interface qcsHomeworkSourceImageCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *sourceImageView;
@property (nonatomic, weak) id<qcsHomeworkSourceImageCellDelegate> delegate;
@property(nonatomic,strong)NSIndexPath *indexPath;

@property(nonatomic,retain)qcsHomeworkMediaModel *homeworkModel;
@end

