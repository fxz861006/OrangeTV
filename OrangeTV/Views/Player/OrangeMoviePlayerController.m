//
//  OrangeMoviePlayerController.m
//  OrangeMoviewPlayer_Xib
//
//  Created by PengchengWang on 16/3/9.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "OrangeMoviePlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import "OrangeAVPlayerHelper.h"
#import <AVCloud.h>

#define TOPVIEW_HEIGHT 64
#define RIGHT_WIDTH 50
#define ROTATOR_BOTTOM_HEIGHT 50
#define VERTICAL_BOTTOM_HEIGHT 90
#define ZERO 0
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define NLSystemVersionGreaterOrEqualThan(version) ([[[UIDevice currentDevice] systemVersion] floatValue] >= version)
#define IOS7 NLSystemVersionGreaterOrEqualThan(7.0)

@interface OrangeMoviePlayerController ()<UIGestureRecognizerDelegate,UMSocialUIDelegate>
{
    AVPlayerItem *playItem;
    float progressSlider;
    BOOL isPlay;
}
///视频model
@property (nonatomic, strong) VideoModel *model;
///视频Url
@property (nonatomic, strong) NSURL *movieURL;
@property (nonatomic, assign)CMTime currentTime;
@property (nonatomic, assign)BOOL isForward;
//  View
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIView *rightView;
@property (strong, nonatomic) IBOutlet UIView *verticalBottomView;
@property (strong, nonatomic) IBOutlet UIView *ratotarBottomView;
- (IBAction)finishAction:(UIButton *)sender;
//  公共的
@property (strong, nonatomic) IBOutlet UILabel *topPastTimeLabel;
@property (strong, nonatomic) IBOutlet UISlider *topProgressSlider;
@property (strong, nonatomic) IBOutlet UILabel *topRemainderLabel;
- (IBAction)rightShareButton:(UIButton *)sender;
- (IBAction)rightCollectButton:(UIButton *)sender;

- (IBAction)topSliderValueChangedAction:(id)sender;
- (IBAction)topSliderTouchDownAction:(id)sender;
- (IBAction)topSliderTouchUpInsideAction:(id)sender;
///分享按钮
@property (weak, nonatomic) IBOutlet UIButton *btnCollect;
//横屏/竖屏下独有的控件
@property (strong, nonatomic) IBOutlet UIImageView *verticalSoundImageView;//声音图片
@property (strong, nonatomic) IBOutlet UIImageView *rotatorSoundImageView;//声音图片
@property (strong, nonatomic) IBOutlet UISlider *rotatorBottomSlider;//  声音进度slider
@property (strong, nonatomic) IBOutlet UISlider *verticalBottomSlider;//  声音进度slider
@property (strong, nonatomic) IBOutlet UIButton *verticalPlayButton;//  播放button
@property (strong, nonatomic) IBOutlet UIButton *rotatorPlayButton;//  播放button

- (IBAction)rotatorUpAction:(id)sender;
- (IBAction)rotatorPlayAction:(UIButton *)sender;
- (IBAction)rotatorNextAction:(UIButton *)sender;
- (IBAction)bottomSoundSliderAction:(UISlider *)sender;

@property (nonatomic, assign) BOOL isFirstRotatorTap;//  横屏下第一次点击
@property (nonatomic, assign) BOOL isFirstVerticalTap;//  竖屏下第一次点击
@property (nonatomic, strong) OrangeAVPlayerHelper *playerHelper;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, assign) BOOL isPlayOrParse;
@property (nonatomic, assign) CGFloat totalMovieDuration;//  保存该视频资源的总时长，快进或快退的时候要用
@end

@implementation OrangeMoviePlayerController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setMoviePlay];
//    [self.rotatorBottomSlider setThumbImage:[UIImage imageNamed:@"blueqface_32 2"] forState:(UIControlStateNormal)];
//    [self.verticalBottomSlider setThumbImage:[UIImage imageNamed:@"blueqface_32 2"] forState:(UIControlStateNormal)];
    [self.rotatorBottomSlider setThumbImage:[UIImage imageNamed:@"bullet_white"] forState:(UIControlStateNormal)];
    [self.verticalBottomSlider setThumbImage:[UIImage imageNamed:@"bullet_white"] forState:(UIControlStateNormal)];
    self.rotatorBottomSlider.value = 0.3;
    self.verticalBottomSlider.value = 0.3;
    self.modalTransitionStyle = 0;
    [self setCollectBtn];
    [self setTopRightBottomFrame];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self setMovieParse];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.topProgressSlider.value = 0.0;
    [self addGestureRecognizer];
    //  添加观察者
    [self addNotificationCenters];
    [self addAVPlayer];
}

