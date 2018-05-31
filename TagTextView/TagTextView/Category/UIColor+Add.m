//
//  UIColor+Add.m
//  TagTextView
//
//  Created by bigzl on 2018/5/31.
//  Copyright © 2018年 bigzl. All rights reserved.
//

#import "UIColor+Add.h"

@implementation UIColor (Add)

+ (UIColor*)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue {
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}

@end
