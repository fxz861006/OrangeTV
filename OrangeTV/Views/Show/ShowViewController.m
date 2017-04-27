//
//  ShowViewController.m
//  OrangeTV
//
//  Created by PengchengWang on 16/3/9.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "ShowViewController.h"
#import "OrangeMoviePlayerController.h"
#import "ShowCenterViewController.h"
#import "VideoModel.h"
#import "SecendViewController.h"
#import "ThirdViewController.h"
#import <FMDB.h>

@interface ShowViewController ()<UIScrollViewDelegate,UMSocialUIDelegate>

{
    NSUserDefaults *userInfo;
    //本地历史记录
    NSMutableArray *arrHistoryVideoID;
    //本地三个当前视频
    NSMutableDictionary *dicCurrentVideoModel;
    VideoModel *modelTep1;
    VideoModel *modelTep2;
    VideoModel *modelTep3;
    
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *centerView;
///收藏按钮
@property (weak, nonatomic) IBOutlet UIButton *btnCollect;

@property(nonatomic,strong)NSMutableArray *arrAllData;
@property(nonatomic,strong)ShowCenterViewController *showCenterVC1;
@property(nonatomic,strong)SecendViewController *showCenterVC2;
@property(nonatomic,strong)ThirdViewController *showCenterVC3;
///记录当前是第几个视频页
@property(nonatomic,assign)NSInteger page;
///FMDB数据库对象
@property (nonatomic,strong)FMDatabase *db;
///FMDB操作队列
@property (nonatomic,strong)FMDatabaseQueue *queue;
///是否可以使用流量
@property(nonatomic,strong)NSString *strUseFlow;
@end

@implementation ShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViews];
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
    [self setCollectBtn];
}

-(void)setViews{
#pragma mark -automaticallyAdjustsScrollViewInsets
    //    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    self.scrollView.delegate = self;
    self.page = 1;
    ///设置scrollView不自动适应大小,否则上下左右都能滑动
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = YES;
    self.showCenterVC1 = [[ShowCenterViewController alloc]init];
    self.showCenterVC2 = [[SecendViewController alloc]init];
    self.showCenterVC3 = [[ThirdViewController alloc]init];
    int y = 10;
    if (kScreenHeight>568) {
        y = 80;
    }else if(kScreenHeight>568 && kScreenHeight<668){
        y = 40;
    }
    self.showCenterVC1.view.frame = CGRectMake((kScreenWidth-300)/2,y, 0, 500);
    self.showCenterVC2.view.frame = CGRectMake((kScreenWidth-300)/2+kScreenWidth, y, 0, 500);
    self.showCenterVC3.view.frame = CGRectMake((kScreenWidth-300)/2+kScreenWidth*2, y, 0, 500);
    [self addChildViewController:self.showCenterVC1];
    [self addChildViewController:self.showCenterVC2];
    [self addChildViewController:self.showCenterVC3];
    [self.centerView addSubview:self.showCenterVC1.view];
    [self.centerView addSubview:self.showCenterVC2.view];
    [self.centerView addSubview:self.showCenterVC3.view];
    userInfo = [NSUserDefaults standardUserDefaults];
    arrHistoryVideoID = [userInfo valueForKey:@"arrHistoryVideoID"];
    dicCurrentVideoModel = [userInfo valueForKey:@"dicCurrentVideoModel"];
    if (dicCurrentVideoModel[@"1"]) {
        VideoModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:dicCurrentVideoModel[@"1"]];
        if (model.sandboxFileName) {
            self.showCenterVC1.model = model;
        }else{
            [self dataBoundFirst];
        }
    }else{
        [self dataBoundFirst];
    }
    
    if (dicCurrentVideoModel[@"2"]) {
        VideoModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:dicCurrentVideoModel[@"2"]];
        if (model.sandboxFileName) {
            self.showCenterVC2.model = model;
        }else{
            [self dataBoundSecend];
        }
    }else{
        [self dataBoundSecend];
    }
    
    if (dicCurrentVideoModel[@"3"]) {
        VideoModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:dicCurrentVideoModel[@"3"]];
        if (model.sandboxFileName) {
            self.showCenterVC3.model = model;
        }else{
            [self dataBoundThird];
        }
    }else{
        [self dataBoundThird];
    }
    [self setCollectBtn];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataBoundFirst) name:@"firstVideoDeleted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataBoundSecend) name:@"secendVideoDeleted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataBoundThird) name:@"thirdVideoDeleted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteVideoAfterPlay) name:@"PlayDidEnd" object:nil];
    
    self.navigationItem.title = @"橙子TV";
}

