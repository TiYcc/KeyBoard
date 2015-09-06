//
//  YTEmojiView.m
//  YTChatDemo
//
//  Created by TI on 15/8/26.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "YTEmojiBottom.h"
#import "YTEmojiButton.h"
#import "YTEmojiView.h"
#import "YTEmojiFile.h"
#import "YTEmojiPage.h"

#define EMOJI_PAGECONTROL_HEIGHT   24.0f

@interface YTEmojiView()<UIScrollViewDelegate>{
    YTEmojiPage *currentPageBT; //当前表情页
    CGFloat priopPointX; // scrollView 划过的前一个点x坐标
    BOOL fromeScroll; // 标记切换表情方法来源
}
@property (nonatomic, assign) id<YTEmojiViewDelegate> delegate; //代理
@property (nonatomic, strong) UIScrollView *scrollView; //显示表情图片
@property (nonatomic, strong) UIPageControl *pageControl; //图片翻页标示
@property (nonatomic, strong) NSMutableArray *pageBts; //底部切换表情按钮
@property (nonatomic, strong) YTEmojiBottom *bottomView; //底部空间
@end

@implementation YTEmojiView

#pragma mark - 初始化

- (NSMutableArray *)pageBts{
    if (!_pageBts) {
        _pageBts = [NSMutableArray array];
    }
    return _pageBts;
}

- (instancetype)initWithDelegate:(id<YTEmojiViewDelegate>)delegate{
    CGRect frame = CGRectMake(0, 0, WIDTH, EMOJI_VIEW_HEIGHT);
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        [self initUI];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    frame.size = CGSizeMake(WIDTH, EMOJI_VIEW_HEIGHT);
    [super setFrame:frame];
}

- (void)initUI{
    CGRect frame = self.bounds;
    frame.size.height = EMOJI_SCROLL_HEIGHT;
    [self addScroll:frame]; /*scroll*/
    
    frame.origin.y = CGRectGetHeight(frame)- EMOJI_PAGECONTROL_HEIGHT;
    frame.size.height = EMOJI_PAGECONTROL_HEIGHT;
    [self addPageControl:frame]; /*pagecontrol*/
    
    frame.origin.y = CGRectGetHeight(self.bounds) - EMOJI_BOTTOM_HEIGHT;
    frame.size.height = EMOJI_BOTTOM_HEIGHT;
    [self addBottom:frame];/*bottom*/
    
    [self showIcons];//展示表情图标
}

#pragma mark 添加控件
-(void)addScroll:(CGRect)frame{
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:frame];
    scroll.delegate = self;
    scroll.pagingEnabled = YES;
    scroll.showsHorizontalScrollIndicator = NO;
    [self addSubview:scroll];
    self.scrollView = scroll;
}

-(void)addPageControl:(CGRect)frame{
    UIPageControl *page = [[UIPageControl alloc]initWithFrame:frame];
    page.currentPageIndicatorTintColor = [UIColor lightGrayColor];
    page.pageIndicatorTintColor = [UIColor blackColor];
    page.userInteractionEnabled = NO;
    [self addSubview:page];
    self.pageControl = page;
}

