//
//  qcsHomeworkReleaseController.m
//  NIM
//
//  Created by 中电和讯 on 2018/5/11.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "qcsHomeworkReleaseController.h"
#import "QCSchoolDefine.h"
#import "ETTextView.h"
#import <AVFoundation/AVFoundation.h>
#import "LGAudioKit.h"
#import <Photos/Photos.h>
#import "QCSNetHelper.h"
#import "NSString+NTES.h"

#import <TZImagePickerController.h>

#import "GYZCustomCalendarPickerView.h"

#import "qcsHomeworkChooseTypeController.h"
#import "ZXCollectionCell.h"
#import "qcsHomeworkObjectController.h"

#import "HVideoViewController.h"
#import "qcsHomeworkModel.h"
#import "lame.h"

#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

#import <TZImagePickerController/TZVideoPlayerController.h>
#import <TZImagePickerController/TZAssetModel.h>
#import <SDWebImageManager.h>
#import "NIMKitMediaFetcher.h"
#import "NTESVideoViewController.h"
#import "TYHHttpTool.h"

#import "LYSDatePickerController.h"
#define DocumentPath  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface qcsHomeworkReleaseController ()<GYZCustomCalendarPickerViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,ZXCollectionCellDelegate,TZImagePickerControllerDelegate,UIDocumentInteractionControllerDelegate,LYSDatePickerSelectDelegate>


@property(nonatomic,retain)NSMutableArray *itemArray;

@property (nonatomic, weak) NSTimer *timerOf60Second;

@property (nonatomic,strong) NIMKitMediaFetcher *mediaFetcher;

@property(nonatomic,retain)NSMutableArray *delItemArray;

@property(nonatomic,copy)NSString *currentTimeString;
@end


@implementation qcsHomeworkReleaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"布置作业";
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor QCSBackgroundColor];
    
    self.mainScrollview.backgroundColor = [UIColor QCSBackgroundColor];
    
    
    self.mainCollectionBGViewLayoutHeight.constant = 1;
//    [self.chooseTimeButton setTitle:[QCSSourceHandler getDateTodayWIthSecond] forState:UIControlStateNormal];
    
    _textView.placeholder = @"请输入作业内容";
    [self setUpCollectionView];
    
    [_saveRecordButton addTarget:self action:@selector(startRecordVoice) forControlEvents:UIControlEventTouchDown];
    [_saveRecordButton addTarget:self action:@selector(cancelRecordVoice) forControlEvents:UIControlEventTouchUpOutside];
    [_saveRecordButton addTarget:self action:@selector(confirmRecordVoice) forControlEvents:UIControlEventTouchUpInside];
    [_saveRecordButton addTarget:self action:@selector(updateCancelRecordVoice) forControlEvents:UIControlEventTouchDragExit];
    [_saveRecordButton addTarget:self action:@selector(updateContinueRecordVoice) forControlEvents:UIControlEventTouchDragEnter];
    
    if (_isStudent) {
        
        
        [self.releaseButton setTitle:@"提交作业" forState:UIControlStateNormal];
        if(_studentHasSubmit)
        {
            self.title = @"提交作业";
            [self.releaseButton setTitle:@"覆盖并提交" forState:UIControlStateNormal];
        }
        else if(![QCSSourceHandler checkProductDate:_studentFinishTimeLimitDate])
        {
            self.title = @"补交作业";
            [self.releaseButton setTitle:@"补交作业" forState:UIControlStateNormal];
        }
    }
}


- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    if ([view isKindOfClass:[UIButton class]])
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}


