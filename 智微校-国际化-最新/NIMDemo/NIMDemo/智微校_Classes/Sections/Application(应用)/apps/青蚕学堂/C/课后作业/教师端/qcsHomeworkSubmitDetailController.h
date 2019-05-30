//
//  qcsHomeworkSubmitDetailController.h
//  NIM
//
//  Created by 中电和讯 on 2018/12/26.
//  Copyright © 2018 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface qcsHomeworkSubmitDetailController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@property(nonatomic,copy)NSString *wisdomclassId;

@property(nonatomic,copy)NSString *homewordID;

@property(nonatomic,copy)NSString *dateEnd;
@end

