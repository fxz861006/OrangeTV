//
//  ThirdViewController.m
//  OrangeTV
//
//  Created by PengchengWang on 16/3/11.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "ThirdViewController.h"
#import "DownLoadThird.h"
#import "OrangeMoviePlayerController.h"
#import "DetailHotVCViewController.h"

@interface ThirdViewController ()
{
    DownLoadThird *downloadMgr;
}
@end

@implementation ThirdViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViews];
    [self dataBound];
}

-(void)setViews{
    self.imgVideo.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapImg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tabImgAction)];
    [self.imgVideo addGestureRecognizer:tapImg];
    if (!self.model) {
        self.imgVideo.layer.cornerRadius = 40;
        self.imgVideo.layer.masksToBounds = YES;
        NSUserDefaults *userDefa = [NSUserDefaults standardUserDefaults];
        downloadStateType downloadState = resourceIsNull;
        [userDefa setValue:[NSNumber numberWithInteger:downloadState] forKey:@"downloadStateThird"];
        [self.imgVideo setImage:[UIImage imageNamed:@"videoMaxCountLimit"]];
    }
    self.ProgressLabel.textColor = [UIColor whiteColor];
    //添加通知中心,监听下载进度
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadOverAction:) name:@"thirdDownLoadOver" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadProgressAction:) name:@"thirdDownLoadProgress" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ThirdResourceNOAction) name:@"thirdResourceNO" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useFlowAction) name:@"useFlow" object:nil];
    ///KVO,监听自己的model,当model发生变化时执行方法
    [self addObserver:self forKeyPath:@"self.model" options: NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld  context:nil];
    UITapGestureRecognizer *tapComment = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCommentActtion)];
    [self.imgComment addGestureRecognizer:tapComment];
    self.imgPlay.hidden = YES;
    self.myProgressView.hidden = YES;
    self.imgComment.hidden = YES;
    self.lblCommentCount.hidden = YES;
}

-(void)useFlowAction{
    NSUserDefaults *userDefa = [NSUserDefaults standardUserDefaults];
    NSString *strUseFlow = [userDefa valueForKey:@"strUseFlow"];
    BOOL boolUseFlow = [strUseFlow isEqualToString:@"1"];
    //当在非wifi环境下正在下载视频时,停止下载
    if (!boolUseFlow) {
        if (![[URLRequestManager getNetWorkStates] isEqualToString:@"WIFI"]) {
            downloadStateType downloadState = [[userDefa valueForKey:@"downloadStateThird"] integerValue];
            if (downloadState == isDownloading) {
                downloadStateType downloadState = pauseDownloading;
                [userDefa setValue:[NSNumber numberWithInteger:downloadState] forKey:@"downloadStateThird"];
                [downloadMgr beginOrPauseDownload];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.ProgressLabel.text = @"暂停下载";
                });
            }
        }
    }else{
        downloadStateType downloadState = [[userDefa valueForKey:@"downloadStateThird"] integerValue];
        if (downloadState == pauseDownloading) {
            [userDefa setValue:[NSNumber numberWithInteger:isDownloading] forKey:@"downloadStateThird"];
            [downloadMgr beginOrPauseDownload];
        }else if (downloadState == resourceIsNull)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"thirdVideoDeleted" object:nil];
        }
    }
}


