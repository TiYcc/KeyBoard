//
//  ChatOtherIconsView.h
//  6park
//
//  Created by TI on 15/5/6.
//  Copyright (c) 2015年 6park. All rights reserved.
//

@import AVFoundation;
@import AssetsLibrary;
#import <UIKit/UIKit.h>

#define ChatOtherIconsView_Hight  210.0f
@protocol ChatOtherIconsViewDelegate <NSObject>

-(void)imagePickerControllerSourceType:(UIImagePickerControllerSourceType)sourceType;

@end

@interface ChatOtherIconsView : UIView
@property (nonatomic,assign) id<ChatOtherIconsViewDelegate> delegate;
@end
