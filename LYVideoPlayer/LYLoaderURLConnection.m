//
//  LYLoaderURLConnection.m
//  LYVideoPlayer
//
//  Created by LiYong on 2019/2/22.
//  Copyright © 2019 勇 李. All rights reserved.
//

#import "LYLoaderURLConnection.h"
#import "UserData.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "LYSegmentCacheVideoFile.h"

@interface LYLoaderURLConnection()<LYVideoRequestTaskDelegate>
@property (nonatomic,strong)NSMutableArray  *pendingRequests;
@property (nonatomic,strong)LYSegmentCacheVideoFile        *videoFile;

@end

@implementation LYLoaderURLConnection
- (instancetype)init{
    if (self = [super init]) {
        self.pendingRequests = [NSMutableArray array];
    }
    return self;
}

- (void)procesPendingRequest{
    NSMutableArray * requestsCompleted = [NSMutableArray array];
    //每次下载一块数据，都是一个请求，把这些请求放在数据里面，遍历数组
    for (AVAssetResourceLoadingRequest *loadingRequest in self.pendingRequests) {
        if (!self.videoFile.length) {//没有数据，开始下载
            self.task = [[LYVideoRequestTask alloc]init];
            self.task.delegate = self;
            [self.task setUrl:self.videoFile.URL withOffset:0 len:self.videoFile.length];
            return;
        }
        //对每次请求加上长度、文件类型等信息
        [self fillInContentInformation:loadingRequest.contentInformationRequest];
        //判断此次请求的数据是否处理完全
        BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest];
        if (didRespondCompletely) {
            [requestsCompleted addObject:loadingRequest];
            [loadingRequest finishLoading];
        }
    }
    [self.pendingRequests removeObjectsInArray:requestsCompleted];
}
- (void)fillInContentInformation:(AVAssetResourceLoadingContentInformationRequest *)contentInformationRequest{
    NSString *mimeType = self.videoFile.mimeType;
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
    contentInformationRequest.byteRangeAccessSupported = YES;
    contentInformationRequest.contentType = CFBridgingRelease(contentType);
    contentInformationRequest.contentLength = self.videoFile.length;
}
- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    AVAssetResourceLoadingDataRequest* dataRequest=loadingRequest.dataRequest;
    
    long long startOffset = dataRequest.requestedOffset;
    if (dataRequest.currentOffset != 0) {
        startOffset = dataRequest.currentOffset;
    }
    
//        if ((self.task.offset + self.task.downLoadingOffset) < startOffset) {
//            return NO;
//        }
//    if (startOffset < self.task.offset) {
//        return NO;
//    }
    NSRange range = NSMakeRange(startOffset, dataRequest.requestedLength);;
    NSData *rangeData = [self.videoFile dataWithRange:range];
    if (!rangeData) {
        if (self.task) {
//            NSLog(@"not find 3");
            //如果新的range的起始位置比当前缓存的位置还大或者往回拖，也重新按照range请求数据
//            if ((self.task.offset + self.task.downLoadingOffset < range.location || range.location < self.task.offset)&&!self.task.isLoading) {
            NSUInteger now = time(0);
            NSUInteger fabsSep = fabs(now - self.task.loadTime);
            if (fabsSep > 1) {
                self.task.loadTime = now;
                [self.task setUrl:self.videoFile.URL withOffset:range.location len:self.videoFile.length];
                NSLog(@"dao shi jian");
            }
            NSLog(@"拖动数据：now time:%lu**%lu**%lu ---range:%.2lu,%.2lu",(unsigned long)now,(unsigned long)self.task.loadTime,now-self.task.loadTime, (unsigned long)self.task.offset,(unsigned long)self.task.downLoadingOffset);
//            }else{
//                NSLog(@"range2:%.2lu,%.2lu",(unsigned long)self.task.offset,(unsigned long)self.task.downLoadingOffset);
//            }
        }else{
            self.task = [[LYVideoRequestTask alloc]init];
            self.task.delegate = self;
            NSUInteger now = time(0);
            self.task.loadTime = now;
            [self.task setUrl:self.videoFile.URL withOffset:0 len:self.videoFile.length];
        }
//        NSLog(@"not find2 length:%lld---%ld",startOffset,(long)dataRequest.requestedLength);

        return NO;
    }
    [dataRequest respondWithData:rangeData];
    
    if (dataRequest.currentOffset == dataRequest.requestedOffset+dataRequest.requestedLength || !self.task) {
//        NSLog(@"find length:%lld---%ld",startOffset,(long)dataRequest.requestedLength);

        return YES;

    }
//    NSLog(@"not find1");
    return NO;
}
- (NSURL *)getSchemeVideoURL:(NSURL *)url
{
    if (!url) {
        return nil;
    }
    self.videoFile = [[LYSegmentCacheVideoFile alloc]initWithUrl:url];
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    components.scheme = @"streaming";
    return [components URL];
}
#pragma -mark loader delegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    [self.pendingRequests addObject:loadingRequest];
//    NSLog(@"loadingRequest:%@",loadingRequest);
    [self procesPendingRequest];
    return YES;
}
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
//    NSLog(@"pendingRequests remove requst");
    [self.pendingRequests removeObject:loadingRequest];
}
#pragma -mark task delegate
- (void)LYVideoRequestTaskDelegateDidFinish:(LYVideoRequestTask *)task{
    [task cancel];
    [self.videoFile writeMeta];

    if ([self.delegate respondsToSelector:@selector(LYLoaderURLConnectionDelegateDidFinishLoadingWithTask:)]) {
        [self.delegate LYLoaderURLConnectionDelegateDidFinishLoadingWithTask:task];
    }
}
- (void)LYVideoRequestTaskDelegateDidfaild:(LYVideoRequestTask *)task error:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(LYLoaderURLConnectionDelegateDidFailLoadingWithTask:error:)]) {
        [self.delegate LYLoaderURLConnectionDelegateDidFailLoadingWithTask:task error:error];
    }
}
- (void)LYVideoRequestTaskDelegateDidReceiveData:(LYVideoRequestTask *)task data:(nonnull NSData *)data offset:(NSUInteger)offset{
    [self.videoFile writeData:data offset:offset];
    [self procesPendingRequest];
}
- (void)LYVideoRequestTaskDelegateDidReceiveResponse:(LYVideoRequestTask *)task videoLenght:(NSUInteger)videoLength mimeType:(NSString *)mimeType{
    [self.videoFile setLength:videoLength mimeType:mimeType];
}
@end
