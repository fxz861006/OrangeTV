//
//  OrangeMoviePlayerController.h
//  OrangeMoviewPlayer_Xib
//
//  Created by PengchengWang on 16/3/9.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoModel.h"

@interface OrangeMoviePlayerController : UIViewController



@property (nonatomic,assign)CGPoint firstPoint;
@property (nonatomic,assign)CGPoint secondPoint;
///自定义初始化方法
- (instancetype)initWithVideoModel:(VideoModel*)model;

@end