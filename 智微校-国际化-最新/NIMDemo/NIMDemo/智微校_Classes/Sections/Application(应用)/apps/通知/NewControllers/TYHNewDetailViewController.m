//
//  TYHNewDetailViewController.m
//  TYHxiaoxin
//
//  Created by hzth-mac3 on 15/12/28.
//  Copyright © 2015年 Lanxum. All rights reserved.
//

#import "TYHNewDetailViewController.h"
#import "TYHHttpTool.h"
#import "AttachDropMenu.h"
#import "AttachmentViewController.h"
#import "UIView+Extention.h"
#import "TYHNoticeController.h"
#import <UIView+Toast.h>
#import "SingleManager.h"
#import "TYHReadInfo2ViewController.h"
#import "TYHNewSendViewController.h"
#import <MJExtension.h>
#import "UIView+SDAutoLayout.h"

@interface TYHNewDetailViewController ()<UIWebViewDelegate,AttachDropMenuDelegate,UIScrollViewDelegate,UIAlertViewDelegate,UIDocumentInteractionControllerDelegate,AttachmentViewControllerDelegate>

@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@property (nonatomic, strong) NSArray * attachArray;
@property (weak, nonatomic) IBOutlet UIView *sView;
@property (nonatomic, strong) MBProgressHUD  * hub;
@property (nonatomic, strong) SingleManager * manager;

@property (nonatomic, strong) AttachDropMenu * drop;

@property(nonatomic,copy)NSString *dataSourceName;
@end

@implementation TYHNewDetailViewController
{
    int lastFrameY;
}
- (NSArray *)attachArray {
    
    if (_attachArray == nil) {
        self.attachArray = [AttachmentModel mj_objectArrayWithKeyValuesArray:self.model.attachmentFlag];
    }
    return _attachArray;
}

- (void)initData {
    
    NSString *tempUserName = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_LOGINNAME];
    _organizationID = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_ORIGANIZATION_ID];
    _userName = [NSString stringWithFormat:@"%@%@%@",tempUserName,@"%2C",_organizationID];
    _password = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_PASSWORD];
    _userId = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_USERID];
    _token = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_TOKEN];
    _dataSourceName = [[NSUserDefaults standardUserDefaults]valueForKey:@"USER_DEFAULT_DataSourceName"];
    _dataSourceName = _dataSourceName.length?_dataSourceName:@"";
}

- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}
- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor TabBarColorYellow];
    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//
    self.navigationController.navigationBar.translucent = YES;
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    lastFrameY = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (![self.result isEqualToString:@"1"]) {
        _buttonView.hidden = YES;
    } else {
        if (lastFrameY - scrollView.contentOffset.y >= 0) {
            
            self.buttonView.hidden = NO;
        }else {
            
            self.buttonView.hidden = YES;
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    _showAttachbtn.selected = NO;
    
}
- (void)getNoticeContent {

     NSString *string = [NSString stringWithFormat:@"%@/no/noticeMobile/getNoticeDetail",BaseURL];
    NSString * url = [NSString stringWithFormat:@"%@?sys_username=%@&sys_auto_authenticate=true&sys_password=%@&id=%@&imToken=%@&dataSourceName=%@",string,_userName,_password,self.ID,self.token,_dataSourceName];
    
    [TYHHttpTool gets:url params:nil success:^(id json) {
        
        self.model = [NoticeModel mj_objectWithKeyValues:json];
        NSString *setRead = [NSString stringWithFormat:@"%@/no/noticeMobile/setNoticeRead",BaseURL];
        NSString *serReadURL = [NSString stringWithFormat:@"%@?userId=%@&id=%@&sys_username=%@&sys_auto_authenticate=true&sys_password=%@&imToken=%@&dataSourceName=%@",setRead,_userId,_model.ID,_userName,_password,self.token,_dataSourceName];
        [TYHHttpTool gets:serReadURL params:nil success:^(id json) {
        } failure:^(NSError *error) {
        }];

        [self getHahaData];
        
    } failure:^(NSError *error) {
        NSLog(@"error == %@",[error localizedDescription]);
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initData];
    
    self.navigationItem.title= NSLocalizedString(@"APP_note_detail", nil);
    
    self.ID = self.modelID;
    
    if (self.model == nil) {
        
        [self getNoticeContent];
    } else {
    
        [self getHahaData];
    }
    
    [self creatLeftItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentView:) name:@"PresentView" object:nil];
    if ([self.model.sendUser isEqualToString:NSLocalizedString(@"APP_note_Me",nil)]) {
        
        [self creatRightItem];
    }
    
    if (kDevice_Is_iPhoneX) {
        _buttonView.frame = CGRectMake(0, SCREEN_WIDTH, SCREEN_WIDTH - 64 - 34, 44);
    }
    
}


- (void)getHahaData {

    self.deleteBigBtn.hidden = YES;
    
    
    self.sendUserLabel.text = self.model.title;
    self.sendUserLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    CGSize maximumLabelSize = CGSizeMake(self.view.width, MAXFLOAT);//labelsize的最大值
    //关键语句
    CGSize expectSize = [self.sendUserLabel sizeThatFits:maximumLabelSize];
    //别忘了把frame给回label，如果用xib加了约束的话可以只改一个约束的值
    if (expectSize.height > 40) {
        
        self.sendUserLabel.frame = CGRectMake(10, 10, expectSize.width, expectSize.height);
    }
    
    self.sendTime.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"APP_note_sendTime", nil),self.model.sendTime];
    self.kindLabel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"APP_note_sendPerson", nil),self.model.sendUser];
    
    [self.attentionBtn setImage:[UIImage imageNamed:@"收藏01"] forState:(UIControlStateNormal)];
    [self.attentionBtn setImage:[UIImage imageNamed:@"收藏02"] forState:(UIControlStateSelected)];
    
    [self.attentionBigBtn setImage:[UIImage imageNamed:@"收藏01"] forState:(UIControlStateNormal)];
    [self.attentionBigBtn setImage:[UIImage imageNamed:@"收藏02"] forState:(UIControlStateSelected)];
    
    [_showAttachbtn setTitle:NSLocalizedString(@"APP_note_approve", nil) forState:(UIControlStateNormal)];
    [_showAttachbtn setTitle:NSLocalizedString(@"APP_note_hidden", nil) forState:(UIControlStateSelected)];
    
    if (![self.result isEqualToString:@"1"]) {
        self.buttonView.hidden = YES;
        self.deleteBigBtn.hidden = NO;
        self.attentionBigBtn.hidden = NO;
    } else {
        self.deleteBigBtn.hidden = YES;
        self.attentionBigBtn.hidden = YES;
    }
    
    if (self.model.attentionFlag) {
        self.attentionBigBtn.selected = YES;
        self.attentionBtn.selected = YES;
        
    } else {
        self.attentionBigBtn.selected = NO;
        self.attentionBtn.selected = NO;
        
    }
    
    
    if (self.model.attachmentFlag != nil && ![self.model.attachmentFlag isKindOfClass:[NSNull class]] && self.model.attachmentFlag.count != 0) {
        self.attachmentImage.hidden = NO;
        self.attachCount.text = [NSString stringWithFormat:@"%ld%@",(long)self.model.attachmentFlag.count,NSLocalizedString(@"APP_note_gefujian", nil)];
        self.attachCount.hidden = NO;
        self.showAttachbtn.hidden = NO;
    }
    else {
        self.attachmentImage.hidden = YES;
        self.attachCount.hidden = YES;
        self.showAttachbtn.hidden = YES;
    }
    
    self.sView.sd_layout.bottomEqualToView(self.tempLabel);
    self.webView.sd_layout.topEqualToView(self.tempLabel);
    
    [self getWebViewData];
}

