//
//  HottestViewController.m
//  OrangeTV
//
//  Created by PengchengWang on 16/3/10.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "HottestViewController.h"
#import "HotCell.h"
#import <AFNetworking.h>
#import "Hotmodel.h"
#import <UIImageView+WebCache.h>
#import <MJRefresh/MJRefresh.h>
#import <Masonry.h>
#import "DetailHotVCViewController.h"
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height
@interface HottestViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic ,strong)NSMutableArray *AllDataArr;
@property (nonatomic,strong) NSMutableArray *idleImages;
@property (nonatomic,strong) NSMutableArray *pullingImages;//刷新ing动画的图片数组
@property (nonatomic,strong) NSMutableArray *refreshImages;//正在刷新状态下的图片数组
@end

@implementation HottestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getNetData];
    [self setViews];
    
    // Do any additional setup after loading the view from its nib.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
#pragma mark - 获取数据
-(void)getNetData{
    //请求
    self.AllDataArr = nil;
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    __weak typeof(self) weakself = self;
    //    NSLog(@"闲杂三十多岁的%@",weakself.AllDataArr);
    [manager GET:@"http://magicapi.vmovier.com/magicapi/find?json=1&p=1" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        NSLog(@"%@",responseObject);
        //json解析
        
        //        NSLog(@"闲杂三十多岁的%@",weakself.AllDataArr);
        for (NSDictionary * dic in responseObject[@"data"]) {
            Hotmodel * model = [[Hotmodel alloc]init];
            [model setValuesForKeysWithDictionary:dic];
            [weakself.AllDataArr addObject:model];
            //            NSLog(@"现在%lu",(unsigned long)self.AllDataArr.count);
        }
        [self endRefresh];
        // 通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.tableView reloadData];
            [weakself.tableView setHidden:NO];//显示tableview
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [MBProgressHUD hideHUDForView:weakself.view animated:YES];
            });
        }) ;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakself endRefresh];
    }];
}
-(void)endRefresh{
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
}
-(void)setViews{
    //判断网络状态
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    __weak typeof(self) weakself = self;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == 2 && self.AllDataArr != nil) {
            [weakself justDoIt];
        }else if( status == 1 && self.AllDataArr != nil){
            [weakself justDoIt];
        }else if(status == -1 || status  == 0){
            if (self.AllDataArr == nil) {
                
                //移除tbView
                [weakself.tableView removeFromSuperview];
                //设置view的背景图：没有网络
                UIImageView * IMView =[[UIImageView alloc]init];
                IMView.image = [UIImage imageNamed:@"no_connect"];
                [weakself.view addSubview:IMView];
                [IMView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.center.equalTo(weakself.view);
                    make.size.mas_equalTo(CGSizeMake(ScreenW/3, ScreenH/4));
                }];
            }
        }
    }];
    self.navigationItem.title = @"热门";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont systemFontOfSize:18]};
}
-(void)justDoIt{
    [self getNetData];//重新联网时再次加载数据
    UIView * view =[[UIView alloc]initWithFrame:CGRectMake(0, 20, 0, 0)];
    
    self.tableView.tableHeaderView = view;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64,ScreenW , ScreenH-64) style:0];
    [self.view addSubview:view];
    [self.view addSubview:self.tableView];
    [self setDelegate];
    [self.tableView reloadData];
    //隐藏tableview
    [self.tableView setHidden:YES];
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(getNetData)];
    //隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    // 隐藏状态
    header.stateLabel.hidden = YES;
    // 设置动画图片
    self.idleImages    = [NSMutableArray array];
    [self.idleImages addObject:[UIImage imageNamed:@"load-34"]];
    self.pullingImages = [NSMutableArray array];
    for (int i = 0; i <34; i++) {
        [self.pullingImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"load-%d",i]]];
    }
    for (int i = 34; i >=0; i--) {
        [self.pullingImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"load-%d",i]]];
    }
    self.refreshImages = [NSMutableArray array];
    [self.refreshImages addObject:[UIImage imageNamed:@"load-34"]];
    [self.refreshImages addObject:[UIImage imageNamed:@"load-35"]];
    // 设置普通状态的动画图片
    [header setImages:self.idleImages forState:MJRefreshStateIdle];
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    [header setImages:self.pullingImages duration:0.5 forState:MJRefreshStatePulling];
    // [header setImages:self.pullingImages forState:MJRefreshStatePulling];
    // 设置正在刷新状态的动画图片
    [header setImages:self.refreshImages forState:MJRefreshStateRefreshing];
    // 设置header
    self.tableView.mj_header = header;
    // 设置文字
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }];
//    MJRefreshAutoFooterIdleText
}
-(void)setDelegate{
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
}

#pragma mark -代理方法实现
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (self.view.frame.size.height)/3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 30;
}

-(UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HotCell * cell = [tableView dequeueReusableCellWithIdentifier:@"HotCell"];
    if (!cell) {
        cell = [[NSBundle mainBundle]loadNibNamed:@"HotCell" owner:self options:nil].lastObject;
    }
    if (self.AllDataArr.count > 0) {
        Hotmodel * model = self.AllDataArr[indexPath.row];
        [cell.IMV sd_setImageWithURL:[NSURL URLWithString:model.pimg] placeholderImage:[UIImage imageNamed:@"backgroundDown960"]];
        cell.Title.text  = model.pfullname;
        cell.time.text   = model.pviewtime;
        cell.Share.text  = model.count_share;
        cell.commentCount.text = model.count_comment;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DetailHotVCViewController * DtHCV = [[DetailHotVCViewController alloc]init];
    DtHCV.hidesBottomBarWhenPushed = YES;
    Hotmodel * model = self.AllDataArr[indexPath.row];
    DtHCV.idd        = model.id;
    //    NSLog(@"%@",model.id);
    DtHCV.videolink  = model.videolink ;
    DtHCV.sharelink  = model.sharelink ;
    DtHCV.pfullname  = model.pfullname ;
    //    NSLog(@"%@",model.videolink);
    [self.navigationController pushViewController:DtHCV animated:YES];
    //    DtHCV.hidesBottomBarWhenPushed = NO ;
}
//懒加载
-(NSMutableArray *)AllDataArr{
    if (!_AllDataArr) {
        _AllDataArr = [NSMutableArray array];
    }
    return _AllDataArr;
}
//滑动隐藏导航栏

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    //    [self.navigationController setNavigationBarHidden:translation.y<0 animated:YES];
    if (translation.y<0) {
        self.tabBarController.tabBar.hidden = YES;
        
    }else{
        self.tabBarController.tabBar.hidden = NO;
    }
    
    //NSLog(@"ContentOffset  x is  %f,yis %f",translation.x,translation.y);
}


@end
