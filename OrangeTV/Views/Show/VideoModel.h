//
//  VideoModel.h
//  OrangeTV
//
//  Created by PengchengWang on 16/3/11.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "BaseModel.h"

@interface VideoModel : BaseModel
///分享链接
@property(nonatomic,strong)NSString *sharelink;
///标题
@property(nonatomic,strong)NSString *title;
///分秒时长
@property(nonatomic,strong)NSString *pviewtime;
///秒数时长
@property(nonatomic,strong)NSString *pviewtimeint;
///视频下载连接.MP4
@property(nonatomic,strong)NSString *video;
///评论数
@property(nonatomic,strong)NSString *count_comment;
///分享数
@property(nonatomic,strong)NSString *count_share;
///文件大小(单位B)
@property(nonatomic,strong)NSString *_1_file_size;
///视频id
@property(nonatomic,strong)NSString *id;
///视频缩略小图
@property(nonatomic,strong)NSString *pimg_small;
///文件在沙盒中地址
@property(nonatomic,strong)NSString *sandboxFileName;
///视频链接
@property(nonatomic,strong)NSString *videolink;



@end
