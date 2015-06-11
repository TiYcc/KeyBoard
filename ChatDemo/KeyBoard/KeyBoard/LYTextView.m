//
//  LYTextView.m
//  chatUI
//
//  Created by TI on 15/4/21.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "LYTextView.h"
@interface LYTextView()

@end

@implementation LYTextView

-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(void)awakeFromNib{
    self.textStorage.delegate = self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textStorage.delegate = self;
        self.dataDetectorTypes = UIDataDetectorTypeAll;
    }
    return self;
}

-(NSString *)plainText{
    
    NSRange range = NSMakeRange(0, self.attributedText.length);
    NSMutableAttributedString *result = [self.attributedText mutableCopy];
    
    [result enumerateAttribute:NSAttachmentAttributeName inRange:range options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value && [value isKindOfClass:[EmoTaxtAttachment class]]) {
            EmoTaxtAttachment *attach = (EmoTaxtAttachment *)value;
            [result deleteCharactersInRange:range];
            [result insertAttributedString:[[NSAttributedString alloc] initWithString:attach.emoName] atIndex:range.location];
        }
    }];
    return result.string;
}

+ (CGRect)getJamTextSize:(CGSize)constrainedSize attributeString:(NSAttributedString *)attributeString {
    return [attributeString boundingRectWithSize:constrainedSize
                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                         context:nil];
}

+ (NSAttributedString *)getAttributedText:(NSString *)source font:(UIFont *)font color:(UIColor *)color jamScale:(float)jamScale jamTop:(CGFloat)jamTop bottom:(float)bottom{
    
    NSScanner *theScanner;
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] init];
    NSString *text = nil;
    
    NSRange prange = [source rangeOfString:@"["];
    if (prange.location == NSNotFound) {//没有自定义表情
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:source attributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:color}];
        [attributeString appendAttributedString:str];
        return attributeString;
    }
    
    theScanner = [NSScanner scannerWithString:source];
    while (![theScanner isAtEnd]) {
        [theScanner scanUpToString:@"[" intoString:&text];//截取"["之前字符
        if (text && ![text isEqualToString:@"]"] && (text.length > 0)) {
            NSAttributedString *str = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:color}];
            [attributeString appendAttributedString:str];
        }
        
        text = nil;
        [theScanner scanUpToString:@"]" intoString:&text];//取得"[]"之间字符
        if (text && ![text isEqualToString:@"]"] && (text.length > 0)) {
            EmoTaxtAttachment *attach = [[EmoTaxtAttachment alloc] initWithData:nil ofType:nil];
            attach.Scale = jamScale;
            attach.Top = jamTop;
            attach.image = [UIImage imageNamed:[NSString stringWithFormat:@"emo_%@", [text substringFromIndex:1]]];
            if (attach.image && attach.image.size.width > 1.0f) {
                attach.emoName = [NSString stringWithFormat:@"[%@]", [text substringFromIndex:1]];
                [attributeString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
                
                NSRange range;
                range.location = attributeString.length - 1;
                range.length = 1;
                
                NSParagraphStyle *paragraph = [NSParagraphStyle defaultParagraphStyle];
                
                [attributeString setAttributes:@{NSAttachmentAttributeName:attach, NSFontAttributeName:font, NSBaselineOffsetAttributeName:[NSNumber numberWithInt:bottom], NSParagraphStyleAttributeName:paragraph} range:range];
            } else {
                NSString *txt = [NSString stringWithFormat:@"%@]", text];
                NSAttributedString *str;
                if ([txt isEqualToString:@"[草稿]"]) {
                    str = [[NSAttributedString alloc] initWithString:txt attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:[UIColor redColor]}];
                } else {
                    str = [[NSAttributedString alloc] initWithString:txt attributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:color}];
                }
                if (str) {
                    [attributeString appendAttributedString:str];
                } 
            }
        }
        text = nil;
        [theScanner scanString: @"]" intoString: NULL];
    }
    
    return attributeString;
}

+ (NSAttributedString *)getAttributedText:(NSString *)source font:(UIFont *)font color:(UIColor *)color jamScale:(float)jamScale bottom:(float)bottom{
    
    if (!color)  color = [UIColor blackColor];
    
    return [self getAttributedText:source font:font color:color jamScale:jamScale jamTop:-5.0f bottom:bottom];
}

@end
