//
//  PersonalViewController.h
//  OrangeTV
//
//  Created by lanou3g on 16/3/16.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *keyScrollView;

@property (weak, nonatomic) IBOutlet UITableView *collectionTableV;

@property (weak, nonatomic) IBOutlet UIView *leftline;
@property (weak, nonatomic) IBOutlet UIButton *editButton;


@end
