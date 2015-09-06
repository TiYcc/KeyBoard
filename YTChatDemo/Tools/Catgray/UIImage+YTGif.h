//
//  UIImage+YTGif.h
//  YTChatDemo
//
//  Created by TI on 15/9/6.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (YTGif)
/** 根据名字去取gif图片，有可能返回PNG类型image及nil */
+ (UIImage *)gifImageNamed:(NSString *)name;

/** 根据data去取gif图片，有可能返回PNG类型image及nil */
+ (UIImage *)gifImageWithData:(NSData *)data;
@end
