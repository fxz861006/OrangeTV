//
//  HotCell.h
//  OrangeTV
//
//  Created by lanou3g on 16/3/10.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *IMV;
@property (weak, nonatomic) IBOutlet UILabel *Title;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *Share;
@property (weak, nonatomic) IBOutlet UILabel *commentCount;

@end
