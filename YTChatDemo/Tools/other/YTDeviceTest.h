//
//  YTDeviceTest.h
//  YTImageBrowser
//
//  Created by TI on 15/8/24.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//
//  这是一个访问手机部分硬件是否别允许的简单封装

#import <Foundation/Foundation.h>


@interface YTDeviceTest : NSObject

/**判断相册是否被允许访问 返回YES为允许访问*/
+ (BOOL)userAuthorizationPhotoStatus;

/**判断相机是否被允许访问 返回YES为允许访问*/
+ (BOOL)userAuthorizationCameraStatus;

/**判断麦克风是否被允许访问 返回YES为允许访问*/
+ (BOOL)userAuthorizationAudioStatus;

/***/

@end
