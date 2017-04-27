//
//  Hotmodel.m
//  OrangeTV
//
//  Created by lanou3g on 16/3/11.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import "Hotmodel.h"

@implementation Hotmodel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.id = value;
    }
}
@end
