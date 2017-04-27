//
//  BaseViewController.m
//  OrangeTV
//
//  Created by PengchengWang on 16/3/9.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "BaseViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
@interface BaseViewController ()
@property(nonatomic ,strong)MBProgressHUD * HUD;
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.HUD = [[MBProgressHUD alloc]initWithView:self.view];
    self.HUD.mode =  MBProgressHUDModeIndeterminate;
    self.HUD.dimBackground = NO;
    self.HUD.color = [UIColor clearColor];
    [self.view addSubview:self.HUD];
    [self.HUD show:YES];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
