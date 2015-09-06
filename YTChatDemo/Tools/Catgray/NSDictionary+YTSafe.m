//
//  NSDictionary+YTSafe.m
//  YTChatDemo
//
//  Created by TI on 15/8/25.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "NSDictionary+YTSafe.h"

@implementation NSDictionary (YTSafe)

- (id)safeValueForKey:(NSString *)key {
    id obj = [self objectForKey:key];
    if([self isEmpty:obj]) {
        return @"";
    } else if([obj isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)obj stringValue];
    }
    return obj;
}

- (NSDictionary *)safeDictForKey:(NSString *)key {
    id obj = [self objectForKey:key];
    if([self isEmpty:obj]) {
        return @{};
    } else if(![obj isKindOfClass:[NSDictionary class]]) {
        return @{};
    }
    return obj;
}

- (NSArray *)safeArrayForKey:(NSString *)key {
    id obj = [self objectForKey:key];
    if([self isEmpty:obj]) {
        return @[];
    }else if(![obj isKindOfClass:[NSArray class]]) {
        return @[];
    }
    return obj;
}

- (NSInteger)safeIntegerValueForKey:(NSString *)key {
    id obj = [self objectForKey:key];
    if ([self isEmpty:obj]) {
        return 0;
    }else if (![obj isKindOfClass:[NSNumber class]]) {
        if ([obj isKindOfClass:[NSString class]]) {
            return [obj integerValue];
        } else {
            return 0;
        }
    }
    return [obj integerValue];
}

- (float)safeFloatValueForKey:(NSString *)key {
    id obj = [self objectForKey:key];
    if ([self isEmpty:obj]) {
        return 0.0f;
    }else if (![obj isKindOfClass:[NSNumber class]]) {
        if ([obj isKindOfClass:[NSString class]]) {
            return [obj floatValue];
        } else {
            return 0.0f;
        }
    }
    return [obj floatValue];
}

- (NSString *)safeStringValueForKey:(NSString *)key {
    id obj = [self objectForKey:key];
    if ([self isEmpty:obj]) {
        return @"";
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj stringValue];
    }
    if (![obj isKindOfClass:[NSString class]]) {
        return @"";
    }
    if ([@"null" isEqualToString:obj]) {
        return @"";
    }
    return obj;
}

- (BOOL)safeBoolValueForKey:(NSString *)key{
    id obj = [self objectForKey:key];
    if ([self isEmpty:obj]) {
        return NO;
    }
    if (![obj isKindOfClass:[NSNumber class]]) {
        if ([obj isKindOfClass:[NSString class]]) {
            return [obj boolValue];
        } else {
            return NO;
        }
    }
    return [obj boolValue];
}

- (BOOL)isEmpty:(id)obj{
    return ((!obj)||([obj isKindOfClass:[NSNull class]]));
}

@end
