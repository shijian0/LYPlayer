//
//  LYPlayerVidoeRequestTask.m
//  LYVideoPlayer
//
//  Created by LiYong on 2019/2/22.
//  Copyright © 2019 勇 李. All rights reserved.
//

#import "LYVideoRequestTask.h"
#import "UserData.h"
@interface LYVideoRequestTask()<NSURLConnectionDataDelegate>
@property (nonatomic,strong)NSMutableArray   *taskArr;
@property (nonatomic,strong)NSURLConnection  *connection;
@property (nonatomic,assign)BOOL              reTry;
@property (nonatomic,assign)NSUInteger        len;

@end
@implementation LYVideoRequestTask
- (instancetype)init{
    if (self = [super init]) {
        self.taskArr = [NSMutableArray array];
    }
    return self;
}
- (void)setUrl:(NSURL * _Nonnull)url withOffset:(NSUInteger)offset len:(NSUInteger)len{
    [self cancel];
    self.isLoading = YES;
    _url = url;
    _offset = offset;
    _len = len;
    self.downLoadingOffset = 0;
    
    [self connectionStart:len];
}
- (void)connectionStart:(NSUInteger)len{
    NSURLComponents *actualURLComponents = [[NSURLComponents alloc]initWithURL:self.url resolvingAgainstBaseURL:NO];
    actualURLComponents.scheme = @"http";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[actualURLComponents URL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0];
    if (self.offset > 0 && self.videoLength > 0) {
        [request addValue:[NSString stringWithFormat:@"bytes=%ld-",(unsigned long)self.offset] forHTTPHeaderField:@"Range"];
//        NSLog(@"more%.2lu~%.2lu",(unsigned long)self.offset,self.videoLength-1);
    }
//    NSLog(@"task request:%@----%lu",request,len);

    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection setDelegateQueue:[NSOperationQueue mainQueue]];
    [self.connection start];
}
- (void)cancel{
    [self.taskArr removeAllObjects];
    [self.connection cancel];
    self.isLoading = NO;
}
- (void)continueLoading{
    
}
- (void)clearData{
    [self cancel];
//    [UserData removeFileWithPath:self.tempPath];
}
//- (void)reTryOnce{
//    self.reTry = YES;
//    [self cancel];
//    [self connectionStart];
//}
#pragma -mark NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"connection once");
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *dict =(NSDictionary *)[httpResponse allHeaderFields];
    NSString *content = [dict valueForKey:@"Content-Range"];
    NSArray *array = [content componentsSeparatedByString:@"/"];
    NSString *lenght = array.lastObject;
    
    NSUInteger videoLength;
    if (lenght.integerValue == 0) {
        videoLength = (NSUInteger)httpResponse.expectedContentLength;
    }else{
        videoLength = lenght.integerValue;
    }
    self.videoLength = videoLength;
    self.mimeType = @"video/mp4";
    
    if ([self.delegate respondsToSelector:@selector(LYVideoRequestTaskDelegateDidReceiveResponse:videoLenght:mimeType:)]) {
        [self.delegate LYVideoRequestTaskDelegateDidReceiveResponse:self videoLenght:self.videoLength mimeType:self.mimeType];
    }
    [self.taskArr addObject:connection];
    
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSUInteger start = self.offset+self.downLoadingOffset;
    self.downLoadingOffset +=data.length;
    if ([self.delegate respondsToSelector:@selector(LYVideoRequestTaskDelegateDidReceiveData:data:offset:)]) {
        [self.delegate LYVideoRequestTaskDelegateDidReceiveData:self data:data offset:start];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self cancel];
    if (error.code == -1001 && !self.reTry) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
           // [self reTryOnce];
        });
    }else if (error.code == -1009){
        NSLog(@"无网络链接");
    }
    if ([self.delegate respondsToSelector:@selector(LYVideoRequestTaskDelegateDidfaild:error:)]) {
        [self.delegate LYVideoRequestTaskDelegateDidfaild:self error:error];
    }
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [self cancel];
//    NSString *path = [[UserData getDocumentsPath] stringByAppendingPathComponent:@"video.mp4"];
//    BOOL isSuccess = [[NSFileManager defaultManager] copyItemAtPath:_tempPath toPath:path error:nil];
//    if (isSuccess) {
//        NSLog(@"保存成功");
//    }else{
//        NSLog(@"保存失败");
//    }
//    NSLog(@"newPath:%@",_tempPath);
    NSLog(@"保存成功");

    if ([self.delegate respondsToSelector:@selector(LYVideoRequestTaskDelegateDidFinish:)]) {
        [self.delegate LYVideoRequestTaskDelegateDidFinish:self];
    }
}

@end
