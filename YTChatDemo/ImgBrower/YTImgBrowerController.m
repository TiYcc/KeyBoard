//
//  YTImgBrowerController.m
//  YTImgBrower
//
//  Created by TI on 15/10/26.
//  Copyright © 2015年 ycctime.com. All rights reserved.
//

#import "YTImgBrowerController.h"
#import "YTImgScroll.h"

#define Page_Lab_H  14.0f
#define Page_Scale  (4.9f/5.0f)

@interface YTImgBrowerController ()<UIScrollViewDelegate>{
    NSInteger beginIndex, currentIndex;//当前显示图片下标
    YTImgScroll *currentScroll;//当前ImgScroll
    CGFloat frontPointX;
}
@property(nonatomic, assign) id <YTImgBrowerControllerDelegate> delegate;
@property(nonatomic, strong) NSArray *imgInfos;
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UILabel *pageNumber;

@property(nonatomic, strong) NSMutableArray *imgScrolls;
@end

@implementation YTImgBrowerController

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (NSMutableArray *)imgScrolls{
    if (!_imgScrolls) {
        _imgScrolls = [NSMutableArray arrayWithCapacity:2];
    }
    return _imgScrolls;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showImgBrower];
    [self addGestureRecognizers];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self delegateWillDismiss];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (instancetype)initWithDelegate:(id<YTImgBrowerControllerDelegate>)delegate imgInfos:(NSArray *)imgInfos index:(NSInteger)index{
    if (self = [super init]) {
        self.delegate = delegate;
        self.imgInfos = [imgInfos copy];
        beginIndex = index;
        currentIndex = -1;
        [self performSelector:@selector(initEnd) withObject:nil afterDelay:0.1];
    }
    return self;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
        scrollView.delegate = self;
        scrollView.pagingEnabled = YES;
        scrollView.alwaysBounceVertical = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.backgroundColor = [UIColor blackColor];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_scrollView = scrollView];
    }
    return _scrollView;
}

- (UILabel *)pageNumber{
    if (!_pageNumber) {
        UILabel *pageNumber = [[UILabel alloc]init];
        pageNumber.textColor = [UIColor whiteColor];
        pageNumber.textAlignment = NSTextAlignmentCenter;
        pageNumber.font = [UIFont systemFontOfSize:12.0f];
        pageNumber.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:_pageNumber = pageNumber];
    }
    return _pageNumber;
}

- (void)showImgBrower{
    [self setingScrollViewView];
    self.pageNumber.text = [self getPabeNumberText];
}

- (void)addGestureRecognizers{//添加单击返回,双击缩放手势
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [tap2 setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:tap2];
    
    [tap1 requireGestureRecognizerToFail:tap2];//单击优先级滞后于双击
}

- (void)setingScrollViewView{
    /* 提示：当图片数大于等于2张时，目前设计为2个ImgScroll进行重用，修改需谨慎 */
    for (int i = 0; i < MIN(2, self.imgInfos.count); i++) {
        YTImgScroll *imgScroll = [[YTImgScroll alloc]initWithFrame:self.scrollView.bounds];
        imgScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.scrollView addSubview:imgScroll];
        [self.imgScrolls addObject:imgScroll];
    }
    [self imgScrollToIndex:beginIndex];
}

- (NSString*)getPabeNumberText{
    return [NSString stringWithFormat:@"%i/%i",(int)(currentIndex+1),(int)self.imgInfos.count];
}


- (void)tapAction:(UITapGestureRecognizer *)ges{
    if (ges.numberOfTapsRequired == 1) { // 单击
        [self dismissViewControllerAnimated:NO completion:nil];
    }else { //双击
        [currentScroll doubleTapAction];
    }
}

#pragma mark - layout Sub Views (横竖屏切换重新布局)
- (void)scrollViewLayoutSubViews{//重新布局scrollView内部的控件
    for (YTImgScroll *imgScroll in self.imgScrolls) {
        if (![imgScroll isKindOfClass:[YTImgScroll class]]) return;
        CGRect frame = self.scrollView.bounds;
        frame.origin.x = (imgScroll.imgInfo.index) * (frame.size.width);
        imgScroll.frame = frame;
        [imgScroll layoutSubview];
    }
    
    [currentScroll replyStatuseAnimated:YES];
    [self.scrollView setContentOffset:currentScroll.frame.origin];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGSize size = self.scrollView.bounds.size;
    size.width *= self.imgInfos.count;
    self.scrollView.contentSize = size;
    
    CGRect frame = self.view.bounds;
    frame.origin.y = (frame.size.height*Page_Scale) - Page_Lab_H;
    frame.size.height = Page_Lab_H;
    self.pageNumber.frame = frame;
    
    [self scrollViewLayoutSubViews];
}


#pragma mark - Scroll View Deledate (scroll 代理)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!scrollView.isDragging) return;
    [self scrollViewDragging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [self scrollViewDragging:scrollView];
    
    for (YTImgScroll *imgScroll in self.imgScrolls) {
        if (imgScroll != currentScroll) {
            [imgScroll replyStatuseAnimated:NO];
        }
    }
}

#pragma mark - Image Scroll Reuse (imageScroll复用)
- (void)scrollViewDragging:(UIScrollView *)scrollView{
    CGFloat pointx = (scrollView.contentOffset.x)/(scrollView.bounds.size.width);
    
    if (scrollView.contentOffset.x > frontPointX) {
        [self imgScrollToIndex:ceilf(pointx)];//取上整
    }else{
        [self imgScrollToIndex:floorf(pointx)];//取下整
    }
    
    NSInteger integer = pointx+0.5;
    if (integer != currentIndex) {
        //currentIndex = integer;
        self.pageNumber.text = [self getPabeNumberText];
    }
    frontPointX = scrollView.contentOffset.x;
}

- (void)imgScrollToIndex:(NSInteger)index{
    BOOL back = currentIndex > index;
    if ((currentIndex == index)||(index >= self.imgInfos.count)) {
        return;
    }
    currentIndex = index;
    YTImgScroll *imgScroll = [self getFollowScroll];
    currentScroll = imgScroll;
    if (imgScroll.tag == index) return;
    
    [currentScroll replyStatuseAnimated:NO];
    CGRect frame = self.scrollView.bounds;
    frame.origin.x = index*(frame.size.width);
    imgScroll.frame = frame;
    imgScroll.tag = index;
    imgScroll.imgInfo = self.imgInfos[index];
    if (back) { //预加载
        if (currentIndex > 0) {
            [(YTImgInfo *)self.imgInfos[index-1] httpRequest];
        }
    }else{
        if (currentIndex < self.imgInfos.count-1) {
            [(YTImgInfo *)self.imgInfos[index+1] httpRequest];
        }
    }
}

- (YTImgScroll *)getFollowScroll{
    YTImgScroll *imgScroll = self.imgScrolls.lastObject;
    [self.imgScrolls removeLastObject];
    [self.imgScrolls insertObject:imgScroll atIndex:0];
    return imgScroll;
}

- (void)initEnd{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imgBrowerControllerInitEnd:)]) {
        YTImgInfo *imgInfo = self.imgInfos[beginIndex];
        [self.delegate imgBrowerControllerInitEnd:imgInfo];
    }
}

- (void)delegateWillDismiss{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imgBrowerControllerWillDismiss:)]) {
        [self.delegate imgBrowerControllerWillDismiss:currentScroll.imgInfo];
    }
}

@end
