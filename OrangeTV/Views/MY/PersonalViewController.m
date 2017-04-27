//
//  PersonalViewController.m
//  OrangeTV
//
//  Created by lanou3g on 16/3/16.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "PersonalViewController.h"
#import "EditInfoViewController.h"
#import "CollectionTableViewCell.h"
#import "LoginViewController.h"
#import "VideoModel.h"
#import "DetailHotVCViewController.h"
@interface PersonalViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    AVUser *currentUser;
    
}

@property (weak, nonatomic) IBOutlet UIImageView *userHeaderImage;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property(nonatomic,strong) NSMutableArray *arrAllData;

@end

@implementation PersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViews];
}

-(void)viewWillAppear:(BOOL)animated{
    self.leftline.backgroundColor = [UIColor blueColor];
    currentUser = [AVUser currentUser];
    if (currentUser != nil) {
        AVQuery *query = [AVQuery queryWithClassName:@"UserInfo"];
        //设置请求查询条件
        [query whereKey:@"userObjectId" equalTo:currentUser.objectId];
        //找到符合条件的数据
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count) {
                NSDictionary *dic = objects[0];
                [self.userHeaderImage sd_setImageWithURL:dic[@"userIconUrl"]];
            } else {
                // 输出错误信息
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    self.navigationController.navigationBar.translucent = YES;
    [self setEditView];
    [self dataBound];
    [self setNavagationBarTitle];
    // 隐藏 tarBar
    self.tabBarController.tabBar.hidden = YES ;
}

-(void)setViews{
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Theme_Background.jpg"]]];
//    [self.collectionTableV setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Theme_Background.jpg"]]];
    self.editButton.layer.cornerRadius = 15;
    self.editButton.layer.masksToBounds = YES;
    [self.editButton setBackgroundImage:[UIImage imageNamed:@"1_write_64px_14182_easyicon.net"] forState:(UIControlStateNormal)];
    self.userHeaderImage.image = [UIImage imageNamed:@"headImage"];
    self.userHeaderImage.layer.cornerRadius = 40;
    self.userHeaderImage.layer.masksToBounds = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCountAction)];
    [self.userHeaderImage addGestureRecognizer:tapGesture];
    self.collectionTableV.delegate = self;
    self.collectionTableV.dataSource = self;
    [self.collectionTableV registerNib:[UINib nibWithNibName:@"CollectionTableViewCell" bundle:nil] forCellReuseIdentifier:@"CollectionTableViewCell"];
}

-(void)setNavagationBarTitle{
    currentUser = [AVUser currentUser];
    //创建颜色UIColor
    UIColor * color = [UIColor blackColor];
    //创建NSDictionary,对应key和颜色
    NSDictionary * dict = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    //设置navigationController颜色
    self.navigationController.navigationBar.titleTextAttributes = dict;
    if (currentUser != nil) {
        AVQuery *query = [AVQuery queryWithClassName:@"UserInfo"];
        //设置请求查询条件
        [query whereKey:@"userObjectId" equalTo:currentUser.objectId];
        //找到符合条件的数据
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count) {
                NSDictionary *dic = objects[0];
                self.title = [NSString stringWithFormat:@"%@の私人空间",dic[@"userName"]];
            } else {
                // 输出错误信息
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }else{
        self.title = [NSString stringWithFormat:@"私人空间"];
    }
}

-(void)setEditView{
    currentUser = [AVUser currentUser];
    if (currentUser != nil) {
        self.lblTitle.text = @"云收藏";
        
    }else{
        self.lblTitle.text = @"本地收藏(点击头像登录)";
    }
}

- (IBAction)editButtonAction:(UIButton *)sender {
    [self tapCountAction];
}

