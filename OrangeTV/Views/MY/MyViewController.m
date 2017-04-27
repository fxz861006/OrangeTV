//
//  MyViewController.m
//  OrangeTV
//
//  Created by PengchengWang on 16/3/10.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "MyViewController.h"

#import <MessageUI/MFMailComposeViewController.h>

#import "LoginViewController.h"
#import "StyleViewController.h"
#import "PersonalViewController.h"
#import "UserTableViewCell.h"
#import "CallUsViewController.h"
#import "AboutUsViewController.h"
@interface MyViewController ()<UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mineTableView;
@property(nonatomic,strong) UILabel * la;
@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    self.title = @"我";
    [self setDelegate];
    
    [self.mineTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.mineTableView registerNib:[UINib nibWithNibName:@"UserTableViewCell" bundle:nil] forCellReuseIdentifier:@"UserTableViewCell"];
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    [self.mineTableView reloadData];
    self.tabBarController.tabBar.hidden = NO;
}

#pragma mark - 设置代理
-(void)setDelegate{
    self.mineTableView.delegate = self;
    self.mineTableView.dataSource = self;
}


#pragma mark - cell个数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return 1;
    }
    return 5;
}
#pragma mark - 组数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
#pragma mark - cell的显示内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        UserTableViewCell *userCell = [tableView dequeueReusableCellWithIdentifier:@"UserTableViewCell" forIndexPath:indexPath];
        
        userCell.imgV.layer.cornerRadius = 30;
        userCell.imgV.layer.masksToBounds = YES;
        AVUser *currentUser = [AVUser currentUser];
        if (currentUser != nil) {
            
            AVQuery *query = [AVQuery queryWithClassName:@"UserInfo"];
            //设置请求查询条件
            [query whereKey:@"userObjectId" equalTo:currentUser.objectId];
            //找到符合条件的数据
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (objects.count) {
                    NSDictionary *dic = objects[0];
                    userCell.lblUserName.text = dic[@"userName"];
                    [userCell.imgV sd_setImageWithURL:dic[@"userIconUrl"]];
                } else {
                    // 输出错误信息
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        } else {
            userCell.lblUserName.text = @"私人空间";
            userCell.imgV.image = [UIImage imageNamed:@"headerUnLogin"];
        }
        return userCell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
        //右边的 > 符号
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        switch (indexPath.row) {
            case 0:{
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.text = @"清除缓存";
                UILabel *label = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, 50, 30))];
                //获取缓存的大小
                NSUInteger intg = [[SDImageCache sharedImageCache] getSize];
                NSString * currentVolum = [NSString stringWithFormat:@"%@",[self fileSizeWithInterge:intg]];
                label.text = currentVolum;
                cell.accessoryView = label;
                break;
            }
            case 1:{
                cell.textLabel.text = @"问题反馈";
                break;
            }
            case 2:{
                cell.textLabel.text = @"联系我们";
                break;
            }
            case 3:{
                cell.textLabel.text = @"关于我们";
                break;
            }
            case 4:{
                cell.accessoryType = UITableViewCellAccessoryNone;
                /**
                 * 管理流量下载的开关
                 */
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                [switchView addTarget:self action:@selector(switchAction:) forControlEvents:(UIControlEventValueChanged)];
//                switchView.onTintColor = [UIColor orangeColor];
                cell.accessoryView = switchView;
                cell.textLabel.text = @"允许流量自动下载";
                //将cell的选中状态设置为NO,即不可点击,但对于UISwitch无影响
                cell.selectionStyle = NO;
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                NSString *strUseFlow = [user valueForKey:@"strUseFlow"];
                switchView.on = [strUseFlow isEqualToString:@"1"];
                break;
            }
            default:
                break;
        }
        return cell;
    }
}

