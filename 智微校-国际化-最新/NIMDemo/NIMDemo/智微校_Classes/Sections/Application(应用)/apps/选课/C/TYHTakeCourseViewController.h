//
//  TYHTakeCourseViewController.h
//  TYHxiaoxin
//
//  Created by 中电和讯 on 16/7/23.
//  Copyright © 2016年 Lanxum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYHTakeCourseViewController : UIViewController

-(instancetype)initWithEcID:(NSString *)EcID;
@property(nonatomic,retain)NSMutableArray *tempIndexPathAndModeltypeArray;

@end
