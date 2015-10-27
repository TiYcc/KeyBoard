//
//  YTImageModel.m
//  YTImageBrowser
//
//  Created by TI on 15/8/24.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

@import AssetsLibrary;
#import "YTImageModel.h"

#define Max_Count_Obj 5000 //它具体是多少随便你
#define Device_Size ([UIScreen mainScreen].bounds.size)

@interface YTImageModel()
@property (nonatomic, strong) NSString *explin; //图片信息
@property (nonatomic, strong) NSURL *url;     //图片地址
@property (nonatomic, assign) NSInteger index; //位置索引
@property (nonatomic, assign) CGSize size;     //图片适配后大小
@property (nonatomic, assign, getter=isPhoto) BOOL photo;  //是否是相册
@end

@implementation YTImageModel

+ (NSArray *)IMGMessagesWithImgs:(NSArray *)imgs Urls:(NSArray *)urls Photo:(BOOL)photo{
    //根据图片及图片网址来创建一组该对象 最多为(Max_Count_Obj)个
    NSInteger max =  MAX(imgs.count, urls.count);
    NSInteger maxInt = MIN(Max_Count_Obj, max);
    NSMutableArray *imgModels = [NSMutableArray arrayWithCapacity:maxInt];
    for (int i = 0; i < maxInt; i++) {
        YTImageModel *img = [[YTImageModel alloc]init];
        id objUrl = i < urls.count?urls[i]:nil;
        if (photo) {
            if (objUrl) {
                [self imageModel:img Obj:objUrl];
            }
        }else{
            img.image = i < imgs.count?imgs[i]:nil;
            if (objUrl) {
                if ([objUrl isKindOfClass:[NSURL class]]) {
                    img.url = objUrl;
                }else if([objUrl isKindOfClass:[NSString class]]){
                    img.url = [NSURL URLWithString:objUrl];
                }else{
                    img.url = nil;
                }
            }
            if (!img.image||(img.image.size.width < 1.0f)) {
                img.image = [UIImage imageNamed:@"default_img"];
            }
            img.http = NO;
        }
        img.index = i;
        img.photo = photo;
        [imgModels addObject:img];
    }
    return imgModels;
}

+ (void)imageModel:(YTImageModel *)imgModel Obj:(id)obj{
    if ([obj isKindOfClass:[ALAsset class]]) {
        UIImage *image = [UIImage imageWithCGImage:[[obj defaultRepresentation] fullScreenImage]];
        imgModel.image = image;
        imgModel.url = [obj defaultRepresentation].url;
        imgModel.http = YES;
    }else if([obj isKindOfClass:[NSURL class]]){
        ALAssetsLibrary *libary = [[ALAssetsLibrary alloc]init];
        [libary assetForURL:obj resultBlock:^(ALAsset *asset) {
            UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
            imgModel.image = image;
            imgModel.url = obj;
            imgModel.http = YES;
        } failureBlock:^(NSError *error) {
            imgModel.url = obj;
            imgModel.http = NO;
        }];
    }else{
        imgModel.url = nil;
        imgModel.image = [UIImage imageNamed:@"default_img"];
    }
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