///是否开启流量使用
-(void)switchAction:(id)sender{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    UISwitch *switchView = (UISwitch *)sender;
    if ([switchView isOn]) {
        [user setValue:@"1" forKey:@"strUseFlow"];
        
        if (_la !=nil) {
            [_la removeFromSuperview];
        }
        [self showview:@"土豪，您允许使用蜂窝网络观看视频"];
    }
    else{
       [user setValue:@"0" forKey:@"strUseFlow"];
        if (_la !=nil) {
            [_la removeFromSuperview];
        }
        [self showview:@"屌丝，你不允许蜂窝网络观看视频"];
    }
    NSNotificationCenter *notifi = [NSNotificationCenter defaultCenter];
    [notifi postNotificationName:@"useFlow" object:nil];
    
}
-(void)showview:(NSString *)showtitle{
    
     _la = [[UILabel alloc]initWithFrame:CGRectMake(0,200,kScreenWidth, 64)];
    _la.backgroundColor = kColor(57, 163, 240, 1);
    _la.text = showtitle;
    _la.textColor = [UIColor whiteColor];
    _la.textAlignment = 1;
    _la.font =[UIFont systemFontOfSize:16];
    
    [self.view addSubview:_la];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:3];
    [UIView setAnimationDelegate:self];
    
    _la.center = CGPointMake(kScreenWidth/2, -32);
    [UIView commitAnimations];
    
   
    
    
}
//计算出大小
- (NSString *)fileSizeWithInterge:(NSInteger)size{
    // 1k = 1024B, 1m = 1024k
    if (size < 1024) {// 小于1k
        return [NSString stringWithFormat:@"%ldB",(long)size];
    }else if (size < 1024 * 1024){// 小于1m
        CGFloat aFloat = size/1024;
        return [NSString stringWithFormat:@"%.0fK",aFloat];
    }else if (size < 1024 * 1024 * 1024){// 小于1G
        CGFloat aFloat = size/(1024 * 1024);
        return [NSString stringWithFormat:@"%.1fM",aFloat];
    }else{
        CGFloat aFloat = size/(1024*1024*1024);
        return [NSString stringWithFormat:@"%.1fG",aFloat];
    }
}


#pragma mark - cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 70;
    }else{
        return 50;
    }
}