- (void)creatRightItem {
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"APP_note_stastic", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(readInfo)];
    rightItem.tintColor = [UIColor whiteColor];
    NSUInteger size = 13;
    UIFont * font = [UIFont boldSystemFontOfSize:size];
    NSDictionary * attributes = @{NSFontAttributeName: font};
    [rightItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}
- (void)readInfo {
    
    TYHReadInfo2ViewController * readInfo = [[TYHReadInfo2ViewController alloc] init];
    readInfo.ID = self.ID;
    [self.navigationController pushViewController:readInfo animated:YES];
    
}
- (void)presentView:(NSNotificationCenter *)notice {
    
    TYHNoticeController * noticeVc = [[TYHNoticeController alloc] init];
    noticeVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController  pushViewController:noticeVc animated:YES];
}
- (void)getWebViewData {
    
    self.webView.delegate = self;
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.delegate = self;
    self.webView.scalesPageToFit = YES;
    NSString * string = @"";
    if([_model.url rangeOfString:@"?"].location !=NSNotFound)
    {
        string = [NSString stringWithFormat:@"%@&",_model.url];
    }
    else
    {
        string = [NSString stringWithFormat:@"%@?",_model.url];
    }
    NSString * url = [NSString stringWithFormat:@"%@id=%@&dataSourceName=%@",string,self.ID,self.dataSourceName];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    
}
- (void)creatLeftItem {
    
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem =leftItem;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    MBProgressHUD  * hub = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hub];
    hub.alpha = 1;
    self.hub = hub;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [self.hub removeFromSuperview];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [webView stringByEvaluatingJavaScriptFromString:@"var element = document.createElement('meta');  element.name = \"viewport\";  element.content = \"width=device-width,initial-scale=1.0,minimum-scale=0.5,maximum-scale=3,user-scalable=1\"; var head = document.getElementsByTagName('head')[0]; head.appendChild(element);"];
//    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= ’150%’"];
//    NSString *jsString = [[NSString alloc] initWithFormat:@"document.body.style.fontSize=%f;document.body.style.color=%@",8.0,[UIColor redColor]];
//    [webView stringByEvaluatingJavaScriptFromString:jsString];
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    //临时注释
    [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error)
     {
         extern NSString *NTESNotificationLogout;
         [[NSNotificationCenter defaultCenter] postNotificationName:@"TokenCheckFalse" object:nil];
         [[NSNotificationCenter defaultCenter] postNotificationName:NTESNotificationLogout object:nil];
     }];
    if (error) {
        UIAlertView *alterview = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"APP_note_tokenFalse", nil)  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alterview show];
    }
    
//    UIAlertView *alterview = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    
}
- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    
    if (self.drop) {
        [self.drop dismiss];
    }
    
//    self.navigationController.navigationBar.translucent = YES;
}

- (void)returnClicked {
    
    _showAttachbtn.selected = NO;
    
    if (self.drop) {
        [self.drop dismiss];
    }
    
    if (self.atttentionFlag) {
    
        self.atttentionFlag(self.model.attentionFlag);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSMutableArray *)modelArray2 {

    if (_modelArray2 == nil) {
        self.modelArray2 = [NSMutableArray arrayWithArray:_modelArray];
    }
    return _modelArray2;
}
#pragma mark - AttachmentViewControllerDelegate
-(void)tableViewDidSelectWithUrl:(NSURL *)url
{
    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    [self.documentInteractionController setDelegate:self];
    
    
    CGRect navRect = self.navigationController.navigationBar.frame;
    
    navRect.size = CGSizeMake(1500.0f, 40.0f);
    
    [_documentInteractionController presentOptionsMenuFromRect:navRect inView:self.view animated:YES];
}
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return [self navigationController];
}

-(void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    self.navigationController.navigationBar.translucent = NO;
    
}

#pragma mark - DropdownMenuDelegate
//下拉菜单被销毁了
- (void)dropdownMenuDidDismiss:(AttachDropMenu *)menu
{
    if (![self.result isEqualToString:@"1"]) {
        _buttonView.hidden = YES;
    } else {
        
        _buttonView.hidden = NO;
    }
    _showAttachbtn.selected = NO;
}

