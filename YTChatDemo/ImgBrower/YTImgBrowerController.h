//
//  YTImgBrowerController.h
//  YTImgBrower
//
//  Created by TI on 15/10/26.
//  Copyright © 2015年 ycctime.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YTImgInfo;
typedef NS_ENUM(NSInteger, YTImgBrowerModel) {
    YTImgBrowerModelNone = 0,
};

@protocol YTImgBrowerControllerDelegate <NSObject>
@optional
/** 图片信息初始化完成触发 */
- (void)imgBrowerControllerInitEnd:(YTImgInfo *)imgInfo;
/** 在控制器消失之前触发 */
- (void)imgBrowerControllerWillDismiss:(YTImgInfo *)imgInfo;
@end

@interface YTImgBrowerController : UIViewController

@property(nonatomic, assign) YTImgBrowerModel *model;
/*
 * delegate 代理
 * imgInfos <YTImgInfo *> 里面是YTImgInfo对象
 * index 开始定位到第几张图片 默认是0 代表第一张
 */
- (instancetype)initWithDelegate:(id<YTImgBrowerControllerDelegate>)delegate imgInfos:(NSArray <YTImgInfo *> *)imgInfos index:(NSInteger)index;
@end