#pragma ButtonClickedActions
- (IBAction)chooseImageOrVideoAction:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    [alertController addAction:[UIAlertAction actionWithTitle:@"拍照 或 拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (_itemArray.count>=9) {
            [weakSelf.view makeToast:@"最多支持9个附件上传" duration:1.5 position:CSToastPositionCenter];
            return ;
        }
        else
        {
            [weakSelf.mediaFetcher fetchMediaFromCamera:^(NSString *path, UIImage *image) {
                if (path) {
                    [weakSelf addObjectToItemArray:path];
                } else {
                    [weakSelf addObjectToItemArray:image];
                }
                [weakSelf ChangeCollectionViewHeight];
            }];
        }
 
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"选取图片或视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (_itemArray.count>=9) {
            [weakSelf.view makeToast:@"最多支持9个附件上传" duration:1.5 position:CSToastPositionCenter];
            return ;
        }
        else
        {
            [weakSelf.mediaFetcher fetchPhotoFromLibrary:^(NSArray *images, NSString *path, PHAssetMediaType type) {
                
                switch (type) {
                    case PHAssetMediaTypeImage:
                    {
                        for (UIImage *image in images) {
                            [weakSelf addObjectToItemArray:image];
                        }
                        if (path) {
                            if ([path.pathExtension isEqualToString:@"HEIC"])
                            {
                                //iOS 11 苹果采用了新的图片格式 HEIC ，如果采用原图会导致其他设备的兼容问题，在上层做好格式的兼容转换,压成 jpeg
                                UIImage *image = [UIImage imageWithContentsOfFile:path];
                                [weakSelf addObjectToItemArray:image];
                            }
                            else
                            {
                                UIImage *image = [UIImage imageWithContentsOfFile:path];
                                [weakSelf addObjectToItemArray:image];
                            }
                            
                        }
                        [weakSelf ChangeCollectionViewHeight];
                    }
                        break;
                    case PHAssetMediaTypeVideo:
                    {
                        [weakSelf addObjectToItemArray:path];
                        [weakSelf ChangeCollectionViewHeight];
                    }
                        break;
                    default:
                        return;
                }
                
            }];
        }
        
    }]];


    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [_textView resignFirstResponder];
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.textView.isFirstResponder == YES) {
        [self.view endEditing:YES];
    }
}



- (IBAction)saveRecordAction:(id)sender {
    
//    [self startRecordVoice];
//    tempController *con = [tempController new];
//    [self.navigationController pushViewController:con animated:YES];
}


- (IBAction)chooseObjectAction:(id)sender {
    
    qcsHomeworkObjectController *oView = [qcsHomeworkObjectController new];
    oView.studentCourseArray = [NSMutableArray arrayWithArray:self.studentCourseArray];
    [self.navigationController pushViewController:oView animated:YES];
    
}

- (IBAction)chooseTypeAction:(id)sender {
    
    qcsHomeworkChooseTypeController *typeView = [qcsHomeworkChooseTypeController new];
    [self.navigationController pushViewController:typeView animated:YES];
    
}

- (IBAction)chooseTimeAction:(id)sender {
//    GYZCustomCalendarPickerView *pickerView = [[GYZCustomCalendarPickerView alloc]initWithTitle:@"请选择日期"];
//    pickerView.delegate = self;
//    pickerView.calendarType = GregorianCalendar;//日期类型
//    [pickerView show];
    
    
    LYSDatePickerController *datePicker = [[LYSDatePickerController alloc] init];
    datePicker.headerView.backgroundColor = [UIColor QCSThemeColor];
    datePicker.indicatorHeight = 1;
    datePicker.delegate = self;
    datePicker.headerView.centerItem.textColor = [UIColor whiteColor];
    datePicker.headerView.leftItem.textColor = [UIColor whiteColor];
    datePicker.headerView.rightItem.textColor = [UIColor whiteColor];
    datePicker.pickHeaderHeight = 40;
    datePicker.pickType = LYSDatePickerTypeDayAndTime;
    datePicker.minuteLoop = YES;
    datePicker.headerView.showTimeLabel = YES;
    datePicker.weakDayType = LYSDatePickerWeakDayTypeUSShort;
    datePicker.showWeakDay = YES;
    [datePicker setDidSelectDatePicker:^(NSDate *date) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *currentDate = [dateFormat stringFromDate:date];
        
        if([QCSSourceHandler checkProductDate:currentDate])
        {
            [self.chooseTimeButton setTitle:currentDate forState:UIControlStateNormal];
            self.chooseFinishTime = currentDate;
        }
        else
        {
            [self.view makeToast:@"选择时间不可在当前时间之前" duration:1.5 position:CSToastPositionCenter];
        }
        
    }];
    [datePicker showDatePickerWithController:self];
    
}