-(void)dataBoundFirst{
    BOOL boolUseFlow = [self.strUseFlow isEqualToString:@"1"];
    if (!boolUseFlow && ![[URLRequestManager getNetWorkStates] isEqualToString:@"WIFI"]) {
        return;
    }
    if (self.arrAllData.count != 0) {
        [self dataBoundFirstVedio];
    }else
    {
        [self requestFirstVideo];
    }
}

-(void)dataBoundSecend{
    BOOL boolUseFlow= [self.strUseFlow isEqualToString:@"1"];
    if (!boolUseFlow && ![[URLRequestManager getNetWorkStates] isEqualToString:@"WIFI"]) {
        return;
    }
    if (self.arrAllData.count != 0) {
        [self dataBoundSecendVedio];
    }else
    {
        [self requestSecendVideo];
    }

}

-(void)dataBoundThird{
    BOOL boolUseFlow= [self.strUseFlow isEqualToString:@"1"];
    if (!boolUseFlow && ![[URLRequestManager getNetWorkStates] isEqualToString:@"WIFI"]) {
        return;
    }
    if (self.arrAllData.count != 0) {
        [self dataBoundThirdVedio];
    }else
    {
        [self requestThirdVideo];
    }
}

-(void)requestFirstVideo{
    [URLRequestManager requestUrlWithType:GET strURL:kVideoInfoUrl condition:nil success:^(id item) {
        NSDictionary *dicData = item;
        for (NSDictionary *dic in dicData[@"data"]) {
            VideoModel *model = [[VideoModel alloc]init];
            [model setValuesForKeysWithDictionary:dic];
            NSArray *pdownlink = dic[@"pdownlink"];
            NSArray *item = pdownlink[0];
            NSDictionary *dicVideo = item[0];
            model.video = dicVideo[@"video"];
            [self.arrAllData addObject:model];
        }
        [self dataBoundFirstVedio];
        
    } faile:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

-(void)requestSecendVideo{
    [URLRequestManager requestUrlWithType:GET strURL:kVideoInfoUrl condition:nil success:^(id item) {
        NSDictionary *dicData = item;
        for (NSDictionary *dic in dicData[@"data"]) {
            VideoModel *model = [[VideoModel alloc]init];
            [model setValuesForKeysWithDictionary:dic];
            NSArray *pdownlink = dic[@"pdownlink"];
            NSArray *item = pdownlink[0];
            NSDictionary *dicVideo = item[0];
            model.video = dicVideo[@"video"];
            [self.arrAllData addObject:model];
        }
        [self dataBoundSecendVedio];
    } faile:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

-(void)requestThirdVideo{
    [URLRequestManager requestUrlWithType:GET strURL:kVideoInfoUrl condition:nil success:^(id item) {
        NSDictionary *dicData = item;
        for (NSDictionary *dic in dicData[@"data"]) {
            VideoModel *model = [[VideoModel alloc]init];
            [model setValuesForKeysWithDictionary:dic];
            NSArray *pdownlink = dic[@"pdownlink"];
            NSArray *item = pdownlink[0];
            NSDictionary *dicVideo = item[0];
            model.video = dicVideo[@"video"];
            [self.arrAllData addObject:model];
        }
        [self dataBoundThirdVedio];
    } faile:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

-(void)dataBoundFirstVedio{
    ///获取本地用户数据
    userInfo = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [userInfo valueForKey:@"arrHistoryVideoID"];
    NSDictionary *dic = [userInfo valueForKey:@"dicCurrentVideoModel"];
    arrHistoryVideoID = arr.mutableCopy;
    dicCurrentVideoModel = dic.mutableCopy;
    if (!arrHistoryVideoID) {
        arrHistoryVideoID = [[NSMutableArray alloc]init];
        //避免遍历空数组崩溃
        [arrHistoryVideoID addObject:@0];
    }
    if (!dicCurrentVideoModel) {
        dicCurrentVideoModel = [[NSMutableDictionary alloc]init];
    }
    if (dicCurrentVideoModel[@"1"]) {
        modelTep1 = [NSKeyedUnarchiver unarchiveObjectWithData:dicCurrentVideoModel[@"1"]];
    }
    //遍历请求到的所有数据
    BOOL isHaveResource = NO;
    for (VideoModel *model in self.arrAllData) {
        if (![arrHistoryVideoID containsObject:model.id]) {
            if (dicCurrentVideoModel[@"1"]) {
                if (!modelTep1.sandboxFileName) {
                    self.showCenterVC1.model = model;
                    [arrHistoryVideoID addObject:model.id];
                    [userInfo setObject:arrHistoryVideoID forKey:@"arrHistoryVideoID"];
                    isHaveResource = YES;
                    return;
                }
            }else{
                self.showCenterVC1.model = model;
                [arrHistoryVideoID addObject:model.id];
                [userInfo setObject:arrHistoryVideoID forKey:@"arrHistoryVideoID"];
                isHaveResource = YES;
                return;
            }
        }
    }
    if (!isHaveResource) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"firstResourceNO" object:nil];
    }
}

-(void)dataBoundSecendVedio{
    ///获取本地用户数据
    userInfo = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [userInfo valueForKey:@"arrHistoryVideoID"];
    NSDictionary *dic = [userInfo valueForKey:@"dicCurrentVideoModel"];
    arrHistoryVideoID = arr.mutableCopy;
    dicCurrentVideoModel = dic.mutableCopy;
    if (!arrHistoryVideoID) {
        arrHistoryVideoID = [[NSMutableArray alloc]init];
        //避免遍历空数组崩溃
        [arrHistoryVideoID addObject:@0];
    }
    if (!dicCurrentVideoModel) {
        dicCurrentVideoModel = [[NSMutableDictionary alloc]init];
    }
    if (dicCurrentVideoModel[@"2"]) {
        modelTep2 = [NSKeyedUnarchiver unarchiveObjectWithData:dicCurrentVideoModel[@"2"]];
    }
    //遍历请求到的所有数据
    BOOL isHaveResource = NO;
    for (VideoModel *model in self.arrAllData) {
        if (![arrHistoryVideoID containsObject:model.id]) {
            if (dicCurrentVideoModel[@"2"]) {
                if (!modelTep2.sandboxFileName) {
                    self.showCenterVC2.model = model;
                    [arrHistoryVideoID addObject:model.id];
                    [userInfo setObject:arrHistoryVideoID forKey:@"arrHistoryVideoID"];
                    return;
                }
            }else{
                self.showCenterVC2.model = model;
                [arrHistoryVideoID addObject:model.id];
                [userInfo setObject:arrHistoryVideoID forKey:@"arrHistoryVideoID"];
                return;
            }
        }
    }
    if (!isHaveResource) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"secendResourceNO" object:nil];
    }
}

-(void)dataBoundThirdVedio{
    ///获取本地用户数据
    userInfo = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [userInfo valueForKey:@"arrHistoryVideoID"];
    NSDictionary *dic = [userInfo valueForKey:@"dicCurrentVideoModel"];
    arrHistoryVideoID = arr.mutableCopy;
    dicCurrentVideoModel = dic.mutableCopy;
    if (!arrHistoryVideoID) {
        arrHistoryVideoID = [[NSMutableArray alloc]init];
        //避免遍历空数组崩溃
        [arrHistoryVideoID addObject:@0];
    }
    if (!dicCurrentVideoModel) {
        dicCurrentVideoModel = [[NSMutableDictionary alloc]init];
    }
    if (dicCurrentVideoModel[@"3"]) {
        modelTep3 = [NSKeyedUnarchiver unarchiveObjectWithData:dicCurrentVideoModel[@"3"]];
    }
    //遍历请求到的所有数据
    BOOL isHaveResource = NO;
    for (VideoModel *model in self.arrAllData) {
        if (![arrHistoryVideoID containsObject:model.id]) {
            if (dicCurrentVideoModel[@"3"]) {
                if (!modelTep3.sandboxFileName) {
                    self.showCenterVC3.model = model;
                    [arrHistoryVideoID addObject:model.id];
                    [userInfo setObject:arrHistoryVideoID forKey:@"arrHistoryVideoID"];
                    return;
                }
            }else{
                self.showCenterVC3.model = model;
                [arrHistoryVideoID addObject:model.id];
                [userInfo setObject:arrHistoryVideoID forKey:@"arrHistoryVideoID"];
                return;
            }
        }
    }
    if (!isHaveResource) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"thirdResourceNO" object:nil];
    }
}

