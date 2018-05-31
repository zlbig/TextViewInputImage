//
//  UIImage+Add.m
//  TagTextView
//
//  Created by bigzl on 2018/5/31.
//  Copyright © 2018年 bigzl. All rights reserved.
//

#import "UIImage+Add.h"

@implementation UIImage (Add)

+ (UIImage *)imageFromString:(NSString *)string attributes:(NSDictionary *)attributes size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [string drawInRect:CGRectMake(0, 0, size.width, size.height) withAttributes:attributes];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
