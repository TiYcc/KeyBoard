//
//  YTImageBrowerController.m
//  YTImageBrowser
//
//  Created by TI on 15/8/24.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "YTImageBrowerController.h"
#import "YTImageScroll.h"

#define Page_Lab_H  14.0f
#define Page_Scale  (4.9f/5.0f)

@interface YTImageBrowerController ()<UIScrollViewDelegate>{
    NSInteger currentPageNumber,currentIndex;
    CGFloat priopPointX; // scrollView 划过的前一个点x坐标
}

@property (nonatomic, assign) id<YTImageBrowerControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *imgModels;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *imgScrolls;
@end

@implementation YTImageBrowerController

#pragma mark - INIT (一切都是为了初始化)
- (NSMutableArray *)imgScrolls{
    if (!_imgScrolls) {
        _imgScrolls = [NSMutableArray arrayWithCapacity:2];
    }
    return _imgScrolls;
}

- (void)didReceiveMemoryWarning {
    [[NSURLCache sharedURLCache]removeAllCachedResponses];
    [super didReceiveMemoryWarning];
}

- (instancetype)initWithDelegate:(id<YTImageBrowerControllerDelegate>)delegate Assets:(NSArray*)assets PageIndex:(NSInteger)index{
     NSArray *imgMsgs = [YTImageModel IMGMessagesWithImgs:nil Urls:assets Photo:YES];
    return [self initWithDelegate:delegate ImgModels:imgMsgs PageIndex:index];
}

- (instancetype)initWithDelegate:(id<YTImageBrowerControllerDelegate>)delegate Imgs:(NSArray *)imgs Urls:(NSArray *)urls PageIndex:(NSInteger)index{
    
    NSArray *imgMsgs = [YTImageModel IMGMessagesWithImgs:imgs Urls:urls Photo:NO];
    return [self initWithDelegate:delegate ImgModels:imgMsgs PageIndex:index];
}

- (instancetype)initWithDelegate:(id<YTImageBrowerControllerDelegate>)delegate ImgModels:(NSArray *)imgModels PageIndex:(NSInteger)index{
    if (self = [super init]) {
        self.delegate = delegate;
        self.imgModels = [imgModels copy];
        currentPageNumber = index;
        currentIndex = -1;
        [self performSelector:@selector(initEnd) withObject:nil afterDelay:0.1];
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self delegateWillDismiss];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI{
    [self addScrollView];
    [self addPageLabel];
    [self addGesture];
}

- (void)addScrollView{//添加scrollView
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    scroll.backgroundColor = [UIColor blackColor];
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.showsVerticalScrollIndicator = NO;
    scroll.alwaysBounceVertical = NO;
    scroll.pagingEnabled = YES;
    scroll.delegate = self;
    self.scrollView = scroll;
    [self scrollViewAddSubView];
    [self.view addSubview:scroll];
}

- (void)addPageLabel{//添加 显示当前页码和总的页码UI
    UILabel *page = [[UILabel alloc]init];
    page.textAlignment = NSTextAlignmentCenter;
    page.font = [UIFont systemFontOfSize:12.0f];
    page.textColor = [UIColor whiteColor];
    page.text = [self pageText];
    
    [self.view addSubview:self.pageLabel = page];
}

- (void)addGesture{//添加单击返回,双击缩放手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTap];
    
    [tap requireGestureRecognizerToFail:doubleTap];//单击优先级滞后于双击
    
}

- (void)scrollViewAddSubView{//scrollView添加内置IMGSeeScroll视图
    
    /* 提示：当图片数大于等于2张时，目前设计为2个IMGSeeScroll进行重用，修改需谨慎 */
    for (int i = 0; i < MIN(2, self.imgModels.count); i++) {
        YTImageScroll *imageScroll = [[YTImageScroll alloc]initWithFrame:self.scrollView.bounds];
        [self.scrollView addSubview:imageScroll];
        [self.imgScrolls addObject:imageScroll];
    }
    
    [self scrollviewIndex:currentPageNumber];
}

#pragma mark - layout Sub Views (横竖屏切换重新布局)
- (void)scrollViewLayoutSubViews{//重新布局scrollView内部的控件
    for (YTImageScroll *imageScroll in self.imgScrolls) {
        if (![imageScroll isKindOfClass:[YTImageScroll class]]) return;
        CGRect frame = self.scrollView.bounds;
        frame.origin.x = (imageScroll.imgM.index) * (frame.size.width);
        imageScroll.frame = frame;
        [imageScroll layoutSubview];
    }
    
    [currentScroll replyStatuseAnimated:YES];
    [self.scrollView setContentOffset:currentScroll.frame.origin];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.scrollView.frame = self.view.bounds;
    
    CGSize size = self.scrollView.bounds.size;
    size.width*= self.imgModels.count;
    self.scrollView.contentSize = size;
    
    CGRect frame = self.view.bounds;
    frame.origin.y = (frame.size.height*Page_Scale) - Page_Lab_H;
    frame.size.height = Page_Lab_H;
    self.pageLabel.frame = frame;
    
    [self scrollViewLayoutSubViews];
}

#pragma mark - Tap Gesture Recognizer action (手势)
- (void)tapAction:(UITapGestureRecognizer*)tap{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)doubleTapAction:(UITapGestureRecognizer*)doubleTap{
    [currentScroll doubleTapAction];
}

#pragma mark - Scroll View Deledate (scroll 代理)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!scrollView.isDragging) return;
    [self scrollViewDragging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [self scrollViewDragging:scrollView];
    
    for (YTImageScroll *sc in self.imgScrolls) {
        if (sc != currentScroll) {
            [sc replyStatuseAnimated:NO];
        }
    }
    [self pageHiden];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self pageShow];
}

