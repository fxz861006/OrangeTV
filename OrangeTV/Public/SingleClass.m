//
//  SingleClass.m
//  OrangeTV
//
//  Created by PengchengWang on 16/3/11.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "SingleClass.h"

@interface SingleClass ()



@end

@implementation SingleClass
+ (SingleClass*)shareInstance {
    static SingleClass *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[SingleClass alloc]init];
    });
    return  obj;
}






@end
