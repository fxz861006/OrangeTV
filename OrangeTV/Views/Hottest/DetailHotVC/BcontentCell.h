//
//  BcontentCell.h
//  OrangeTV
//
//  Created by lanou3g on 16/3/21.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BcontentCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *concent;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UIButton *zan;
@property (strong, nonatomic) IBOutlet UIImageView *userIMG;
@property(nonatomic,strong)UILabel * reply;
@property(nonatomic,strong)UILabel * replyname;
@property(nonatomic,strong)UILabel * topline;

//根据传过来的参数字符串计算出高度
+(CGFloat)cellHightWithString:(NSString *)str;
@end
