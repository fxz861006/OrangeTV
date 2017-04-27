//
//  UIImage+Change.h
//  OrangeTV
//
//  Created by PengchengWang on 16/3/18.
//  Copyright © 2016年 pengchengWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Change)
//截取部分图像
-(UIImage*)getSubImage:(CGRect)rect;
//等比例缩放
-(UIImage*)scaleToSize:(CGSize)size;
@end