-(void)dataBound{
    NSUserDefaults *userDefa = [NSUserDefaults standardUserDefaults];
    if (self.model) {
        self.lblCommentCount.text = self.model.count_comment;
        self.lblTitle.text = self.model.title;
        CGFloat fileSize = self.model._1_file_size.floatValue;
        self.lblVideoSize.text =[NSString stringWithFormat:@"文件大小:%.2fM",fileSize/1024.0/1024];
        self.lblPviewtime.text = self.model.pviewtime;
        self.lblPviewtime.textColor = [UIColor whiteColor];
        [self.imgVideo sd_setImageWithURL:[NSURL URLWithString:self.model.pimg_small]];
        if (self.model.sandboxFileName) {
            downloadStateType downloadState = downloadOver;
            [userDefa setValue:[NSNumber numberWithInteger:downloadState] forKey:@"downloadStateThird"];
            self.ProgressLabel.hidden = YES;
            self.myProgressView.hidden = YES;
            self.imgComment.hidden = NO;
            self.lblCommentCount.hidden = NO;
            self.imgPlay.hidden = NO;
        }
        else{
            self.ProgressLabel.hidden = NO;
            self.myProgressView.hidden = NO;
            self.imgComment.hidden = NO;
            self.lblCommentCount.hidden = NO;
            downloadMgr = [[DownLoadThird alloc]initWithUrl:[NSURL URLWithString:self.model.video]];
            downloadStateType downloadState = isDownloading;
            [userDefa setValue:[NSNumber numberWithInteger:downloadState] forKey:@"downloadStateThird"];
            [downloadMgr beginOrPauseDownload];
        }
    }
}