- (IBAction)uploadHomeworkAction:(id)sender {
    
    if ([NSString isBlankString:_chooseFinishTime]) {
        [self.view makeToast:@"请选择完成时间" duration:1.5 position:CSToastPositionCenter];
        return;
    }
    
    
    [SVProgressHUD showWithStatus:@"上传作业数据中"];
    
    
    QCSNetHelper *helper = [QCSNetHelper new];
    
    if (_isStudent) {
        if ([NSString isBlankString:_textView.text] && !_itemArray.count) {
            [self.view makeToast:@"不可以提交空的作业哦" duration:1.5 position:CSToastPositionCenter];
            [SVProgressHUD dismiss];
            return;
        }
    
        
        
        [helper submitHomeworkWithHwId:_homeworkID Content:_textView.text souceArray:_itemArray status:^(BOOL successful) {
            if (successful) {
                [SVProgressHUD dismiss];
                [self.view makeToast:@"提交作业完成" duration:1.5 position:CSToastPositionCenter];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
                
            }else
            {
                [SVProgressHUD dismiss];
                [self.view makeToast:@"提交作业失败" duration:1.5 position:CSToastPositionCenter];
            }
            
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            [self.view makeToast:@"提交作业失败" duration:1.5 position:CSToastPositionCenter];
        }];
    }
    
    
   
    
    //如果是修改然后上传,需要删除现有带ID的附件,然后itemarray的附件就是新上传的
    if (_preDetailModel) {
        [_itemArray enumerateObjectsUsingBlock:^(qcsHomeworkMediaModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![NSString isBlankString:model.itemID]) {
                [_itemArray removeObject:model];
            }
        }];
    }
    if(!_isStudent)
    {
        [helper uploadHomeworkWithPostdic:[self getPostDic] andItemSource:_itemArray andStatus:^(BOOL successful) {
            if (successful) {
                [SVProgressHUD dismiss];
                [self.view makeToast:@"发布作业完成" duration:1.5 position:CSToastPositionCenter];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
                
            }else
            {
                [SVProgressHUD dismiss];
                [self.view makeToast:@"发布作业失败" duration:1.5 position:CSToastPositionCenter];
            }
            
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            [self.view makeToast:@"发布作业失败" duration:1.5 position:CSToastPositionCenter];
        }];
        
    }
    
}


-(NSMutableDictionary *)getPostDic
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *datenow = [NSDate date];
    //----------将nsdate按formatter格式转成nsstring
    _currentTimeString = [formatter stringFromDate:datenow];
    
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    
    [postDic setValue:_chooseClassID forKey:@"eclassIds"];
    [postDic setValue:_chooseTypeID forKey:@"kind"];
    [postDic setValue:_chooseCourseID forKey:@"dboCourse.id"];
    [postDic setValue:_chooseFinishTime forKey:@"dateEnd"];
    [postDic setValue:_textView.text.length?_textView.text:@"" forKey:@"content"];
    [postDic setValue:_currentTimeString forKey:@"dateStart"];
    [postDic setValue:_chooseGradeID forKey:@"dboGrade.id"];
    
    if (_preDetailModel) {
        [postDic setValue:_homeworkID.length?_homeworkID:@"" forKey:@"id"];
        
        NSMutableString *delString = [NSMutableString string];
        [_delItemArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [delString appendFormat:@"%@,",obj];
        }];
        [postDic setValue:delString.length?delString:@"" forKey:@"attIdsDel"];
        
    }
    
    
    return postDic;
}



