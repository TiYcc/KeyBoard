//
//  YTNetworkLoad.m
//  YTImageBrowser
//
//  Created by TI on 15/8/24.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "YTNetworkLoad.h"
@import UIKit;

typedef void (^block)();

@interface YTNetworkLoad()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>{
    float totalLength;
    BOOL isSuccess;
}

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *dataSource;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, copy) block result_block;
@property (nonatomic, assign) float changeLength;
@end

@implementation YTNetworkLoad

- (instancetype)initWithUrl:(NSURL *)url success:(void (^)(NSURLRequest *, id))success failure:(void (^)(NSError *))failure{
    if (self = [super init]) {
        [self beginLoadUrl:url success:success failure:failure];
    }
    return self;
}

-(void)dealloc{
    [self cancel];
}

- (void)beginLoadUrl:(NSURL *)url success:(void (^)(NSURLRequest *,id))success failure:(void (^)(NSError *))failure{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.networkServiceType = NSURLNetworkServiceTypeBackground;
    self.connection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:NO];
    [self.connection setDelegateQueue:[NSOperationQueue currentQueue]];
    
    __weak __typeof (self)weekself = self;
    _result_block = ^(){
        if (isSuccess == YES) {
            success(weekself.connection.currentRequest,weekself.dataSource);
        }else{
            failure(weekself.error);
        }
    };
    [self.connection start];
}

- (void)cancel{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.connection setDelegateQueue:nil];
    [self.connection cancel];
    self.connection = nil;
}

#define mark - Connection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    totalLength = MAX([response expectedContentLength], 1);
    self.dataSource = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    _changeLength += [data length];
    [self.dataSource appendData:data];
    if ((_changeLength < totalLength)&&_updataBlock) {
        _updataBlock(_changeLength/totalLength);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    isSuccess = YES;
    [self resultBlock];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    _error = error;
    [self resultBlock];
}

- (void)resultBlock{
    if (_result_block) {
        _result_block();
    }
    [self cancel];
}

@end
