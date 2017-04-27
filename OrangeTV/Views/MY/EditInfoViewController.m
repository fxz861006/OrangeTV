//
//  EditInfoViewController.m
//  OrangeTV
//
//  Created by lanou3g on 16/3/21.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "EditInfoViewController.h"
#import "ImageTableViewCell.h"
#import "TextFieldTableViewCell.h"
#import "UIImage+Change.h"

@interface EditInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImageView *imgHeader;
    UITextField *txtName;
    UITextField *txtSex;
    UITextField *txtMail;
    UITextField *txtPhone;
    UITextField *txtAge;
    UITextField *txtRePwd;
    NSString *strMail;
    NSString *strPhone;
    __block NSString *strIconUrl;
    __block NSString *strName;
    __block NSString *strSex;
    __block NSString *strAge;
}
@property (weak, nonatomic) IBOutlet UITableView *editTableView;

@end

@implementation EditInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViews];
    [self dataBound];
}

-(void)setViews{
    [self.editTableView registerNib:[UINib nibWithNibName:@"ImageTableViewCell" bundle:nil] forCellReuseIdentifier:@"ImageTableViewCell"];
    [self.editTableView registerNib:[UINib nibWithNibName:@"TextFieldTableViewCell" bundle:nil] forCellReuseIdentifier:@"TextFieldTableViewCell"];
    self.editTableView.showsVerticalScrollIndicator = NO;
    self.editTableView.delegate = self;
    self.editTableView.dataSource = self;
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapTableViewAction)];
    [self.editTableView addGestureRecognizer:tapGest];
}

-(void)tapTableViewAction{
    [self.view endEditing:YES];
}

-(void)tapImgHeader{
    UIImagePickerController *picCon = [[UIImagePickerController alloc]init];
    picCon.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picCon.delegate = self;
    picCon.allowsEditing = YES;
    [self presentViewController:picCon animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    imgHeader.image=[info valueForKey:@"UIImagePickerControllerEditedImage"];
    //模态窗口返回
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 100;
    }else {
        return 50;
    }
}

-(void)dataBound{
    AVUser *user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"UserInfo"];
    [query whereKey:@"userObjectId" equalTo:user.objectId];
    //找到符合条件的数据
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count!=0) {
            AVObject *obj = [objects lastObject];
            strIconUrl = [obj valueForKey:@"userIconUrl"];
            strName = [obj valueForKey:@"userName"];
            strSex = [obj valueForKey:@"sex"];
            strPhone = [obj valueForKey:@"mobilePhoneNumber"];
            strMail = [obj valueForKey:@"email"];
            if ([obj valueForKey:@"age"]) {
                strAge = [NSString stringWithFormat:@"%@",[obj valueForKey:@"age"]];
            }
        }
        [self.editTableView reloadData];
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        ImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageTableViewCell" forIndexPath:indexPath];
        cell.selectionStyle = NO;
        cell.userHeaderLabel.text = @"头像";
        cell.userHeaderImage.layer.cornerRadius = 40;
        cell.userHeaderImage.layer.masksToBounds = YES;
        cell.userHeaderImage.image = [UIImage imageNamed:@"headImage"];
        imgHeader = cell.userHeaderImage;
        imgHeader.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImgHeader)];
        [imgHeader addGestureRecognizer:tapGest];
        if (strIconUrl) {
            [imgHeader sd_setImageWithURL:[NSURL URLWithString:strIconUrl]];
        }
        return cell;
    }else{
        TextFieldTableViewCell *cellText = [tableView dequeueReusableCellWithIdentifier:@"TextFieldTableViewCell" forIndexPath:indexPath];
        cellText.selectionStyle = NO;
        switch (indexPath.row) {
            case 1:{
                cellText.userNameLabel.text = @"昵称";
                txtName = cellText.userNameText;
                txtName.delegate = self;
                txtName.text = strName;
                break;
            }
            case 2:{
                cellText.userNameLabel.text = @"性别";
                txtSex = cellText.userNameText;
                UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSexText)];
                [txtSex addGestureRecognizer:tapGest];
                txtSex.text = strSex;
                break;
            }
            case 3:{
                cellText.userNameLabel.text = @"邮箱";
                txtMail = cellText.userNameText;
                txtMail.delegate = self;
                txtMail.text = strMail;
                break;
            }
            case 4:{
                cellText.userNameLabel.text = @"手机号";
                cellText.userNameText.keyboardType = UIKeyboardTypeNumberPad;
                txtPhone = cellText.userNameText;
                txtPhone.delegate = self;
                txtPhone.text = strPhone;
                break;
            }
            case 5:{
                cellText.userNameLabel.text = @"年龄";
                cellText.userNameText.keyboardType = UIKeyboardTypeNumberPad;
                txtAge = cellText.userNameText;
                txtAge.delegate = self;
                txtAge.text = strAge;
                break;
            }
            default:
                break;
        }
        return cellText;
    }
   
}

