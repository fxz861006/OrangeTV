//
//  AppDelegate.h
//  OrangeTV
//
//  Created by PengchengWang on 16/3/9.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
 
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


//新浪appkey:3524621101
//secret:7f1073320c543b83d7976973a9e5061a

//腾讯QQappID:1105254554 > 十六进制 :0x41E0D89A
//appkey: KvDuHSjbtk4hql6k

//微信 APPID: wx9adbb88c0b57926d
//appsecret: 656c991396fa7393e901e6a6aeb5de02




@end