-(instancetype)initWithVideoModel:(VideoModel *)model
{
    self = [super init];
    if (self) {
        self.model = model;
        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [caches stringByAppendingPathComponent:self.model.sandboxFileName];
        self.movieURL = [NSURL fileURLWithPath:filePath];
    }
    return self;
}

- (void)addAVPlayer{
    playItem = [AVPlayerItem playerItemWithURL: self.movieURL];
    self.playerHelper = [[OrangeAVPlayerHelper alloc] init];
    [_playerHelper initAVPlayerWithAVPlayerItem:playItem];
    //  创建显示层
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer: _playerHelper.getAVPlayer];
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    //  竖屏的时候frame
    [self setVerticalFrame];
    //  这是视频的填充模式, 默认为AVLayerVideoGravityResizeAspect
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //  插入到view层上面, 没有用addSubLayer
    [self.view.layer insertSublayer:_playerLayer atIndex:0];
    //  添加进度观察
    [self addProgressObserver];
    [self addObserverToPlayerItem: playItem];
    self.btnCollect.layer.cornerRadius = 10;
    self.btnCollect.layer.masksToBounds = YES;
    
}
//  播放页面添加轻拍手势
- (void)addGestureRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAllSubViews:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}
#pragma mark - 观察者 观察播放完毕 观察屏幕旋转
- (void)addNotificationCenters {
    //  注册观察者用来观察，是否播放完毕
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //  注册观察者来观察屏幕的旋转
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}
#pragma mark - 横屏 竖屏的时候frame的设置
- (void)statusBarOrientationChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeRight) {
        [self setPlayerLayerFrame];
        self.isFirstRotatorTap = YES;
        [self setTopRightBottomFrame];
        NSLog(@"我是横屏");
    }
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        [self setPlayerLayerFrame];
        self.isFirstRotatorTap = YES;
       [self setTopRightBottomFrame];
        NSLog(@"我是横屏");
    }
    if (orientation == UIInterfaceOrientationPortrait) {
         // 竖屏的时候
        [self setVerticalFrame];
        self.isFirstRotatorTap = YES;
        [self setTopRightBottomFrame];
        NSLog(@"我是横屏");
    }
}
//  横屏的时候frame
- (void)setPlayerLayerFrame {
    CGRect frame = self.view.bounds;
    frame.origin.x = 20;
    frame.origin.y = (SCREEN_HEIGHT - SCREEN_HEIGHT * (SCREEN_WIDTH - 40) / SCREEN_WIDTH) / 2;
    frame.size.width = SCREEN_WIDTH - 40;
    frame.size.height = SCREEN_HEIGHT * (SCREEN_WIDTH - 40) / SCREEN_WIDTH;
    _playerLayer.frame = frame;
}
//  竖屏的时候frame
- (void)setVerticalFrame {
    CGRect frame = self.view.bounds;
    frame.origin.x = ZERO;
    frame.origin.y = (SCREEN_HEIGHT - SCREEN_WIDTH * (SCREEN_WIDTH / SCREEN_HEIGHT)) / 2;
    frame.size.width = SCREEN_WIDTH;
    frame.size.height = SCREEN_WIDTH * (SCREEN_WIDTH / SCREEN_HEIGHT);
    _playerLayer.frame = frame;
}

