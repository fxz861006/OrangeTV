//
//  NSObject+AutoEncode.m
//  DynamicEncode
//
//  Created by 陈凯 on 15/12/2.
//  Copyright © 2015年 鸥！陈凯. All rights reserved.
//

#import "NSObject+AutoEncode.h"
#import <Foundation/Foundation.h>
//#import <objc/objc-runtime.h>
#import <objc/runtime.h>
@implementation NSObject (AutoEncode)
/*
 #define _C_ID       '@'
 #define _C_CLASS    '#'
 #define _C_SEL      ':'
 #define _C_CHR      'c'
 #define _C_UCHR     'C'
 #define _C_SHT      's'
 #define _C_USHT     'S'
 
 #define _C_INT      'i'
 #define _C_UINT     'I'
 #define _C_LNG      'l'
 #define _C_ULNG     'L'
 #define _C_LNG_LNG  'q'
 #define _C_ULNG_LNG 'Q'
 
 #define _C_FLT      'f'
 #define _C_DBL      'd'
 #define _C_BFLD     'b'
 #define _C_BOOL     'B'
 #define _C_VOID     'v'
 #define _C_UNDEF    '?'
 #define _C_PTR      '^'
 #define _C_CHARPTR  '*'
 #define _C_ATOM     '%'
 #define _C_ARY_B    '['
 #define _C_ARY_E    ']'
 #define _C_UNION_B  '('
 #define _C_UNION_E  ')'
 #define _C_STRUCT_B '{'
 #define _C_STRUCT_E '}'
 #define _C_VECTOR   '!'
 #define _C_CONST    'r'
 */
static NSString *I = @"iIlLqQ";
static NSString *D = @"fd";
static NSString *N = @"@\"NS@\"UI";
- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int ivarCount = 0;
    Ivar *vars = class_copyIvarList(object_getClass(self), &ivarCount);
    for (int i = 0; i < ivarCount; i++) {
        Ivar var = vars[i];
        
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(var)];
        NSLog(@"%@",type);
        NSString *varName = [NSString stringWithUTF8String:ivar_getName(var)];
        id value = [self valueForKey:varName];
        [aCoder encodeObject:value forKey:varName];
    }
    free(vars);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    unsigned int ivarCount = 0;
    Ivar *vars = class_copyIvarList(object_getClass(self), &ivarCount);
    for (int i = 0; i < ivarCount; i++) {
        Ivar var = vars[i];
        
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(var)];

        NSString *varName = [NSString stringWithUTF8String:ivar_getName(var)];
        NSLog(@"%@  %@",type,varName);
        [self setValue:[aDecoder decodeObjectForKey:varName] forKey:varName];
        
    }
    free(vars);
    return self;
}
/*
 - (void)encodeWithCoder:(NSCoder *)encoder
 {
 unsigned int count = 0;
 //  利用runtime获取实例变量的列表
 Ivar *ivars = class_copyIvarList([self class], &count);
 for (int i = 0; i < count; i ++) {
 //  取出i位置对应的实例变量
 Ivar ivar = ivars[i];
 //  查看实例变量的名字
 const char *name = ivar_getName(ivar);
 
 NSString *nameStr = [NSString stringWithUTF8String:name];        //  利用KVC取出属性对应的值
 id value = [self valueForKey:nameStr];
 //  归档
 [encoder encodeObject:value forKey:nameStr];
 }
 
 //  记住C语言中copy出来的要进行释放
 free(ivars);
 
 }
 
 - (id)initWithCoder:(NSCoder *)decoder
 {
 if (self = [self init]) {
 unsigned int count = 0;
 Ivar *ivars = class_copyIvarList([self class], &count);
 for (int i = 0; i < count; i ++) {
 Ivar ivar = ivars[i];
 const char *name = ivar_getName(ivar);
 
 //
 NSString *key = [NSString stringWithUTF8String:name];
 id value = [decoder decodeObjectForKey:key];
 //  设置到成员变量身上
 [self setValue:value forKey:key];
 }
 
 free(ivars);
 }
 return self;
 }
 */
 
@end
