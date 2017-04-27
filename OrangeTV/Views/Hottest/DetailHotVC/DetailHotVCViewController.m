//
//  DetailHotVCViewController.m
//  OrangeTV
//
//  Created by lanou3g on 16/3/14.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "DetailHotVCViewController.h"
#import <UIImageView+WebCache.h>
#import "DetatilModel.h"
#import "AContentCell.h"
#import "UIView+KYJkeyboard.h"
#import "reDetatilModel.h"
#import "BcontentCell.h"
#import "Time.h"
#import <AVOSCloud/AVOSCloud.h>
#import "LoginViewController.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define Powder [UIColor colorWithRed:254/255.0 green:124/255.0 blue:148/255.0 alpha:1]
@interface DetailHotVCViewController ()<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate,UITextFieldDelegate>
@property(nonatomic ,strong)NSMutableArray *AllDataArr;
@property(nonatomic ,strong)NSMutableArray *AllDataArrR;
@property(nonatomic,strong)UIWebView * weView;
@property (nonatomic, strong) UIView *critiqueView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITapGestureRecognizer * singleTap;
@property (nonatomic, strong) UIView *viewn;
@property (nonatomic, strong) NSString * comenttime;
@end

@implementation DetailHotVCViewController
{
    NSString * useeerUrl;
    NSString * userrNaem;
}



//滑动隐藏导航栏
//-(void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//
//    self.navigationController.navigationBarHidden = NO;
//
//}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
    [self loadUserxinxi];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //关闭自动填充屏幕
    self.automaticallyAdjustsScrollViewInsets = NO ;
    _weView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 20,kScreenWidth, 1)];
    _weView.delegate = self ;
    _weView.scrollView.scrollEnabled = NO;
    [_weView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.videolink]]];
    
    
    
    UILabel * lableT = [[UILabel alloc]init];
    lableT.font =[UIFont systemFontOfSize:15];
    lableT.text = @" 炙热评论";
    [_weView addSubview:lableT];
    [lableT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.bottom.equalTo(@-10);
        make.width.equalTo(@100);
        
    }];
    
    [self getData];
    UIBarButtonItem * baritem1 =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction)];
    
    NSArray * arr1 = [[NSArray alloc]initWithObjects:baritem1, nil];
    self.navigationItem.rightBarButtonItems = arr1;
}
-(void)shareAction{
    
    AVUser *currentUser = [AVUser currentUser];
    if (currentUser != nil) {
        // 允许用户使用应用
        NSString *strText = [NSString stringWithFormat:@"来自橘子TV的分享 ->%@<-,%@",self.pfullname,self.videolink];
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
    } else {
        LoginViewController * logvc = [[LoginViewController alloc]init];
        [self presentViewController:logvc animated:YES completion:nil];
        
    }
    
    
}
-(void)setViews{
    self.tableView.autoresizesSubviews = YES ;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,kScreenWidth, kScreenHeight) style:1];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    //影藏cell的占位线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self showKEYboard];
    
    
    
}

#pragma mark - 获取数据
-(void)getData{
    //请求
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    __weak typeof(self) weakself = self;
    NSString * url = [NSString stringWithFormat:@"http://magicapi.vmovier.com/magicapi/comment/getList&postid=%@",self.idd];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //json解析
        weakself.AllDataArr = nil;
        for (NSDictionary * dic in responseObject[@"data"][@"comments"]) {
            DetatilModel * model = [[DetatilModel alloc]init];
            [model setValuesForKeysWithDictionary:dic];
            
            [weakself.AllDataArr addObject:model];
            if ([dic.allKeys containsObject:@"subcomment"]) {
                for (NSDictionary * dicc in dic[@"subcomment"]) {
                    DetatilModel * Rmodel = [[DetatilModel alloc]init];
                    [Rmodel setValuesForKeysWithDictionary:dicc];
                    [weakself.AllDataArr addObject:Rmodel];
                }
                
            }
        }
        
        // 通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [weakself setViews];
                [weakself setdelegate];
                //     [weakself loadUserxinxi];
            });
        }) ;
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


