//
//  YTTextView.m
//  YTChatDemo
//
//  Created by TI on 15/8/31.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "YTTextAttachment.h"
#import "UIImage+YTGif.h"
#import "YTTextView.h"

@implementation YTTextView

- (NSString *)clearText{
    NSMutableAttributedString *result = [self.attributedText mutableCopy];
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [result enumerateAttribute:NSAttachmentAttributeName inRange:range options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value && [value isKindOfClass:[YTTextAttachment class]]) {
            YTTextAttachment *attach = (YTTextAttachment *)value;
            [result deleteCharactersInRange:range];
            [result insertAttributedString:[[NSAttributedString alloc] initWithString:attach.emojiCode] atIndex:range.location];
        }
    }];
    return result.string;
}

+ (NSAttributedString *)getAttributedText:(NSString *)source Font:(UIFont *)font Color:(UIColor *)color Offset:(CGFloat)offset{
    if (!color) color = [UIColor blackColor];
    if (!font) font = [UIFont systemFontOfSize:15];
    
    NSRange prange = [source rangeOfString:@"["];
    NSRange hrange = [source rangeOfString:@"]"];
    if ((prange.location==NSNotFound)||(hrange.location==NSNotFound)) { // 没有自定义表情
        NSAttributedString * attributeString = [[NSAttributedString alloc] initWithString:source attributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:color}];
        return attributeString;
    }
    
    // 有可能包含自定义表情
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] init];
    NSScanner *theScanner = [NSScanner scannerWithString:source];
    NSString *text = nil;
    while (![theScanner isAtEnd]) {
        //截取"["之前字符
        [theScanner scanUpToString:@"[" intoString:&text];
        if (text&&(text.length > 0)) {
            NSAttributedString *str = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:color}];
            [attributeString appendAttributedString:str];
        }//end
        
        text = nil;
        //取得"[]"之间字符
        [theScanner scanUpToString:@"]" intoString:&text];
        if (text && ![text isEqualToString:@"]"] && (text.length > 0)) {
            NSString *imageName = [text substringFromIndex:1];
            BOOL insert= [[self class]insertAttri:attributeString imageName:imageName font:font offset:offset];
            if (!insert) {
                NSString *txt = [NSString stringWithFormat:@"%@]", text];
                NSDictionary *attrs = nil;
                // 识别是不是草稿
                if ([txt isEqualToString:@"[草稿]"]) {
                    attrs = @{NSFontAttributeName:font, NSForegroundColorAttributeName:[UIColor redColor]};
                } else {
                    attrs = @{NSFontAttributeName:font, NSForegroundColorAttributeName:color};
                }
                
                NSAttributedString * str = [[NSAttributedString alloc] initWithString:txt attributes:attrs];
                if (str) {
                    [attributeString appendAttributedString:str];
                }

            }
        }
        text = nil;
        [theScanner scanString:@"]" intoString:NULL];
    }
    return attributeString;
}

+ (BOOL)insertAttri:(NSMutableAttributedString *)attri imageName:(NSString *)imageName font:(UIFont *)font offset:(CGFloat)offect{
    NSData *data = UIImagePNGRepresentation([UIImage imageNamed:imageName]);
    YTTextAttachment *attach = [[YTTextAttachment alloc] initWithData:data ofType:nil];
    if (attach.image && attach.image.size.width > 1.0f) {
        // 表情插入strat
        attach.emojiCode = [NSString stringWithFormat:@"[%@]", imageName];
        [attach insertAttri:attri font:font offset:offect];
        return YES;
        // 表情图片插入end
    }else{
        return NO;
    }
}

@end
