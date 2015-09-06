//
//  UIImage+YTGif.m
//  YTChatDemo
//
//  Created by TI on 15/9/6.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "UIImage+YTGif.h"
@import ImageIO;

@implementation UIImage (YTGif)

+ (UIImage *)gifImageNamed:(NSString *)name{
    NSString *gifPath = [[NSBundle mainBundle] pathForResource:[name stringByAppendingString:@"@2x"] ofType:@"gif"];
    if (!gifPath) {
        gifPath = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
    }
    NSData *gifData = [NSData dataWithContentsOfFile:gifPath];
    if (gifData) {
        return [self gifImageWithData:gifData];
    }else {
        return [self imageNamed:name];
    }
}

+ (UIImage *)gifImageWithData:(NSData *)data{
    if (!data) return nil;
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    size_t count = CGImageSourceGetCount(source);
    UIImage *gifImage = nil;
    if (count <= 1) {
        gifImage = [self imageWithData:data];
    }else{
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:count];
        for (size_t index; index < count; index++) {
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, index, NULL);
            [images addObject:[UIImage imageWithCGImage:imageRef]];
            CGImageRelease(imageRef);
        }
        CGFloat delayTime = [self durtaionAtIndex:0 source:source];
        NSTimeInterval duration = delayTime*count;
        gifImage = [self animatedImageWithImages:images duration:duration];
    }
    return gifImage;
}

// 取出指定位置图片播放时长
+ (CGFloat)durtaionAtIndex:(size_t)index source:(CGImageSourceRef)source{
    CGFloat dealyTime = 0.0f;
    CFDictionaryRef sourceProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *dicProperties = (__bridge NSDictionary *)sourceProperties;
    NSDictionary *gifProperties = dicProperties[(NSString *)kCGImagePropertyGIFDictionary];
    NSNumber *delayTimeUnclamped = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    
    if (delayTimeUnclamped) {
        dealyTime = [delayTimeUnclamped floatValue];
    }else {
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (dealyTime) {
            dealyTime = [delayTimeProp floatValue];
        }
    }
    if (dealyTime <= 0.01) dealyTime = 0.1f;
    CFRelease(sourceProperties);
    return dealyTime;
}

@end
