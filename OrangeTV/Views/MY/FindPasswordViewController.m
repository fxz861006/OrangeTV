//
//  FindPasswordViewController.m
//  OrangeTV
//
//  Created by lanou3g on 16/3/16.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "FindPasswordViewController.h"
#import "LoginViewController.h"
#import "RegistViewController.h"
#import <AVCloud.h>
@interface FindPasswordViewController ()

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
///是否以邮箱方式找回密码
@property(nonatomic,assign,getter=isMailStyle)BOOL mailStyle;
///短信验证码是否发送成功
@property(nonatomic,assign,getter=isPhoneCode)BOOL phoneCode;
@property (weak, nonatomic) IBOutlet UITextField *txtMailOrPhone;

@property (weak, nonatomic) IBOutlet UIButton *suerButton;

@property (weak, nonatomic) IBOutlet UIButton *cancelBT;

@property (weak, nonatomic) IBOutlet UIImageView *imgPhoneCodeLine;


@end

@implementation FindPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViews];
}

-(void)setViews{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"IMG_0651"]];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"close_log"] forState:(UIControlStateNormal)];
    self.suerButton.layer.cornerRadius = 10;
    self.suerButton.layer.masksToBounds = YES;
    self.cancelBT.layer.cornerRadius = 10;
    self.cancelBT.layer.masksToBounds = YES;
}

- (IBAction)cancelButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)suerButton:(id)sender {
    [AVUser requestPasswordResetForEmailInBackground:self.txtMailOrPhone.text block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"邮件已发送" message:@"申请修改密码成功,请到对应邮箱中修改密码" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alter animated:YES completion:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alter dismissViewControllerAnimated:YES completion:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        } else {
            UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"邮件获取失败" message:@"用户名或邮箱错误,请核对信息后重新申请修改密码" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alter animated:YES completion:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alter dismissViewControllerAnimated:YES completion:nil];
            });
            NSLog(@"%@",error);
        }
    }];
}


- (IBAction)cancelButtonAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