- (NSString *)removeSpaceAndNewline:(NSString *)str
{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return temp;
}

    
#pragma QTCustomCalendarPickerViewDelegate
//接收日期选择器选项变化的通知
- (void)notifyNewCalendar:(IDJCalendar *)cal {
    NSString *result = @"";
    if ([cal isMemberOfClass:[IDJCalendar class]]) {//阳历
        
        NSString *year =[NSString stringWithFormat:@"%@",cal.year];
        NSString *month = [cal.month intValue] > 9 ? cal.month:[NSString stringWithFormat:@"0%@",cal.month];
        NSString *day = [cal.day intValue] > 9 ? cal.day:[NSString stringWithFormat:@"0%@",cal.day];
        result = [NSString stringWithFormat:@"%@-%@-%@",year,month, day];
        
    } else if ([cal isMemberOfClass:[IDJChineseCalendar class]]) {//阴历
        
        IDJChineseCalendar *_cal=(IDJChineseCalendar *)cal;
        
        NSArray *array=[_cal.month componentsSeparatedByString:@"-"];
        NSString *dateStr = @"";
        if ([[array objectAtIndex:0]isEqualToString:@"a"]) {
            dateStr = [NSString stringWithFormat:@"%@%@",dateStr,[_cal.chineseMonths objectAtIndex:[[array objectAtIndex:1]intValue]-1]];
        } else {
            dateStr = [NSString stringWithFormat:@"%@闰%@",dateStr,[_cal.chineseMonths objectAtIndex:[[array objectAtIndex:1]intValue]-1]];
        }
        result = [NSString stringWithFormat:@"%@%@",dateStr, [NSString stringWithFormat:@"%@", [_cal.chineseDays objectAtIndex:[_cal.day intValue]-1]]];
    }
    [self.chooseTimeButton setTitle:result forState:UIControlStateNormal];
    self.chooseFinishTime = result;
    
}


