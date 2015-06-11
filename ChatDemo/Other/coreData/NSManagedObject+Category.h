//
//  NSManagedObject+Category.h
//  demo2
//
//  Created by TI on 15/4/14.
//  Copyright (c) 2015年 6park. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "coreDBA.h"

typedef void(^Finished)(BOOL finished);
typedef void(^Request)(NSFetchRequest *request);
typedef void(^ListResult)(NSArray* result, NSError *error);
typedef void(^ObjectResult)(id result, NSError *error);
typedef id(^AsyncProcess)(NSManagedObjectContext *ctx, NSFetchRequest *request);

@interface NSManagedObject (Category)
/**创建一个当前对象*/
+(id)createNew;
/**保存同步*/
+(void)save:(OperationResult)handler;
/*
 ** predicate -> NSPredicate 字符串标示 查询条件
 ** orders -> 存放多个NSString 如果需要降序:字符串前加"-"
 ** offset -> 数据偏移量 位置标示
 ** limit  -> 取出多少条数据
 ** filter -> 数据(多个“NSManagedObject”类对象)
 */
+(NSArray*)filter:(NSString *)predicate orderby:(NSArray *)orders offset:(int)offset limit:(int)limit;
/**
 ** 工能同上 -> 采用回调方法 handler 参数result = filter(up)
 */
+(void)filter:(NSString *)predicate orderby:(NSArray *)orders offset:(int)offset limit:(int)limit on:(ListResult)handler;
/**根据查询条件取出一个"NSManagedObject"对象*/
+(id)one:(NSString*)predicate;
/**功能同上 - 回调方法*/
+(void)one:(NSString*)predicate on:(ObjectResult)handler;

+ (void)removeAllObj:(NSString*)predicate finished:(Finished)finished;
/**删除一个"NSManagedObject"类对象*/
+(void)delobject:(id)object;
/**自定义条件取出多个“NSManagedObject”类对象 - 回调方法*/
+(void)async:(AsyncProcess)processBlock result:(ListResult)resultBlock;
/**谓语查询数据库包含此对象数量*/
+(NSUInteger)count:(NSString*)predicate;
/**ios8 功能同上*/
+(void)asyncRequest:(Request)requestBlock result:(ListResult)resultBlock;
@end
