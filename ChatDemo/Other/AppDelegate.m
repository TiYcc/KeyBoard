//
//  AppDelegate.m
//  ChatDemo
//
//  Created by TI on 15/6/5.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "AppDelegate.h"
#import "coreDBA.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [coreDBA instance];
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
*/

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    /*内存警告*/
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark - Core Data stack & Saving support
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext {
    NSError * error;
    if ([[coreDBA instance].privateObjectContext hasChanges]) {
        [[coreDBA instance].privateObjectContext save:&error];
    }
}

@end
