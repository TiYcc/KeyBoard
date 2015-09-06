//
//  YTCoreData.m
//  YTChatDemo
//
//  Created by TI on 15/9/2.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "YTCoreData.h"


@interface YTCoreData()
{
    NSString *_modelName;
    NSString *_fileName;
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}
@end

@implementation YTCoreData

static YTCoreData * singleModel;
+ (YTCoreData *)instance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleModel = [[YTCoreData alloc]init];
    });
    return singleModel;
}

- (instancetype)init{
    if (self = [super init]) {
        NSDictionary *infodic =[[NSBundle mainBundle]infoDictionary];
        _modelName = [infodic valueForKey:(NSString*)kCFBundleNameKey];
        _fileName = [_modelName stringByAppendingString:@".sqlite"];
        [self initCoreData];
    }
    return self;
}

- (void)initCoreData{
    _privateObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_privateObjectContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    _mainObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_mainObjectContext setParentContext:_privateObjectContext];
}

- (NSManagedObjectContext *)createPrivateObjectContext
{
    NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [ctx setParentContext:_mainObjectContext];
    return ctx;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator{
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:_fileName];
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@", error);
        //abort();
    }
    return persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:_modelName withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}

- (void)save:(OperationResult)handler{
    NSError *error;
    if ([_mainObjectContext hasChanges]) {
        [_mainObjectContext save:&error];
        [_privateObjectContext performBlock:^{
            __block NSError *inner_error = nil;
            [_privateObjectContext save:&inner_error];
            if (handler){
                [_mainObjectContext performBlock:^{
                    handler(inner_error);
                }];
            }
        }];
    }
    if (error) {
        NSLog(@" save: error %@, %@",error,[error userInfo]);
    }
}

@end
