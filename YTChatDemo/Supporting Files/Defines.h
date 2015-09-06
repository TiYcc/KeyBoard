//
//  Defines.h
//  ChatDemo
//
//  Created by TI on 15/6/8.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#ifdef DEBUG

#define log(format,...)    NSLog(format, ## __VA_ARGS__)
#define LOG(format)        log(@"%@",(format))

#else

#define log(format,...)
#define LOG(format)

#endif
