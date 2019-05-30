//
//  qcsHomeworkMainStuController.h
//  NIM
//
//  Created by 中电和讯 on 2018/12/26.
//  Copyright © 2018 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface qcsHomeworkMainStuController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@property(nonatomic,retain)NSMutableArray *studentCourseArray;

@property(nonatomic,copy)NSString *eclassIDs;
@property(nonatomic,copy)NSString *idCourses;
@property(nonatomic,copy)NSString *idGrade;
@property(nonatomic,copy)NSString *type;
@property(nonatomic,copy)NSString *startTime;
@property(nonatomic,copy)NSString *endTime;

-(void)requestData;
@property(nonatomic,copy)NSString *eclassID;

@end

NS_ASSUME_NONNULL_END
