//
//  TabBarViewController.m
//  OrangeTV
//
//  Created by PengchengWang on 16/3/10.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "TabBarViewController.h"
#import "ShowViewController.h"
#import "HottestViewController.h"
#import "MyViewController.h"
#import "AppDelegate.h"
@interface TabBarViewController ()

@property(nonatomic,strong)AppDelegate *appDelegate;
@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViews];
}

-(void)setViews{
    ShowViewController *showVC = [[ShowViewController alloc]init];
    HottestViewController *hottestVC = [[HottestViewController alloc]init];
    MyViewController *myVC = [[MyViewController alloc]init];
    UINavigationController *showNvg = [[UINavigationController alloc]initWithRootViewController:showVC];
    UINavigationController *hottestNvg = [[UINavigationController alloc]initWithRootViewController:hottestVC];
    UINavigationController *myNvg = [[UINavigationController alloc]initWithRootViewController:myVC];
    self.viewControllers = @[showNvg,hottestNvg,myNvg];
    showNvg.tabBarItem.title = @"OTV";
    showNvg.tabBarItem.image = [UIImage imageNamed:@"magicbox_normal"];
    hottestNvg.tabBarItem.title = @"热门";
    hottestNvg.tabBarItem.image = [UIImage imageNamed:@"explore_normal"];
    myNvg.tabBarItem.title = @"MY";
    myNvg.tabBarItem.image = [UIImage imageNamed:@"mine_normal"];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//支持的方向
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
    
}


@end
