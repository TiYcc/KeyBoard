//
//  NSDictionary+YTSafe.h
//  YTChatDemo
//
//  Created by TI on 15/8/25.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (YTSafe)
/* 顾名思义，不解释 */
- (id)safeValueForKey:(NSString *)key;
- (NSDictionary*)safeDictForKey:(NSString *)key;
- (NSArray*)safeArrayForKey:(NSString *)key;
- (NSInteger)safeIntegerValueForKey:(NSString *)key;
- (float)safeFloatValueForKey:(NSString *)key;
- (NSString*)safeStringValueForKey:(NSString *)key;
- (BOOL)safeBoolValueForKey:(NSString*)key;
@end