//下拉菜单显示了
- (void)dropdownMenuDidShow:(AttachDropMenu *)menu
{
    _buttonView.hidden = YES;
    _showAttachbtn.selected = YES;
    menu.frame = CGRectMake(menu.frame.origin.x, menu.frame.origin.y - 58, menu.frame.size.width, menu.frame.size.height);
    [self.view addSubview:menu];
}
- (IBAction)showAttachBtn:(id)sender {
    
    // 创建下拉菜单
    AttachDropMenu *drop = [[AttachDropMenu alloc] init];
    self.drop = drop;
    // 设置下拉菜单弹出、销毁事件的监听者
    drop.delegate = self;
    
    // 2.设置要显示的内容
    AttachmentViewController *titleMenuVC = [[AttachmentViewController alloc] init];
    titleMenuVC.delegate = self;
    titleMenuVC.drop = drop;
    
    titleMenuVC.attachmentArray = self.model.attachmentFlag;
    // 创建view的高度
    titleMenuVC.view.height = self.view.height - CGRectGetMaxY(self.sView.frame);
    titleMenuVC.view.width = self.view.width;
    drop.contentController = titleMenuVC;
    // 显示
    [drop showFrom:sender];
}

- (IBAction)deleteBtn:(id)sender {
    
    UIAlertController * alertVc = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"APP_note_Delete", nil) message:NSLocalizedString(@"APP_note_delNotifacation", nil) preferredStyle:(UIAlertControllerStyleAlert)];
    
    [alertVc addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"APP_General_Cancel", nil) style:(UIAlertActionStyleCancel) handler:nil]];
    [alertVc addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"APP_note_Delete", nil) style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *string = [NSString stringWithFormat:@"%@/no/noticeMobile/setNoticeDelete",BaseURL];
        
        NSString * url = [NSString stringWithFormat:@"%@?sys_username=%@&sys_auto_authenticate=true&sys_password=%@&id=%@&imToken=%@&dataSourceName=%@",string,_userName,_password,self.ID,self.token,_dataSourceName];
