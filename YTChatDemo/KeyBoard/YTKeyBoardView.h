//
//  YTKeyBoardView.h
//  YTChatDemo
//
//  Created by TI on 15/8/31.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMoreView.h"
#import "YTTextView.h"

@class YTKeyBoardView;
@protocol YTKeyBoardDelegate <NSObject>
@optional
// 当键盘位置发生变化是调用，durtaion时长
- (void)keyBoardView:(YTKeyBoardView *)keyBoard ChangeDuration:(CGFloat)durtaion;

// 发送事件 文字，图片都有可能
- (void)keyBoardView:(YTKeyBoardView *)keyBoard sendResous:(id)resous;

// 音频事件
- (void)keyBoardView:(YTKeyBoardView *)keyBoard audioRuning:(UILongPressGestureRecognizer *)longPress;

// 其他事件，有可能是后期扩展
- (void)keyBoardView:(YTKeyBoardView *)keyBoard otherType:(YTMoreViewTypeAction)type;
@end

@interface YTKeyBoardView : UIView
/* 键盘顶部view 控制键盘各种事件 */
@property (nonatomic,strong) UIView *topView;

// 创建键盘快捷方法
- (instancetype)initDelegate:(id)delegate superView:(UIView *)superView;

// 键盘输入框内容发生变化
- (void)textChange;

// 点击，键盘回到底部
- (void)tapAction;
@end
