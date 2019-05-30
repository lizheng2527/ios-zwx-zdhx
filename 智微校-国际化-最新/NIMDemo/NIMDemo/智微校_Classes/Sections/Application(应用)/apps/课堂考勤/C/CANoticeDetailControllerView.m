//
//  CANoticeDetailControllerView.m
//  NIM
//
//  Created by 中电和讯 on 2018/9/29.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "CANoticeDetailControllerView.h"
#import "TYHClassAttendanceController.h"
#import "NSString+NTES.h"



@interface CANoticeDetailControllerView ()

@end

@implementation CANoticeDetailControllerView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    self.title = @"课堂考勤";
    
    self.title = _titleString;
    [self createBarItem];
    
    _titleLabel.text = _titleString;
    
    _detailLabel.text = [NSString isBlankString:_detailString]?@"暂无详情":_detailString;
    
}


-(void)createBarItem
{
    UIBarButtonItem * rightItem = nil;
    
        rightItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"ca_icon_toapp"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(inCAAction:)];

    //临时注释
//    self.navigationItem.rightBarButtonItem =rightItem;
}


-(void)inCAAction:(id)sender
{
    TYHClassAttendanceController *caView = [TYHClassAttendanceController new];
    [self.navigationController pushViewController:caView animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
