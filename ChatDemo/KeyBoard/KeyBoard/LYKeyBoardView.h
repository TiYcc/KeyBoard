//
//  LYKeyBoardView.h
//  6park
//
//  Created by TI on 15/5/5.
//  Copyright (c) 2015年 6park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYTextView.h"

@class LYKeyBoardView;
@protocol LYKeyBoardViewDelegate <NSObject>
@optional
-(void)keyBoardView:(LYKeyBoardView*)keyBoard ChangeDuration:(CGFloat)durtaion;

-(void)keyBoardView:(LYKeyBoardView*)keyBoard sendMessage:(NSString*)message;

-(void)keyBoardView:(LYKeyBoardView*)keyBoard imgPicType:(UIImagePickerControllerSourceType)sourceType;

-(void)keyBoardView:(LYKeyBoardView*)keyBoard audioRuning:(UILongPressGestureRecognizer*)longPress;

@end

@interface LYKeyBoardView : UIView
@property (nonatomic,strong) UIView * topView;
@property (nonatomic,strong) LYTextView * inputText;
@property (nonatomic,assign) id<LYKeyBoardViewDelegate> delegate;

-(instancetype)initDelegate:(id)delegate superView:(UIView*)superView;

-(void)textViewChangeText;
-(void)tapAction;
@end
