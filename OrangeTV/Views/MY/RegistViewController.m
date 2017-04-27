//
//  RegistViewController.m
//  OrangeTV
//
//  Created by lanou3g on 16/3/14.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "RegistViewController.h"
#import "MyViewController.h"
#import "LoginViewController.h"
#import "UIImage+Change.h"
@interface RegistViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userHeadImage;//头像
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;//取消按钮
@property (weak, nonatomic) IBOutlet UIButton *registButton;//注册按钮
@property (weak, nonatomic) IBOutlet UIButton *loginButton;//登录按钮
@property (weak, nonatomic) IBOutlet UIButton *sinaButton;//新浪登录
@property (weak, nonatomic) IBOutlet UIButton *qqButton;//qq登录
@property (weak, nonatomic) IBOutlet UITextField *userName;//用户名
@property (weak, nonatomic) IBOutlet UITextField *password;//密码
@property (weak, nonatomic) IBOutlet UITextField *aginPassword;//确认密码
@property (weak, nonatomic) IBOutlet UITextField *yourEmail;//邮箱

@end

@implementation RegistViewController

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
    
    self.loginButton.layer.cornerRadius = 10;
    self.loginButton.layer.masksToBounds = YES;
    self.registButton.layer.cornerRadius = 10;
    self.registButton.layer.masksToBounds = YES;
    //设置轻点手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.userHeadImage addGestureRecognizer:tapGesture];

}
#pragma mark - 手势
-(void)tapAction{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置头像" message:@"选择您想使用的方式设置头像" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionPhotos = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self fromPhotos];
    }];
    UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self fromCamera];
    }];
    UIAlertAction *actionPhotoLibrary = [UIAlertAction actionWithTitle:@"图库" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self fromPhotoLibrary];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"算了" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:actionPhotos];
    [alert addAction:actionCamera];
    [alert addAction:actionPhotoLibrary];
    [alert addAction:actionCancel];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)fromPhotos{
    //创建UIImagePickerController对象
    UIImagePickerController *imp=[[UIImagePickerController alloc]init];
    //.sourceType设置对象类型(相机/相册/图库)
    imp.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    //设置代理(目的:为了让这个对象执行协议中的方法)
    imp.delegate=self;
    //设置获取出来的照片是否可以编辑
    imp.allowsEditing=YES;
    //模态推出视图
    [self presentViewController:imp animated:YES completion:nil];
}

//调用系统相机方法
-(void)fromCamera{
    //判断是否能够调用相机功能
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //创建UIImagePickerController对象
        UIImagePickerController *imp=[[UIImagePickerController alloc]init];
        //UIImagePickerController为调用相机类型
        imp.sourceType=UIImagePickerControllerSourceTypeCamera;
        //设置代理
        imp.delegate=self;
        imp.allowsEditing = YES;
        //模态推出视图
        [self presentViewController:imp animated:YES completion:nil];
    }else{
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"没有相机" message:@"您的设备不支持相机功能" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }
}

//调用图库
-(void)fromPhotoLibrary{
    UIImagePickerController *imp=[[UIImagePickerController alloc]init];
    imp.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    imp.delegate=self;
    imp.allowsEditing=YES;
    [self presentViewController:imp animated:YES completion:nil];
}