///点击分享按钮
- (IBAction)btnShareAction:(id)sender {
    userInfo = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userInfo valueForKey:@"dicCurrentVideoModel"];
    VideoModel *model = [NSKeyedUnarchiver unarchiveObjectWithData: dic[[NSString stringWithFormat:@"%ld",(long)self.page]]];
    if (model.sandboxFileName) {
        NSString *strText = [NSString stringWithFormat:@"来自橘子TV的分享->%@<-%@",model.title,model.videolink];
       
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
    }else{
        UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"莫着急" message:@"请在视频下载完毕后再分享哦" preferredStyle:(UIAlertControllerStyleActionSheet)];
        [self presentViewController:alter animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alter dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

///点击收藏按钮
- (IBAction)btnCollectAction:(id)sender {
    userInfo = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userInfo valueForKey:@"dicCurrentVideoModel"];
    VideoModel *model = [NSKeyedUnarchiver unarchiveObjectWithData: dic[[NSString stringWithFormat:@"%ld",(long)self.page]]];
    __block NSString *strMessage = @"不晓得收藏了没";
    if (!model.sandboxFileName) {
        UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"莫着急" message:@"请在视频下载完毕后再收藏哦" preferredStyle:(UIAlertControllerStyleActionSheet)];
        [self presentViewController:alter animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alter dismissViewControllerAnimated:YES completion:nil];
        });
        return;
    }
    
    AVUser *user = [AVUser currentUser];
    if (user) {
        //视频下载完毕才能收藏
        if (model.sandboxFileName) {
            MBProgressHUD *hudCollect = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hudCollect.mode = MBProgressHUDModeText;
            hudCollect.labelText = @"🍊😄🍊";
            AVQuery *query = [AVQuery queryWithClassName:@"UserCollect"];
            //设置请求查询条件
            [query whereKey:@"userObjectId" equalTo:user.objectId];
            [query whereKey:@"videoId" equalTo:model.id];
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
                        hudCollect.hidden = YES;
                    }];
                }
                else{
//                    MBProgressHUD *hudDeletCollect = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//                    hudDeletCollect.mode = MBProgressHUDModeText;
//                    hudDeletCollect.labelText = @"橙子TV正在努力的为你收藏";
                    AVObject *collecItem = [AVObject objectWithClassName:@"UserCollect"];
                    [collecItem setObject:user.objectId forKey:@"userObjectId"];
                    //id为系统关键字,用videoId存放进leanCloud
                    [collecItem setObject:model.id forKey:@"videoId"];
                    [collecItem setObject:model.title forKey:@"title"];
                    [collecItem setObject:model.sharelink forKey:@"sharelink"];
                    [collecItem setObject:model.pviewtime forKey:@"pviewtime"];
                    [collecItem setObject:model.count_comment forKey:@"count_comment"];
                    [collecItem setObject:model.count_share forKey:@"count_share"];
                    [collecItem setObject:model.pimg_small forKey:@"pimg_small"];
                    [collecItem setObject:model.videolink forKey:@"videolink"];
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
                        hudCollect.hidden = YES;
                    }];
                }
            }];
            
        }else{
            UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"莫着急" message:@"请在视频下载完毕后再收藏哦" preferredStyle:(UIAlertControllerStyleActionSheet)];
            [self presentViewController:alter animated:YES completion:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alter dismissViewControllerAnimated:YES completion:nil];
            });
        }
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
                FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM t_userCollect where videoId = ?",model.id];
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
                    insertBool = [db executeUpdate:@"INSERT INTO t_userCollect (videoId ,model) VALUES (?, ? );", model.id, [NSKeyedArchiver archivedDataWithRootObject:model]];
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
    userInfo = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userInfo valueForKey:@"dicCurrentVideoModel"];
    VideoModel *model = [NSKeyedUnarchiver unarchiveObjectWithData: dic[[NSString stringWithFormat:@"%ld",(long)self.page]]];
    if (!model.sandboxFileName) {
        [self.btnCollect setImage:[UIImage imageNamed:@"keep_normal"] forState:(UIControlStateNormal)];
        return;
    }
    AVUser *user = [AVUser currentUser];
    if (user) {
        AVQuery *query = [AVQuery queryWithClassName:@"UserCollect"];
        //设置请求查询条件
        [query whereKey:@"userObjectId" equalTo:user.objectId];
        [query whereKey:@"videoId" equalTo:model.id];
        //找到符合条件的数据
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count) {
                [self.btnCollect setImage:[UIImage imageNamed:@"keep_selected"] forState:(UIControlStateNormal)];
            }else{
                [self.btnCollect setImage:[UIImage imageNamed:@"keep_normal"] forState:(UIControlStateNormal)];
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
                FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM t_userCollect where videoId = ?",model.id];
                //遍历结果
                while ([resultSet next]) {
                    videoId = [resultSet stringForColumn:@"videoId"];
                }
                //关闭
                [resultSet close];
            }];
            if (videoId.length == 0) {
                [self.btnCollect setImage:[UIImage imageNamed:@"keep_normal"] forState:(UIControlStateNormal)];
            }else{
                [self.btnCollect setImage:[UIImage imageNamed:@"keep_selected"] forState:(UIControlStateNormal)];
            }
        }
    }
}

