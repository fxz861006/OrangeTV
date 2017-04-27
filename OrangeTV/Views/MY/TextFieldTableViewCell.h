//
//  TextFieldTableViewCell.h
//  OrangeTV
//
//  Created by lanou3g on 16/3/21.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *userNameText;

@end
