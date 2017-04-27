//
//  StyleViewController.m
//  OrangeTV
//
//  Created by lanou3g on 16/3/15.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "StyleViewController.h"
#import "StyleCollectionViewCell.h"
#import "HeaderView.h"
#import "FooterView.h"

@interface StyleViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong)NSMutableArray *arrAllData;
@property (weak, nonatomic) IBOutlet UICollectionView *styleCollectionView;

@end

@implementation StyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"喜好设置";
    [self setViews];
    //设置代理
    self.styleCollectionView.delegate = self;
    self.styleCollectionView.dataSource = self;
    
    [self setData];
   
}
#pragma mark - 设置视图
-(void)setViews{
    
    self.styleCollectionView.backgroundColor = kColor(57, 163, 240, 1);
    
    UICollectionViewFlowLayout *flowLayOut = [[UICollectionViewFlowLayout alloc] init];
    //cell大小
    flowLayOut.itemSize = CGSizeMake((kScreenWidth-100)/3, 30);
    flowLayOut.minimumInteritemSpacing = 20;
    flowLayOut.minimumLineSpacing = 20;
    flowLayOut.sectionInset = UIEdgeInsetsMake(30, 30, 30, 30);
    
    self.styleCollectionView.collectionViewLayout = flowLayOut;
    //上下滑动
    [flowLayOut setScrollDirection:(UICollectionViewScrollDirectionVertical)];
    //设置头视图和尾视图
    [flowLayOut setHeaderReferenceSize:(CGSizeMake(self.styleCollectionView.frame.size.width, 90))];
    [flowLayOut setFooterReferenceSize:(CGSizeMake(self.styleCollectionView.frame.size.width, 50))];
    
    //注册cell
    [self.styleCollectionView registerNib:[UINib nibWithNibName:@"StyleCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell_id"];
    //注册header和footer
    [self.styleCollectionView registerClass:[HeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header_id"];
    [self.styleCollectionView registerClass:[FooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer_id"];
}
#pragma mark - 解析数据
-(void)setData{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"style" ofType:@"plist"];
//    self.arrAllData = [[NSMutableArray alloc] init];
    self.arrAllData = [NSMutableArray arrayWithContentsOfFile:filePath];
    
    for (NSString *str in self.arrAllData) {
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:str];
    }
}

#pragma mark - cell 个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.arrAllData.count;
}
#pragma mark - cell内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    StyleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell_id" forIndexPath:indexPath];

    cell.labelText.text = self.arrAllData[indexPath.row];
    return cell;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionReusableView *reusableView = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        HeaderView *header = (HeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header_id" forIndexPath:indexPath];
        
//        header.label.numberOfLines = 0;
        header.label.text = @"选择你喜欢的标签,我们会根据你的选择为你推送更多的内容";
        reusableView = header;
        
        
    }else{
        FooterView *footerView = (FooterView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer_id" forIndexPath:indexPath];
        
        [footerView.saveButton setTitle:@"保存" forState:(UIControlStateNormal)];
//        [footerView.saveButton setBackgroundColor:[UIColor orangeColor]];
        [footerView.saveButton addTarget:self action:@selector(saveButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
        reusableView = footerView;
    }
    return reusableView;
}

-(void)saveButtonAction{
//    self.styleCollectionView.backgroundColor = [UIColor colorWithRed:<#(CGFloat)#> green:<#(CGFloat)#> blue:<#(CGFloat)#> alpha:<#(CGFloat)#>]
    self.styleCollectionView.backgroundColor = [UIColor cyanColor];
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    StyleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell_id" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor greenColor];
    NSLog(@"%ld--%ld",indexPath.section,indexPath.row);
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