//  动画(出现或隐藏top - right - bottom)
- (void)dismissAllSubViews:(UITapGestureRecognizer *)tap {
    [self setTopRightBottomFrame];
}
//  设置TopRightBottomFrame
- (void)setTopRightBottomFrame {
    __weak typeof (self) myself = self;
    if (!self.isFirstRotatorTap) {
        [UIView animateWithDuration:.2f animations:^{
            myself.topView.frame = CGRectMake(myself.topView.frame.origin.x, -TOPVIEW_HEIGHT, myself.topView.frame.size.width, myself.topView.frame.size.height);
            myself.rightView.frame = CGRectMake(SCREEN_WIDTH, myself.rightView.frame.origin.y, myself.rightView.frame.size.width, myself.rightView.frame.size.height);
            myself.verticalBottomView.frame = CGRectMake(myself.verticalBottomView.frame.origin.x, SCREEN_HEIGHT, myself.verticalBottomView.frame.size.width, myself.verticalBottomView.frame.size.height);
            myself.ratotarBottomView.frame = CGRectMake(myself.ratotarBottomView.frame.origin.x, SCREEN_HEIGHT, myself.ratotarBottomView.frame.size.width, myself.ratotarBottomView.frame.size.height);
        }];
        self.isFirstRotatorTap = YES;
    } else {
        [UIView animateWithDuration:.2f animations:^{
            myself.topView.frame = CGRectMake(myself.topView.frame.origin.x, ZERO, myself.topView.frame.size.width, myself.topView.frame.size.height);
            myself.rightView.frame = CGRectMake(SCREEN_WIDTH - RIGHT_WIDTH, myself.rightView.frame.origin.y, myself.rightView.frame.size.width, myself.rightView.frame.size.height);
            myself.verticalBottomView.frame = CGRectMake(myself.verticalBottomView.frame.origin.x, SCREEN_HEIGHT - VERTICAL_BOTTOM_HEIGHT, myself.verticalBottomView.frame.size.width, myself.verticalBottomView.frame.size.height);
            myself.ratotarBottomView.frame = CGRectMake(myself.ratotarBottomView.frame.origin.x, SCREEN_HEIGHT - ROTATOR_BOTTOM_HEIGHT, myself.ratotarBottomView.frame.size.width, myself.ratotarBottomView.frame.size.height);
        }];
        self.isFirstRotatorTap = NO;
    }
}
//  显示top,right,bottom的View
- (void)setTopRightBottomViewHiddenToShow {
    _topView.hidden = NO;
    _rightView.hidden = NO;
    _ratotarBottomView.hidden = NO;
    _verticalBottomView.hidden = NO;
    _isFirstRotatorTap = NO;
}
//  隐藏top,right,bottom的View
- (void)setTopRightBottomViewShowToHidden {
    _topView.hidden = YES;
    _rightView.hidden = YES;
    _ratotarBottomView.hidden = YES;
    _verticalBottomView.hidden = YES;
    _isFirstRotatorTap = YES;
}
#pragma mark - 暂停
- (void)setMovieParse {
    [_playerHelper.getAVPlayer pause];
    isPlay = NO;
    //  因为用的是xib,不设置的话图片会重合
    _verticalPlayButton.imageView.image = nil;
    _rotatorPlayButton.imageView.image = nil;
    [_verticalPlayButton setImage:[UIImage imageNamed:@"播放器_播放"] forState: UIControlStateNormal];
    [_rotatorPlayButton setImage:[UIImage imageNamed:@"播放器_播放"] forState:UIControlStateNormal];
}
#pragma mark - 播放
- (void)setMoviePlay {
    [_playerHelper.getAVPlayer play];
    isPlay = YES;
    //  因为用的是xib,不设置的话图片会重合
    _verticalPlayButton.imageView.image = nil;
    _rotatorPlayButton.imageView.image = nil;
    [_verticalPlayButton setImage:[UIImage imageNamed:@"播放器_暂停"] forState: UIControlStateNormal];
    [_rotatorPlayButton setImage:[UIImage imageNamed:@"播放器_暂停"] forState:UIControlStateNormal];
}

#pragma mark -  添加进度观察 - addProgressObserver
- (void)addProgressObserver {
    //  设置每秒执行一次
    [_playerHelper.getAVPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue: NULL usingBlock:^(CMTime time) {
NSLog(@"进度观察 + %f", _topProgressSlider.value);
        //  获取当前时间
        CMTime currentTime = _playerHelper.getAVPlayer.currentItem.currentTime;
        //  转化成秒数
        CGFloat currentPlayTime = (CGFloat)currentTime.value / currentTime.timescale;
        //  总时间
        CMTime totalTime = playItem.duration;
        //  转化成秒
        _totalMovieDuration = (CGFloat)totalTime.value / totalTime.timescale;
        //  相减后
        _topProgressSlider.value = CMTimeGetSeconds(currentTime) / _totalMovieDuration;
        progressSlider = CMTimeGetSeconds(currentTime) / _totalMovieDuration;
NSLog(@"%f", _topProgressSlider.value);
        NSDate *pastDate = [NSDate dateWithTimeIntervalSince1970: currentPlayTime];
         _topPastTimeLabel.text = [self getTimeByDate:pastDate byProgress: currentPlayTime];
        CGFloat remainderTime = _totalMovieDuration - currentPlayTime;
        NSDate *remainderDate = [NSDate dateWithTimeIntervalSince1970: remainderTime];
        _topRemainderLabel.text = [self getTimeByDate:remainderDate byProgress: remainderTime];
        if (_isFirstRotatorTap) {
            [self setTopRightBottomViewShowToHidden];
        } else {
            [self setTopRightBottomViewHiddenToShow];
        }
    }];
    //  设置topProgressSlider图片
//    [self.topProgressSlider setThumbImage:[UIImage imageNamed:@"Little_Princess_Snail"] forState:(UIControlStateNormal)];
//    [self.topProgressSlider setThumbImage:[UIImage imageNamed:@"Little_Princess_Snail"] forState:(UIControlStateHighlighted)];
    [self.topProgressSlider setThumbImage:[UIImage imageNamed:@"bullet_white"] forState:(UIControlStateNormal)];
    [self.topProgressSlider setThumbImage:[UIImage imageNamed:@"bullet_white"] forState:(UIControlStateHighlighted)];
}