#pragma mark - CollectionView
- (void)setUpCollectionView {
    
    _itemArray = [NSMutableArray array];
    
    
    if (_preDetailModel) {
        
        _delItemArray = [NSMutableArray array];
        
        NSMutableString *classString = [NSMutableString string];
        NSMutableString *classIDString = [NSMutableString string];
        
        //选择的班级赋值
        [_preDetailModel.homeworkEclassesModelArray enumerateObjectsUsingBlock:^(qcsHomeworkItemModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [classString appendFormat:@"%@,",obj.dboEclassName];
            [classIDString appendFormat:@"%@,",obj.dboEclassID];
            
        }];
        [self.chooseObjectButton setTitle:[NSString removeLastOneChar:[NSString stringWithFormat:@"%@",classString]] forState:UIControlStateNormal];
        self.chooseClassID = classIDString;
        
        //内容赋值
        self.textView.text = _preDetailModel.content;
        //完成时间
        [self.chooseTimeButton setTitle:_preDetailModel.dateEnd forState:UIControlStateNormal];
        
        //课程ID
        _chooseCourseID = [_preDetailModel.dboCourse objectForKey:@"id"];
        _chooseGradeID  = [_preDetailModel.dboGrade objectForKey:@"id"];
        
        //类型ID
        __block NSMutableString *chooseTypeIDs = [NSMutableString string];
        __block NSMutableString *chooseTypeNames = [NSMutableString string];

//        getHomeworkChooseTypeArray
        [_preDetailModel.homeworkTypesModelArray enumerateObjectsUsingBlock:^(qcsHomeworkItemModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [chooseTypeIDs appendFormat:@"%@,",obj.type];
            
            [[QCSSourceHandler getHomeworkChooseTypeArray] enumerateObjectsUsingBlock:^(QCSSourceModel *objType, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.type isEqualToString:objType.typeNum]) {
                    [chooseTypeNames appendFormat:@"%@ ",objType.itemTitle];
                }
            }];
            
        }];
        _chooseTypeID = chooseTypeIDs;
        //选择类型
        [self.chooseTypeButton setTitle:chooseTypeNames forState:UIControlStateNormal];
        
        //结束时间
        _chooseFinishTime = _preDetailModel.dateEnd;
        //开始时间
        _currentTimeString = _preDetailModel.dateStart;
        
        
        [_preDetailModel.attachmentVosModelArray enumerateObjectsUsingBlock:^(qcsHomeworkItemModel   *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
//            [_delItemArray addObject:obj.id];
            
            if ([obj.name hasSuffix:@"png"] || [obj.name hasSuffix:@"jpg"]) {
                qcsHomeworkMediaModel *mediaModel = [qcsHomeworkMediaModel new];
                mediaModel.CoverImage =  [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"%@%@",[QCSSourceHandler getImageBaseURL],obj.picUrl]];
                mediaModel.type = @"Image";
                mediaModel.itemID = obj.id;
                
                //            mediaModel.type = @"Video";
                //            mediaModel.type = @"Audio";
                
                [_itemArray addObject:mediaModel];
            }
            else if ([obj.name hasSuffix:@"MP4"] || [obj.name hasSuffix:@"mp4"]) {
                qcsHomeworkMediaModel *mediaModel = [qcsHomeworkMediaModel new];
                mediaModel.CoverImage =  [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"%@%@",[QCSSourceHandler getImageBaseURL],obj.picUrl]];
                mediaModel.type = @"Video";
                mediaModel.name = obj.name;
                mediaModel.downUrl = obj.downloadUrl;
                
                [_itemArray addObject:mediaModel];
            }else if ([obj.name hasSuffix:@"mp3"] || [obj.name hasSuffix:@"MP3"]) {
                qcsHomeworkMediaModel *mediaModel = [qcsHomeworkMediaModel new];
                mediaModel.type = @"Audio";
                mediaModel.CoverImage = [UIImage imageNamed:@""];
                mediaModel.name = obj.name;
                mediaModel.downUrl = obj.downloadUrl;
                [_itemArray addObject:mediaModel];
            }
            
        }];
    }
    
    self.view.backgroundColor = [UIColor QCSBackgroundColor];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    flowLayout.itemSize = CGSizeMake((SCREEN_WIDTH - 10) / 6, (SCREEN_WIDTH - 10) / 6);
    flowLayout.minimumInteritemSpacing=5; //cell之间左右的
    flowLayout.minimumLineSpacing=5;      //cell上下间隔
    flowLayout.sectionInset = UIEdgeInsetsMake(6, 0, 0, 0);
    
    _mainCollectionBGView.collectionViewLayout = flowLayout;
    _mainCollectionBGView.backgroundColor = [UIColor QCSBackgroundColor];
    _mainCollectionBGView.dataSource = self;
    _mainCollectionBGView.delegate = self;
    _mainCollectionBGView.bounces = NO;
    
    [_mainCollectionBGView registerClass:[ZXCollectionCell class] forCellWithReuseIdentifier:@"ZXCollectionCell"];
    
    [self ChangeCollectionViewHeight];
}


#pragma mark - Collection View Data Source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _itemArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identify = @"ZXCollectionCell";
    ZXCollectionCell *cell = (ZXCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    if (!cell) {
        NSLog(@"无法创建CollectionViewCell时打印，自定义的cell就不可能进来了。");
    }
    cell.delegate = self;
    cell.model = _itemArray[indexPath.row];
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}


