//
//  EmojiObj.m
//  chatUI
//
//  Created by TI on 15/4/23.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//


#import "EmojiObj.h"

@implementation EmojiObj

/*子类中实现*/
+(NSArray *)emojiObjsWithPage:(NSInteger)page{return @[];}

+(NSInteger)pageCountIsSupport{return 0;}

/*子类不需要实现*/
+(NSInteger)countInOneLine{
   return  (Width+EmojiIMG_Space-2*EmojiView_Border)/(EmojiIMG_Width_Hight+EmojiIMG_Space);
}

+(NSInteger)onePageCount{
    NSInteger count_line = [[self class]countInOneLine];
    return count_line*EmojiIMG_Lines-1;
}

+(EmojiObj *)del_Obj{
    EmojiObj * del_obj = [EmojiObj new];
    del_obj.emojiImgName = @"btn_facecancel";
    return del_obj;
}
@end
