//
//  YTImgInfo.h
//  YTImgBrower
//
//  Created by TI on 15/10/26.
//  Copyright © 2015年 ycctime.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIScreen.h>
typedef NS_ENUM(NSInteger, YTImgInfoFromeType) {
    YTImgInfoFromeTypePhoto = 0, //来之本地相册
    YTImgInfoFromeTypeRemote     //来之远程网络
};

@interface YTImgInfo : NSObject
/** image, url 有可能为空 引用时要判断 */
@property(nonatomic, strong) UIImage *image; //图片
@property(nonatomic, strong, readonly) NSString *explin; //图片信息
@property(nonatomic, strong, readonly) NSURL *url; //图片地址
@property(nonatomic, assign, readonly) NSInteger index; //位置索引
@property(nonatomic, assign, readonly) CGSize size; //图片适配后大小
@property(nonatomic, assign, readonly) YTImgInfoFromeType fromeType;  //来之哪里
@property (nonatomic, assign, getter=ishttp) BOOL http; //网络请求成功与否

+ (NSArray *)imgInfosWithImgs:(NSArray *)imgs urls:(NSArray *)urls type:(YTImgInfoFromeType)type;

- (void)httpRequest; // 网络请求数据
@end
