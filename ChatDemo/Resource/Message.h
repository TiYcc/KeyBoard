//
//  Message.h
//  ChatDemo
//
//  Created by TI on 15/6/8.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
typedef NS_ENUM(NSInteger, MessageType) {
    MessageTypeMe = 0,
    MessageTypeOther
};

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * objID;

@end
