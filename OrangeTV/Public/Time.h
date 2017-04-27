//
//  Time.h
//  OrangeTV
//
//  Created by lanou3g on 16/3/22.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Time : NSObject
// 处理后返回
+ (NSString *)handleDate:(NSString *)dateString;
// 从服务器请求下来的
+ (NSString *)timeIntervalToDate:(NSString *)timeinterval;
@end
