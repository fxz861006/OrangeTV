//
//  SingleClass.h
//  OrangeTV
//
//  Created by PengchengWang on 16/3/11.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingleClass : NSObject

///是否允许流量下载
//@property (nonatomic, assign,getter=isUseFlow) BOOL useFlow;

+ (SingleClass*)shareInstance;

@end
