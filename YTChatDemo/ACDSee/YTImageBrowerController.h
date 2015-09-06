//
//  YTImageBrowerController.h
//  YTImageBrowser
//
//  Created by TI on 15/8/24.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//
//  希望使用者能够根据你的需求进行第二次封装。

#import <UIKit/UIKit.h>
@class YTImageScroll;

@protocol YTImageBrowerControllerDelegate <NSObject>
@optional
/*
 ** img   图片
 ** index 第几张图片 为0时是第一张
 ** size  图片大小
 */
//当第一张图片信息初始化完之后会触发这个代理方法
- (void)ACDSeeControllerInitEnd:(CGSize)size;

//当前控制器就要消失的时候调用 在消失之前调
- (void)ACDSeeControllerWillDismiss:(CGSize)size Img:(UIImage*)img Index:(NSInteger)index;
@end

@interface YTImageBrowerController : UIViewController{
    /** 通过currentScroll可获得当前图片所有信息 */
    YTImageScroll * currentScroll;
}
/** 图片页数显示 eg:(3/210) 有210张图片 正在显示第3张*/
@property (nonatomic, strong) UILabel *pageLabel;

/*
 ** 该方法专为本地相册提供
 ** targart 代理,可为nil
 ** assets 可以包含多个(ALAsset*或NSUrl*:可混排)的数组
 */
- (instancetype)initWithDelegate:(id<YTImageBrowerControllerDelegate>)delegate Assets:(NSArray *)assets PageIndex:(NSInteger)index;

/*
 ** 非本地相册方法
 ** targart 代理,可为nil
 ** img_s 默认显示图片组,可为nil
 ** url_s 网络加载图片地址,可为nil
 ** index 开始图片位置 为0时是第一张
 */
- (instancetype)initWithDelegate:(id<YTImageBrowerControllerDelegate>)delegate Imgs:(NSArray *)imgs Urls:(NSArray *)urls PageIndex:(NSInteger)index;

/*
 ** 上面方法最总都会转化为这个方法
 ** targart 代理,可为nil
 ** imgModels 参考 "YTImageModel.h"
 ** index 开始图片位置 为0时是第一张
 */
- (instancetype)initWithDelegate:(id<YTImageBrowerControllerDelegate>)delegate ImgModels:(NSArray *)imgModels PageIndex:(NSInteger)index;

//-下面是为了更好的进行二次封装而提供出来的接口-//
/**默认点击响应该控制器消失 也就是dealloc*/
- (void)tapAction:(UITapGestureRecognizer *)tap;
@end
