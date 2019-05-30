//
//  TYHUploadNewStateController.m
//  NIM
//
//  Created by 中电和讯 on 2017/4/17.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "TYHUploadNewStateController.h"
#import <TZImagePickerController.h>
#import "ETTextView.h"
#import "NSString+Empty.h"
#import "AreaHelper.h"
#import "TYHChossClassViewController.h"
#import "ACMediaFrame.h"

@interface TYHUploadNewStateController ()<UITextViewDelegate>

@property (nonatomic, strong) ETTextView *contentView;

//获取用户所属班级ID
@property(nonatomic,copy)NSString *departmentID;

@property(nonatomic,retain)TYHChossClassViewController *chooseView;

//上传图片数组
@property (nonatomic, strong) NSMutableArray *images;

@property(nonatomic,assign)NSInteger uploadImageViewHeigh;
@property(nonatomic,retain)UIView *bgView;
@end

@implementation TYHUploadNewStateController
{
    UIBarButtonItem * rightBtn;
    UIButton *chooseClassBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"APP_Circle_newState", nil);
    [self initView];
    [self createLeftBar];
    _images = [NSMutableArray array];
    
    self.view.backgroundColor = [UIColor TabBarColorGray];
    
    [self viewWillAppear:YES];
}


#pragma mark - ButtonClicked
-(void)sendPhotoAction
{
    if ([self isEmpty]) {
        [self.view makeToast:NSLocalizedString(@"APP_Circle_shareNewState", nil) duration:1 position:CSToastPositionCenter];
        return;
    }
    else if (_isClassPaper) {
        _departmentID = _tmpClassModel.classID;
        if ([NSString isBlankString:_departmentID]) {
            [self.view makeToast:NSLocalizedString(@"APP_Circle_chooseClass", nil) duration:1 position:CSToastPositionCenter];
            return;
        }
        else
        {
            [self.view endEditing:YES];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelFont = [UIFont systemFontOfSize:12];
            AreaHelper *helper = [[AreaHelper alloc]init];
            if (![NSString isBlankString:_tmpClassModel.classID]) {
                [helper uploadClassPaperCommentWith:_contentView.text tadID:@"123" publicFlag:@"1" departmentId:_tmpClassModel.classID location:nil url:nil uploadFiles:_images andStatus:^(BOOL successful, NSMutableArray *afterUploadInfo) {
                    if (successful) {
                        [hud removeFromSuperview];
                        [self.view endEditing:YES];
                        [self.view makeToast:NSLocalizedString(@"APP_Circle_shareSuccess", nil) duration:1 position:CSToastPositionCenter];
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.navigationController popViewControllerAnimated:YES];
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshFriendArea" object:nil];
                            
                        });
                    }
                } failure:^(NSError *error) {
                    [self.view endEditing:YES];
                    [self.view makeToast:NSLocalizedString(@"APP_Circle_shareFailed", nil) duration:1 position:CSToastPositionCenter];
                }];
            }
            }
    }
    else
    {
        [self.view endEditing:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelFont = [UIFont systemFontOfSize:12];
        AreaHelper *helper = [[AreaHelper alloc]init];
        if (![NSString isBlankString:_tmpClassModel.classID]) {
            [helper uploadClassPaperCommentWith:_contentView.text tadID:@"123" publicFlag:@"1" departmentId:_tmpClassModel.classID location:nil url:nil uploadFiles:_images andStatus:^(BOOL successful, NSMutableArray *afterUploadInfo) {
                if (successful) {
                    [hud removeFromSuperview];
                    [self.view endEditing:YES];
                    [self.view makeToast:NSLocalizedString(@"APP_Circle_shareSuccess", nil) duration:1 position:CSToastPositionCenter];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:YES];
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshFriendArea" object:nil];
                        
                    });
                }
            } failure:^(NSError *error) {
                [self.view endEditing:YES];
                [self.view makeToast:NSLocalizedString(@"APP_Circle_shareFailed", nil) duration:1 position:CSToastPositionCenter];
            }];
        }
        else
        {
            [helper uploadCommentWith:_contentView.text tadID:@"123" publicFlag:@"1" location:@"北京" url:nil uploadFiles:_images andStatus:^(BOOL successful, NSMutableArray *afterUploadInfo) {
                if (successful) {
                    [hud removeFromSuperview];
                    [self.view endEditing:YES];
                    [self.view makeToast:NSLocalizedString(@"APP_Circle_shareSuccess", nil) duration:1 position:CSToastPositionCenter];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:YES];
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshFriendArea" object:nil];
                        
                    });
                }
            } failure:^(NSError *error) {
                [self.view endEditing:YES];
                [self.view makeToast:NSLocalizedString(@"APP_Circle_shareFailed", nil) duration:1 position:CSToastPositionCenter];
            }];
        }
    }
}

-(void)returnClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)pushAction
{
    _chooseView = [[TYHChossClassViewController alloc]init];
    _chooseView.settingArray = _classArray;
    [self.navigationController pushViewController:_chooseView animated:YES];
}

#pragma mark - 逻辑
-(BOOL)isEmpty
{
    if ([NSString isBlankString:_contentView.text] && _images.count == 0) {
        return YES;
    }
    else return NO;
}