///点击删除按钮
- (IBAction)btnDeleteAction:(id)sender {
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"确认要删除?" message:@"你确认要删除该视频吗" preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteVideoNow];
    }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"我再想想" style:UIAlertActionStyleCancel handler:nil];
    [alter addAction:yesAction];
    [alter addAction:noAction];
    [self presentViewController:alter animated:yesAction completion:nil];

}

-(void)deleteVideoAfterPlay{
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"观看完毕" message:@"该视频已撸完,要删吗主人?" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteVideoNow];
    }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"我再想想" style:UIAlertActionStyleDefault handler:nil];
    [alter addAction:yesAction];
    [alter addAction:noAction];
    [self presentViewController:alter animated:YES completion:nil];
}

-(void)deleteVideoNow{
    switch (self.page) {
        case 1:
            [self.showCenterVC1 deleteVideo];
            break;
        case 2:
            [self.showCenterVC2 deleteVideo];
            break;
        case 3:
            [self.showCenterVC3 deleteVideo];
            break;
        default:
            break;
    }
    [self setCollectBtn];
}

///滑动结束记录当前第几个视频页
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.scrollView.contentOffset.x<kScreenWidth) {
        self.page = 1;
    }else if (self.scrollView.contentOffset.x>=kScreenWidth && self.scrollView.contentOffset.x<kScreenWidth*2){
        self.page = 2;
    }else{
        self.page = 3;
    }
    [self setCollectBtn];
}

-(NSMutableArray *)arrAllData{
    if (!_arrAllData) {
        _arrAllData = [[NSMutableArray alloc]init];
    }
    return _arrAllData;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)strUseFlow{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *str = [user valueForKey:@"strUseFlow"];
    return str;
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
