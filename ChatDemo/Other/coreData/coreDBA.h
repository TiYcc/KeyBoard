//
//  coreDBA.h
//  coreData
//
//  Created by TI on 15/4/9.
//  Copyright (c) 2015年 6park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void(^OperationResult)(NSError* error);

@interface coreDBA : NSObject
@property (readonly, strong, nonatomic) NSOperationQueue *queue;
@property (readonly ,strong, nonatomic) NSManagedObjectContext *privateObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *mainObjectContext;
/**单例模式*/
+ (coreDBA*)instance;
/**创建一个队列context 做异步处理 -> 主要怎对线程和大量数据*/
- (NSManagedObjectContext *)createPrivateObjectContext;
/**保存同步coreData*/
- (void)save:(OperationResult)handler;
@end
