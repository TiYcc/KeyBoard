//
//  YTImageScroll.m
//  YTImageBrowser
//
//  Created by TI on 15/8/24.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

@import AssetsLibrary;
#import "YTImageScroll.h"
#import "MBProgressHUD.h"
#import "YTNetworkLoad.h"
#import "YTDeviceTest.h"

#define MaxZoomScale  2.5f
#define MinZoomScale  1.0f

@interface YTImageScroll()<UIScrollViewDelegate,UIActionSheetDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    BOOL needAnimal;
}

@property (nonatomic, strong) YTNetworkLoad *imgLoad;

@end

@implementation YTImageScroll

#pragma mark - INIT (初始化)
- (UIImageView *)imgView{
    if (!_imgView) {
        UIImageView *img = [[UIImageView alloc]init];
        img.userInteractionEnabled = YES;
        [img setContentMode:UIViewContentModeScaleAspectFit];
        [img setClipsToBounds:YES];
        [self addSubview:(_imgView = img)];
        [self addGestureRecognizers];
        [self addHUD];
    }
    return _imgView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.alwaysBounceVertical = NO;
        self.maximumZoomScale = MaxZoomScale;
        self.minimumZoomScale = MinZoomScale;
        self.contentSize = self.bounds.size;
        self.tag = -1; /* 注明：后面以tag来判断当前页以免造成混乱 */
    }
    return self;
}

- (void)addGestureRecognizers{
    //长按手势 保存图片
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
    [self addGestureRecognizer:longPress];
}

- (void)addHUD{
    HUD = [[MBProgressHUD alloc]initWithView:self];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.color = [UIColor clearColor];
    HUD.delegate = self;
    [self addSubview:HUD];
}

#pragma mark - Public Action
#pragma mark 恢复图片原始状态
- (void)replyStatuseAnimated:(BOOL)animated{
    [self setZoomScale:1.0f animated:animated];
}

#pragma mark 双击事件
- (void)doubleTapAction{//图片变大或变小
    if (self.minimumZoomScale <= self.zoomScale && self.maximumZoomScale > self.zoomScale) {
        [self setZoomScale:self.maximumZoomScale animated:YES];
    }else {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
}

#pragma mark 横竖屏切换布局
- (void)layoutSubview{
    [_imgM setImage:_imgM.image];
    [self setImgM:_imgM];
}

- (void)setImgM:(YTImageModel *)imgM{
    if (!imgM) return;
    BOOL BUG = (_imgM.index == imgM.index);
    _imgM = imgM;
    self.imgView.image = imgM.image;
    CGRect frame = self.bounds;
    frame.size = imgM.size;
    if ((needAnimal == YES) && (BUG == YES)) {
        needAnimal = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.imgView.frame = frame;
            [self scrollViewDidZoom:self];
        }];
    }else{
        needAnimal = NO;
        self.imgView.frame = frame;
        [self scrollViewDidZoom:self];
        [self loadHttpImg];
    }
    
}

#pragma mark - Network loag (图片网络请求)
- (void)loadHttpImg{
    //自己写的网络请求加载
    if ((_imgM.url) && (!_imgM.ishttp)) {
        [HUD show:YES];
        __weak __typeof (self)weekSelf = self;
        if (_imgM.isPhoto) {
            ALAssetsLibrary *libary = [[ALAssetsLibrary alloc]init];
            [libary assetForURL:_imgM.url resultBlock:^(ALAsset *asset) {
                UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                __strong __typeof (weekSelf)strongSelf = weekSelf;
                [strongSelf requestResult:image];
            } failureBlock:^(NSError *error) {
                __strong __typeof (weekSelf)strongSelf = weekSelf;
                [strongSelf requestResult:nil];
            }];
        }else{
            [_imgLoad cancel];
            _imgLoad = [[YTNetworkLoad alloc]initWithUrl:_imgM.url success:^(NSURLRequest *request, id data) {
                __strong __typeof (weekSelf)strongSelf = weekSelf;
                [strongSelf requestResult:[UIImage imageWithData:data]];
            } failure:^(NSError *error) {
                __strong __typeof (weekSelf)strongSelf = weekSelf;
                [strongSelf requestResult:nil];
            }];
            
            _imgLoad.updataBlock = ^(float progress){
                __strong __typeof (weekSelf)strongSelf = weekSelf;
                strongSelf->HUD.mode = MBProgressHUDModeDeterminate;
                strongSelf->HUD.progress = progress;
            };
        }
    }else{
        [HUD hide:YES];
    }
    //第三方库AFNetworking 网络请求加载
    /*
     if ((_imgM.url) && (!_imgM.ishttp)) {
     [HUD show:YES];
     __weak __typeof (self)weekSelf = self;
     [self.imgView setImageWithURLRequest:[NSURLRequest requestWithURL:_imgM.url] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
     __strong __typeof (weekSelf)strongSelf = weekSelf;
     [strongSelf requestResult:image];
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
     __strong __typeof (weekSelf)strongSelf = weekSelf;
     [strongSelf requestResult:nil];
     }];
     }else{
     [HUD hide:YES];
     }*/
}

- (void)requestResult:(UIImage*)image{
    if (HUD.isHidden) return;
    if (image) {
        needAnimal = YES;
        [_imgM setImage:image];
        _imgM.http = YES;
        [self setImgM:_imgM];
    }
    [HUD hide:YES];
}

#pragma mark - Scroll View Deledate (不断适配图片大小)
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imgView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    //放大或缩小时图片位置(frame)调整,保证居中
    CGFloat Wo = self.frame.size.width - self.contentInset.left - self.contentInset.right;
    CGFloat Ho = self.frame.size.height - self.contentInset.top - self.contentInset.bottom;
    CGFloat W = _imgView.frame.size.width;
    CGFloat H = _imgView.frame.size.height;
    CGRect rct = _imgView.frame;
    rct.origin.x = MAX((Wo-W)*0.5, 0);
    rct.origin.y = MAX((Ho-H)*0.5, 0);
    _imgView.frame = rct;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.isDragging) {
        if (scrollView.bounds.size.width <= scrollView.contentSize.width) {
            self.scrollEnabled = NO;
            self.scrollEnabled = YES;
        }
    }
}

#pragma mark - Image Save (图像保存)
#pragma mark 长按手势
-(void)longPressAction:(UILongPressGestureRecognizer*)longPress{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if ([YTDeviceTest userAuthorizationPhotoStatus]) {
            UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到手机", nil];
            [actionSheet showInView:self];
        }
    }
}

#pragma mark Action Sheet Delegate (actionSheet代理)
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        if (self.imgView.image) {//保存图片
            UIImageWriteToSavedPhotosAlbum(self.imgView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

#pragma mark 图片保存结果回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{//保存图片回调
    if (error != NULL){ //失败
        NSLog(@"图片保存失败->%@",error);
    }else{//成功
        NSLog(@"图片保存成功");
    }
}

#pragma mark - HUD delegate
- (void)hudWasHidden:(MBProgressHUD *)hud{
    HUD.progress = 0.0f;
}

@end
