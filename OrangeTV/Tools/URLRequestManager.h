//
//  URLRequestManager.h
//  PCNews
//
//  Created by PengchengWang on 16/3/1.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,requestUrlType){
    POST,
    GET
};
typedef void(^success)(id item);

@interface URLRequestManager : NSObject

+(void)requestUrlWithType:(requestUrlType)type
                      strURL:(NSString*)URL
                condition:(NSMutableDictionary*)condition
                  success:(success)success
                    faile:(void(^)(NSError *error))faile;
//获取当前网络状态
+(NSString *)getNetWorkStates;
//single_interface(URLRequestManager);


@end
