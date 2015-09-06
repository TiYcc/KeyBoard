//
//  YTEmojiButton.m
//  YTChatDemo
//
//  Created by TI on 15/8/26.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "YTEmojiButton.h"
#import "YTEmoji.h"

@implementation YTEmojiButton

- (void)setEmoji:(YTEmoji *)emoji{
    _emoji = emoji;
    [self setImage:[UIImage imageNamed:emoji.emojiImage] forState:UIControlStateNormal];
}

@end