-(void)deleteVideo{
    NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userInfo valueForKey:@"dicCurrentVideoModel"];
    NSMutableDictionary *dicCurrentVideoModel = dic.mutableCopy;
    NSUserDefaults *userDefa = [NSUserDefaults standardUserDefaults];
    downloadStateType downloadState = [[userDefa valueForKey:@"downloadStateThird"] integerValue];
    if (downloadState == isDownloading) {
        [downloadMgr endDownload];
        downloadMgr = nil;
    }
    self.imgComment.hidden = YES;
    self.lblCommentCount.hidden = YES;
    self.lblTitle.text = nil;
    self.lblVideoSize.text =nil;
    self.lblPviewtime.text = nil;
    self.ProgressLabel.text = nil;
    self.myProgressView.hidden = YES;
    self.imgPlay.hidden = YES;
    [self.imgVideo setImage:[UIImage imageNamed:@"videoMaxCountLimit"]];
    if (dicCurrentVideoModel[@"3"]) {
        if (self.model.sandboxFileName) {
            // 删除沙盒里的文件
            NSFileManager* fileManager=[NSFileManager defaultManager];
            NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSString *filePath = [caches stringByAppendingPathComponent:self.model.sandboxFileName];
            //删除model中文件沙盒地址
            self.model.sandboxFileName = nil;
            [dicCurrentVideoModel setObject:[NSKeyedArchiver archivedDataWithRootObject:self.model] forKey:@"3"];
            [userInfo setObject:dicCurrentVideoModel forKey:@"dicCurrentVideoModel"];
            //将下载状态改为"无资源"
            downloadStateType downloadState = resourceIsNull;
            [userDefa setValue:[NSNumber numberWithInteger:downloadState] forKey:@"downloadStateThird"];
            BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
            if (!blHave) {
                NSLog(@"no have");
                return ;
            }else {
                NSLog(@" have");
                BOOL blDele= [fileManager removeItemAtPath:filePath error:nil];
                if (blDele) {
                    NSLog(@"dele success");
                }else {
                    NSLog(@"dele fail");
                }
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"thirdVideoDeleted" object:nil];
}

//点击图片事件
-(void)tabImgAction{
    NSUserDefaults *userDefa = [NSUserDefaults standardUserDefaults];
    downloadStateType downloadState = [[userDefa valueForKey:@"downloadStateThird"] integerValue];
    NSString *strUseFlow = [userDefa valueForKey:@"strUseFlow"];
    BOOL boolUseFlow= [strUseFlow isEqualToString:@"1"];
    if (downloadState != downloadOver) {
        if (!boolUseFlow && ![[URLRequestManager getNetWorkStates] isEqualToString:@"WIFI"]) {
            UIAlertController *alterCon = [UIAlertController alertControllerWithTitle:@"注意" message:@"当前为非WIFI环境,使用流量请在设置界面开启流量使用" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alterCon animated:YES completion:nil];
            //经过几秒后执行方法
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alterCon dismissViewControllerAnimated:YES completion:nil];
            });
            return;
        }
    }
    switch (downloadState) {
        case resourceIsNull:{
            UIAlertController *alterCon = [UIAlertController alertControllerWithTitle:@"不要着急" message:@"橙子正在努力的为您寻找资源" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alterCon animated:YES completion:nil];
            //经过几秒后执行方法
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alterCon dismissViewControllerAnimated:YES completion:nil];
            });
            break;
        }
        case isDownloading:{
            downloadStateType downloadState = pauseDownloading;
            [userDefa setValue:[NSNumber numberWithInteger:downloadState] forKey:@"downloadStateThird"];
            [downloadMgr beginOrPauseDownload];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.ProgressLabel.text = @"暂停下载";
            });
            break;
        }
        case pauseDownloading:{
            downloadStateType downloadState = isDownloading;
            [userDefa setValue:[NSNumber numberWithInteger:downloadState] forKey:@"downloadStateThird"];
            [downloadMgr beginOrPauseDownload];
            break;
        }
        case downloadOver:{
            OrangeMoviePlayerController *orangPlayer = [[OrangeMoviePlayerController alloc]initWithVideoModel:self.model];
            [self presentViewController:orangPlayer animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

//点击评论跳转详情
-(void)tapCommentActtion{
    //    DetailHotVCViewController * DtHCV = [[DetailHotVCViewController alloc]init];
    //    DtHCV.hidesBottomBarWhenPushed = YES;
    //    DtHCV.idd        = self.model.id;
    //    DtHCV.videolink  = self.model.videolink;
    //     self.navigationController.navigationBar.hidden = NO;
    //    [self.navigationController pushViewController:DtHCV animated:YES];
    DetailHotVCViewController * DtHCV = [[DetailHotVCViewController alloc]init];
    DtHCV.hidesBottomBarWhenPushed = YES;
    DtHCV.idd        = self.model.id;
    DtHCV.videolink  = self.model.videolink;
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:DtHCV animated:YES];
}

//每下载一点就走此方法
-(void)downLoadProgressAction:(id)sender{
    NSDictionary *dic = sender;
    NSNumber *numProgress = [dic valueForKey:@"object"];
    self.ProgressLabel.text = [NSString stringWithFormat:@"%.2f%%",100*numProgress.floatValue];
    self.myProgressView.progress = numProgress.floatValue;
}

//下载完成走此方法
-(void)downLoadOverAction:(id)sender{
    NSString *strFileName = [sender valueForKey:@"object"];
    NSUserDefaults *userDefa = [NSUserDefaults standardUserDefaults];
    [userDefa setValue:[NSNumber numberWithInteger:downloadOver] forKey:@"downloadStateThird"];
    self.ProgressLabel.hidden = YES;
    self.myProgressView.hidden = YES;
    self.imgPlay.hidden = NO;
    ///将文件沙盒地址存入model
    self.model.sandboxFileName = strFileName;
    NSLog(@"文件名:%@",self.model.sandboxFileName);
    NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic =[userInfo valueForKey:@"dicCurrentVideoModel"];
    NSMutableDictionary *dicCurrentVideoModel = dic.mutableCopy;
    if (!dicCurrentVideoModel) {
        dicCurrentVideoModel = [[NSMutableDictionary alloc]init];
    }
    NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:self.model];
    [dicCurrentVideoModel setObject:modelData forKey:@"3"];
    [userInfo setObject:dicCurrentVideoModel forKey:@"dicCurrentVideoModel"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    [self dataBound];
}

-(void)ThirdResourceNOAction{
    NSUserDefaults *userDefa = [NSUserDefaults standardUserDefaults];
    [userDefa setValue:[NSNumber numberWithInteger:resourceIsNull] forKey:@"downloadStateThird"];
    self.imgComment.hidden = YES;
    self.lblCommentCount.hidden = YES;
    self.lblPviewtime.hidden = YES;
    self.lblTitle.hidden = YES;
    self.lblVideoSize.hidden = YES;
    self.ProgressLabel.hidden = YES;
    self.myProgressView.hidden = YES;
    self.imgVideo.image = [UIImage imageNamed:@"netError"];
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