#pragma mark - cell的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        PersonalViewController *personalVC = [[PersonalViewController alloc] init];
        [self.navigationController pushViewController:personalVC animated:YES];
        
    }else{
        switch (indexPath.row) {
            case 0:{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"将为您清除本地缓存,确定要删除吗" preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDefault) handler:nil];
                UIAlertAction *actionSure = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    //清除缓存
                    [[SDImageCache sharedImageCache] clearDisk];
                    [[SDImageCache sharedImageCache] clearMemory];
                    [self.mineTableView reloadData];
                }];
                [alert addAction:actionCancel];
                [alert addAction:actionSure];
                [self presentViewController:alert animated:YES completion:nil];
                
                break;
            }
            case 1:{
//                NSMutableString *mailUrl = [[NSMutableString alloc]init];
//                //添加收件人
//                NSArray *toRecipients = [NSArray arrayWithObject: @"15238337696@163.com"];
//                [mailUrl appendFormat:@"mailto:%@", [toRecipients componentsJoinedByString:@","]];
//                //添加抄送
//                NSArray *ccRecipients = [NSArray arrayWithObjects:@"wangzhongguang2527@163.com",  nil];
//                [mailUrl appendFormat:@"?cc=%@", [ccRecipients componentsJoinedByString:@","]];
//                //添加密送
//                NSArray *bccRecipients = [NSArray arrayWithObjects:@"kangyuejie@iCloud.com", nil];
//                [mailUrl appendFormat:@"&bcc=%@", [bccRecipients componentsJoinedByString:@","]];
//                //添加主题
//                [mailUrl appendString:@"&subject= 橙子TV_用户反馈"];
//                //添加邮件内容
//                [mailUrl appendString:[NSString stringWithFormat:@"&body=%@",@"吐槽:"]];
//                // 进行ut-8编码
//                NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
//                NSURL *urll = [NSURL URLWithString:[mailUrl stringByAddingPercentEncodingWithAllowedCharacters:set]];
//                [[UIApplication sharedApplication] openURL:urll];
//                //或者
//                NSURL *url = [NSURL URLWithString:@"sms://10010"];
//                [[UIApplication sharedApplication] openURL:url];
                [self didClickSendEmailButtonAction];
                break;
            }
            case 2:{
                CallUsViewController *callUsVC = [[CallUsViewController alloc] init];
                callUsVC.hidesBottomBarWhenPushed = YES ;
                [self.navigationController pushViewController:callUsVC animated:YES];
                callUsVC.hidesBottomBarWhenPushed = NO ;
                break;
            }
            case 3:{
                AboutUsViewController *aboutVC = [[AboutUsViewController alloc] init];
                 aboutVC.hidesBottomBarWhenPushed = YES ;
                [self.navigationController pushViewController:aboutVC animated:YES];
                aboutVC.hidesBottomBarWhenPushed = NO ;
                break;
            }
            default:
                break;
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -Emaill
- (void)didClickSendEmailButtonAction{
    
    if ([MFMailComposeViewController canSendMail] == YES) {
        
        MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
        //  设置代理(与以往代理不同,不是"delegate",千万不能忘记呀,代理有3步)
        mailVC.mailComposeDelegate = self;
        //  收件人
        NSArray *sendToPerson = @[@"15238337696@163.com"];
        [mailVC setToRecipients:sendToPerson];
        //  抄送
        NSArray *copyToPerson = @[@"kangyuejie@iCloud.com"];
        [mailVC setCcRecipients:copyToPerson];
        //  密送
        NSArray *secretToPerson = @[@"wangzhongguang2527@163.com"];
        [mailVC setBccRecipients:secretToPerson];
        //  主题
        [mailVC setSubject:@"问题反馈"];
        [self presentViewController:mailVC animated:YES completion:nil];
        [mailVC setMessageBody:@"" isHTML:NO];
    }else{
        
        NSLog(@"此设备不支持邮件发送");
        
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"取消发送");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"发送失败");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"保存草稿文件");
            break;
        case MFMailComposeResultSent:
            NSLog(@"发送成功");
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//  系统发送,模拟器不支持,要用真机测试
- (void)didClickSendSystemEmailButtonAction{
    
    NSURL *url = [NSURL URLWithString:@"wangzhongguang2527@163.com"];
    if ([[UIApplication sharedApplication] canOpenURL:url] == YES) {
        
        [[UIApplication sharedApplication] openURL:url];
        
    }else{
        
        NSLog(@"此设备不支持");
    } 
    
}
#pragma mark - 尾视图高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 150;
    }else{
        return 20;
    }
}

#pragma mark - 尾视图
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mineTableView.frame.size.width, 150)];
    if (section == 1){
        //退出登录按钮
        self.quitButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [self.quitButton setTitle:@"退出登录" forState:(UIControlStateNormal)];
        [self.quitButton setBackgroundColor:kColor(57, 163, 240, 1)];
        self.quitButton.layer.cornerRadius = 10;
        self.quitButton.layer.masksToBounds = YES;
        [self.quitButton addTarget:self action:@selector(quitButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
        [footerView addSubview:self.quitButton];
        AVUser *currentUser = [AVUser currentUser];
        if (currentUser == nil) {
            self.quitButton.hidden = YES;
        }
        //上,左,下,右
        //登录按钮下的label
        UILabel *label = [[UILabel alloc] init];
        label.text = @"    为了让大家的体验更好，欢迎大家前来吐槽\n点击“联系我们”，即可添加我们开发者的微信号，提出你们宝贵的意见";
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        [footerView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(UIEdgeInsetsMake(70, 20, 0, 20));
        }];
        [self.quitButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(UIEdgeInsetsMake(30, 20, 90, 20));
        }];
    }
    return footerView;
}
#pragma mark - 退出登录按钮事件
-(void)quitButtonAction{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定注销?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *actionSure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [AVUser logOut];
        [self.mineTableView reloadData];
    }];
    [alert addAction:action];
    [alert addAction:actionSure];
    [self presentViewController:alert animated:YES completion:nil];
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
