//
//  ChatEmojiIcons.h
//  chatUI
//
//  Created by TI on 15/4/23.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

@import Foundation;

@interface ChatEmojiIcons : NSObject

+(NSInteger)getPandaPopCount;
+(NSString *)getPandaNameByTag:(NSInteger)tag;
+(NSString *)getPandaPopNameByTag:(NSInteger)tag;
+(NSString *)getPandaPopIMGNameByTag:(NSInteger)tag;

+(NSInteger)getEmojiPopCount;
+(NSString *)getEmojiNameByTag:(NSInteger)tag;
+(NSString *)getEmojiPopNameByTag:(NSInteger)tag;
+(NSString *)getEmojiPopIMGNameByTag:(NSInteger)tag;

@end
