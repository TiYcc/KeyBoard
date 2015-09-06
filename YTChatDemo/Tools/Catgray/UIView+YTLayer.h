//
//  UIView+YTLayer.h
//  YTChatDemo
//
//  Created by TI on 15/8/26.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (YTLayer)

/* 指定圆角大小处理 */
- (void)cornerRadius:(CGFloat)radius;

/* 添加border */
- (void)borderWithColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth;

/* 指定圆角大小，且带border */
- (void)cornerRadius:(CGFloat)radius borderColor:(UIColor*)borderColor borderWidth:(CGFloat)borderWidth;

/* 对UIView的四个角进行选择性的圆角处理 */
- (void)makeRoundedCorner:(UIRectCorner)byRoundingCorners cornerRadii:(CGSize)cornerRadii;
@end
