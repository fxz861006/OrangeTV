//
//  StyleCollectionViewCell.m
//  OrangeTV
//
//  Created by lanou3g on 16/3/15.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "StyleCollectionViewCell.h"

@implementation StyleCollectionViewCell

- (void)awakeFromNib {
    
    
    self.labelText.layer.cornerRadius = 15;
    self.labelText.layer.masksToBounds = YES;
    self.labelText.font = [UIFont systemFontOfSize:14];
    self.labelText.textColor = kColor(57, 163, 240, 1);
}

@end
