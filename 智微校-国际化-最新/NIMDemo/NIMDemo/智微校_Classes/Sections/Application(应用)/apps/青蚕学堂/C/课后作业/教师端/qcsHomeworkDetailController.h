//
//  qcsHomeworkDetailController.h
//  NIM
//
//  Created by 中电和讯 on 2018/12/27.
//  Copyright © 2018 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class qcsHomeworkSubmitListModel;



@interface qcsHomeworkDetailController : UIViewController

@property(nonatomic,retain)qcsHomeworkSubmitListModel *model;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UILabel *finisthTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *submitStatusLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property(nonatomic,copy)NSString *dateEnd;
@end

