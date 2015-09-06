//
//  YTEmojiChartletM.m
//  YTChatDemo
//
//  Created by TI on 15/8/25.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "YTEmojiChartletM.h"

@implementation YTEmojiChartletM

-(void)setNorms:(YTEmojiNorms)norms{
    norms.lines = 2;
    norms.boardWH = 54.5f;
    norms.spaceBoard = 12.0f;
    norms.spaceHorizontalMIN = 20.0f;
    norms.spaceVerticalityMIN = 15.0f;
    [super setNorms:norms];
}

@end