-(void)moveImageBtnClick:(ZXCollectionCell *)aCell
{
    NSIndexPath *indexPath = [_mainCollectionBGView indexPathForCell:aCell];
    qcsHomeworkMediaModel *model = _itemArray[indexPath.row];
    
    NSString *delString = model.itemID;
    [_delItemArray addObject:delString];
    [_itemArray removeObject:model];
    
    
    [_mainCollectionBGView reloadData];
    [self ChangeCollectionViewHeight];
}
-(void)showAlertController:(ZXCollectionCell *)aCell
{
    
    NSIndexPath *indexPath = [_mainCollectionBGView indexPathForCell:aCell];
    
    qcsHomeworkMediaModel *model = _itemArray[indexPath.row];
    
    if (_preDetailModel) {
        if ([model.type isEqualToString:@"Image"]) {
            MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
            NSMutableArray *photos = [NSMutableArray array];
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.image = model.CoverImage;
            [photos addObject:photo];
            browser.photos = photos;
            browser.currentPhotoIndex = 0;
            [browser show];
        }
        else if([model.type isEqualToString:@"Video"] || [model.type isEqualToString:@"Audio"]) {
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString * paths = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",_homeworkID,model.name]];
            
            if (![fileManager fileExistsAtPath:paths])
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确定下载此项目吗?" message:nil preferredStyle:UIAlertControllerStyleAlert];
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }]];
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    TYHHttpTool *tool = [[TYHHttpTool alloc]init];
                    [tool downloadInferface:[NSString stringWithFormat:@"%@%@",[QCSSourceHandler getImageBaseURL],model.downUrl] downloadSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        
                        NSData *data = (NSData *)responseObject;
                        [data writeToFile:paths atomically:YES];
                        
                    } downloadFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        
                        [self.view makeToast:@"下载失败" duration:1.5 position:CSToastPositionCenter];
                        
                    } progress:^(float progress) {
                        [SVProgressHUD showProgress:progress status:[NSString stringWithFormat:@"下载中:%f%%",progress]];
                        if (progress == 1) {
                            [SVProgressHUD dismiss];
                            
                        }
                    }];
                    
                }]];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else
            {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                NSURL *url = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
                
                NSURL *path = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",_homeworkID,model.name]];
                
                UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: path];
                
                interactionController.delegate = self;
                [interactionController presentPreviewAnimated:YES];
                CGRect navRect = self.navigationController.navigationBar.frame;
                navRect.size =CGSizeMake(1500.0f,40.0f);
            }
    }
//        NTESVideoViewItem *item = [NTESVideoViewItem new];
//        item.itemId = @"";
//        item.path = [NSString stringWithFormat:@"%@",model.URL];
//        item.url =[NSString stringWithFormat:@"%@",model.URL];
//        NTESVideoViewController *controller = [[NTESVideoViewController alloc]initWithVideoViewItem:item];
//        [self.navigationController pushViewController:controller animated:YES];
    }
    else
    {
        if ([model.type isEqualToString:@"Image"]) {
            MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
            NSMutableArray *photos = [NSMutableArray array];
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.image = model.CoverImage;
            [photos addObject:photo];
            browser.photos = photos;
            browser.currentPhotoIndex = 0;
            [browser show];
        }
        else
        {
            UIDocumentInteractionController *interactionController =
            [UIDocumentInteractionController interactionControllerWithURL: model.URL];
            interactionController.delegate = self;
            [interactionController presentPreviewAnimated:YES];
            CGRect navRect =self.navigationController.navigationBar.frame;
            navRect.size =CGSizeMake(1500.0f,40.0f);
            //显示包含预览的菜单项
            //        [interactionController presentOptionsMenuFromRect:navRect inView:self.view animated:YES];
        }
        
    }
    
}




#pragma mark - ChangeCollectionViewHeight
-(void)ChangeCollectionViewHeight
{
    if (_itemArray.count == 0) {
        self.mainCollectionBGViewLayoutHeight.constant = 1;
    }
    else if (_itemArray.count >= 1&& _itemArray.count <= 5) {
        self.mainCollectionBGViewLayoutHeight.constant = SCREEN_WIDTH / 6 + 5;
    }else if(_itemArray.count >= 6&& _itemArray.count <= 10)
    {
        self.mainCollectionBGViewLayoutHeight.constant = SCREEN_WIDTH / 6 * 2 + 10;
    }
    
    [_mainCollectionBGView reloadData];
}


