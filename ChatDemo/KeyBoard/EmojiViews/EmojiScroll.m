//
//  EmojiScroll.m
//  chatUI
//
//  Created by TI on 15/4/23.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "EmojiScroll.h"

@implementation EmojiScroll
-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
    }
    
    return self;
}
@end
