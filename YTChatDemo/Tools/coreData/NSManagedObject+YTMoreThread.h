//
//  NSManagedObject+YTMoreThread.h
//  YTChatDemo
//
//  Created by TI on 15/9/2.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//
//  该类与YTCoreData.h结合使用，很好地解决啦多线程访问coredata问题。

#import <CoreData/CoreData.h>
#import "YTCoreData.h"

#define YTDBA  [YTCoreData instance]

typedef void(^Finished)(BOOL finished);
typedef void(^Request)(NSFetchRequest *request);
typedef void(^ListResult)(NSArray* result, NSError *error);
typedef void(^ObjectResult)(id result, NSError *error);
typedef id(^AsyncProcess)(NSManagedObjectContext *ctx, NSFetchRequest *request);

@interface NSManagedObject (YTMoreThread)
/**创建一个当前对象*/
+ (id)createNew;

/**保存同步*/
+ (void)save:(OperationResult)handler;

/*
 ** predicate -> NSPredicate 字符串标示 查询条件
 ** orders -> 存放多个NSString 如果需要降序:字符串前加"-"
 ** offset -> 数据偏移量 位置标示
 ** limit  -> 取出多少条数据
 ** filter -> 数据(多个“NSManagedObject”类对象)
 */
+ (NSArray *)filter:(NSString *)predicate orderby:(NSArray *)orders offset:(int)offset limit:(int)limit;

/**
 ** 工能同上 -> 采用回调方法 handler 参数result = filter(up)
 */
+ (void)filter:(NSString *)predicate orderby:(NSArray *)orders offset:(int)offset limit:(int)limit on:(ListResult)handler;

/**根据查询条件取出一个"NSManagedObject"对象*/
+ (id)one:(NSString *)predicate;

/**根据查询条件取出一个"NSManagedObject"对象*/
+ (void)one:(NSString *)predicate on:(ObjectResult)handler;

/**根据查询条件取所有符合条件的"NSManagedObject"对象*/
+ (void)removeAllObj:(NSString *)predicate finished:(Finished)finished;

/**删除一个"NSManagedObject"类对象*/
+ (void)delobject:(id)object;

/**自定义条件取出多个“NSManagedObject”类对象 - 回调方法*/
+ (void)async:(AsyncProcess)processBlock result:(ListResult)resultBlock;

/**谓语查询数据库包含此对象数量*/
+ (NSUInteger)count:(NSString *)predicate;

/**ios8新方法*/
+ (void)asyncRequest:(Request)requestBlock result:(ListResult)resultBlock;
@end