- (NSString *)getTimeByDate:(NSDate *)date byProgress:(float)current {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (current / 3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    return [formatter stringFromDate:date];
}

- (void)addObserverToPlayerItem:(AVPlayerItem *)playerItem {
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem {
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

//  观察者的方法, 会在加载好后触发, 可以在这个方法中, 保存总文件的大小, 用于后面的进度的实现
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if (status == AVPlayerStatusReadyToPlay) {
            NSLog(@"正在播放...,视频总长度: %.2f",CMTimeGetSeconds(playerItem.duration));
            CMTime totalTime = playerItem.duration;
            self.totalMovieDuration = (CGFloat)totalTime.value / totalTime.timescale;
        }
    }
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray *array = playerItem.loadedTimeRanges;
        //  本次缓冲时间范围
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        //  缓冲总长度
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;
//        NSLog(@"共缓冲%.2f", totalBuffer);
        NSLog(@"进度 + %f", progressSlider);
        self.topProgressSlider.value = progressSlider;
    }
}

#pragma mark - UIGestureRecognizerDelegate Method 方法
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    //  不让子视图响应点击事件
    if( CGRectContainsPoint(self.topView.frame, [gestureRecognizer locationInView:self.view]) || CGRectContainsPoint(self.rightView.frame, [gestureRecognizer locationInView:self.view]) || CGRectContainsPoint(self.ratotarBottomView.frame, [gestureRecognizer locationInView:self.view]) || CGRectContainsPoint(self.verticalBottomView.frame, [gestureRecognizer locationInView:self.view])) {
        return NO;
    } else{
        return YES;
    };
}

#pragma mark - 播放进度
- (IBAction)topSliderValueChangedAction:(id)sender {
    UISlider *test = (UISlider *)sender;
    NSLog(@"进度条进度 + %f", test.value);
    UISlider *senderSlider = sender;
    double currentTime = floor(_totalMovieDuration * senderSlider.value);
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(currentTime, 1);
    [_playerHelper.getAVPlayer seekToTime:dragedCMTime completionHandler:^(BOOL finished) {
        if (_isPlayOrParse) {
            [_playerHelper.getAVPlayer play];
        }
    }];
}

- (IBAction)topSliderTouchDownAction:(id)sender {
}

- (IBAction)topSliderTouchUpInsideAction:(id)sender {
}

#pragma mark - 播放上一个
- (IBAction)rotatorUpAction:(id)sender {
    NSLog(@"上一个~~~");
}

#pragma mark - 播放...
- (IBAction)rotatorPlayAction:(UIButton *)sender {
    if (isPlay) {
        [self setMovieParse];
    } else {
        [self setMoviePlay];
    }
}

#pragma mark - 播放下一个...
- (IBAction)rotatorNextAction:(UIButton *)sender {
    NSLog(@"下一个~~~");
}

#pragma mark - 返回按钮...
- (IBAction)finishAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 播放结束后的代理回调
- (void)moviePlayDidEnd:(NSNotification *)notify
{
    [self dismissViewControllerAnimated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayDidEnd" object:nil];
    });
}

