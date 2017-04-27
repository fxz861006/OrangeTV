//
//  CallUsViewController.m
//  OrangeTV
//
//  Created by lanou3g on 16/3/12.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "CallUsViewController.h"

@interface CallUsViewController ()

@end

@implementation CallUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    //双击
//    tap.numberOfTapsRequired = 2;
    tap.numberOfTapsRequired = 1;
    //多点触控
//    tap.numberOfTouchesRequired = 2;//两根手指才又效果
    tap.numberOfTouchesRequired = 1;
    //将手势加到图片上
    [self.callUsPicture addGestureRecognizer:tap];
   
}

#pragma mark - 轻点手势触发事件
-(void)tapAction{
    
    UIAlertController *alertSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存图片" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        //往系统相册保存图片的方法
        UIImageWriteToSavedPhotosAlbum(self.callUsPicture.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }];
    //点击取消按钮不调用保存图片的方法
    UIAlertAction *cancelSave = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    [alertSheet addAction:saveAction];
    [alertSheet addAction:cancelSave];
    [self presentViewController:alertSheet animated:YES completion:nil];
}
#pragma mark - 为了知道图片的保存结果时，指定回调方法
-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error == nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"图片保存成功" preferredStyle:(UIAlertControllerStyleAlert)];
        
        [self presentViewController:alert animated:YES completion:^{
            sleep(1);
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"图片保存失败" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:nil];
        [alert addAction:sure];
        [self presentViewController:alert animated:YES completion:nil];
    }
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
