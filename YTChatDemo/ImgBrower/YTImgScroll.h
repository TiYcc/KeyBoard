//
//  YTImgScroll.h
//  YTImgBrower
//
//  Created by TI on 15/10/26.
//  Copyright © 2015年 ycctime.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTImgInfo.h"

@interface YTImgScroll : UIScrollView
@property(nonatomic, strong) YTImgInfo *imgInfo;
/**恢复图片原始状态 animated->是否需要动画*/
- (void)replyStatuseAnimated:(BOOL)animated;

/**双击事件(父视触发，放大或缩小)*/
- (void)doubleTapAction;

/**在横竖屏变化是调用 重新布局*/
- (void)layoutSubview;
@end