#pragma mark - 音量slider
- (IBAction)bottomSoundSliderAction:(UISlider *)sender {
    //  0 - 1
    [_playerHelper setAVPlayerVolume:sender.value];
    self.rotatorBottomSlider.value = sender.value;
    self.verticalBottomSlider.value = sender.value;
//    if (sender.value == 0) {
//        self.rotatorSoundImageView.image = [UIImage imageNamed:@"mute_16px_1199951_easyicon.net"];
//        self.verticalSoundImageView.image = [UIImage imageNamed:@"mute_16px_1199951_easyicon.net"];
//    } else {
//        self.rotatorSoundImageView.image = [UIImage imageNamed:@"high_volume_17.752866242038px_1199944_easyicon.net"];
//        self.verticalSoundImageView.image = [UIImage imageNamed:@"high_volume_17.752866242038px_1199944_easyicon.net"];
//    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch *touch in event.allTouches) {
        self.firstPoint = [touch locationInView:self.view];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch *touch in event.allTouches) {
        self.secondPoint = [touch locationInView:self.view];
    }
    if (self.firstPoint.x > self.view.frame.size.width/2) {
        
        CGFloat value =  self.rotatorBottomSlider.value;
        NSLog(@"%f",value);
        value += (self.firstPoint.y - self.secondPoint.y)/10000.0;
        self.rotatorBottomSlider.value = value;
        [_playerHelper setAVPlayerVolume:self.rotatorBottomSlider.value];
        NSLog(@"%f",value);
    }else{
        CGFloat value = [UIScreen mainScreen].brightness ;
        value += (self.firstPoint.y - self.secondPoint.y)/5000.0;
        //设置系统屏幕的亮度值
        [[UIScreen mainScreen] setBrightness:value];
        NSLog(@"%f",value);
        
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.firstPoint = self.secondPoint = CGPointZero;
}

#pragma mark -  分享 - 收藏 - 缓存
///分享
- (IBAction)rightShareButton:(UIButton *)sender {
       [self setMovieParse];
        NSString *strText = [NSString stringWithFormat:@"来自橘子TV的分享->%@<-%@",self.model.title,self.model.sharelink];
    
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:@"56e6af0767e58e82dc000482"
                                          shareText:strText
                                         shareImage:[UIImage imageNamed:@"Icon"]
                                    shareToSnsNames:[NSArray arrayWithObjects:
                                                     UMShareToSina,
                                                     UMShareToQQ,
                                                     UMShareToQzone,
                                                     UMShareToWechatSession,
                                                     UMShareToWechatTimeline,
                                                     nil]
                                           delegate:self];
}
///收藏
- (IBAction)rightCollectButton:(UIButton *)sender {
    __block NSString *strMessage;
    AVUser *user = [AVUser currentUser];
    if (user) {
            AVQuery *query = [AVQuery queryWithClassName:@"UserCollect"];
            //设置请求查询条件
            [query whereKey:@"userObjectId" equalTo:user.objectId];
            [query whereKey:@"videoId" equalTo:self.model.id];
            //找到符合条件的数据
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (objects.count) {
                    AVObject *objUserCollectInfo = [objects lastObject];
                    [objUserCollectInfo deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            strMessage = @"不再爱了";
                        }else{
                            strMessage = @"旧欢不走,不知为何";
                        }
                        [self setCollectBtn];
                        UIAlertController *alter = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:(UIAlertControllerStyleActionSheet)];
                        [self presentViewController:alter animated:YES completion:nil];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [alter dismissViewControllerAnimated:YES completion:nil];
                        });
                    }];
                }
                else{
                    AVObject *collecItem = [AVObject objectWithClassName:@"UserCollect"];
                    [collecItem setObject:user.objectId forKey:@"userObjectId"];
                    //id为系统关键字,用videoId存放进leanCloud
                    [collecItem setObject:self.model.id forKey:@"videoId"];
                    [collecItem setObject:self.model.title forKey:@"title"];
                    [collecItem setObject:self.model.sharelink forKey:@"sharelink"];
                    [collecItem setObject:self.model.pviewtime forKey:@"pviewtime"];
                    [collecItem setObject:self.model.count_comment forKey:@"count_comment"];
                    [collecItem setObject:self.model.count_share forKey:@"count_share"];
                    [collecItem setObject:self.model.pimg_small forKey:@"pimg_small"];
                    [collecItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            strMessage = @"有新欢了";
                        }
                        [self setCollectBtn];
                        UIAlertController *alter = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:(UIAlertControllerStyleActionSheet)];
                        [self presentViewController:alter animated:YES completion:nil];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [alter dismissViewControllerAnimated:YES completion:nil];
                        });
                    }];
                }
            }];
    }
    //用户没登录时
    else{
        //1.获得数据库文件的路径
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        //通过指定SQLite数据库文件路径来创建FMDatabase对象
        NSString *fileName = [doc stringByAppendingPathComponent:@"t_userCollect.sqlite"];
        FMDatabase *dataBase = [FMDatabase databaseWithPath:fileName];
        if (![dataBase open]) {
            NSLog(@"数据库打开失败");
        }else{
            __block NSString *videoId = nil;
            //创建数据库实例队列
            FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:fileName];
            [queue inDatabase:^(FMDatabase *db) {
                FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM t_userCollect where videoId = ?",self.model.id];
                //遍历结果
                while ([resultSet next]) {
                    videoId = [resultSet stringForColumn:@"videoId"];
                }
                //关闭
                [resultSet close];
            }];
            if (videoId.length == 0) {
                //执行更新：除了查询都成为更新
                //创表
                BOOL createResult = [dataBase executeUpdate:@"CREATE TABLE IF NOT EXISTS t_userCollect (videoId text NOT NULL PRIMARY KEY, model blob );"];
                //插入数据库
                __block BOOL insertBool = NO;
                [queue inDatabase:^(FMDatabase *db) {
                    insertBool = [db executeUpdate:@"INSERT INTO t_userCollect (videoId ,model) VALUES (?, ? );", self.model.id, [NSKeyedArchiver archivedDataWithRootObject:self.model]];
                }];
                if (createResult && insertBool) {
                    [self setCollectBtn];
                    UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"收藏成功!" message:@"新欢已收藏进本地,登录可以进行云收藏哦" preferredStyle:(UIAlertControllerStyleActionSheet)];
                    [self presentViewController:alter animated:YES completion:nil];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [alter dismissViewControllerAnimated:YES completion:nil];
                    });
                }
                else{
                    [self setCollectBtn];
                    UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"收藏失败!" message:@"请在视频下载完毕后再收藏哦" preferredStyle:(UIAlertControllerStyleActionSheet)];
                    [self presentViewController:alter animated:YES completion:nil];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [alter dismissViewControllerAnimated:YES completion:nil];
                    });
                }
            }
            else{
                FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:fileName];
                [queue inDatabase:^(FMDatabase *db) {
                    [db executeUpdate:@"DELETE FROM t_userCollect WHERE videoId = ?",videoId];
                }];
                [self setCollectBtn];
                UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"不再爱了" message:@"收藏已从本地拉出去斩了" preferredStyle:(UIAlertControllerStyleActionSheet)];
                [self presentViewController:alter animated:YES completion:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alter dismissViewControllerAnimated:YES completion:nil];
                });
                
            }
        }
    }
}

