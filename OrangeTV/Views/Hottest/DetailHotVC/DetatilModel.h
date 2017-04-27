//
//  DetatilModel.h
//  OrangeTV
//
//  Created by lanou3g on 16/3/15.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DetatilModel : NSObject
//点赞数
@property(nonatomic,strong)NSString * count_approve;
//评论id
@property(nonatomic,strong)NSString * commentid;
//评论呢
@property(nonatomic,strong)NSString * content;
//评论时间
@property(nonatomic,strong)NSString * addtime;
//子评论
@property(nonatomic,strong)NSString * subcomment;
//评论者
@property(nonatomic,strong)NSDictionary * user;
//回复评论者
@property(nonatomic,strong)NSMutableDictionary * replyuser;
@property(nonatomic,strong)NSString * referid;
@end
