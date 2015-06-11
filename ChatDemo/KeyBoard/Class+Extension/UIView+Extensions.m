//
//  LYKeyBoardView.h
//  6park
//
//  Created by TI on 15/5/5.
//  Copyright (c) 2015年 6park. All rights reserved.
//

#import "UIView+Extensions.h"

@implementation UIView (Extensions)

- (void)cornerRadius:(CGFloat)radius {
    self.layer.masksToBounds = YES;
	self.layer.cornerRadius  = radius;
}

- (void)cornerRadius:(CGFloat)radius borderColor:(UIColor*)borderColor borderWidth:(CGFloat)borderWidth {
    self.layer.masksToBounds = YES;
	self.layer.cornerRadius  = radius;
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = borderWidth;
}

- (void)borderWithColor:(UIColor*)borderColor borderWidth:(CGFloat)borderWidth {
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = borderWidth;
}

- (void)makeRoundedCorner:(UIRectCorner)byRoundingCorners cornerRadii:(CGSize)cornerRadii {
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:byRoundingCorners cornerRadii:cornerRadii];
    CAShapeLayer* shape = [CAShapeLayer layer];
    shape.path = path.CGPath;
    self.layer.mask = shape;
}

@end
