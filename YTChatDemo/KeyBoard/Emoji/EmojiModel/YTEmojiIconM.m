//
//  YTEmojiIconM.m
//  YTChatDemo
//
//  Created by TI on 15/8/25.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "YTEmojiIconM.h"

@implementation YTEmojiIconM

-(void)setNorms:(YTEmojiNorms)norms{
    norms.lines = 3;
    norms.boardWH = 32.0f;
    norms.spaceBoard = 12.0f;
    norms.spaceHorizontalMIN = 20.0f;
    norms.spaceVerticalityMIN = 15.0f;
    [super setNorms:norms];
}

-(NSInteger)countOnePage{
    return ([super countOnePage] - 1);//最后一个是删除键
}

@end
