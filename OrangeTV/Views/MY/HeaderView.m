//
//  HeaderView.m
//  OrangeTV
//
//  Created by lanou3g on 16/3/15.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "HeaderView.h"

@implementation HeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [[UILabel alloc] init];
        
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.numberOfLines = 0;
        self.label.layer.cornerRadius = 10;
        self.label.layer.masksToBounds = YES;
        self.label.font = [UIFont systemFontOfSize:18];
        [self addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(UIEdgeInsetsMake(30, 35, 5, 35));
        }];
    }
    return self;
}

@end
