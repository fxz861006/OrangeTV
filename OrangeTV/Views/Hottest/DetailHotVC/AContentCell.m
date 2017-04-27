//
//  AContentCell.m
//  OrangeTV
//
//  Created by lanou3g on 16/3/16.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "AContentCell.h"
#import "BcontentCell.h"
@implementation AContentCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addAllViews];
    }
    return self;
}


- (void)addAllViews{
    self.topline = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, kScreenWidth, 1)];
    self.topline.backgroundColor = kColor(231, 231, 231, 0.8);
  
   self.userIMG = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
    self.name = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 100, 15)];
    
    self.concent = [[UILabel alloc]init];
    self.concent.numberOfLines = 0;
    self.time = [[UILabel alloc]init];
    [self.contentView addSubview:self.topline];
    [self.contentView addSubview:self.userIMG];
    [self.contentView addSubview:self.name];
    [self.contentView addSubview:self.concent];
    self.concent.numberOfLines = 0;
    [self.concent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.name.mas_left);
        make.top.mas_equalTo(self.name.mas_bottom).offset(5);
        make.width.equalTo(@(kScreenWidth-70));
    }];
    [self.contentView addSubview:self.time];
    [self.time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.concent.mas_bottom).offset(5);
        make.left.equalTo(self.concent.mas_left);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    

    
}


+(CGFloat)cellHightWithString:(NSString *)str{
    
    //限定宽度的参数
    //宽度也一定是跟你的控件设定的宽度一样
    CGSize size = CGSizeMake(kScreenWidth-70, MAXFLOAT);
    //限定字体大小的参数
    //这里写的字体大小一定要跟你控件中设定的字体大小一样啊
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:15]};
    //计算一段文本在限定宽度和限定字体大小的情况下占据的矩形框大小.
    CGRect rect = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    return rect.size.height+60;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
