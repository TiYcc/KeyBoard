//
//  YTEmojiPage.m
//  YTChatDemo
//
//  Created by TI on 15/8/26.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "YTEmojiPage.h"

@implementation YTEmojiPage

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGRect rect = [super imageRectForContentRect:contentRect];
    rect.size= CGSizeMake(EMOJI_IMG_WH, EMOJI_IMG_WH);
    CGFloat W = self.bounds.size.width;
    CGFloat H = self.bounds.size.height;
    rect.origin = CGPointMake((W-EMOJI_IMG_WH)*0.5f, (H-EMOJI_IMG_WH)*0.5f);
    return rect;
}

@end