//点击图库中相片触发事件,并将点击的图片返回
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //设置imageView为获取到的图片,使用KVC方式获取,"UIImagePickerControllerOriginalImage"系统默认值
    self.userHeadImage.image=[info valueForKey:@"UIImagePickerControllerEditedImage"];
    //模态窗口返回
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//点击右上角Cancel(取消)按钮触发事件
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 取消按钮响应事件
- (IBAction)cancelButtonAction:(UIButton *)sender {
    if (self.navigationController == nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        
       [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

///判断字符串是否为字母数字组合6-20位
- (BOOL) isPwd: (NSString *) strPwd {
    NSString *userNameRegex = @"^[A-Za-z0-9]{6,20}+$";
    NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameRegex];
    BOOL B = [userNamePredicate evaluateWithObject:strPwd];
    return B;
}

#pragma mark - 注册按钮响应事件
- (IBAction)registButtonAction:(UIButton *)sender {
    BOOL isPwd = [self isPwd:self.password.text];
    BOOL isName = [self isPwd:self.userName.text];
    if (!(isPwd&&isName)) {
        UIAlertController *alterCon = [UIAlertController alertControllerWithTitle:@"注册失败" message:@"用户名和密码,必须为6-20位的数字加字母组合" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionPwdErr = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
        [alterCon addAction:actionPwdErr];
        [self presentViewController:alterCon animated:YES completion:nil];
        return;
    }
    if (self.password.text.length == 0||self.userName.text.length == 0) {
        UIAlertController *alterCon = [UIAlertController alertControllerWithTitle:@"注册失败" message:@"用户名/密码不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionPwdErr = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
        [alterCon addAction:actionPwdErr];
        [self presentViewController:alterCon animated:YES completion:nil];
    }
    else{
        if ([self.password.text isEqualToString:self.aginPassword.text]) {
            //创建AVObject对象上传数据
            AVObject *userInfoUpLoad = [AVObject objectWithClassName:@"_User"];
            [userInfoUpLoad setObject:self.userName.text forKey:@"username"];
            [userInfoUpLoad setObject:self.password.text forKey:@"password"];
            if (self.yourEmail.text.length) {
                [userInfoUpLoad setObject:self.yourEmail.text forKey:@"email"];
            }
            //异步保存数据
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"正在注册中,请耐心等待......";
            [userInfoUpLoad saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    
                    [AVUser logInWithUsernameInBackground:self.userName.text password:self.password.text block:^(AVUser *user, NSError *error) {
                        if (user != nil) {
                            NSString *objeceId = user.objectId;
                            UIImage *image = self.userHeadImage.image;
                             image = [image scaleToSize:CGSizeMake(500, 500)];
                            //将图片对象转换为NSData数据类型
                            NSData *imageData = UIImagePNGRepresentation(image);
                            //创建AVFile对象保存图片
                            AVFile *imageFile = [AVFile fileWithName:@"userIcon.png" data:imageData];
                           //上传头像,返回头像的url(imageFile.url)
                            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                //创建AVObject对象上传数据
                                AVObject *userInfoObjc = [AVObject objectWithClassName:@"UserInfo"];
                                [userInfoObjc setObject:objeceId forKey:@"userObjectId"];
                                [userInfoObjc setObject:self.userName.text forKey:@"userName"];
                                [userInfoObjc setObject:self.yourEmail.text forKey:@"email"];
                                [userInfoObjc setObject:imageFile.url forKey:@"userIconUrl"];
                                [userInfoObjc saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    if (succeeded) {
                                        
                                        UIAlertController *alterCon = [UIAlertController alertControllerWithTitle:@"注册成功" message:@"恭喜你成为橙子TV用户,接下来您可以进行云收藏功能了!" preferredStyle:UIAlertControllerStyleAlert];
                                        UIAlertAction *actionSucceed = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                            [self.navigationController popToRootViewControllerAnimated:YES];
                                            self.presentingViewController.view.alpha = 0;
                                            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                            
                                        }];
                                        [alterCon addAction:actionSucceed];
                                        [self presentViewController:alterCon animated:YES completion:nil];
                                        hud.hidden = YES;
                                    }
                                }];
                                
                            }];
                            
                        }else{
                        
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"注册失败,请重新注册" preferredStyle:UIAlertControllerStyleAlert];
                            [self presentViewController:alert animated:YES completion:^{
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                });
                            }];
                        }
                    }];
                } else {
                    NSString *strError = @"用户信息有误,注册失败";
                    switch (error.code) {
                        case 202:{
                            strError = @"该用户名已被注册,请换个用户名试试";
                            break;
                        }
                        case 125:{
                            strError = @"邮箱输入有误,请输入正确的邮箱地址";
                            break;
                        }
                            
                        case 203:{
                            strError = @"该邮箱已被使用,请换个邮箱试试";
                            break;
                        }
                        case 28:{
                            strError = @"服务器繁忙，请稍后再试";
                            break;
                        }
                        default:
                            break;
                    }
                    UIAlertController *alterCon = [UIAlertController alertControllerWithTitle:@"注册失败" message:[NSString stringWithFormat:@"%@",strError] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *actionSucceed = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
                    [alterCon addAction:actionSucceed];
                    [self presentViewController:alterCon animated:YES completion:nil];
                    hud.hidden = YES;
                }
            }];
        }
        else{
            UIAlertController *alterCon = [UIAlertController alertControllerWithTitle:@"注册失败" message:@"两次输入密码不一致,重新确认密码" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionPwdErr = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.password.text = nil;
                self.aginPassword.text = nil;
            }];
            [alterCon addAction:actionPwdErr];
            [self presentViewController:alterCon animated:YES completion:nil];
        }
    }
}



#pragma mark - 登录按钮响应事件
- (IBAction)loginButtonAction:(UIButton *)sender {
    if (self.navigationController == nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 第三方新浪微博登录
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

#pragma mark - 第三方QQ登录
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
#pragma mark -
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
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
