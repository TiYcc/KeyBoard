//
//  EmojiButton.m
//  chatUI
//
//  Created by TI on 15/4/23.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "EmojiButton.h"
#import "EmojiObj.h"

@implementation EmojiButton

-(void)setEmojiIcon:(EmojiObj *)emojiIcon{
    _emojiIcon = emojiIcon;
    [self setImage:[UIImage imageNamed:emojiIcon.emojiImgName] forState:UIControlStateNormal];
}

@end