-(void)setdelegate{
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
}
#pragma mark - cell头视图尾视图
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
#pragma mark - cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        if(indexPath.row == 0){
            
            return self.weView.frame.size.height+20;
        }
    }
    DetatilModel * mode =  self.AllDataArr[indexPath.row];
    return [AContentCell cellHightWithString:mode.content];
}
#pragma mark - cell个数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return 1;
    }
    return self.AllDataArr.count;
}
#pragma mark - 组数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}


-(UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetatilModel * model =self.AllDataArr[indexPath.row];
    static NSString *ID3 = @"BcontentCell";
    BcontentCell *cellb = [tableView dequeueReusableCellWithIdentifier:ID3];
    
    if (indexPath.section == 0) {
        static NSString *ID1 = @"CellA";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID1];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID1];
            [cell addSubview:_weView];
        }
        /* 忽略点击效果 */
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        
        return cell;
        
    }
    
    if (indexPath.section == 1)
    {
        if ([model.referid isEqualToString:@"0"])
        {
            
            static NSString *ID2 = @"AContentCell";
            AContentCell *cell = [tableView dequeueReusableCellWithIdentifier:ID2];
            if (!cell)
            {
                cell = [[AContentCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID2];
            }
            //        DetatilModel * mode =  self.AllDataArr[indexPath.row];
            cell.userIMG.layer.cornerRadius = 20;
            cell.userIMG.layer.masksToBounds = YES;
            //图片自适应
            cell.userIMG.contentMode = UIViewContentModeScaleAspectFit;
            [cell.userIMG sd_setImageWithURL:[model.user valueForKey:@"avatar"]placeholderImage:[UIImage imageNamed:@"headImage"]];
            cell.name.text = [model.user valueForKey:@"username"];
            cell.name.font = [UIFont systemFontOfSize:12];
            cell.name.textColor = [UIColor lightGrayColor];
            //根据文字重新改变拉不了的高度
            CGRect rect = cell.concent.frame;
            rect.size.height = [AContentCell cellHightWithString:model.content];
            cell.concent.frame = rect;
            cell.concent.text = model.content;
            cell.concent.textColor = kColor(20, 20, 20, 0.8);
            cell.concent.font = [UIFont systemFontOfSize:15];
            //时间
            NSString * date = [Time timeIntervalToDate:model.addtime];
            
            cell.time.text = [Time handleDate:date];
            cell.time.font = [UIFont systemFontOfSize:11];
            cell.time.textColor = [UIColor lightGrayColor];
            /* 忽略点击效果 */
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

            
            return cell;
            
        }else
        {
            if (!cellb)
            {
                cellb = [[BcontentCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID3];
            }
            
            cellb.userIMG.layer.cornerRadius = 20;
            cellb.userIMG.layer.masksToBounds = YES;
            //图片自适应
            cellb.userIMG.contentMode = UIViewContentModeScaleAspectFit;
            [cellb.userIMG sd_setImageWithURL:[model.user valueForKey:@"avatar"]placeholderImage:[UIImage imageNamed:@"headImage"]];
            cellb.name.text = [model.user valueForKey:@"username"];
            cellb.name.font = [UIFont systemFontOfSize:12];
            cellb.name.textColor = [UIColor lightGrayColor];
            cellb.replyname.text = [model.replyuser valueForKey:@"username"];
            cellb.replyname.font = [UIFont systemFontOfSize:12];
            cellb.replyname.textColor = [UIColor lightGrayColor];
            //根据文字重新改变拉不了的高度
            CGRect rect = cellb.concent.frame;
            rect.size.height = [AContentCell cellHightWithString:model.content];
            cellb.concent.frame = rect;
            cellb.concent.text = model.content;
            cellb.concent.textColor = kColor(20, 20, 20, 0.8);
            cellb.concent.font = [UIFont systemFontOfSize:15];
            //时间
            NSString * date = [Time timeIntervalToDate:model.addtime];
            
            cellb.time.text = [Time handleDate:date];
            
            cellb.time.font = [UIFont systemFontOfSize:11];
            cellb.time.textColor = [UIColor lightGrayColor];
            /* 忽略点击效果 */
            [cellb setSelectionStyle:UITableViewCellSelectionStyleNone];

        }
    }
    return cellb;
}


//cell的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView  deselectRowAtIndexPath:indexPath animated:YES];
    
    AVUser *currentUser = [AVUser currentUser];
    if (currentUser != nil) {
        [self.textField becomeFirstResponder];
        DetatilModel * model =self.AllDataArr[indexPath.row];
        self.comenttime = model.addtime;
        self.textField.placeholder = [NSString stringWithFormat:@"回复：%@",[model.user valueForKey:@"username"]];
        [self.critiqueView setHidden:NO];
    }else {
        LoginViewController * logvc = [[LoginViewController alloc]init];
        [self presentViewController:logvc animated:YES completion:nil];
        
    }
    
    
}
/**
 *  webView完成加载
 */
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    //获取到webview的高度
    CGFloat height = [[self.weView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    self.weView.frame = CGRectMake(self.weView.frame.origin.x,self.weView.frame.origin.y+10, kScreenWidth, height);
    [self.tableView reloadData];
    //加载完成后重新设置 tableview的cell的高度,和webview的frame
}
//懒加载
-(NSMutableArray *)AllDataArr{
    if (!_AllDataArr) {
        _AllDataArr = [NSMutableArray array];
    }
    return _AllDataArr;
}
-(NSMutableArray *)AllDataArrR{
    if (!_AllDataArrR) {
        _AllDataArrR = [NSMutableArray array];
    }
    return _AllDataArrR;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

//滑动隐藏导航栏

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    [self.navigationController setNavigationBarHidden:translation.y<0 animated:YES];
    
    if (translation.y<0) {
        
        [self.critiqueView setHidden:YES];
    }else{
        [self.critiqueView setHidden:NO];
    }
    
}
#pragma mark - 监听方法
/**
 * 键盘的frame发生改变时调用（显示、隐藏等）
 */
- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    //    if (self.picking) return;
    /**
     notification.userInfo = @{
     // 键盘弹出\隐藏后的frame
     UIKeyboardFrameEndUserInfoKey = NSRect: {{0, 352}, {320, 216}},
     // 键盘弹出\隐藏所耗费的时间
     UIKeyboardAnimationDurationUserInfoKey = 0.25,
     // 键盘弹出\隐藏动画的执行节奏（先快后慢，匀速）
     UIKeyboardAnimationCurveUserInfoKey = 7
     }
     */
    
    NSDictionary *userInfo = notification.userInfo;
    
    // 动画的持续时间
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 键盘的frame
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 执行动画
    [UIView animateWithDuration:duration animations:^{
        // 工具条的Y值 == 键盘的Y值 - 工具条的高度
        if (keyboardF.origin.y > self.view.height) { // 键盘的Y值已经远远超过了控制器view的高度
            self.critiqueView.y = self.view.height - self.critiqueView.height;//这里的<span style="background-color: rgb(240, 240, 240);">self.toolbar就是我的输入框。</span>
        } else {
            self.critiqueView.y = keyboardF.origin.y - self.critiqueView.height;
            
        }
    }];
    CGRect frame = _viewn.frame;
    frame.size.height = self.critiqueView.y;
    _viewn.frame = frame;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    
    AVUser *currentUser = [AVUser currentUser];
    if (currentUser != nil) {
        [self.textField becomeFirstResponder];
        [UIView animateWithDuration:0.2 animations:^{
            
            self.critiqueView.frame = CGRectMake(0, kScreenHeight - 294, kScreenWidth, 40);
            
        }];
        NSLog(@"%f",self.critiqueView.frame.size.height);
        _viewn = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth,  0)];
        NSLog(@"%f",_viewn.frame.origin.y);
        _viewn.backgroundColor = kColor(100, 100, 100, 0.5);
        [self.view addSubview:_viewn];
        _singleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
        [_viewn addGestureRecognizer:_singleTap];
        
    }else {
        LoginViewController * logvc = [[LoginViewController alloc]init];
        [self presentViewController:logvc animated:YES completion:nil];
        [self.textField resignFirstResponder];
    }
    
    
    
}
-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    
    [self.textField resignFirstResponder];
    self.textField.placeholder =  @"请输入评论...";
    self.textField.font = [UIFont fontWithName:@"Arial" size:13.0f];
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [_viewn removeFromSuperview];
    //
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendMess];
    
    return YES;
}
- (void)sendMess
{
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
    
    
    
    if ([self.textField.placeholder isEqualToString: @"请输入评论..."] && self.textField.text.length >0) {
        DetatilModel * model = [[DetatilModel alloc]init];
        //评论时间
        NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970];
        model.addtime =[NSString stringWithFormat:@"%f",nowtime];
        model.content = self.textField.text;
        
        model.user = @{@"avatar":useeerUrl,@"username":userrNaem};
        model.referid = @"0";
        [self.AllDataArr addObject:model];
        
        [self.tableView reloadData];
    }else if (self.textField.text.length >0){
        for (int i = 0; i<self.AllDataArr.count; i++) {
            DetatilModel * modell = self.AllDataArr[i];
            NSString * placeholdertext =[self.textField.placeholder substringFromIndex:3];
            if ([[modell.user valueForKey:@"username"] isEqualToString: placeholdertext] && [modell.addtime isEqualToString:self.comenttime]) {
                DetatilModel * model = [[DetatilModel alloc]init];
                //评论时间
                NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970];
                model.addtime =[NSString stringWithFormat:@"%f",nowtime];
                model.content = self.textField.text;
                
                model.user = @{@"avatar":useeerUrl,@"username":userrNaem};
                model.referid = @"1";
                model.replyuser = [NSMutableDictionary new];
                [model.replyuser setValue:placeholdertext forKey:@"username"];
                [self.AllDataArr insertObject:model atIndex:i+1];
                [self.tableView reloadData];
            }
        }
        
    }
    
    self.textField.placeholder =  @"请输入评论...";
    self.textField.font = [UIFont fontWithName:@"Arial" size:13.0f];
    
    self.textField.text = @"";
}

