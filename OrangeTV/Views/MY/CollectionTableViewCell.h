//
//  CollectionTableViewCell.h
//  OrangeTV
//
//  Created by lanou3g on 16/3/17.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionTableViewCell : UITableViewCell
///图片
@property (weak, nonatomic) IBOutlet UIImageView *imgPic;
///时长
@property (weak, nonatomic) IBOutlet UILabel *lblPviewtime;
///标题
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
///分享数
@property (weak, nonatomic) IBOutlet UILabel *lblCount_share;
///评论数
@property (weak, nonatomic) IBOutlet UILabel *lblCount_comment;


@end
