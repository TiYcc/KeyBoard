//
//  YTEmojiBottom.h
//  YTChatDemo
//
//  Created by TI on 15/8/26.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//
//  如果你不喜欢这个效果可以自己写个bottom或者对它加以修改，来吻合你的想法。

#import <UIKit/UIKit.h>

#define EMOJI_BOTTOM_HEIGHT        35.0f
#define EMOJI_BOTTOM_BUTTON_WIDTH  40.0f

@interface YTEmojiBottom : UIView

@property (nonatomic, strong) UIButton *rightButton; //发送
@property (nonatomic, strong) UIButton *liftButton; //添加
@property (nonatomic, strong) UIScrollView *scrollView; //表情栏

//发送按钮-隐藏与显示
- (void)rightButtonAnimationHiden:(BOOL)hiden;

@end
