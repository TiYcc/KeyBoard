//
//  YTImgScroll.m
//  YTImgBrower
//
//  Created by TI on 15/10/26.
//  Copyright © 2015年 ycctime.com. All rights reserved.
//

@import AssetsLibrary;
#import "YTImgScroll.h"
#import "MBProgressHUD.h"
#import "YTNetworkLoad.h"

#define MaxZoomScale  2.5f
#define MinZoomScale  1.0f

@interface YTImgScroll()<UIScrollViewDelegate,UIActionSheetDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    YTNetworkLoad *netLoad;
    BOOL needAnimal;
}
@property (nonatomic, strong) UIImageView *imgView;
@end

@implementation YTImgScroll

- (UIImageView *)imgView{
    if (!_imgView) {
        UIImageView *imgView = [[UIImageView alloc]init];
        imgView.userInteractionEnabled = YES;
        [imgView setContentMode:UIViewContentModeScaleAspectFit];
        [imgView setClipsToBounds:YES];
        [self addSubview:_imgView = imgView];
        // 添加HUD和手势
        [self addHUD];
        [self addGestureRecognizers];
    }
    return _imgView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        self.alwaysBounceVertical = NO;
        self.contentSize = self.bounds.size;
        self.maximumZoomScale = MaxZoomScale;
        self.minimumZoomScale = MinZoomScale;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
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

#pragma mark 横竖屏切换布局
- (void)layoutSubview{
    [_imgInfo setImage:_imgInfo.image];
    [self setImgInfo:_imgInfo];
}

-(void)setImgInfo:(YTImgInfo *)imgInfo{
    if (!imgInfo) return;
    BOOL BUG = (_imgInfo.index == imgInfo.index);
    _imgInfo = imgInfo;
    self.imgView.image = imgInfo.image;
    CGRect frame = self.bounds;
    frame.size = imgInfo.size;
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
    if ((_imgInfo.url)&&(!_imgInfo.ishttp)) {
        [HUD show:YES];
        __weak __typeof (self)weekSelf = self;
        switch (_imgInfo.fromeType) {
            case YTImgInfoFromeTypePhoto:
            {
                ALAssetsLibrary *libary = [[ALAssetsLibrary alloc]init];
                [libary assetForURL:_imgInfo.url resultBlock:^(ALAsset *asset) {
                    UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                    __strong __typeof (weekSelf)strongSelf = weekSelf;
                    [strongSelf requestResult:image];
                } failureBlock:^(NSError *error) {
                    __strong __typeof (weekSelf)strongSelf = weekSelf;
                    [strongSelf requestResult:nil];
                }];
            }
                break;
              case YTImgInfoFromeTypeRemote:
            {
                [netLoad cancel];
                netLoad = [[YTNetworkLoad alloc]initWithUrl:_imgInfo.url success:^(NSURLRequest *request, id data) {
                    __strong __typeof (weekSelf)strongSelf = weekSelf;
                    [strongSelf requestResult:[UIImage imageWithData:data]];
                } failure:^(NSError *error) {
                    __strong __typeof (weekSelf)strongSelf = weekSelf;
                    [strongSelf requestResult:nil];
                }];
                
                netLoad.updataBlock = ^(float progress){
                    __strong __typeof (weekSelf)strongSelf = weekSelf;
                    strongSelf->HUD.mode = MBProgressHUDModeDeterminate;
                    strongSelf->HUD.progress = progress;
                };
            }
            default:
                break;
        }
    }else{
        [HUD hide:YES];
    }
}

- (void)requestResult:(UIImage*)image{
    if (HUD.isHidden) return;
    if (image) {
        needAnimal = YES;
        [_imgInfo setImage:image];
        _imgInfo.http = YES;
        [self setImgInfo:_imgInfo];
    }
    [HUD hide:YES];
}


#pragma mark - Public Action
#pragma mark 恢复图片原始状态
- (void)replyStatuseAnimated:(BOOL)animated{
    [self setZoomScale:1.0f animated:animated];
}

#pragma mark 双击事件
- (void)doubleTapAction{//图片变大或变小
    if ((self.minimumZoomScale<=self.zoomScale)&&(self.maximumZoomScale>self.zoomScale)) {
        [self setZoomScale:self.maximumZoomScale animated:YES];
    }else {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
}

#pragma mark - Scroll View Deledate (不断适配图片大小)
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imgView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    //放大或缩小时图片位置(frame)调整,保证居中
    CGFloat Wo = self.frame.size.width - self.contentInset.left - self.contentInset.right;
    CGFloat Ho = self.frame.size.height - self.contentInset.top - self.contentInset.bottom;
    UIImageView *imgView = _imgView;
    CGFloat W = imgView.frame.size.width;
    CGFloat H = imgView.frame.size.height;
    CGRect rct = imgView.frame;
    rct.origin.x = MAX((Wo-W)*0.5, 0);
    rct.origin.y = MAX((Ho-H)*0.5, 0);
    imgView.frame = rct;
}

#pragma mark - Image Save (图像保存)
#pragma mark 长按手势
-(void)longPressAction:(UILongPressGestureRecognizer*)longPress{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if (YES) {//[YTDeviceTest userAuthorizationPhotoStatus]
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到手机", nil];
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
