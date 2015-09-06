//
//  YTCoreData.h
//  YTChatDemo
//
//  Created by TI on 15/9/2.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void(^OperationResult)(NSError* error);

@interface YTCoreData : NSObject
@property (readonly, strong, nonatomic) NSOperationQueue *queue;
@property (readonly ,strong, nonatomic) NSManagedObjectContext *privateObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *mainObjectContext;

/**单例模式*/
+ (YTCoreData *)instance;

/**创建一个队列context 做异步处理 -> 主要怎对线程和大量数据*/
- (NSManagedObjectContext *)createPrivateObjectContext;

/**保存同步coreData*/
- (void)save:(OperationResult)handler;
@end
