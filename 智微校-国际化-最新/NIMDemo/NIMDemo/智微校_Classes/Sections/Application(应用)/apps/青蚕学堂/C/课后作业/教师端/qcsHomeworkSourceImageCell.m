//
//  qcsHomeworkSourceImageCell.m
//  NIM
//
//  Created by 中电和讯 on 2019/1/3.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "qcsHomeworkSourceImageCell.h"
#import "qcsHomeworkModel.h"
#import "QCSchoolDefine.h"
#import <UIImageView+WebCache.h>


@implementation qcsHomeworkSourceImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sourceImageTap:)];
    
    _sourceImageView.userInteractionEnabled = YES;
    [_sourceImageView addGestureRecognizer:ges];
}

-(void)setIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
}

-(void)setHomeworkModel:(qcsHomeworkMediaModel *)homeworkModel
{
    if (homeworkModel.fileName.length) {
        NSArray *fileTypeArray = [homeworkModel.fileName componentsSeparatedByString:@"."];
        [self.sourceImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[QCSSourceHandler getImageBaseURL],homeworkModel.downUrl]] placeholderImage:[UIImage imageNamed:[self returnImageName:fileTypeArray[1]]]];
    }
    
}

-(void)sourceImageTap:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickSourceImageViewInCell:)]) {
        [self.delegate didClickSourceImageViewInCell:_indexPath];
    }
}


//- (id)transformedValue:(id)value
//{
//
//    double convertedValue = [value doubleValue];
//    int multiplyFactor = 0;
//
//    NSArray *tokens = @[@"bytes",@"KB",@"MB",@"GB",@"TB"];
//
//    while (convertedValue > 1024) {
//        convertedValue /= 1024;
//        multiplyFactor++;
//    }
//
//    return [NSString stringWithFormat:@"%4.2f %@",convertedValue, tokens[multiplyFactor]];
//}

-(NSString *)returnImageName:(NSString *)fileType
{
    if ([fileType isEqualToString:@"doc"] || [fileType isEqualToString:@"docx"]) {
        return @"qc_word";
    }
    else if ([fileType isEqualToString:@"ppt"] || [fileType isEqualToString:@"pptx"]) {
        return @"qc_ppt";
    }
    else if ([fileType isEqualToString:@"mp4"] || [fileType isEqualToString:@"mov"]|| [fileType isEqualToString:@"flv"] || [fileType isEqualToString:@"avi"] || [fileType isEqualToString:@"swf"] || [fileType isEqualToString:@"mpg"]) {
        return @"视频";
    }
    else if ([fileType isEqualToString:@"jpg"] || [fileType isEqualToString:@"jpeg"]|| [fileType isEqualToString:@"gif"]|| [fileType isEqualToString:@"png"]) {
        return @"图片";
    }
    else if ([fileType isEqualToString:@"mp3"] || [fileType isEqualToString:@"wma"]) {
        return @"音频";
    }
    else return @"暂无图片Test";
}


@end