-(void)addObjectToItemArray:(id)object
{
    qcsHomeworkMediaModel *model = [[qcsHomeworkMediaModel alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    dateString = [self removeSpaceAndNewline:dateString];
    
    if ([object isKindOfClass:[UIImage class]]) {
        model.fileName = [NSString stringWithFormat:@"%@.jpeg",dateString];
        model.CoverImage = object;
        model.type = @"Image";
        model.mimeType = @"image/png";
        [_itemArray addObject:model];
    }
    else if ([object isKindOfClass:[NSString class]]) {
        model.fileName = [NSString stringWithFormat:@"%@.MP4",dateString];
        model.URL = [[NSURL alloc]initFileURLWithPath:object];
        model.type = @"Video";
        model.mimeType = @"video/mpeg4";
        model.CoverImage = [QCSSourceHandler getCoverImageByVideoURL:[[NSURL alloc]initFileURLWithPath:object]];
        [_itemArray addObject:model];
    }
    
    
    if (_itemArray.count > 9) {
        [self.view makeToast:@"最多支持9个附件上传" duration:1.5 position:CSToastPositionCenter];
        
        [_itemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx >=9) {
                [_itemArray removeObject:obj];
            }
        }];
    }
}

//#pragma mark - CollectionView Layout
//-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGSize itemSize = CGSizeMake(75, 25);
//    return itemSize;
//
//}



#pragma mark - Private Methods

/**
 *  开始录音
 */
- (void)startRecordVoice{
    

    __block BOOL isAllow = 0;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                isAllow = 1;
            } else {
                isAllow = 0;
            }
        }];
    }
    if (isAllow) {
        //        //停止播放
        [[LGAudioPlayer sharePlayer] stopAudioPlayer];
        //        //开始录音
        [[LGSoundRecorder shareInstance] startSoundRecord:self.mainScrollview recordPath:[self recordPath]];
        //开启定时器
        if (_timerOf60Second) {
            [_timerOf60Second invalidate];
            _timerOf60Second = nil;
        }
        _timerOf60Second = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(sixtyTimeStopSendVodio) userInfo:nil repeats:YES];
    } else {
        
    }
}

/**
 *  录音结束
 */
- (void)confirmRecordVoice {
    if ([[LGSoundRecorder shareInstance] soundRecordTime] < 1.0f) {
        if (_timerOf60Second) {
            [_timerOf60Second invalidate];
            _timerOf60Second = nil;
        }
        [self showShotTimeSign];
        return;
    }
    
    if ([[LGSoundRecorder shareInstance] soundRecordTime] < 61) {
        [self sendSound];
        [[LGSoundRecorder shareInstance] stopSoundRecord:self.mainScrollview];
    }
    if (_timerOf60Second) {
        [_timerOf60Second invalidate];
        _timerOf60Second = nil;
    }
}

/**
 *  更新录音显示状态,手指向上滑动后 提示松开取消录音
 */
- (void)updateCancelRecordVoice {
    [[LGSoundRecorder shareInstance] readyCancelSound];
}

/**
 *  更新录音状态,手指重新滑动到范围内,提示向上取消录音
 */
- (void)updateContinueRecordVoice {
    [[LGSoundRecorder shareInstance] resetNormalRecord];
}

/**
 *  取消录音
 */
- (void)cancelRecordVoice {
    [[LGSoundRecorder shareInstance] soundRecordFailed:self.mainScrollview];
}

/**
 *  录音时间短
 */
- (void)showShotTimeSign {
    [[LGSoundRecorder shareInstance] showShotTimeSign:self.mainScrollview];
}

