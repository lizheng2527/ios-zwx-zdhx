//
//  qcsHomeworkDetailController.m
//  NIM
//
//  Created by 中电和讯 on 2018/12/27.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "qcsHomeworkDetailController.h"
#import "qcsHomeworkModel.h"
#import "QCSchoolDefine.h"
#import "qcsClassDetailInsideJXKJCell.h"
#import "TYHHttpTool.h"
#import "NTESVideoViewController.h"
#import "qcsHomeworkSourceImageCell.h"

@interface qcsHomeworkDetailController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIDocumentInteractionControllerDelegate,qcsHomeworkSourceImageCellDelegate>

@end

@implementation qcsHomeworkDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (_model) {
        self.title = _model.name;
        _contentLabel.text = _model.content;
        _finisthTimeLabel.text = _model.ft;
        
        if ([QCSSourceHandler isCurrentDate:_model.ft  beforeInputDate:_dateEnd]) {
            self.submitStatusLabel.text = @"已提交";
        }else self.submitStatusLabel.text = @"补交";
        
    }
    
    [self tableViewConfig];
    self.view.backgroundColor = [UIColor QCSBackgroundColor];
}



#pragma mark - Collection View Data Source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _model.fileItemModelArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    

            qcsHomeworkSourceImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"qcsHomeworkSourceImageCell" forIndexPath:indexPath];
            if (_model.fileItemModelArray.count) {
                cell.homeworkModel = _model.fileItemModelArray[indexPath.row];
                cell.indexPath = indexPath;
            }
    cell.delegate = self;
            return cell;

}


-(void)didClickSourceImageViewInCell:(NSIndexPath *)indexPath
{
    {
    qcsHomeworkMediaModel *model = _model.fileItemModelArray[indexPath.row];
    
//    qcsHomeworkSourceImageCell *cell = (qcsHomeworkSourceImageCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString * paths = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",model.size,model.fileName]];
    
    if (![fileManager fileExistsAtPath:paths])
    {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认下载该文件吗" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"APP_General_Confirm", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
            NSString * paths = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",model.size,model.fileName]];
            
            NSString *downloadURL = [NSString stringWithFormat:@"%@%@",[QCSSourceHandler getImageBaseURL],model.downUrl];
            
            TYHHttpTool *downloadHelper = [[TYHHttpTool alloc]init];
            [downloadHelper downloadInferface:downloadURL downloadSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSData * data = (NSData *)responseObject;
                [data writeToFile:paths atomically:YES];
                
            } downloadFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self.view makeToast:@"下载失败" duration:1.5 position:CSToastPositionCenter];
            } progress:^(float progress) {
                
                //                        cell.processView.hidden = NO;
                [SVProgressHUD showProgress:progress];
                //                        cell.processView.progress = progress;
                if (progress == 1) {
                    //                            [cell.processView setHidden:YES];
                    [SVProgressHUD dismiss];
                }
            }];
            
        }];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"APP_General_Cancel", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alertController addAction:noAction];
        [alertController addAction:yesAction];
        
        [self presentViewController:alertController animated:yesAction completion:nil];
    }
    else
    {
        
        
        //                        NTESVideoViewItem *item = [NTESVideoViewItem new];
        //                        item.itemId = @"";
        //                        item.path = paths;
        //                        item.url = paths;
        //                        NTESVideoViewController *controller = [[NTESVideoViewController alloc]initWithVideoViewItem:item];
        //                        [self.navigationController pushViewController:controller animated:YES];
        
        
        
        UIDocumentInteractionController *interactionController =
        [UIDocumentInteractionController interactionControllerWithURL: [NSURL fileURLWithPath:paths]];
        interactionController.delegate = self;
        [interactionController presentPreviewAnimated:YES];
        CGRect navRect =self.navigationController.navigationBar.frame;
        navRect.size =CGSizeMake(1500.0f,40.0f);
        
        
        //                UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: [NSURL fileURLWithPath:paths]];
        //
        //                interactionController.delegate = self;
        //                [interactionController presentPreviewAnimated:YES];
        //                CGRect navRect =self.navigationController.navigationBar.frame;
        //                navRect.size =CGSizeMake(1500.0f,40.0f);
        
        //显示包含预览的菜单项
        //                [interactionController presentOptionsMenuFromRect:navRect inView:self.view animated:YES];
    }
    
}
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - CollectionView Layout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
   
            CGSize itemSize = CGSizeMake(75, 75);
            return itemSize;

}

//#pragma mark - qcsClassDetailInsideXZTCellDelegate
//-(void)ImageViewClicked:(qcsClassDetailInsideXZTCell *)cell
//{
//
//    MJPhotoBrowser *brower = [[MJPhotoBrowser alloc] init];
//    NSMutableArray *photos = [NSMutableArray array];
//    MJPhoto *photo = [[MJPhoto alloc] init];
//    photo.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[QCSSourceHandler getImageBaseURL],cell.model.urls]] ;
//    [photos addObject:photo];
//    brower.photos = photos;
//    brower.currentPhotoIndex = 0;
//    [brower show];
//}
//

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self.navigationController;
}


#pragma mark - Other
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarTintColor:[UIColor QCSThemeColor]];
    
    [self.view endEditing:YES];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self.navigationController.navigationBar setBarTintColor:[UIColor QCSThemeColor]];
    [SVProgressHUD dismiss];
}



#pragma mark - ViewConfig
-(void)tableViewConfig
{
    self.view.backgroundColor = [UIColor QCSBackgroundColor];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    flowLayout.itemSize = CGSizeMake(80, 80);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 5; //调节Cell间距
//    flowLayout.sectionInset = UIEdgeInsetsMake(2,2,2,2);
    
    _collectionView.collectionViewLayout = flowLayout;
    
    _collectionView.backgroundColor = [UIColor QCSBackgroundColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.bounces = NO;
    [_collectionView registerNib:[UINib nibWithNibName:@"qcsHomeworkSourceImageCell" bundle:nil] forCellWithReuseIdentifier:@"qcsHomeworkSourceImageCell"];
    
    // 注册headView
    _collectionView.ly_emptyView = [LYEmptyView emptyViewWithImageStr:@"noData"
                                                             titleStr:NSLocalizedString(@"APP_General_noData", nil)
                                                            detailStr:@""];
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
