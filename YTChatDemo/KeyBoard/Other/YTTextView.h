//
//  YTTextView.h
//  YTChatDemo
//
//  Created by TI on 15/8/31.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface YTTextView : UITextView
/* 返回一个干净的字符串，主要去掉编码和属性字符 */
@property (nonatomic, strong, readonly) NSString *clearText;

/*
 **  通过传入source 返回一个有可能带属性和表情编码的字符串
 **  fout color 字体大小和颜色 默认15，黑色
 **  offset 设置基线偏移值，取值为 NSNumber(float),正值上偏，负值下偏
 */
+ (NSAttributedString *)getAttributedText:(NSString *)source Font:(UIFont *)font Color:(UIColor *)color Offset:(CGFloat)offset;

// 快速插入一个表情
+ (BOOL)insertAttri:(NSMutableAttributedString *)attri imageName:(NSString *)imageName font:(UIFont *)font offset:(CGFloat)offect;

@end
