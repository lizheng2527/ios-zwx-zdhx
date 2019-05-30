//
//  qcsClassStasticInsideXTTJCell.m
//  NIM
//
//  Created by 中电和讯 on 2018/4/9.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "qcsClassStasticInsideXTTJCell.h"
#import "QCSStasticModel.h"
#import "QCSchoolDefine.h"

#import "qcsHomeworkModel.h"


@implementation qcsClassStasticInsideXTTJCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initLabelFrame];
}


-(void)setModel:(QCSStasticModel *)model
{
    self.scoreImageView.hidden = YES;
    
    self.rankLabel.text = model.orderNumber;
    self.nameLabel.text = model.rightAnswer;
    self.scoreLabel.text = model.countStr;
    self.levelLabel.text = model.percentStr;
}

-(void)setCModel:(QCSStasticComprehensiveModel *)cModel
{
    
    if ([cModel.orderNumber isEqualToString:@"1"]) {
        
        self.scoreImageView.image = [UIImage imageNamed:@"modal1"];
        self.nameLabel.text = cModel.studentName;
        self.scoreLabel.text = cModel.totalScore;
        self.levelLabel.text = cModel.range;
        
    }else if([cModel.orderNumber isEqualToString:@"2"])
    {
        self.scoreImageView.image = [UIImage imageNamed:@"modal2"];
        self.nameLabel.text = cModel.studentName;
        self.scoreLabel.text = cModel.totalScore;
        self.levelLabel.text = cModel.range;
    }else if([cModel.orderNumber isEqualToString:@"3"])
    {
        self.scoreImageView.image = [UIImage imageNamed:@"modal3"];
        self.nameLabel.text = cModel.studentName;
        self.scoreLabel.text = cModel.totalScore;
        self.levelLabel.text = cModel.range;
    }
    else
    {
        self.scoreImageView.hidden = YES;
        self.rankLabel.text = cModel.orderNumber;
        self.nameLabel.text = cModel.studentName;
        self.scoreLabel.text = cModel.totalScore;
        self.levelLabel.text = cModel.range;
    }
    
}


-(void)setHomeworkModel:(qcsHomeworkSubmitListModel *)homeworkModel
{
    _homeworkModel = homeworkModel;
    self.rankLabel.text = homeworkModel.orderNumber;
    self.nameLabel.text = homeworkModel.name;
    self.scoreLabel.text = homeworkModel.eclassName;
    self.levelLabel.text = [homeworkModel.finishFlag isEqualToString:@"1"] ?@"查看详情":@"未完成";
  
    if ([homeworkModel.finishFlag isEqualToString:@"1"]) {
        self.levelLabel.textColor = [UIColor QCSThemeColor];
        
        if (![QCSSourceHandler isCurrentDate:homeworkModel.ft beforeInputDate:_dateEnd]) {
//            self.levelLabel.text = @"查看详情\n(补)";
//            self.levelLabel.text = @"查看详情  补";
            
            NSMutableAttributedString *textFont = [[NSMutableAttributedString alloc] initWithString:@"查看详情(补)"];
            [textFont addAttribute:NSFontAttributeName
                             value:[UIFont boldSystemFontOfSize:13.0]
                             range:[@"查看详情(补)" rangeOfString:@"(补)"]];
            [textFont addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[@"查看详情(补)" rangeOfString:@"(补)"]]; // 关键步骤，设置指定位置文字的颜色
            self.levelLabel.attributedText = textFont;
        }
    }
    
}

-(void)initLabelFrame
{
    
    _scoreImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    _scoreImageView.center = CGPointMake((SCREEN_WIDTH - 16) / 8, 22);
    [self addSubview:_scoreImageView];
    
    _lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH - 16, 1.0f)];
    _lineView.backgroundColor = [UIColor QCSBackgroundColor];
    [self addSubview:_lineView];
    
    _rankLabel.center = CGPointMake((SCREEN_WIDTH - 16) / 8, 22);
    _nameLabel.frame = CGRectMake((SCREEN_WIDTH - 16) / 4, 0,(SCREEN_WIDTH - 16) / 4 , 44);
    _scoreLabel.frame = CGRectMake((SCREEN_WIDTH - 16) / 2, 0,(SCREEN_WIDTH - 16) / 4 , 44);
    _levelLabel.frame = CGRectMake((SCREEN_WIDTH - 16) / 4 * 3, 0,(SCREEN_WIDTH - 16) / 4 , 44);
    
    
//    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(finishLabelTapAction)];
//    _levelLabel.userInteractionEnabled  = YES;
//    [_levelLabel addGestureRecognizer:ges];
}

                                   
-(void)finishLabelTapAction
{
    if (self.delegate && [_delegate respondsToSelector:@selector(didClickFinishLabelInCell:)]) {
        [self.delegate didClickFinishLabelInCell:self];
    }
}
                                   
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
