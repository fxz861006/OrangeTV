//
//  ThirdViewController.h
//  OrangeTV
//
//  Created by PengchengWang on 16/3/11.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "BaseViewController.h"
#import "VideoModel.h"
#import "ShowCenterViewController.h"
//typedef NS_ENUM(NSInteger,downloadStateType){
//    resourceIsNull,
//    isDownloading,
//    pauseDownloading,
//    downloadOver
//};
@interface ThirdViewController : BaseViewController
///视频缩略图
@property (weak, nonatomic) IBOutlet UIImageView *imgVideo;
///视频标题
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
///文件大小
@property (weak, nonatomic) IBOutlet UILabel *lblVideoSize;
///评论数
@property (weak, nonatomic) IBOutlet UILabel *lblCommentCount;
///视频时间
@property (weak, nonatomic) IBOutlet UILabel *lblPviewtime;

@property (weak, nonatomic) IBOutlet UIProgressView *myProgressView;

@property (weak, nonatomic) IBOutlet UILabel *ProgressLabel;

@property (weak, nonatomic) IBOutlet UIImageView *imgPlay;

@property (weak, nonatomic) IBOutlet UIImageView *imgComment;


@property(nonatomic,strong)VideoModel *model;

@property(nonatomic,assign)downloadStateType downloadState;

-(void)deleteVideo;
@end
