//
//  WHChooseWareHouseController.h
//  TYHxiaoxin
//
//  Created by 中电和讯 on 17/2/13.
//  Copyright © 2017年 Lanxum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHChooseWareHouseController : UIViewController

@property(nonatomic,retain)NSMutableArray *assetDatasource;

@property(nonatomic,copy)NSString *typeString;  //申请 && 查找 (只有这两种赋值)

@end
