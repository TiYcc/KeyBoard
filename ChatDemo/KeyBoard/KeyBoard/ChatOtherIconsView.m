//
//  ChatOtherIconsView.m
//  6park
//
//  Created by TI on 15/5/6.
//  Copyright (c) 2015年 6park. All rights reserved.
//


#import "ChatOtherIconsView.h"

#define wight  ([UIScreen mainScreen].bounds.size.width)
#define Bt_W 50.0f
#define Bt_H 70.0f
#define Bt_s 15.0f
@interface ButtonIcon : UIButton

@end

@implementation ButtonIcon

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    contentRect = CGRectMake(0, 0, Bt_W, Bt_W);
    return contentRect;
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    contentRect = CGRectMake(0, Bt_W, Bt_W, Bt_H-Bt_W);
    return contentRect;
}

@end

@interface ChatOtherIconsView()
{
    ButtonIcon * _Album;
    ButtonIcon * _Camera;
}
@end

@implementation ChatOtherIconsView

-(instancetype)init{
    
    return [self initWithFrame:CGRectZero];
}

-(instancetype)initWithFrame:(CGRect)frame{
    frame = CGRectMake(0, 0, wight, ChatOtherIconsView_Hight);
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self initUI];
    }
    return self;
}

-(void)initUI{
    _Album = [[ButtonIcon alloc]initWithFrame:CGRectMake(Bt_s, Bt_s, Bt_W, Bt_H)];
    [_Album setImage:[UIImage imageNamed:@"btn_pic"] forState:UIControlStateNormal];
    [_Album setImage:[UIImage imageNamed:@"img_down"] forState:UIControlStateHighlighted];
    [_Album setTitle:@"图片" forState:UIControlStateNormal];
    [_Album addTarget:self action:@selector(selectPhotoAlbum) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_Album];
    
    _Camera = [[ButtonIcon alloc]initWithFrame:CGRectMake(Bt_W+Bt_s*3, Bt_s, Bt_W, Bt_H)];
    [_Camera setImage:[UIImage imageNamed:@"btn_photo"] forState:UIControlStateNormal];
    [_Camera setImage:[UIImage imageNamed:@"camera_down"] forState:UIControlStateHighlighted];
    [_Camera setTitle:@"照相" forState:UIControlStateNormal];
    [_Camera addTarget:self action:@selector(selectCamera) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_Camera];
}

#pragma mark - 相机,相册-处理
-(void)selectPhotoAlbum{//相册
    ALAuthorizationStatus statu =  [ALAssetsLibrary authorizationStatus];
    switch (statu) {
        case ALAuthorizationStatusAuthorized:
        case ALAuthorizationStatusNotDetermined:
            [self sourceType: UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        default:{
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的“设置-隐私-照片”中允许访问您的照片" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
            break;
        }
    }
}

-(void)selectCamera{//相机
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
        case AVAuthorizationStatusAuthorized:
            if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
                [self sourceType:sourceType];
            }
            break;
            
        default:{
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"无法访问相机" message:@"请在iPhone的“设置-隐私-相机”中允许访问您的相机" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
            break;
        }
    }
}

#pragma mark - delegate
-(void)sourceType:(UIImagePickerControllerSourceType)type{
    if ([self.delegate respondsToSelector:@selector(imagePickerControllerSourceType:)]) {
        [self.delegate imagePickerControllerSourceType:type];
    }
}
@end
