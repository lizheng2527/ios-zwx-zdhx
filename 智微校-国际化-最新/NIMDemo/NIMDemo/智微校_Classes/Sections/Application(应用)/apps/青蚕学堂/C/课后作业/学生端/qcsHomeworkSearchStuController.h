//
//  qcsHomeworkSearchStuController.h
//  NIM
//
//  Created by 中电和讯 on 2018/12/26.
//  Copyright © 2018 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface qcsHomeworkSearchStuController : UIViewController


@property (weak, nonatomic) IBOutlet UIButton *chooseCourseButton;

@property (weak, nonatomic) IBOutlet UIButton *chooseStartTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *chooseEndTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *chooseTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property(nonatomic,retain)NSMutableArray *studentCourseArray;

@end

NS_ASSUME_NONNULL_END