-(void)tapCountAction{
    if (currentUser != nil) {
        EditInfoViewController *editiInfoVC = [[EditInfoViewController alloc]init];
        [self.navigationController pushViewController:editiInfoVC animated:YES];
    }else{
        LoginViewController *loginVC = [[LoginViewController alloc]init];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}

-(void)dataBound{
    self.arrAllData = nil;
    if (currentUser) {
        AVQuery *query = [AVQuery queryWithClassName:@"UserCollect"];
        //设置请求查询条件
        [query whereKey:@"userObjectId" equalTo:currentUser.objectId];
        //找到符合条件的数据
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count) {
                for (AVObject *obj in objects) {
                    [self.arrAllData addObject:obj];
                }
            }else{
                return;
            }
            [self.collectionTableV reloadData];
        }];
    }else{
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        //通过指定SQLite数据库文件路径来创建FMDatabase对象
        NSString *fileName = [doc stringByAppendingPathComponent:@"t_userCollect.sqlite"];
        FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:fileName];
        [queue inDatabase:^(FMDatabase *db) {
            FMResultSet *resultSet = [db executeQuery:@"SELECT model FROM t_userCollect"];
            //遍历结果
            while ([resultSet next]) {
                NSData *modelData = [resultSet dataForColumn:@"model"];
                //解码
                VideoModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:modelData];
                [self.arrAllData addObject:model];
                NSLog(@"本地:-----%@",model.title);
            }
            //关闭
            [resultSet close];
            [self.collectionTableV reloadData];
        }];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrAllData.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CollectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionTableViewCell"];
    if (currentUser) {
        AVObject *obj = self.arrAllData[indexPath.row];
        [cell.imgPic sd_setImageWithURL:[NSURL URLWithString:[obj valueForKey:@"pimg_small"]]];
        cell.lblTitle.text = [obj valueForKey:@"title"];
        cell.lblCount_comment.text = [obj valueForKey:@"count_comment"];
        cell.lblCount_share.text = [obj valueForKey:@"count_share"];
        cell.lblPviewtime.text = [obj valueForKey:@"pviewtime"];
        return cell;
    }else{
        VideoModel *model = self.arrAllData[indexPath.row];
        [cell.imgPic sd_setImageWithURL:[NSURL URLWithString:model.pimg_small]];
        cell.lblTitle.text = model.title;
        cell.lblCount_comment.text = model.count_comment;
        cell.lblCount_share.text = model.count_share;
        cell.lblPviewtime.text = model.pviewtime;
        return cell;
    }
}

//点击跳转
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DetailHotVCViewController * DtHCV = [[DetailHotVCViewController alloc]init];
    DtHCV.hidesBottomBarWhenPushed = YES;
    if (self.arrAllData) {
        if (!currentUser) {
            VideoModel *model = self.arrAllData[indexPath.row];
            DtHCV.idd        = model.id;
            DtHCV.videolink  = model.videolink;
        }else{
            AVObject *obj = self.arrAllData[indexPath.row];
            DtHCV.idd        = [obj valueForKey:@"videoId"];
            DtHCV.videolink  = [obj valueForKey:@"videolink"];
        }
        self.navigationController.navigationBar.hidden = NO;
        [self.navigationController pushViewController:DtHCV animated:YES];
    }
}

//删除
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    //返回编辑类型
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!currentUser) {
        VideoModel *model = self.arrAllData[indexPath.row];
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        //通过指定SQLite数据库文件路径来创建FMDatabase对象
        NSString *fileName = [doc stringByAppendingPathComponent:@"t_userCollect.sqlite"];
        FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:fileName];
        [queue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:@"DELETE FROM t_userCollect WHERE videoId = ? ",model.id];
            UIAlertController *alter = [UIAlertController alertControllerWithTitle:nil message:@"本地收藏删除成功" preferredStyle:(UIAlertControllerStyleActionSheet)];
            [self presentViewController:alter animated:YES completion:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alter dismissViewControllerAnimated:YES completion:nil];
            });
            [self dataBound];
        }];
    }else{
        AVObject *obj = self.arrAllData[indexPath.row];
        AVQuery *query = [AVQuery queryWithClassName:@"UserCollect"];
        //设置请求查询条件
        [query whereKey:@"userObjectId" equalTo:currentUser.objectId];
        [query whereKey:@"videoId" equalTo:[obj valueForKey:@"videoId"]];
        //找到符合条件的数据
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count) {
                AVObject *objUserCollectInfo = [objects lastObject];
                [objUserCollectInfo deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        UIAlertController *alter = [UIAlertController alertControllerWithTitle:nil message:@"不再爱了" preferredStyle:(UIAlertControllerStyleActionSheet)];
                        [self presentViewController:alter animated:YES completion:nil];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [alter dismissViewControllerAnimated:YES completion:nil];
                        });
                    }else{
                        NSLog(@"删除失败");
                    }
                    [self dataBound];
                }];
            }
        }];
    }
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
