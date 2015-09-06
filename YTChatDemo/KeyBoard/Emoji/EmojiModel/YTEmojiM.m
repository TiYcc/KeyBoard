//
//  YTEmojiM.m
//  YTChatDemo
//
//  Created by TI on 15/8/25.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "NSDictionary+YTSafe.h"
#import "YTEmojiM.h"

NSString *const local = @"local";
NSString *const network = @"http";

@interface YTEmojiM()

@property (nonatomic, strong) NSString *Id;    //标示(来自网络还是本地)
@property (nonatomic, strong) NSArray *icons;  //表情集合
@end

@implementation YTEmojiM

#pragma mark - public api
- (instancetype)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.image = [dic safeStringValueForKey:@"image"];
        self.name = [dic safeStringValueForKey:@"name"];
        self.Id = [dic safeStringValueForKey:@"Id"];
        self.icons = [dic safeArrayForKey:@"icons"];
        YTEmojiNorms norms;
        self.norms = norms;
    }
    return self;
}

- (NSInteger)countOneLine{
    YTEmojiNorms norms = self.norms;
    return  floorf((WIDTH-norms.spaceBoard*2+norms.spaceHorizontalMIN)/(norms.boardWH + norms.spaceHorizontalMIN));
}

- (NSInteger)countOnePage{
    NSInteger countLine = [self countOneLine];
    return (countLine*self.norms.lines);
}

- (NSInteger)countPageAll{
    NSInteger countPage = [self countOnePage];
    return ceilf(self.icons.count/((float)countPage));
}

- (NSInteger)countPageIndex:(NSInteger)index{
    NSInteger countPage = [self countOnePage];
    NSInteger count = countPage*(index+1);
    if (count <= self.icons.count) {
        return countPage;
    }else{
        return (self.icons.count-(countPage*MAX(index, 0)));
    }
}

#pragma mark - self action
- (void)setIcons:(NSArray *)icons{
    if (!icons) {
        _icons = @[];
    }else{
        NSMutableArray *iconArray = [NSMutableArray arrayWithCapacity:icons.count];
        for (NSDictionary * dic in icons) {
            YTEmoji *ej = [YTEmoji new];
            ej.emojiName = [dic safeStringValueForKey:@"emojiName"];
            ej.emojiImage = [dic safeStringValueForKey:@"emojiImage"];
            ej.emojiCode = [dic safeStringValueForKey:@"emojiCode"];
            [iconArray addObject:ej];
        }
        _icons = [iconArray copy];
    }
}

@end
