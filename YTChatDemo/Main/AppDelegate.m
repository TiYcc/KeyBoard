//
//  AppDelegate.m
//  YTChatDemo
//
//  Created by TI on 15/8/24.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "AppDelegate.h"
#import "YTCoreData.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [YTCoreData instance];//初始化coreData 建立数据库
    return YES;
}

/*
- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}
*/
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    /* 内存警告 */
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark - Core Data stack & Saving support
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext {
    NSError * error;
    if ([[YTCoreData instance].privateObjectContext hasChanges]) {
        [[YTCoreData instance].privateObjectContext save:&error];
    }
}



@end
