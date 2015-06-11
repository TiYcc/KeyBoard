//
//  KeyBoardAnimationV.m
//  6park
//
//  Created by TI on 15/5/6.
//  Copyright (c) 2015年 6park. All rights reserved.
//

#import "KeyBoardAnimationV.h"

@implementation KeyBoardAnimationV

-(void)addSubview:(UIView *)view{
    
    CGRect frameS = self.frame;
    frameS.size.height = CGRectGetHeight(view.frame);
    self.frame = frameS;
    
    for (UIView * v in self.subviews) {
        [v removeFromSuperview];
    }
    
    [super addSubview:view];
    
    CGRect frame = view.frame;
    frame.origin.y = CGRectGetHeight(self.frame);
    view.frame = frame;
    frame.origin.y = 0;
    [UIView animateWithDuration:DURTAION animations:^{
        view.frame = frame;
    }];
}

@end
