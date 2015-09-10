//
//  YTEmojiM.h
//  YTChatDemo
//
//  Created by TI on 15/8/25.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTEmoji.h"
@import UIKit;

#define  WIDTH  ([UIScreen mainScreen].bounds.size.width)

#if !defined(YT_INLINE)
# if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
#  define YT_INLINE static inline
# elif defined(__cplusplus)
#  define YT_INLINE static inline
# elif defined(__GNUC__)
#  define YT_INLINE static __inline__
# else
#  define YT_INLINE static
# endif
#endif

typedef NS_ENUM(NSInteger, YTEmojiType){
    YTEmojiTypeIcon = 0, //一般表情图片
    YTEmojiTypeChartlet  //贴图
};

struct YTEmojiNorms{
    NSUInteger lines;          //行数
    CGFloat boardWH;           //宽高
    CGFloat spaceBoard;        //距离边框距离(水平=垂直)
    CGFloat spaceHorizontalMIN;   //水平间距(min)
    CGFloat spaceVerticalityMIN;  //垂直间距(min)
};

typedef struct YTEmojiNorms YTEmojiNorms;

YT_INLINE YTEmojiNorms YTEmojiNormsMake(NSUInteger lines, CGFloat boardWH, CGFloat spaceBoard, CGFloat spaceHorizontalMIN, CGFloat spaceVerticalityMIN);

@interface YTEmojiM : NSObject

@property (nonatomic, strong) NSString *name;  //这一类表情总名称
@property (nonatomic, strong) NSString *image; //这一类表情代表图标
@property (nonatomic, assign) YTEmojiType type; //类型

@property (nonatomic, strong, readonly) NSString *Id; //标示(来自网络http还是本地local)
@property (nonatomic, strong, readonly) NSArray *icons; //表情集合

@property (nonatomic, assign) YTEmojiNorms norms; //一般交于子类赋值

/* 通过字典初始化 */
- (instancetype)initWithDic:(NSDictionary *)dic;

/* 一行可显示多少个表情 */
- (NSInteger)countOneLine;

/* 一页多少个表情 */
- (NSInteger)countOnePage;

/* 一共多少页 */
- (NSInteger)countPageAll;

/* 第index页包含多少个表情 */
- (NSInteger)countPageIndex:(NSInteger)index;
@end
