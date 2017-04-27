//
//  DownLoadSecend.m
//  OrangeTV
//
//  Created by PengchengWang on 16/3/12.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "DownLoadSecend.h"

@interface DownLoadSecend ()<NSURLSessionDownloadDelegate>
{
    BOOL _isDownloading;
}
@end

@implementation DownLoadSecend
//将session设置懒加载
- (NSURLSession *)session{
    if (_session == nil) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (instancetype)initWithUrl:(NSURL*)url
{
    self = [super init];
    if (self) {
        self.fileUrl = url;
        _isDownloading = NO;
    }
    return self;
}

// 通过delegate来监控下载的进度
- (void)downloadFile{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *strUseFlow = [user valueForKey:@"strUseFlow"];
    BOOL boolUseFlow= [strUseFlow isEqualToString:@"1"];
    if (boolUseFlow) {
        //      判断是否是首次开始下载
        if (self.resumeData == nil) {
            //创建任务
            self.downloadTask = [self.session downloadTaskWithURL:self.fileUrl];
            //开始任务
            [self.downloadTask resume];
        }
        else{
            //继续上次的下载
            //传入上次暂停下载返回的数据，就可以恢复下载
            self.downloadTask = [self.session downloadTaskWithResumeData:self.resumeData];
            [self.downloadTask resume];//开始任务
            self.resumeData = nil;
        }
    }else{
        if ([[URLRequestManager getNetWorkStates] isEqualToString:@"WIFI"]) {
            //      判断是否是首次开始下载
            if (self.resumeData == nil) {
                //创建任务
                self.downloadTask = [self.session downloadTaskWithURL:self.fileUrl];
                //开始任务
                [self.downloadTask resume];
            }
            else{
                //继续上次的下载
                //传入上次暂停下载返回的数据，就可以恢复下载
                self.downloadTask = [self.session downloadTaskWithResumeData:self.resumeData];
                [self.downloadTask resume];//开始任务
                self.resumeData = nil;
            }
        }else{
            NSLog(@"%s当前为非WIFI环境",__FUNCTION__);
        }
    }
    
}

-(void)beginOrPauseDownload{
    _isDownloading = !_isDownloading;
    if (_isDownloading) {
        /*
         想要监听下载进度，苹果通常的做法是通过delegate，
         这里也一样，而且NSURLSession的创建方式也有所不同
         */
        [self downloadFile];
    }
    else{//暂停状态
        __weak typeof(self) weakSelf = self;
        [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            weakSelf.resumeData = resumeData;
            weakSelf.downloadTask = nil;
        }];
    }
}

///结束下载
-(void)endDownload{
    [self beginOrPauseDownload];
    [self.downloadTask cancel];
    self.resumeData = nil;
    self.downloadTask = nil;
    self.session = nil;
    self.currentLength = 0;
    self.fileLength = 0;
    self.totalLength = 0;
    self.fileHanle = nil;
}


#pragma mark -- NSURLSessionDownloadDelegate  代理方法
/**
 *  下载完毕后调用
 *
 *  @param location     临时文件地址
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    //response.suggestedFileName : 建议使用的文件名，一般跟服务器的文件名一致
    NSString *file = [caches stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    NSLog(@"%@",file);
    //将临时文件剪切或者Caches文件夹
    NSFileManager *manager = [NSFileManager defaultManager];
    /**
     *  AtPath:剪切前的文件路径
     *  ToPath:剪切后的文件路径
     */
    [manager moveItemAtPath:location.path toPath:file error:nil];
    //发送下载完成通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"secendDownLoadOver" object:downloadTask.response.suggestedFilename];
}

/**
 *  每次写入沙盒完毕后调用，这里面监听下载进度 ，totalBytesWritten/totalBytesExpectedToWrite
 *
 *  @param totalBytesWritten         这次写入的大小
 *  @param totalBytesExpectedToWrite 文件的总大小
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    self.currentLength +=totalBytesWritten;
    float progress = (float)((float)totalBytesWritten/totalBytesExpectedToWrite);
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"secendDownLoadProgress" object:[NSNumber numberWithFloat:progress]];
    
}

/**
 *  恢复下载时调用
 *
 *  @param session            <#session description#>
 *  @param downloadTask       <#downloadTask description#>
 *  @param fileOffset         <#fileOffset description#>
 *  @param expectedTotalBytes <#expectedTotalBytes description#>
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
    
}

@end