-(void)loadUserxinxi{
    AVUser *currentUser = [AVUser currentUser];
    if (currentUser != nil) {
        
        AVQuery *query = [AVQuery queryWithClassName:@"UserInfo"];
        //设置请求查询条件
        [query whereKey:@"userObjectId" equalTo:currentUser.objectId];
        //找到符合条件的数据
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count) {
                NSDictionary *dic = objects[0];
                
                userrNaem = currentUser.username;
                useeerUrl = dic[@"userIconUrl"];
                //  userCell.lblUserName.text = dic[@"userName"];
                //            model.user = @{@"avatar":dic[@"userIconUrl"],@"username":currentUser.username};
                //[userCell.imgV sd_setImageWithURL:dic[@"userIconUrl"]];
            }
        }];
    }
}
-(void)showKEYboard{
    self.critiqueView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 40, kScreenWidth, 40)];
    self.critiqueView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.critiqueView];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, kScreenWidth - 70, 30)];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.backgroundColor = [UIColor whiteColor];
    self.textField.placeholder = @"请输入评论...";
    self.textField.font = [UIFont fontWithName:@"Arial" size:13.0f];
    self.textField.clearButtonMode = UITextFieldViewModeAlways;
    self.textField.returnKeyType = UIReturnKeyGo;
    self.textField.delegate = self;
    //    self.search.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"所有背景.png"]];
    [self.critiqueView addSubview:self.textField];
    
    UIButton *button = [UIButton buttonWithType:0];
    button.frame = CGRectMake(kScreenWidth - 50, 5, 40, 30);
    [button setTitle:@"发送" forState:0];
    [button setTitleColor:Powder forState:0];
    [self.critiqueView  addSubview:button];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button addTarget:self action:@selector(sendMess) forControlEvents:UIControlEventTouchUpInside];
    
    
    //键盘通知
    
    //键盘的frame发生改变时发出的通知（位置和尺寸）
    
    //UIKeyboardWillChangeFrameNotification
    
    //UIKeyboardDidChangeFrameNotification
    
    //键盘显示时发出的通知
    
    //UIKeyboardWillShowNotification
    
    //UIKeyboardDidShowNotification
    
    //键盘隐藏时发出的通知
    
    //UIKeyboardWillHideNotification
    
    //UIKeyboardDidHideNotification
    
    
    
    [[NSNotificationCenter
      defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:)
     name:UIKeyboardWillChangeFrameNotification object:nil];//在这里注册通知
}


@end
