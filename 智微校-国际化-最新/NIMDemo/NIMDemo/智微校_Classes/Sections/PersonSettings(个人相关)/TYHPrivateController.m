//
//  TYHPrivateController.m
//  NIM
//
//  Created by 中电和讯 on 2019/3/23.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "TYHPrivateController.h"

@interface TYHPrivateController ()

@end

@implementation TYHPrivateController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"隐私政策";
    
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.zdhx-edu.com/hexun/catalog.jhtml?viewId=126"]]];
    [self.webview sizeToFit];
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
