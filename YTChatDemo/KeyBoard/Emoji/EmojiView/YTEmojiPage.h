//
//  YTEmojiPage.h
//  YTChatDemo
//
//  Created by TI on 15/8/26.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YTEmojiM;

#define EMOJI_IMG_WH      20.0f

@interface YTEmojiPage : UIButton
@property (nonatomic, strong) YTEmojiM *emojiM;    //包含此类表情全部信息
@property (nonatomic, assign) CGPoint offsetStart;  //表情开始位置
@property (nonatomic, assign) CGPoint offsetEnd;    //表情结束位置
@end