-(void)addBottom:(CGRect)frame{
    YTEmojiBottom *bottom = [[YTEmojiBottom alloc]initWithFrame:frame];
    //page
    NSArray *emojiMS = [YTEmojiFile emojiModelS];
    for (int i = 0; i < emojiMS.count; i++) {
        CGRect rect = CGRectMake(EMOJI_BOTTOM_BUTTON_WIDTH*i, 0, EMOJI_BOTTOM_BUTTON_WIDTH, EMOJI_BOTTOM_HEIGHT);
        YTEmojiPage *pageBt = [[YTEmojiPage alloc]initWithFrame:rect];
        YTEmojiM *em = emojiMS[i];
        pageBt.emojiM = em;
        pageBt.tag = i;
        [pageBt setImage:[UIImage imageNamed:em.image] forState:UIControlStateNormal];
        [pageBt addTarget:self action:@selector(pageChange:) forControlEvents:UIControlEventTouchUpInside];
        [bottom.scrollView addSubview:pageBt];
        [self.pageBts addObject:pageBt];
    }
    //scroll
    bottom.scrollView.contentSize = CGSizeMake(emojiMS.count*EMOJI_BOTTOM_BUTTON_WIDTH, 0);
    //send
    [bottom.rightButton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    //+"添加"
    //........//
    [self addSubview:bottom];
    self.bottomView = bottom;
}

#pragma mark 表情展示
- (void)showIcons{
    if (self.pageBts.count == 0) return;
    for (int i = 0; i < self.pageBts.count; i++) {
        YTEmojiPage *pageBt = self.pageBts[i];
        if (i == 0) {
            currentPageBT = pageBt;
            pageBt.offsetStart = CGPointZero;
            pageBt.backgroundColor = [UIColor grayColor];
            self.pageControl.numberOfPages = [pageBt.emojiM countPageAll];
        }else{
            YTEmojiPage *p = self.pageBts[(int)MAX(i-1, 0)];
            pageBt.offsetStart = p.offsetEnd;
        }
        [self addIconsWithPage:pageBt];
    }
    CGFloat widthX = ((YTEmojiPage *)[self.pageBts lastObject]).offsetEnd.x;
    self.scrollView.contentSize = CGSizeMake( widthX, 0);
}

- (void)addIconsWithPage:(YTEmojiPage *)pageBt{
    YTEmojiM *em = pageBt.emojiM;
    YTEmojiNorms norms = em.norms;
    CGFloat WH = norms.boardWH;
    CGFloat spaceB = norms.spaceBoard;
    CGFloat spaceV = norms.spaceVerticalityMIN;
    CGFloat initX = pageBt.offsetStart.x;
    NSInteger countInLine = [em countOneLine];
    NSInteger countInPage = [em countOnePage];
    NSInteger countAllPage = [em countPageAll];
    CGFloat spaceH = (WIDTH-spaceB*2-WH*countInLine)/(float)(countInLine-1);
    pageBt.offsetEnd = CGPointMake(pageBt.offsetStart.x+countAllPage*WIDTH, 0);
    for (int page = 0; page < countAllPage; page++) {//多少页
        NSInteger countIndex = [em countPageIndex:page];
        for (int count = 0; count < countIndex; count++) {//一页多少个
            // X:行中第几个，Y:第几行
            NSInteger X = count%countInLine;
            NSInteger Y = count/countInLine;
            CGRect rect = CGRectZero;
            rect.size = CGSizeMake( WH, WH);
            rect.origin.x = spaceB+(spaceH+WH)*X+page*WIDTH+initX;
            rect.origin.y = spaceB+(spaceV+WH)*Y;
            
            YTEmojiButton *eb = [[YTEmojiButton alloc]initWithFrame:rect];
            eb.emoji = em.icons[(page*countInPage+count)];
            [eb addTarget:self action:@selector(selectorThisIcon:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:eb];
            UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longTapAction:)];
            [eb addGestureRecognizer:longTap];
        }
        if (em.type == YTEmojiTypeIcon) {
            CGRect frame = CGRectZero;
            frame.size = CGSizeMake( WH, WH);
            frame.origin.x = spaceB+(spaceH+WH)*(countInLine-1)+page*WIDTH+initX;
            frame.origin.y = spaceB+(spaceV+WH)*(em.norms.lines-1);
            YTEmojiButton *del = [[YTEmojiButton alloc]initWithFrame:frame];
            [del addTarget:self action:@selector(deleteIcons) forControlEvents:UIControlEventTouchUpInside];
            [del setImage:[UIImage imageNamed:@"btn_del"] forState:UIControlStateNormal];
            [self.scrollView addSubview:del];
        }
    }
}

