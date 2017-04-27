//
//  QuitTableViewCell.m
//  OrangeTV
//
//  Created by lanou3g on 16/3/12.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "QuitTableViewCell.h"

@implementation QuitTableViewCell

- (void)awakeFromNib {
    self.quitButton.layer.cornerRadius = 10;
    self.quitButton.layer.masksToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)quitLogin:(UIButton *)sender {
    self.backgroundColor = [UIColor greenColor];
}

@end
