//
//  DataBase.h
//  OrangeTV
//
//  Created by lanou3g on 16/3/18.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


@interface DataBase : NSObject

+(DataBase *)shareDataBase;

//打开数据库
-(void)openDB;

/**
 *  添加数据
 */


@end
