//
//  DownLoadThird.h
//  OrangeTV
//
//  Created by PengchengWang on 16/3/12.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownLoadThird : NSObject

/**
 *  文件的总长度
 */
@property (nonatomic,assign) long long totalLength;
///当前文件长度
@property (nonatomic,assign) long long currentLength;
///文件长度
@property (nonatomic,strong) NSString * fileLength;
///文件句柄
@property (nonatomic,strong) NSFileHandle *fileHanle;
/**
 *  下载任务
 */
@property (nonatomic, strong) NSURLSessionDownloadTask* downloadTask;
/**
 *  resumeData记录下载位置
 */
@property (nonatomic, strong) NSData* resumeData;
/**
 *  session
 */
@property (nonatomic, strong) NSURLSession* session;
@property (nonatomic, strong) NSURL *fileUrl;


- (instancetype)initWithUrl:(NSURL*)url;
//开始下载或者暂停下载方法
-(void)beginOrPauseDownload;
///结束下载
-(void)endDownload;
@end
