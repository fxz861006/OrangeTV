//
//  NSObject+AutoEncode.h
//  DynamicEncode
//
//  Created by 陈凯 on 15/12/2.
//  Copyright © 2015年 鸥！陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AutoEncode)<NSCoding>

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
@end
