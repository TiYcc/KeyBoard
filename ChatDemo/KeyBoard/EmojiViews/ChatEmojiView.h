//
//  ChatEmojiView.h
//  chatUI
//
//  Created by TI on 15/4/23.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ChatEmojiView_Hight    210.0f
#define ChatEmojiView_Bottom_H 40.0f
#define ChatEmojiView_Bottom_W 52.0f

typedef NS_ENUM(NSInteger, ChatEmojiViewIconType){
    ChatEmojiViewIconTypeCommon = 0,
    ChatEmojiViewIconTypePanda
};

@class EmojiObj;

@protocol ChatEmojiViewDelegate <NSObject>

-(void)chatEmojiViewSelectEmojiIcon:(EmojiObj*)objIcon;
-(void)chatEmojiViewTouchUpinsideDeleteButton;
-(void)chatEmojiViewTouchUpinsideSendButton;

@end

@interface ChatEmojiView : UIView
@property (nonatomic,assign) id<ChatEmojiViewDelegate> delegate;
@end