#pragma mark - 尾视图高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 150;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.editTableView.frame.size.width, 150)];
    
    UIButton *sureButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [sureButton setTitle:@"保存" forState:(UIControlStateNormal)];
    sureButton.layer.cornerRadius = 10;
    sureButton.layer.masksToBounds = YES;
//    [sureButton setBackgroundColor:[UIColor orangeColor]];
    [sureButton setBackgroundColor:kColor(57, 163, 240, 1)];
    [sureButton addTarget:self action:@selector(sureButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
    [footerView addSubview:sureButton];
    [sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(UIEdgeInsetsMake(25, 40, 95, 40));
    }];
    UIButton *cancelButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [cancelButton setTitle:@"取消" forState:(UIControlStateNormal)];
    cancelButton.layer.cornerRadius = 10;
    cancelButton.layer.masksToBounds = YES;
    [cancelButton setBackgroundColor:kColor(57, 163, 240, 1)];
    [cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
    [footerView addSubview:cancelButton];
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sureButton.mas_bottom).with.offset(20);
        make.left.mas_equalTo(40);
        make.right.mas_equalTo(-40);
        make.height.mas_equalTo(30);
    }];
    return footerView;
}

-(void)tapSexText{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *secretAction = [UIAlertAction actionWithTitle:@"保密" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        txtSex.text = @"保密";
    }];
    UIAlertAction *maleAction = [UIAlertAction actionWithTitle:@"男" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        txtSex.text = @"男";
    }];
    UIAlertAction *fmaleAction = [UIAlertAction actionWithTitle:@"女" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        txtSex.text = @"女";
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    [alert addAction:secretAction];
    [alert addAction:maleAction];
    [alert addAction:fmaleAction];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

///修改提交
-(void)sureButtonAction{
    AVUser *user = [AVUser currentUser];
    AVObject *post = [AVObject objectWithoutDataWithClassName:@"_User"objectId:user.objectId];
    //更新属性
    [post setObject:txtMail.text forKey:@"email"];
//    [post setObject:txtPhone.text forKey:@"mobilePhoneNumber"];
    //保存
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"信息正在修改中,请耐心等待......";
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            UIImage *image = imgHeader.image;
            image = [image scaleToSize:CGSizeMake(500, 500)];
            //将图片对象转换为NSData数据类型
            NSData *imageData = UIImagePNGRepresentation(image);
            //创建AVFile对象保存图片
            AVFile *imageFile = [AVFile fileWithName:@"userIcon.png" data:imageData];
            //上传头像,返回头像的url(imageFile.url)
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    AVQuery *query = [AVQuery queryWithClassName:@"UserInfo"];
                    [query whereKey:@"userObjectId" equalTo:user.objectId];
                    //找到符合条件的数据
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error) {
                            AVObject *obj = [objects lastObject];
                            obj[@"userIconUrl"] = imageFile.url;
                            obj[@"userName"] = txtName.text;
                            obj[@"sex"] = txtSex.text;
                            obj[@"age"] = [NSNumber numberWithInteger:[txtAge.text integerValue]];
                            obj[@"mobilePhoneNumber"] = txtPhone.text;
                            obj[@"email"] = txtMail.text;
                            //异步批量保存数据
                            [AVObject saveAllInBackground:objects block:^(BOOL succeeded, NSError *error) {
                                if (succeeded) {
                                    UIAlertController *alterCon = [UIAlertController alertControllerWithTitle:@"修改成功" message:@"恭喜你信息修改成功!" preferredStyle:UIAlertControllerStyleAlert];
                                    UIAlertAction *actionSucceed = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                        [self.navigationController popToRootViewControllerAnimated:YES];
                                    }];
                                    [alterCon addAction:actionSucceed];
                                    [self presentViewController:alterCon animated:YES completion:nil];
                                    hud.hidden = YES;
                                }
                            }];
                        } else {
                            UIAlertController *alterCon = [UIAlertController alertControllerWithTitle:@"修改失败" message:@"修改信息有误,请重新修改" preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *actionSucceed = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
                            [self presentViewController:alterCon animated:YES completion:nil];
                            [alterCon addAction:actionSucceed];
                            hud.hidden = YES;
                            
                        }
                    }];
                }
            }];
        } else {
            UIAlertController *alterCon = [UIAlertController alertControllerWithTitle:@"修改信息失败" message:@"邮箱有误,请换个试试" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionPwdErr = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
            [alterCon addAction:actionPwdErr];
            [self presentViewController:alterCon animated:YES completion:nil];
            hud.hidden = YES;
            NSLog(@"%@",error);
        }
    }];
}

-(void)cancelButtonAction{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

//编辑状态视图上移
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    self.editTableView.frame =CGRectMake(0, -115, self.editTableView.frame.size.width, self.editTableView.frame.size.height);
}
//编辑结束视图归位
-(void)textFieldDidEndEditing:(UITextField *)textField{
    self.editTableView.frame =CGRectMake(0, 0, self.editTableView.frame.size.width, self.editTableView.frame.size.height);
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
