//
//  IconButton.m
//  chatUI
//
//  Created by TI on 15/4/24.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "IconButton.h"
#import "UIColor+Extension.h"

#define IMG_H_W  20.0f

@implementation IconButton

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        UIView * line = [[UIView alloc]initWithFrame:
                         CGRectMake(self.bounds.size.width-0.5, 0, 0.5, self.bounds.size.height)];
        line.backgroundColor = [UIColor Grey];
        [self addSubview:line];
    }
    
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    
    CGRect rect = [super imageRectForContentRect:contentRect];
    rect.size.height = rect.size.width = IMG_H_W;
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    rect.origin = CGPointMake((w-IMG_H_W)/2.0f, (h-IMG_H_W)/2.0f);
    
    return rect;
}

@end
