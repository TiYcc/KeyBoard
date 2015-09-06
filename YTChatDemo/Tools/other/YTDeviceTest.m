//
//  YTDeviceTest.m
//  YTImageBrowser
//
//  Created by TI on 15/8/24.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "YTDeviceTest.h"
@import AssetsLibrary;
@import AVFoundation;
@import UIKit;

@implementation YTDeviceTest

+ (BOOL)userAuthorizationPhotoStatus{//相册
    ALAuthorizationStatus statu =  [ALAssetsLibrary authorizationStatus];
    switch (statu) {
        case ALAuthorizationStatusAuthorized:
        case ALAuthorizationStatusDenied:
            return YES;
        default:
        {
            NSString *title = @"无法访问相册";
            NSString *message = @"请在iPhone的“设置-隐私-照片”中允许访问您的照片";
            [[self class]showTitle:title message:message];
            return NO;
        }
    }
}

+ (BOOL)userAuthorizationCameraStatus{//相机
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
        case AVAuthorizationStatusAuthorized:
            if ([UIImagePickerController isSourceTypeAvailable:sourceType]){
                return YES;
            }else{
                return NO;
            }
        default:
        {
            NSString *title = @"无法访问相机";
            NSString *message = @"请在iPhone的“设置-隐私-相机”中允许访问您的相机";
            [[self class]showTitle:title message:message];
            return NO;
        }
    }
}

+ (BOOL)userAuthorizationAudioStatus{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
        case AVAuthorizationStatusAuthorized:
            return YES;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
        default:
        {
            NSString *title = @"无法访问麦克风";
            NSString *message = @"请在iPhone的“设置-隐私-麦克风”中允许访问您的麦克风";
            [[self class]showTitle:title message:message];
        }
        case AVAuthorizationStatusNotDetermined:
            return NO;
    }
}

+ (void)showTitle:(NSString *)title message:(NSString *)message{
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
}

@end