- (void)sixtyTimeStopSendVodio {
    
    int countDown = 60 - [[LGSoundRecorder shareInstance] soundRecordTime];
    NSLog(@"countDown is %d soundRecordTime is %f",countDown,[[LGSoundRecorder shareInstance] soundRecordTime]);
    if (countDown <= 10) {
        [[LGSoundRecorder shareInstance] showCountdown:countDown - 1];
    }
    if ([[LGSoundRecorder shareInstance] soundRecordTime] >= 59 && [[LGSoundRecorder shareInstance] soundRecordTime] <= 60) {
        
        [_saveRecordButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        if (_timerOf60Second) {
            [_timerOf60Second invalidate];
            _timerOf60Second = nil;
        }
    }
}

/**
 *  语音文件存储路径
 *
 *  @return 路径
 */
- (NSString *)recordPath {
    NSString *filePath = [DocumentPath stringByAppendingPathComponent:@"SoundFile"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }
    return filePath;
}

#pragma mark  显示录音
- (void)sendSound {
    
    if (_itemArray.count>=9) {
        [self.view makeToast:@"最多支持9个附件上传" duration:1.5 position:CSToastPositionCenter];
        return ;
    }
    else
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
        dateString = [self removeSpaceAndNewline:dateString];
        
        qcsHomeworkMediaModel *messageModel = [[qcsHomeworkMediaModel alloc] init];
        messageModel.soundFilePath = [[LGSoundRecorder shareInstance] soundFilePath]; //caf文件路径
        messageModel.seconds = [[LGSoundRecorder shareInstance] soundRecordTime];
        messageModel.type = @"Audio";
        messageModel.mimeType = @"audio/mp3";
        messageModel.fileName = [NSString stringWithFormat:@"%@.mp3",dateString];
        messageModel.URL = [[NSURL alloc]initFileURLWithPath:[self audio_PCMtoMP3:messageModel.soundFilePath]];
        
        NSLog(@"recorder sound file path %@",messageModel.soundFilePath);
        
        //    self.messageModel.mp3FilePath = [self formatConversionToMp3];
        messageModel.mp3FilePath = [self audio_PCMtoMP3:messageModel.soundFilePath];
        [self.itemArray addObject:messageModel];
        
        [self ChangeCollectionViewHeight];
    }
}


- (NSString*)audio_PCMtoMP3:(NSString *)path
{
    
    NSString *cafFilePath = path;    //caf文件路径
    
    NSString* fileName = [NSString stringWithFormat:@"/voice-%5.2f.mp3", [[NSDate date] timeIntervalSince1970] ];//存储mp3文件的路径
    
    NSString *mp3FileName = [[DocumentPath stringByAppendingPathComponent:@"SoundFile"] stringByAppendingPathComponent:fileName];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FileName cStringUsingEncoding:4], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
//        lame_set_num_channels(lame,1);//设置1为单通道，默认为2双通道
        lame_set_in_samplerate(lame, 8000.0);
        
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        
    }

    return mp3FileName;
}

#pragma mark -UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return [self navigationController];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(UIImage*)imageFromSdcacheWithURL:(NSString *)url
{
    __block UIImage *thumbnailImage = [UIImage new];
    [[SDWebImageManager sharedManager]diskImageExistsForURL:[NSURL URLWithString:url] completion:^(BOOL isInCache) {
        if (isInCache) {
            thumbnailImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:url];
        }
    }];
    return thumbnailImage;
}


#pragma mark - Private
- (NIMKitMediaFetcher *)mediaFetcher
{
    if (!_mediaFetcher) {
        _mediaFetcher = [[NIMKitMediaFetcher alloc] init];
    }
    return _mediaFetcher;
}

-(void)viewWillAppear:(BOOL)animated
{
    if(_isStudent)
    {
        self.bgViewType.hidden = YES;
        self.bgvViewObj.hidden = YES;
        self.bgViewFinishTime.hidden = YES;
    }
    
    if (![NSString isBlankString:_chooseClassID] && ![NSString isBlankString:_chooseClassNames]) {
        [self.chooseObjectButton setTitle:_chooseClassNames forState:UIControlStateNormal];
    }
    if (![NSString isBlankString:_chooseTypeID] && ![NSString isBlankString:_chooseTypeName]) {
        [self.chooseTypeButton setTitle:_chooseTypeName forState:UIControlStateNormal];
    }
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