-(void)setCollectBtn{
    AVUser *user = [AVUser currentUser];
    if (user) {
        AVQuery *query = [AVQuery queryWithClassName:@"UserCollect"];
        //设置请求查询条件
        [query whereKey:@"userObjectId" equalTo:user.objectId];
        [query whereKey:@"videoId" equalTo:self.model.id];
        //找到符合条件的数据
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count) {
                [self.btnCollect setBackgroundColor:kColor(57, 163, 240, 1)];
            }else{
                [self.btnCollect setBackgroundColor:[UIColor clearColor]];
            }
        }];
    }else{
        //1.获得数据库文件的路径
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        //通过指定SQLite数据库文件路径来创建FMDatabase对象
        NSString *fileName = [doc stringByAppendingPathComponent:@"t_userCollect.sqlite"];
        FMDatabase *dataBase = [FMDatabase databaseWithPath:fileName];
        if (![dataBase open]) {
            NSLog(@"数据库打开失败");
        }else{
            __block NSString *videoId = nil;
            //创建数据库实例队列
            FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:fileName];
            [queue inDatabase:^(FMDatabase *db) {
                FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM t_userCollect where videoId = ?",self.model.id];
                //遍历结果
                while ([resultSet next]) {
                    videoId = [resultSet stringForColumn:@"videoId"];
                }
                //关闭
                [resultSet close];
            }];
            if (videoId.length == 0) {
                 [self.btnCollect setBackgroundColor:[UIColor clearColor]];
            }else{
                [self.btnCollect setBackgroundColor:kColor(57, 163, 240, 1)];
            }
        }
    }
}

- (void)dealloc {
    //  移除观察者,使用观察者模式的时候,记得在不使用的时候,进行移除
    [self removeObserverFromPlayerItem: _playerHelper.getAVPlayer.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    //  返回前一个页面的时候释放内存
    [self.playerHelper.getAVPlayer replaceCurrentItemWithPlayerItem:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//页面支持的方向
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
 

@end