#pragma mark - ViewConfig
-(void) initView
{
    _contentView = [[ETTextView alloc] initWithFrame:CGRectMake(10, 8, SCREEN_WIDTH - 20, 100)];
    _contentView.layer.cornerRadius = 5;
    _contentView.layer.borderWidth = 1.0f;
    _contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _contentView.scrollEnabled = YES;
    _contentView.delegate = self;
    _contentView.placeholder = NSLocalizedString(@"APP_Circle_momentThinking", nil);
    _contentView.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:self.contentView];
    
    [self uploadViewInit];
    if (!_bgView.superview) {
        [self.view addSubview:_bgView];
    }
}

// 初始化上传视图
-(void)uploadViewInit
{
    //1、得到默认布局高度（唯一获取高度方法）
    CGFloat height = [ACSelectMediaView defaultViewHeight];
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(16, 116, [UIScreen mainScreen].bounds.size.width - 32, height)];
    
    //2、初始化
    ACSelectMediaView *mediaView = [[ACSelectMediaView alloc] initWithFrame:CGRectMake(0, 0, _bgView.frame.size.width, _bgView.frame.size.height)];
    
    //3、选择媒体类型：ACMediaType
    mediaView.type = ACMediaTypePhotoAndCamera;
    
    mediaView.mediaArray = [NSMutableArray array];
    
    mediaView.imageMaxCount = 9;
    //是否需要显示图片上的删除按钮
    //mediaView.showDelete = NO;
    
    //5、随时获取新的布局高度
    [mediaView observeViewHeight:^(CGFloat value) {
        _bgView.height = value ;
        _uploadImageViewHeigh = (value - 40) / 2;
        if (_uploadImageViewHeigh < 60) {
            _uploadImageViewHeigh = 0;
        }
        chooseClassBtn.frame = CGRectMake(0
                                          , _bgView.frame.origin.y + _bgView.frame.size.height + 10, self.view.frame.size.width, 30);
        //        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:3];
        //        [_mainTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    //6、随时获取已经选择的媒体文件
    [mediaView observeSelectedMediaArray:^(NSArray<ACMediaModel *> *list) {
        for (ACMediaModel *model in list) {
            NSLog(@"%@",model);
            if (![_images containsObject:model.image]) {
                [_images addObject:model.image];
            }
        }
    }];
    _bgView.backgroundColor = [UIColor clearColor];
    [_bgView addSubview:mediaView];
    
    if (_isClassPaper) {
        if (chooseClassBtn.superview) {
            [chooseClassBtn removeFromSuperview];
        }
        chooseClassBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        chooseClassBtn.frame = CGRectMake(0
                                          , _bgView.frame.origin.y + _bgView.frame.size.height + 10, self.view.frame.size.width, 30);
        chooseClassBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
        chooseClassBtn.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
        [self.view addSubview:chooseClassBtn];
        [chooseClassBtn setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
        chooseClassBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
        
        if ([NSString isBlankString:_tmpClassModel.className] ) {
            [chooseClassBtn setTitle:NSLocalizedString(@"APP_Circle_chooseClass", nil) forState:UIControlStateNormal];
        }
        else
        {
            [chooseClassBtn setTitle:[NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"APP_Circle_sendTo", nil),_tmpClassModel.className] forState:UIControlStateNormal];
        }
        [chooseClassBtn addTarget:self action:@selector(pushAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
}



-(void)createLeftBar
{
    UIBarButtonItem * leftItem = nil;
    rightBtn = nil;
    
    
    UIBarButtonItem *
    barItemInNavigationBarAppearanceProxy = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
    
    //设置字体为加粗的12号系统字，自己也可以随便设置。
    
    [barItemInNavigationBarAppearanceProxy
     setTitleTextAttributes:[NSDictionary
                             dictionaryWithObjectsAndKeys:[UIFont
                                                           boldSystemFontOfSize:15], NSFontAttributeName,nil] forState:UIControlStateNormal];
    
    
    leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    
    rightBtn = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"APP_General_Send", nil) style:UIBarButtonItemStyleDone target:self action:@selector(sendPhotoAction)];
    rightBtn.tintColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem =leftItem;
    self.navigationItem.rightBarButtonItem =rightBtn;
    
}

#pragma mark - Other
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_contentView resignFirstResponder];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if (![NSString isBlankString:_tmpClassModel.className]) {
        [chooseClassBtn setTitle:[NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"APP_Circle_sendTo", nil), _tmpClassModel.className] forState:UIControlStateNormal];
    }
}

-(void)setClassArray:(NSMutableArray *)classArray
{
    _classArray = classArray;
    if (_classArray.count > 1) {
        [chooseClassBtn setTitle:NSLocalizedString(@"APP_Circle_chooseClass", nil) forState:UIControlStateNormal];
    }
    if (_classArray.count == 1) {
        classModel *model = _classArray[0];
        _departmentID = model.classID;
        _tmpClassModel = model;
        chooseClassBtn.userInteractionEnabled = NO;
        [chooseClassBtn setTitle:[NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"APP_Circle_sendTo", nil),model.className] forState:UIControlStateNormal];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationController.navigationBar.translucent = NO;
}


-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = YES;
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
