//
//  UIColor+YTBacal.m
//  YTChatDemo
//
//  Created by TI on 15/8/31.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "UIColor+YTBacal.h"

@implementation UIColor (YTBacal)

+ (UIColor *)colorR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b A:(CGFloat)a{
    return [self colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a];
}

+ (UIColor *)colorR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b{
    return [self colorR:r G:g B:b A:1.0f];
}

+ (UIColor *)C_95A5A6{//灰
    return [self colorR:149 G:165 B:166];
}

+ (UIColor *)C_ECF0F1{//白雾色
    return [self colorR:236 G:240 B:241];
}

+ (UIColor *)C_DDDDDD{//浅灰
    return [self colorR:221 G:221 B:221];
}

+ (UIColor *)C_A9A9A9{//深灰
    return [self colorR:169 G:169 B:169];
}

+ (UIColor *)C_FCFCFC{//浅白
    return [self colorR:252 G:252 B:252];
}

+ (UIColor *)C_F9F7F9{//灰白
    return [self colorR:249 G:247 B:247];
}

@end
