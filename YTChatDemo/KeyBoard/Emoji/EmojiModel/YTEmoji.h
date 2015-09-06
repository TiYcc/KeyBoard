//
//  YTEmoji.h
//  YTChatDemo
//
//  Created by TI on 15/8/25.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTEmoji : NSObject

@property (nonatomic, strong) NSString *emojiName;  //名字(中文)
@property (nonatomic, strong) NSString *emojiImage; //图片名字
@property (nonatomic, strong) NSString *emojiCode;  //表情码(要和“某卓”沟通)
@end
