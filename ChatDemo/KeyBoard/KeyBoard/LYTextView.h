//
//  LYTextView.h
//  chatUI
//
//  Created by TI on 15/4/21.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmoTaxtAttachment.h"
@interface LYTextView : UITextView<NSTextStorageDelegate>

@property (nonatomic, strong)NSString * plainText;

+ (CGRect)getJamTextSize:(CGSize)constrainedSize attributeString:(NSAttributedString *)attributeString;

+ (NSAttributedString *)getAttributedText:(NSString *)source font:(UIFont *)font color:(UIColor*)color jamScale:(float)jamScale bottom:(float)bottom;

@end