#pragma mark - Image Scroll Reuse (imageScroll复用)
- (void)scrollViewDragging:(UIScrollView *)scrollView{
    CGFloat pointx = (scrollView.contentOffset.x)/(scrollView.bounds.size.width);
    
    if (scrollView.contentOffset.x > priopPointX) {
        [self scrollviewIndex:ceilf(pointx)];//取上整
    }else{
        [self scrollviewIndex:floorf(pointx)];//取下整
    }
    
    NSInteger integer = pointx+0.5;
    if (integer != currentPageNumber) {
        currentPageNumber = integer;
        self.pageLabel.text = [self pageText];
    }
    priopPointX = scrollView.contentOffset.x;
}

- (void)scrollviewIndex:(NSInteger)index{
    if ((currentIndex == index)||(index >= self.imgModels.count)){
        return;
    }
    currentIndex = index;
    YTImageScroll *imageScroll = [self dequeueReusableScrollView];
    currentScroll = imageScroll;
    if (imageScroll.tag == index) return;
    
    [currentScroll replyStatuseAnimated:NO];
    CGRect frame = self.scrollView.bounds;
    frame.origin.x = index*(frame.size.width);
    imageScroll.frame = frame;
    imageScroll.tag = index;
    imageScroll.imgM = self.imgModels[index];
}

- (YTImageScroll *)dequeueReusableScrollView{
    YTImageScroll *imageScroll = self.imgScrolls.lastObject;
    [self.imgScrolls removeLastObject];
    [self.imgScrolls insertObject:imageScroll atIndex:0];
    return imageScroll;
}

#pragma mark - Page & Delegate Action (嗯哼...)
- (void)pageHiden{
    
}

- (void)pageShow{
    
}

- (NSString*)pageText{
    return [NSString stringWithFormat:@"%d/%d",(int)(currentPageNumber+1),(int)(self.imgModels.count)];
}

- (void)initEnd{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ACDSeeControllerInitEnd:)]) {
        YTImageModel *imageModel = self.imgModels[currentPageNumber];
        [self.delegate ACDSeeControllerInitEnd:imageModel.size];
    }
}

- (void)delegateWillDismiss{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ACDSeeControllerWillDismiss:Img:Index:)]) {
        [self.delegate ACDSeeControllerWillDismiss:currentScroll.imgM.size Img:currentScroll.imgM.image Index:currentPageNumber];
    }
}

@end
