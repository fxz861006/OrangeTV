//
//  Time.m
//  OrangeTV
//
//  Created by lanou3g on 16/3/22.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "Time.h"

@implementation Time

/*
 传入时间与现在时间差距在60秒以内，输出@“刚刚”
 1个小时以内，输出@“**分钟前”
 差距1-24小时以内，输出@“**小时前”
 差距24小时到48小时，输出昨天
 差距大于48小时，输出@“完整日期”
 */

// 处理后返回
+ (NSString *)handleDate:(NSString *)dateString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    NSTimeInterval timeInterval = date.timeIntervalSinceNow;
    double time = -(timeInterval - 28800);
    NSString *backString;
    if (time < 60 && time > 0) {
        backString = @"刚刚";
    } else if (time > 60 && time < 3600 ) {
        int Minute = time / 60;
        backString = [NSString stringWithFormat:@"%d 分钟前",Minute];
        
    } else if (time > 3600 && time < 86400) {
        int Hour = time / 3600;
        backString = [NSString stringWithFormat:@"%d 小时前",Hour];
        
    } else if (time > 86400 && time < 172800) {
       
        backString = [NSString stringWithFormat:@"昨天"];
        
    } else if (time > 172800) {
        dateFormatter.dateFormat = @"MM-dd HH:mm";
        backString = [dateFormatter stringFromDate:date];
    }
    
    
    return backString;
}


// 从服务器请求下来的
+ (NSString *)timeIntervalToDate:(NSString *)timeinterval {
    
    NSTimeInterval time = [timeinterval doubleValue]; //因为时差问题要加8小时 == 28800 sec
    NSDate *detailDate = [NSDate dateWithTimeIntervalSince1970:time];
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *currentDateStr = [dateFormatter stringFromDate:detailDate];
    
    return currentDateStr;
}

@end
