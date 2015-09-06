//
//  YTEmojiBottom.m
//  YTChatDemo
//
//  Created by TI on 15/8/26.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "UIView+YTLayer.h"
#import "YTEmojiBottom.h"

@interface YTLine : UIView

@end

@implementation YTLine

- (void)addToSuperView:(UIView *)superView{
    if (superView) {
        CGSize size = superView.bounds.size;
        CGRect frame = CGRectMake(size.width-0.5f, 5.0f, 0.5f, size.height-10.0f);
        self.frame = frame;
        self.backgroundColor = [UIColor grayColor];
        [superView addSubview:self];
    }
}

@end

@interface YTScrollView : UIScrollView

@end

@implementation YTScrollView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.alwaysBounceVertical = NO;
    }
    return self;
}

- (void)addSubview:(UIView *)view{
    if (view) {
        YTLine *line = [[YTLine alloc]init];
        [line addToSuperView:view];
        [super addSubview:view];
    }
}

- (void)setContentSize:(CGSize)contentSize{
    contentSize.width = MAX(contentSize.width+(EMOJI_BOTTOM_BUTTON_WIDTH*1.5f), self.bounds.size.width+1);
    [super setContentSize:contentSize];
}

@end

@implementation YTEmojiBottom

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self borderWithColor:[UIColor lightGrayColor] borderWidth:0.5];
        [self initUI];
    }
    return self;
}

- (void)initUI{
    [self addScrollView];
    [self addBts];
}

- (void)addBts{
    UIColor *viewBGColor = [UIColor whiteColor];
    UIColor *btTitleColor = [UIColor grayColor];
    //lift button
    CGRect frame = CGRectMake(0, 0, EMOJI_BOTTOM_BUTTON_WIDTH, self.frame.size.height);
    UIView *liftView = [[UIView alloc]initWithFrame:frame];
    liftView.backgroundColor = viewBGColor;
    UIButton *lift = [[UIButton alloc]initWithFrame:liftView.bounds];
    [lift setTitle:@"+" forState:UIControlStateNormal];
    [lift setTitleColor:btTitleColor forState:UIControlStateNormal];
    YTLine *line = [[YTLine alloc]init];
    [line addToSuperView:lift];
    [liftView addSubview:lift];
    self.liftButton = lift;
    [self addSubview:liftView];
    //right button
    frame.origin.x = self.bounds.size.width - EMOJI_BOTTOM_BUTTON_WIDTH*1.5;
    frame.size.width *= 1.5;
    UIView *rightView = [[UIView alloc]initWithFrame:frame];
    rightView.backgroundColor = viewBGColor;
    frame = rightView.bounds;
    frame.size.width*= 0.75f;
    frame.size.height*= 0.75f;
    UIButton *right = [[UIButton alloc]initWithFrame:frame];
    CGSize size = rightView.bounds.size;
    right.center = CGPointMake(size.width*0.5f, size.height*0.5f);
    [right cornerRadius:5.0f borderColor:btTitleColor borderWidth:1.0f];
    right.titleLabel.font = [UIFont systemFontOfSize:13];
    [right setTitle:@"发送" forState:UIControlStateNormal];
    [right setTitleColor:btTitleColor forState:UIControlStateNormal];
    [rightView addSubview:right];
    self.rightButton = right;
    [self addSubview:rightView];
}

- (void)addScrollView{
    CGRect frame = self.bounds;
    frame.origin.x = EMOJI_BOTTOM_BUTTON_WIDTH;
    frame.size.width -= EMOJI_BOTTOM_BUTTON_WIDTH;
    YTScrollView *scroll = [[YTScrollView alloc]initWithFrame:frame];
    [self addSubview:scroll];
    self.scrollView = scroll;
}

- (void)rightButtonAnimationHiden:(BOOL)hiden{
    CGAffineTransform Transform;
    CGRect frame = self.rightButton.superview.frame;
    if (hiden) {
        if (CGRectGetMinX(frame) >= self.bounds.size.width ) {
            return;
        }
        Transform = CGAffineTransformMakeTranslation(CGRectGetWidth(frame), 0);
    }else{
        if (CGRectGetMinX(frame) < self.bounds.size.width ){
            return;
        }
        Transform = CGAffineTransformIdentity;
    }
    [UIView animateWithDuration:0.5f animations:^{
        self.rightButton.superview.transform = Transform;
    }];
}

@end
