//
//  YTImgInfo.m
//  YTImgBrower
//
//  Created by TI on 15/10/26.
//  Copyright © 2015年 ycctime.com. All rights reserved.
//

@import AssetsLibrary;
#import <UIKit/UIImage.h>
#import "YTNetworkLoad.h"
#import "YTImgInfo.h"

#define Max_Count_Obj 5000 //它具体是多少随便你
#define Device_Size ([UIScreen mainScreen].bounds.size)

@interface YTImgInfo(){
    YTNetworkLoad *netLoad;
}
@property(nonatomic, strong) NSString *explin;//图片信息
@property(nonatomic, strong) NSURL *url;      //图片地址
@property(nonatomic, assign) NSInteger index; //位置索引
@property(nonatomic, assign) CGSize size;     //图片适配后大小
@property(nonatomic, assign) YTImgInfoFromeType fromeType;
@end

@implementation YTImgInfo
+ (NSArray *)imgInfosWithImgs:(NSArray *)imgs urls:(NSArray *)urls type:(YTImgInfoFromeType)type{
    //根据图片及图片网址来创建一组该对象 最多为(Max_Count_Obj)个
    NSInteger max =  MAX(imgs.count, urls.count);
    NSInteger maxInt = MIN(Max_Count_Obj, max);
    NSMutableArray *imgInfos = [NSMutableArray arrayWithCapacity:maxInt];
    for (int index = 0; index < maxInt; index++) {
        YTImgInfo *imgInfo = [[YTImgInfo alloc]init];

        id objUrl = index < urls.count?urls[index]:nil;
        //url
        switch (type) {
            case YTImgInfoFromeTypePhoto:
            {
                if (objUrl) [imgInfo setingPhotoWith:objUrl];
                 break;
            }
             case YTImgInfoFromeTypeRemote:
            {
                //图片
                UIImage *image = index < imgs.count?imgs[index]:nil;
                if (!image||(image.size.width < 1.0f)) {
                    image = [UIImage imageNamed:@"default_img"];
                }
                imgInfo.image = image;
                if (objUrl) [imgInfo setingRemoteWith:objUrl];
                break;
            }
            default:
                break;
        }
        imgInfo.index = index;
        imgInfo.fromeType = type;
        [imgInfos addObject:imgInfo];
    }
    return imgInfos;
}


- (void)setingPhotoWith:(id)objUrl{
    if ([objUrl isKindOfClass:[ALAsset class]]) {
        UIImage *image = [UIImage imageWithCGImage:[[objUrl defaultRepresentation] fullScreenImage]];
        self.image = image;
        self.url = [objUrl defaultRepresentation].url;
        self.http = YES;
    }else if([objUrl isKindOfClass:[NSURL class]]){
        ALAssetsLibrary *libary = [[ALAssetsLibrary alloc]init];
        [libary assetForURL:objUrl resultBlock:^(ALAsset *asset) {
            UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
            self.image = image;
            self.url = objUrl;
            self.http = YES;
        } failureBlock:^(NSError *error) {
            self.url = objUrl;
            self.http = NO;
        }];
    }else{
        self.url = nil;
        self.image = [UIImage imageNamed:@"default_img"];
    }
}

- (void)setingRemoteWith:(id)objUrl{
    if ([objUrl isKindOfClass:[NSURL class]]) {
        self.url = objUrl;
    }else if([objUrl isKindOfClass:[NSString class]]){
        self.url = [NSURL URLWithString:objUrl];
    }else{
        self.url = nil;
    }
    self.http = NO;
}


#pragma mark - Network loag (图片网络请求)
- (void)httpRequest{
    if ((self.url)&&(!self.ishttp)) {
        switch (self.fromeType) {
            case YTImgInfoFromeTypePhoto:
                [self photoRequest];
                break;
               case YTImgInfoFromeTypeRemote:
                [self remoteRequest];
                break;
            default:
                break;
        }
    }
}

- (void)photoRequest{
    ALAssetsLibrary *libary = [[ALAssetsLibrary alloc]init];
    __weak __typeof (self)weekSelf = self;
    [libary assetForURL:self.url resultBlock:^(ALAsset *asset) {
        UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
        __strong __typeof (weekSelf)strongSelf = weekSelf;
        strongSelf.image = image;
        strongSelf.http = YES;
    } failureBlock:^(NSError *error) {
        
    }];
}

- (void)remoteRequest{
    __weak __typeof (self)weekSelf = self;
    [netLoad cancel];
    netLoad = [[YTNetworkLoad alloc]initWithUrl:self.url success:^(NSURLRequest *request, id data) {
        __strong __typeof (weekSelf)strongSelf = weekSelf;
        strongSelf.image = [UIImage imageWithData:data];
        strongSelf.http = YES;
        netLoad = nil;
    } failure:^(NSError *error) {
        netLoad = nil;
    }];
}

- (void)setImage:(UIImage *)image{
    if (image) {
        _image = image;
        self.size = [self imageSize];
    }
}

- (CGSize)imageSize{//图片根据屏幕大小来调整size,保证与屏幕比例适配
    CGFloat wid = _image.size.width;
    CGFloat heig = _image.size.height;
    if ((wid <= Device_Size.width) && (heig <= Device_Size.height)) {
        return _image.size;
    }
    
    CGFloat scale_poor = (wid/Device_Size.width)-( heig/Device_Size.height);
    CGSize endSize = CGSizeZero;
    
    if (scale_poor > 0) {
        CGFloat height_now = heig*(Device_Size.width/wid);
        endSize = CGSizeMake(Device_Size.width, height_now);
    }else{
        CGFloat width_now = wid*(Device_Size.height/heig);
        endSize = CGSizeMake(width_now, Device_Size.height);
    }
    return endSize;
}

@end
