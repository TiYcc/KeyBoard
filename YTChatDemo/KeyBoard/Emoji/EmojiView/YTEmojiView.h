//
//  YTEmojiView.h
//  YTChatDemo
//
//  Created by TI on 15/8/26.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YTEmoji;

#define EMOJI_VIEW_HEIGHT          205.0f
#define EMOJI_SCROLL_HEIGHT        170.0f

@protocol YTEmojiViewDelegate <NSObject>
@optional
/* 点击某个表情，将会显示在输入框内 */
- (void)emojiViewEmoji:(YTEmoji *)emoji;

/* 点击“删除”按钮 */
- (void)emojiViewDelete;

/* 点击“发送”按钮 */
- (void)emojiViewSend;
@end

@interface YTEmojiView : UIView

- (instancetype)initWithDelegate:(id<YTEmojiViewDelegate>)delegate;

@end