#pragma mark - 表情栏切换
- (void)pageChange:(YTEmojiPage *)pageBt{
    if (pageBt.tag == currentPageBT.tag) {
        fromeScroll = NO;
        return;
    }
    YTEmojiM *emojiM = pageBt.emojiM;
    switch (emojiM.type) {
        case YTEmojiTypeChartlet:
            [self.bottomView rightButtonAnimationHiden:YES];
            break;
          case YTEmojiTypeIcon:
            [self.bottomView rightButtonAnimationHiden:NO];
            break;
        default:
            break;
    }
    pageBt.backgroundColor = [UIColor grayColor];
    _pageControl.numberOfPages = [emojiM countPageAll];
    if (!fromeScroll) {
        [self.scrollView setContentOffset:pageBt.offsetStart];
        priopPointX = pageBt.offsetStart.x;
        _pageControl.currentPage = 0;
    }else{
        fromeScroll = NO;
    }
    currentPageBT.backgroundColor = [UIColor clearColor];
    currentPageBT = pageBt;
}

#pragma mark - Scroll View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ((scrollView != self.scrollView)||(!scrollView.isDragging)) return;
    [self scrollViewDidDragging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scrollViewDidDragging:scrollView];
}

- (void)scrollViewDidDragging:(UIScrollView*)scrollView{
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger tag = currentPageBT.tag;
    YTEmojiPage *pageBt = nil;
    if (offsetX > priopPointX) { //右划
        tag = MIN(tag+1, self.pageBts.count-1);
        pageBt = self.pageBts[tag];
        if (fabs(pageBt.offsetStart.x-offsetX)<10) {
            fromeScroll = YES;
            [self pageChange:pageBt];
        }
    }else{ //左划
        tag = MAX(0, tag-1);
        pageBt = self.pageBts[tag];
        if (fabs(pageBt.offsetEnd.x-offsetX-WIDTH)<10) {
            fromeScroll = YES;
            [self pageChange:pageBt];
        }
    }
    self.pageControl.currentPage =((scrollView.contentOffset.x - currentPageBT.offsetStart.x)/scrollView.bounds.size.width)+0.5;
    priopPointX = offsetX;
}

#pragma mark - 长按表情动画
- (void)longTapAction:(UILongPressGestureRecognizer*)longTap{
    YTEmojiButton *eb = (YTEmojiButton*)longTap.view;
    switch (longTap.state) {
        case UIGestureRecognizerStateBegan:
            [self showEmotionName:eb.emoji.emojiName];
            break;
        case UIGestureRecognizerStateEnded:
            [self selectorThisIcon:eb];
            break;
        default:
            break;
    }

}

- (void)showEmotionName:(NSString *)name {
#define W 80.0f
#define H 40.0f
    CGFloat x = (self.superview.frame.size.width-80.0f)/2.0f;
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(x, self.superview.frame.origin.y, W, H)];
    
    lab.text = name;
    lab.alpha = 0.1f;
    lab.layer.masksToBounds = YES;
    lab.layer.cornerRadius  = 10.0f;
    lab.textColor = [UIColor whiteColor];
    lab.backgroundColor = [UIColor grayColor];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.font = [UIFont systemFontOfSize:15.0f];
    
    [self.superview.superview addSubview:lab];
    [UIView animateWithDuration:0.4f animations:^{
        lab.frame = CGRectMake(x, -H, W, H);
        lab.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.3f delay:0.5f options:UIViewAnimationOptionCurveEaseOut animations:^{
                lab.alpha = 0.0f;
            } completion:^(BOOL finished) {
                if (finished) [lab removeFromSuperview];
            }];
        }
    }];
}

#pragma mark - self delegate action
-(void)selectorThisIcon:(YTEmojiButton*)sender{
    if ([self.delegate respondsToSelector:@selector(emojiViewEmoji:)]) {
        [self.delegate emojiViewEmoji:sender.emoji];
    }
}

-(void)deleteIcons{
    if ([self.delegate respondsToSelector:@selector(emojiViewDelete)]) {
        [self.delegate emojiViewDelete];
    }
}

-(void)sendButtonAction{
    if ([self.delegate respondsToSelector:@selector(emojiViewSend)]) {
        [self.delegate emojiViewSend];
    }
}

@end
