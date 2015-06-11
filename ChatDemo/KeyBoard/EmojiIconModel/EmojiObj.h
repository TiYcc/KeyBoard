//
//  EmojiObj.h
//  chatUI
//
//  Created by TI on 15/4/23.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

@import UIKit;
#import <Foundation/Foundation.h>
#import "ChatEmojiIcons.h"

#define  Width  ([UIScreen mainScreen].bounds.size.width)
#define  ScreenH  ([UIScreen mainScreen].bounds.size.height)
#define  EmojiIMG_Width_Hight   32.0f  //表情图片宽高
#define  EmojiView_Border       12.0f  //边框
#define  EmojiIMG_Space         24.0f  //表情间距
#define  EmojiIMG_Space_UP      13.0f  //表情上下间距
#define  EmojiIMG_Lines         3      //表情行数
@interface EmojiObj : NSObject
@property (nonatomic,strong) NSString * emojiName; //表情名称
@property (nonatomic,strong) NSString * emojiImgName; //表情图片名称
@property (nonatomic,strong) NSString * emojiString; //表情码文

+(NSInteger)countInOneLine; //一行多少图片
+(NSInteger)onePageCount;
+(NSInteger)pageCountIsSupport; //支持几页
+(NSArray*)emojiObjsWithPage:(NSInteger)page;
+(EmojiObj*)del_Obj;
@end
