//
//  YTEmojiFile.m
//  YTChatDemo
//
//  Created by TI on 15/8/25.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "YTEmojiFile.h"
#import "NSDictionary+YTSafe.h"

@interface YTEmojiFileM : NSObject

@property (nonatomic, strong) NSString * path;  //表情路径
@property (nonatomic, strong) NSString * Id;    //标示(来自网络还是本地)
@property (nonatomic, assign) YTEmojiType type; //表情类型
@property (nonatomic, assign, getter=isDisable) BOOL disable; //判断可用
@end

@implementation YTEmojiFileM
@end

@implementation YTEmojiFile

+ (NSArray *)emojiModelS{
    return [self emojiDataSource];
}

+ (NSArray *)emojiDataSource{
    NSMutableArray *emojiMS = [NSMutableArray array];
    NSArray *emojiFS = [[self class] emojiFiles];
    for (YTEmojiFileM *ef in emojiFS) {
        NSString *emojiPath = [[NSBundle mainBundle]pathForResource:ef.path ofType:@"plist"];
        NSDictionary *emojiDic = [NSDictionary dictionaryWithContentsOfFile:emojiPath];
        YTEmojiM *em = nil;
        switch (ef.type) {
            case YTEmojiTypeIcon:
                em = [[YTEmojiIconM alloc]initWithDic:emojiDic];
                break;
            case YTEmojiTypeChartlet:
                em = [[YTEmojiChartletM alloc]initWithDic:emojiDic];
                break;
            default:
                break;
        }
        if (em) {
            em.type = ef.type;
            [emojiMS addObject:em];
        }
    }
    
    return [emojiMS copy];
}

+ (NSArray *)emojiFiles{
    NSMutableArray *emojiFS = [NSMutableArray array];
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"EmojiFile" ofType:@"plist"];
    
    
    NSArray *files = [NSArray arrayWithContentsOfFile:filePath];
    for (NSDictionary *dic in files) {
        YTEmojiFileM *ef = [[YTEmojiFileM alloc]init];
        ef.path = [dic safeStringValueForKey:@"path"];
        ef.Id = [dic safeStringValueForKey:@"Id"];
        ef.disable = [dic safeBoolValueForKey:@"disable"];
        ef.type = (YTEmojiType)[dic safeIntegerValueForKey:@"type"];
        if ((!ef.isDisable) && (ef.path.length > 0)) {
            [emojiFS addObject:ef];
        }
    }
    
    return emojiFS;
}

@end
