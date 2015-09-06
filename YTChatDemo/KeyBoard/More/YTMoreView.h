//
//  YTMoreView.h
//  YTChatDemo
//
//  Created by TI on 15/9/1.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, YTMoreViewTypeAction){
    YTMoreViewTypeActionNon = 0, //
    YTMoreViewTypeActionPhoto,
    YTMoreViewTypeActionCamera
};
@protocol YTMoreViewDelegate <NSObject>

/**moewView包含控件事件，有可能是后期扩展*/
- (void)moreViewType:(YTMoreViewTypeAction)type;
@end

@interface YTMoreView : UIView

@property (nonatomic, strong) id<YTMoreViewDelegate> delegate; //代理

@end
