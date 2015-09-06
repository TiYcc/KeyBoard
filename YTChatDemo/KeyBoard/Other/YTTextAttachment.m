//
//  YTTextAttachment.m
//  YTChatDemo
//
//  Created by TI on 15/8/31.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "YTTextAttachment.h"

@implementation YTTextAttachment

- (instancetype)initWithData:(NSData *)contentData ofType:(NSString *)uti{
    if (self = [super initWithData:contentData ofType:uti]) {
        if (!self.image) {
            self.image = [UIImage imageWithData:contentData];
        }
    }
    return self;
}

- (void)insertAttri:(NSMutableAttributedString *)attri font:(UIFont *)font offset:(CGFloat)offset{
   
    [attri appendAttributedString:[NSAttributedString attributedStringWithAttachment:self]];
    NSRange range = NSMakeRange(attri.length-1, 1);
    NSParagraphStyle * paragraph = [NSParagraphStyle defaultParagraphStyle];
    NSDictionary * attrs = @{NSAttachmentAttributeName:self,
                             NSFontAttributeName:font,
                             NSBaselineOffsetAttributeName:[NSNumber numberWithInt:offset],
                             NSParagraphStyleAttributeName:paragraph};
    [attri setAttributes:attrs range:range];
}

// 重写表情加入字符串位置具体信息
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex{
    
    return CGRectMake(0, 0, lineFrag.size.height, lineFrag.size.height);
}

@end
