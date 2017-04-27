//
//  LoginViewController.m
//  OrangeTV
//
//  Created by lanou3g on 16/3/14.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "LoginViewController.h"
#import "MyViewController.h"
#import "RegistViewController.h"
#import "FindPasswordViewController.h"
@interface LoginViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *userHeadImage;


@property (weak, nonatomic) IBOutlet UIButton *cancelButton;//取消按钮
//用户名
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
//密码
@property (weak, nonatomic) IBOutlet UITextField *passwordText;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;//登录按钮
@property (weak, nonatomic) IBOutlet UIButton *registButton;//注册按钮
@property (weak, nonatomic) IBOutlet UIButton *sinaButton;//新浪微博登录
@property (weak, nonatomic) IBOutlet UIButton *qqButton;//qq登录


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViews];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Theme_Background.jpg"]]];
}
#pragma mark - 设置视图
-(void)setViews{
    
    self.userHeadImage.layer.cornerRadius = 40;
    self.userHeadImage.layer.masksToBounds = YES;
    self.userHeadImage.image  = [UIImage imageNamed:@"headImage"];
    
    [self.sinaButton setBackgroundImage:[UIImage imageNamed:@"login_via_weibo"] forState:(UIControlStateNormal)];
    [self.qqButton setBackgroundImage:[UIImage imageNamed:@"login_via_qq"] forState:(UIControlStateNormal)];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"close_log"] forState:(UIControlStateNormal)];
    //button切圆角
    self.loginButton.layer.cornerRadius = 10;
    self.loginButton.layer.masksToBounds = YES;
    self.registButton.layer.cornerRadius = 10;
    self.registButton.layer.masksToBounds = YES;
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark - 取消按钮响应事件:返回我的页面
- (IBAction)cancelButtonAction:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 登录按钮响应事件
- (IBAction)loginButtonAction:(UIButton *)sender {
    if (self.userNameTextField.text.length >0 && self.passwordText.text.length>0 ) {
        [AVUser logInWithUsernameInBackground:self.userNameTextField.text password:self.passwordText.text block:^(AVUser *user, NSError *error) {
            if (user != nil) {
                NSLog(@"三点多");
                [self.navigationController popToRootViewControllerAnimated:YES];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }else if ([self.userNameTextField.text length] == 0 || [self.passwordText.text length] == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"用户名或密码不能为空,请重新输入" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }];
    }
}

#pragma mark - 注册按钮响应事件:跳转注册页面
- (IBAction)registButtonAction:(UIButton *)sender {
    RegistViewController *registVC = [[RegistViewController alloc] init];
    
    if (self.navigationController == nil) {
        [self presentViewController:registVC animated:YES completion:nil];
    }else{
        
        [self.navigationController pushViewController:registVC animated:YES];
    }
    
}

#pragma mark - 第三方登录新浪微博登录
- (IBAction)sinaLoginButtonAction:(UIButton *)sender {
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToSina];
            NSString *platformName = snsAccount.platformName;
            NSString *userName = snsAccount.userName;
            NSString *iconURL = snsAccount.iconURL;
            NSString *usid = snsAccount.usid;
            AVQuery *query = [AVQuery queryWithClassName:@"UserInfo"];
            //设置请求查询条件
            [query whereKey:@"usid" equalTo:usid];
            //找到符合条件的数据
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (objects.count == 0) {
                    AVObject *userKey = [AVObject objectWithClassName:@"_User"];
                    [userKey setObject:userName forKey:@"username"];
                    [userKey setObject:usid forKey:@"password"];
                    [userKey saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            AVObject *userInfoObjc = [AVObject objectWithClassName:@"UserInfo"];
                            [userInfoObjc setObject:userKey.objectId forKey:@"userObjectId"];
                            [userInfoObjc setObject:usid forKey:@"usid"];
                            [userInfoObjc setObject:platformName forKey:@"platformName"];
                            [userInfoObjc setObject:userName forKey:@"userName"];
                            [userInfoObjc setObject:iconURL forKey:@"userIconUrl"];
                            [userInfoObjc saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (succeeded) {
                                    [AVUser logInWithUsernameInBackground:userName password:usid block:^(AVUser *user, NSError *error) {
                                        if (user != nil) {
                                            UIAlertController *alterCon = [UIAlertController alertControllerWithTitle:@"登录成功" message:@"恭喜你新浪微博账户登陆成功,接下来您可以进行云收藏功能了!" preferredStyle:UIAlertControllerStyleAlert];
                                            UIAlertAction *actionSucceed = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                [self.navigationController popToRootViewControllerAnimated:YES];
                                                
                                                [self dismissViewControllerAnimated:YES completion:nil];
                                            }];
                                            [alterCon addAction:actionSucceed];
                                            [self presentViewController:alterCon animated:YES completion:nil];
                                        }
                                    }];
                                }
                            }];
                            
                        }
                    }];
                }
                else {
                    [AVUser logInWithUsernameInBackground:userName password:usid block:^(AVUser *user, NSError *error) {
                        if (user != nil) {
                            UIAlertController *alterCon = [UIAlertController alertControllerWithTitle:@"登录成功" message:@"恭喜你新浪微博账户登陆成功,接下来您可以进行云收藏功能了!" preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *actionSucceed = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                [self.navigationController popToRootViewControllerAnimated:YES];
                                
                                [self dismissViewControllerAnimated:YES completion:nil];
                            }];
                            [alterCon addAction:actionSucceed];
                            [self presentViewController:alterCon animated:YES completion:nil];
                        }else{
                            NSLog(@"新浪微博登录失败");
                        }
                    }];
                }
            }];
        }});
}
#pragma mark - 第三方登录QQ登录
- (IBAction)qqLoginButtonAction:(UIButton *)sender {
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
            NSString *platformName = snsAccount.platformName;
            NSString *userName = snsAccount.userName;
            NSString *iconURL = snsAccount.iconURL;
            NSString *usid = snsAccount.usid;
            AVQuery *query = [AVQuery queryWithClassName:@"UserInfo"];
            //设置请求查询条件
            [query whereKey:@"usid" equalTo:usid];
            //找到符合条件的数据
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (objects.count == 0) {
                    AVObject *userKey = [AVObject objectWithClassName:@"_User"];
                    [userKey setObject:userName forKey:@"username"];
                    [userKey setObject:usid forKey:@"password"];
                    [userKey saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            AVObject *userInfoObjc = [AVObject objectWithClassName:@"UserInfo"];
                            [userInfoObjc setObject:userKey.objectId forKey:@"userObjectId"];
                            [userInfoObjc setObject:usid forKey:@"usid"];
                            [userInfoObjc setObject:platformName forKey:@"platformName"];
                            [userInfoObjc setObject:userName forKey:@"userName"];
                            [userInfoObjc setObject:iconURL forKey:@"userIconUrl"];
                            [userInfoObjc saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (succeeded) {
                                    [AVUser logInWithUsernameInBackground:userName password:usid block:^(AVUser *user, NSError *error) {
                                        if (user != nil) {
                                            UIAlertController *alterCon = [UIAlertController alertControllerWithTitle:@"登录成功" message:@"恭喜你QQ账户登陆成功,接下来您可以进行云收藏功能了!" preferredStyle:UIAlertControllerStyleAlert];
                                            UIAlertAction *actionSucceed = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                [self.navigationController popToRootViewControllerAnimated:YES];
                                                
                                                
                                                [self dismissViewControllerAnimated:YES completion:nil];
                                            }];
                                            [alterCon addAction:actionSucceed];
                                            [self presentViewController:alterCon animated:YES completion:nil];
                                        }
                                    }];
                                }
                            }];
                            
                        }
                    }];
                }
                else {
                    [AVUser logInWithUsernameInBackground:userName password:usid block:^(AVUser *user, NSError *error) {
                        if (user != nil) {
                            UIAlertController *alterCon = [UIAlertController alertControllerWithTitle:@"登录成功" message:@"恭喜你QQ账户登陆成功,接下来您可以进行云收藏功能了!" preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *actionSucceed = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                [self.navigationController popToRootViewControllerAnimated:YES];
                                [self dismissViewControllerAnimated:YES completion:nil];
                            }];
                            [alterCon addAction:actionSucceed];
                            [self presentViewController:alterCon animated:YES completion:nil];
                        }else{
                            NSLog(@"QQ登录失败");
                        }
                    }];
                }
            }];
        }});
}
#pragma mark - 找回密码响应事件
- (IBAction)findBackPassword:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"找回密码?" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *actionSure = [UIAlertAction actionWithTitle:@"废话少说,找密码要紧'" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        FindPasswordViewController *findVC = [[FindPasswordViewController alloc] init];
        
       
[self presentViewController:findVC animated:YES completion:nil];
       

    }];
    UIAlertAction *actionRe = [UIAlertAction actionWithTitle:@"找毛线!重新注册一个" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        RegistViewController *registVC = [[RegistViewController alloc] init];
        if (self.navigationController == nil) {
            [self presentViewController:registVC animated:YES completion:nil];
        }else{
            
            [self.navigationController pushViewController:registVC animated:YES];
        }

//        [self presentViewController:registVC animated:YES completion:nil];
//        [self.navigationController pushViewController:registVC animated:YES];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"以后只做个安静的路人" style:(UIAlertActionStyleCancel) handler:nil];
    [alert addAction:actionSure];
    [alert addAction:actionRe];
    [alert addAction:actionCancel];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - 点击空白回收键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
