//
//  AboutUsViewController.m
//  OrangeTV
//
//  Created by lanou3g on 16/3/12.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *aboutUsLabel;

@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.aboutUsLabel.text = @"        橙子TV是一个优秀的开发团队为大家开发的一款休闲娱乐App，这款应用每次打开时，若在WiFi环境下，会自动为用户下载3部视频短片。这样您在吃饭、坐公交或地铁的时候就会不再无聊，没错，橙子TV就是为了丰富您的闲暇碎片时间而开发的。视频的类型您可以根据您的个人喜好进行选择设置，这里有让您忍俊不禁的搞笑视频，有让您潸然泪下的感人视频，还有让您感到惊叹的创意视频......总之，这里有各种类型的短视频，一定有属于您的那道菜。\n        我们是一个充满激情的年轻的开发团队,旨在为大家提供快乐。如果您也是短片爱好者，就赶快下载橙子TV吧。如果您有一些更好的建议给我们，可以发送邮件给我们，或者添加我们的开发者微信，我们欢迎大家给我们提出任何好的建议。                                                                                                        联系我们 email：15238337696@163.com";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
