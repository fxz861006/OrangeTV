//
//  FooterView.m
//  OrangeTV
//
//  Created by lanou3g on 16/3/15.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "FooterView.h"

@implementation FooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.saveButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        self.saveButton.frame = CGRectMake(0, 0, self.frame.size.width, 40);
        self.saveButton.backgroundColor = [UIColor greenColor];
        self.saveButton.layer.cornerRadius = 10;
        self.saveButton.layer.masksToBounds = YES;
        self.saveButton.highlighted = YES;
        [self addSubview:self.saveButton];
        [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(UIEdgeInsetsMake(10, 30, 10, 30));
        }];
    }
    return self;
}

@end