//        NSLog(@"url2 = %@",url);
        // 删除消息
        [TYHHttpTool gets:url params:nil success:^(id json) {
//            NSLog(@"success");
        } failure:^(NSError *error) {
//            NSLog(@"erorr");
        }];
    
        [self.modelArray2 enumerateObjectsUsingBlock:^(NoticeModel   *models, NSUInteger idx, BOOL * _Nonnull stop) {
           
            NSString * idStr = models.ID;
            NSString * idSource = models.sourceId;
            if ([idStr isEqualToString:self.ID] || [idSource isEqualToString:self.ID]) {
                * stop = YES;
                [self.modelArray2 removeObject:models];
            }
        }];
        [self.view makeToast:NSLocalizedString(@"APP_note_hasDelete",nil) duration:1 position:nil];
        
        if (self.returnNameArrayBlock) {
            self.returnNameArrayBlock(self.modelArray2);
        }
        [self.navigationController popViewControllerAnimated:YES];
        
    }]];
    
    [self presentViewController:alertVc animated:YES completion:nil];
    
}
- (IBAction)attentionBtn:(id)sender {
    
    if (self.attentionBtn.selected == YES||self.attentionBigBtn.selected == YES) {
        
        NSString *string = [NSString stringWithFormat:@"%@/no/noticeMobile/ajaxLightoff",BaseURL];
        NSString * url = [NSString stringWithFormat:@"%@?sys_username=%@&sys_auto_authenticate=true&sys_password=%@&id=%@&imToken=%@&dataSourceName=%@",string,_userName,_password,self.ID,self.token,_dataSourceName];
        // 取消关注
        [TYHHttpTool gets:url params:nil success:^(id json) {
            
            NSLog(@"json == %@",json);
            NSLog(@"%@",[[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]);
        } failure:^(NSError *error) {
            
            NSLog(@"error == %@",error);
        }];
        
        self.attentionBtn.selected = !self.attentionBtn.selected;
        self.attentionBigBtn.selected = !self.attentionBigBtn.selected;
        NSString * str = [NSString stringWithFormat:NSLocalizedString(@"APP_note_hasRemoveAttention", nil)];
        [self.view makeToast:str duration:1 position:nil];
        self.model.attentionFlag = NO;
        
    } else {
        
        //  同步更新网络数据
        NSString *string = [NSString stringWithFormat:@"%@/no/noticeMobile/ajaxLighton",BaseURL];
        
        NSString * url = [NSString stringWithFormat:@"%@?sys_username=%@&sys_auto_authenticate=true&sys_password=%@&id=%@&imToken=%@&dataSourceName=%@",string,_userName,_password,self.ID,self.token,_dataSourceName];
        
        // 关注消息
        [TYHHttpTool gets:url params:nil success:^(id json) {
            
            NSLog(@"json == %@",json);
            
        } failure:^(NSError *error) {
            NSLog(@"error == %@",error);
        }];
        
        self.attentionBtn.selected = !self.attentionBtn.selected;
        
        self.attentionBigBtn.selected = !self.attentionBigBtn.selected;
        
        NSString * str = [NSString stringWithFormat:NSLocalizedString(@"APP_note_hasAttention", nil)];
        [self.view makeToast:str duration:1 position:nil];
        
        self.model.attentionFlag = YES;
    }
    
}

- (IBAction)sendBtn:(id)sender {
    
    SingleManager * manager =  [SingleManager defaultManager];
    self.manager = manager;
    manager.item = [NSString stringWithFormat:@"[%@%@]%@",NSLocalizedString(@"APP_note_transfrom", nil),self.model.sendUser,self.model.title];
    NSString * str = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_USERNAME];
    manager.content = [NSString stringWithFormat:@"\n\n\n\n[%@]转发自智微校客户端",str];
    // 转发 保存原附件Id;
    NSMutableArray * idStrArray = [NSMutableArray array];
    
    for (AttachmentModel * model in self.attachArray) {
        NSLog(@"%@",model.modelID);
        [idStrArray addObject:model.modelID];
    }
    manager.idStrArray = idStrArray;
    //  转发需要判断 是否有附件
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        
        TYHNewSendViewController * sendVc = [[TYHNewSendViewController alloc] init];
        //  带原文
        UIAlertController * alertVc = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"APP_note_forward", nil) message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        [alertVc addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"APP_note_takeToForward", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            // 转发 保存原通知的ID
            manager.idStr = self.ID;
            manager.assets = (NSMutableArray *)self.attachArray;
            [self.navigationController pushViewController:sendVc animated:YES];
        }]];
        [alertVc addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"APP_note_ignoreToForward", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
            manager.assets = (NSMutableArray *)self.attachArray;
            [self.navigationController pushViewController:sendVc animated:YES];
        }]];
        [alertVc addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"APP_General_Cancel", nil) style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [self presentViewController:alertVc animated:YES completion:nil];
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"APP_note_forward", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"APP_General_Cancel", nil) otherButtonTitles:NSLocalizedString(@"APP_note_takeToForward", nil),NSLocalizedString(@"APP_note_ignoreToForward", nil), nil];
        [alert show];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    TYHNewSendViewController * sendVc = [[TYHNewSendViewController alloc] init];
    if (buttonIndex == 1) {
        NSLog(@"buttonIndex");
        // 转发 保存原通知的ID
        self.manager.idStr = self.ID;
        self.manager.assets = (NSMutableArray *)self.attachArray;
        [self.navigationController pushViewController:sendVc animated:YES];
    } else if(buttonIndex == 2){
        self.manager.assets = (NSMutableArray *)self.attachArray;
        [self.navigationController pushViewController:sendVc animated:YES];
        NSLog(@"buttonIndex2");
    }
}
@end
