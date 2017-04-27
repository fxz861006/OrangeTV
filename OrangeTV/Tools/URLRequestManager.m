//
//  URLRequestManager.m
//  PCNews
//
//  Created by PengchengWang on 16/3/1.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "URLRequestManager.h"


@implementation URLRequestManager

+(void)requestUrlWithType:(requestUrlType)type strURL:(NSString *)URL condition:(NSMutableDictionary *)condition success:(success)success faile:(void (^)(NSError *))faile{ 
    URLRequestManager *manager = [[URLRequestManager alloc]init];
    switch (type) {
        case GET:{
            [manager getRequestWithURL:URL condition:condition success:^(id item) {
                if (success) {
                    success(item);
                }
            } faile:^(NSError *error) {
                if (faile) {
                    faile(error);
                }
            }];
            break;
        }
        case POST:{
            [manager postRequestWithURL:URL condition:condition success:^(id item) {
                if (success) {
                    success(item);
                }
            } faile:^(NSError *error) {
                if (faile) {
                    faile(error);
                }
            }];
            break;
        }
        default:
            break;
    }
}

-(void)getRequestWithURL:(NSString*)URL
               condition:(NSMutableDictionary*)condition
                 success:(success)success
                   faile:(void (^)(NSError *))faile{
    NSURLSession *session = [NSURLSession sharedSession];
    __block NSMutableString *urlStr = URL.mutableCopy;
    if (condition.count != 0) {
        [urlStr appendString:@"?"];
        [condition enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [urlStr appendString:[NSString stringWithFormat:@"%@=%@",key,obj]];
        }];
        [urlStr substringToIndex:[urlStr length]-2];
    }
    //转码
    NSCharacterSet *chara = [NSCharacterSet characterSetWithCharactersInString:urlStr];
    [urlStr stringByAddingPercentEncodingWithAllowedCharacters:chara];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"GET"];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                      success(result);
                });
                return ;
            }
        }
        if (faile) {
            dispatch_async(dispatch_get_main_queue(), ^{
                 faile(error);
            });

        }
    }];
    [task resume];
}

-(void)postRequestWithURL:(NSString*)URL
               condition:(NSMutableDictionary*)condition
                 success:(success)success
                   faile:(void (^)(NSError *))faile{
    NSURLSession *session = [NSURLSession sharedSession];
    __block NSMutableString *urlStr = URL.mutableCopy;
    __block NSMutableString *bodyStr = bodyStr;
        [condition enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [bodyStr appendString:[NSString stringWithFormat:@"%@=%@",key,obj]];
        }];
        [bodyStr substringToIndex:[bodyStr length]-2];
    //转码
    NSCharacterSet *chara = [NSCharacterSet characterSetWithCharactersInString:urlStr];
    [urlStr stringByAddingPercentEncodingWithAllowedCharacters:chara];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                  success(result);
                });
                return ;
            }
        }
        if (faile) {
            dispatch_async(dispatch_get_main_queue(), ^{
                faile(error);
            });
        }
    }];
    [task resume];
}


+(NSString *)getNetWorkStates{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"]valueForKeyPath:@"foregroundView"]subviews];
    NSString *state = [[NSString alloc]init];
    int netType = 0;
    //获取到网络返回码
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            //获取到状态栏
            netType = [[child valueForKeyPath:@"dataNetworkType"]intValue];
            
            switch (netType) {
                case 0:
                    state = @"无网络";
                    //无网模式
                    break;
                case 1:
                    state = @"2G";
                    break;
                case 2:
                    state = @"3G";
                    break;
                case 3:
                    state = @"4G";
                    break;
                case 5:
                {
                    state = @"WIFI";
                }
                    break;
                default:
                    break;
            }
        }
    }
    //根据状态选择
    return state;
}

single_implementantion(URLRequestManager)


@end
