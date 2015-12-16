//
//  YTTextAttachment.h
//  YTChatDemo
//
//  Created by TI on 15/8/31.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTTextAttachment : NSTextAttachment

@property (nonatomic, strong) NSString *emojiCode; //编码字符

/** 插入表情到attri中 */
- (void)insertAttri:(NSMutableAttributedString *)attri font:(UIFont *)font;
@end
