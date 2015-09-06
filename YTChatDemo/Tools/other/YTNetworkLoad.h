//
//  YTNetworkLoad.h
//  YTImageBrowser
//
//  Created by TI on 15/8/24.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//
//  轻量级网络数据请求，没法和那些第三方比。若不放心，建议替换。

#import <Foundation/Foundation.h>

typedef void (^progressBlock)(float progress);

@interface YTNetworkLoad : NSOperation

@property (nonatomic, copy) progressBlock updataBlock;

- (instancetype)initWithUrl:(NSURL*)url success:(void (^)(NSURLRequest *request, id data))success failure:(void (^)(NSError *error))failure;

- (void)cancel;

@end
