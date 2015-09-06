//
//  NSManagedObject+YTMoreThread.m
//  YTChatDemo
//
//  Created by TI on 15/9/2.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "NSManagedObject+YTMoreThread.h"

typedef void (^ObjectForId)(NSArray * result);

@implementation NSManagedObject (YTMoreThread)

+ (id)createNew{
    NSString *className = [NSString stringWithUTF8String:object_getClassName(self)];
    return [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:YTDBA.mainObjectContext];
}

+ (void)save:(OperationResult)handler{
    [YTDBA save:handler];
}

+ (NSArray *)filter:(NSString *)predicate orderby:(NSArray *)orders offset:(int)offset limit:(int)limit{
    NSManagedObjectContext *ctx = YTDBA.mainObjectContext;
    NSFetchRequest *fetchRequest = [self makeRequest:ctx predicate:predicate orderby:orders offset:offset limit:limit];
    
    NSError* error = nil;
    NSArray* results = [ctx executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error: %@", error);
        return @[];
    }
    return results;
}

+ (NSFetchRequest *)makeRequest:(NSManagedObjectContext *)ctx predicate:(NSString *)predicate orderby:(NSArray *)orders offset:(int)offset limit:(int)limit{
    NSString *className = [NSString stringWithUTF8String:object_getClassName(self)];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:className inManagedObjectContext:ctx]];
    
    if (predicate) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:predicate]];
    }
    
    NSMutableArray *orderArray = [[NSMutableArray alloc] init];
    if (orders&&orders.count>0) {
        for (NSString *order in orders) {
            NSSortDescriptor *orderDesc = nil;
            if ([[order substringToIndex:1] isEqualToString:@"-"]) {
                orderDesc = [[NSSortDescriptor alloc] initWithKey:[order substringFromIndex:1]
                                                        ascending:NO];
            }else{
                orderDesc = [[NSSortDescriptor alloc] initWithKey:order
                                                        ascending:YES];
            }
            [orderArray addObject:orderDesc];
        }
        [fetchRequest setSortDescriptors:orderArray];
    }
    
    if (offset>0) {
        [fetchRequest setFetchOffset:offset];
    }
    if (limit>0) {
        [fetchRequest setFetchLimit:limit];
    }
    return fetchRequest;
}

+ (void)filter:(NSString *)predicate orderby:(NSArray *)orders offset:(int)offset limit:(int)limit on:(ListResult)handler{
    NSManagedObjectContext *ctx = [YTDBA createPrivateObjectContext];
    
    [ctx performBlock:^{
        NSFetchRequest *fetchRequest = [self makeRequest:ctx predicate:predicate orderby:orders offset:offset limit:limit];
        NSError *error = nil;
        NSArray *results = [ctx executeFetchRequest:fetchRequest error:&error];
        if (results&&results.count>0) {
            [[self class]objIds:results result:^(NSArray *result) {
                if (handler) handler(results, nil);
            }];
        }else{
            [YTDBA.mainObjectContext performBlock:^{
                if (handler) handler(@[], error);
            }];
        }
    }];
}


+ (id)one:(NSString *)predicate{
    NSManagedObjectContext *ctx = YTDBA.mainObjectContext;
    NSFetchRequest *fetchRequest = [self makeRequest:ctx predicate:predicate orderby:nil offset:0 limit:1];
    
    NSError *error = nil;
    NSArray *results = [ctx executeFetchRequest:fetchRequest error:&error];
    if ([results count]!=1) {
        return nil;
        //raise(1);
    }
    return results[0];
}

+ (void)one:(NSString *)predicate on:(ObjectResult)handler{
    NSManagedObjectContext *ctx = [YTDBA createPrivateObjectContext];
    
    [ctx performBlock:^{
        NSFetchRequest *fetchRequest = [self makeRequest:ctx predicate:predicate orderby:nil offset:0 limit:1];
        NSError *error = nil;
        NSArray *results = [ctx executeFetchRequest:fetchRequest error:&error];
        id  obj = nil;
        if (results&&results.count>0) {
            NSManagedObjectID *objId = ((NSManagedObject*)results[0]).objectID;
            obj = [YTDBA.mainObjectContext objectWithID:objId];
        }
        [YTDBA.mainObjectContext performBlock:^{
            if (handler) handler(obj, error);
        }];
    }];
}

+ (void)removeAllObj:(NSString *)predicate finished:(Finished)finished{
    [self filter:predicate orderby:nil offset:0 limit:0 on:^(NSArray *result, NSError *error) {
        
        for (NSManagedObject *obj in result) {
            NSManagedObject *safeobject = [YTDBA.mainObjectContext objectWithID:obj.objectID];
            [self delobject:safeobject];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [YTDBA save:^(NSError *error) {}];
            finished(YES);
            
        });
    }];
}

+ (void)delobject:(id)object{
    [YTDBA.mainObjectContext deleteObject:object];
}

+ (void)async:(AsyncProcess)processBlock result:(ListResult)resultBlock{
    if (!processBlock) return ;
    NSString *className = [NSString stringWithUTF8String:object_getClassName(self)];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:className];
    NSManagedObjectContext *ctx = [YTDBA createPrivateObjectContext];
    
    [ctx performBlock:^{
        id resultList = processBlock(ctx, request);
        if (resultList&&[resultList isKindOfClass:[NSArray class]]) {
            [[self class]objIds:resultList result:^(NSArray *result) {
                if (resultBlock) resultBlock(result, nil);
            }];
        }else{
            if (resultBlock) resultBlock(@[], nil);
        }
    }];
}

+ (void)objIds:(NSArray *)Ids result:(ObjectForId)objHander{
    NSMutableArray *idArray = [NSMutableArray array];
    for (NSManagedObject *obj in Ids) {
        [idArray addObject:obj.objectID];
    }
    
    [YTDBA.mainObjectContext performBlock:^{
        NSMutableArray *objArray = [NSMutableArray array];
        for (NSManagedObjectID *robjId in idArray) {
            [objArray addObject:[YTDBA.mainObjectContext objectWithID:robjId]];
        }
        if (objHander) objHander([objArray copy]);
    }];
}

+ (NSUInteger)count:(NSString *)predicate{
    NSString *className = [NSString stringWithUTF8String:object_getClassName(self)];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:className];
    [request setPredicate:[NSPredicate predicateWithFormat:predicate]];
    return [YTDBA.mainObjectContext countForFetchRequest:request error:nil];
}

+ (void)asyncRequest:(Request)request result:(ListResult)resultBlock{
    [YTDBA.createPrivateObjectContext performBlock:^{
        NSString *className = [NSString stringWithUTF8String:object_getClassName(self)];
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
        if (request) request(fetchRequest);
        NSAsynchronousFetchRequest *requ = [[NSAsynchronousFetchRequest alloc]initWithFetchRequest:fetchRequest completionBlock:^(NSAsynchronousFetchResult *result) {
            [[self class] objIds:result.finalResult result:^(NSArray *result) {
                if (resultBlock) resultBlock(result,nil);
            }];
        }];
        [YTDBA.mainObjectContext executeRequest:requ error:nil];
    }];
}

@end
