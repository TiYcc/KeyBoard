//
//  LYKeyBoardView.h
//  6park
//
//  Created by TI on 15/5/5.
//  Copyright (c) 2015年 6park. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extensions)

//指定大小的圆角处理
- (void)cornerRadius:(CGFloat)radius;

//指定大小圆角，且带border
- (void)cornerRadius:(CGFloat)radius borderColor:(UIColor*)borderColor borderWidth:(CGFloat)borderWidth;

//添加border
- (void)borderWithColor:(UIColor*)borderColor borderWidth:(CGFloat)borderWidth;

// 对UIView的四个角进行选择性的圆角处理
- (void)makeRoundedCorner:(UIRectCorner)byRoundingCorners cornerRadii:(CGSize)cornerRadii;

@end
